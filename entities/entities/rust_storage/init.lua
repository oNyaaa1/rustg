AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.InventorySlots = 16
ENT.InventoryName = "STORAGE CONTAINER"
ENT.SaveItems = true
ENT.Interactable = true
ENT.Damageable = true
ENT.DisplayName = "LOOT"
ENT.MeleeDamage = 1.0
ENT.BulletDamage = 1.0
ENT.ExplosiveDamage = 1.0

function ENT:Initialize()
    if CLIENT then return end

    self:SetModel(self.Deploy and self.Deploy.Model or "models/darky_m/rust/shopfront.mdl")
    self:SetSolid(SOLID_VPHYSICS)

    if self.Deploy then
        self:PhysicsInitStatic(SOLID_VPHYSICS)
    else
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Sleep()
        end
    end

    self:SetUseType(SIMPLE_USE)
    self:SetHealth(100)
    self:SetMaxHealth(100)

    self:CreateInventory(self.InventorySlots)

    if self.Deploy and self.Deploy.Sound then
        self:EmitSound(self.Deploy.Sound)
    end
end

function ENT:CreateInventory(slots)
    slots = slots or self.InventorySlots
    
    if slots <= 0 or slots > 200 then
        ErrorNoHalt("[rust_storage] Invalid inventory slots: " .. tostring(slots))
        slots = 16
    end
    
    self.Inventory = {}
    self.InventorySlots = slots
    
    timer.Simple(0, function()
        if IsValid(self) then
            self:SyncInventory()
        end
    end)
end

function ENT:SyncInventory()
    if not self.Inventory then return end
    
    net.Start("gRust.Inventory.Request")
    net.WriteEntity(self)
    
    local validItems = {}
    for i = 1, self.InventorySlots do
        local item = self.Inventory[i]
        if item and IsValid(item) then
            table.insert(validItems, {slot = i, item = item})
        end
    end
    
    net.WriteUInt(math.min(#validItems, 63), 6)
    for _, data in ipairs(validItems) do
        net.WriteUInt(data.slot, 6)
        net.WriteItem(data.item)
    end
    
    net.WriteUInt(self.InventorySlots, 6)
    net.Broadcast()
end

function ENT:SyncSlot(slot)
    if not self.Inventory or not slot or slot < 1 or slot > self.InventorySlots then
        return
    end

    local item = self.Inventory[slot]
    
    if item and IsValid(item) then
        net.Start("gRust.Inventory.SyncSlot")
        net.WriteEntity(self)
        net.WriteUInt(slot, 6)
        net.WriteItem(item)
        net.Broadcast()
    else
        net.Start("gRust.Inventory.Remove")
        net.WriteEntity(self)
        net.WriteUInt(slot, 6)
        net.Broadcast()
    end
end

function ENT:SyncSlots(slots)
    if not self.Inventory or not slots or #slots == 0 then return end
    
    local updates = {}
    
    for _, slot in ipairs(slots) do
        if slot >= 1 and slot <= self.InventorySlots then
            local item = self.Inventory[slot]
            table.insert(updates, {
                slot = slot,
                item = item
            })
        end
    end
    
    if #updates == 0 then return end
    
    net.Start("gRust.Inventory.SyncMultiple")
    net.WriteEntity(self)
    net.WriteUInt(#updates, 6)
    
    for _, update in ipairs(updates) do
        net.WriteUInt(update.slot, 6)
        if update.item and IsValid(update.item) then
            net.WriteBool(true)
            net.WriteItem(update.item)
        else
            net.WriteBool(false)
        end
    end
    
    net.Broadcast()
end


function ENT:RemoveSlot(slot)
    if not self.Inventory or not slot or slot < 1 or slot > self.InventorySlots then
        return
    end

    self.Inventory[slot] = nil
    self:SyncSlot(slot)
    
    if self:ShouldCheckEmpty() then
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:CheckAndRemoveIfEmpty()
            end
        end)
    end
end

function ENT:ShouldCheckEmpty()
    return self:GetClass() == "rust_stash"
end

function ENT:RemoveItem(itemClass, amount)
    if not self.Inventory or not itemClass then return false end
    
    amount = amount or 1
    
    if not self:HasItem(itemClass, amount) then
        return false
    end
    
    local remaining = amount
    local slotsToUpdate = {}
    
    for i = 1, self.InventorySlots do
        if remaining <= 0 then break end
        
        local item = self.Inventory[i]
        if item and IsValid(item) and item:GetItem() == itemClass then
            local currentQty = item:GetQuantity() or 1
            local takeAmount = math.min(remaining, currentQty)
            
            item:RemoveQuantity(takeAmount)
            remaining = remaining - takeAmount
            
            if item:GetQuantity() <= 0 then
                self.Inventory[i] = nil
            end
            
            table.insert(slotsToUpdate, i)
        end
    end
    
    if #slotsToUpdate > 0 then
        self:SyncSlots(slotsToUpdate)
    end
    
    if self:ShouldCheckEmpty() then
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:CheckAndRemoveIfEmpty()
            end
        end)
    end
    
    return remaining == 0
end

function ENT:AddItem(itemClass, amount, wear, startSlot, endSlot)
    if not self.Inventory or not itemClass then return false end
    if not gRust.Items[itemClass] then return false end
    
    amount = amount or 1
    startSlot = startSlot or 1
    endSlot = endSlot or self.InventorySlots
    
    local remaining = amount
    local itemData = gRust.Items[itemClass]
    local maxStack = itemData:GetStack() or 1
    local slotsToUpdate = {}
    
    for i = startSlot, endSlot do
        if remaining <= 0 then break end
        
        local existingItem = self.Inventory[i]
        if existingItem and IsValid(existingItem) and existingItem:GetItem() == itemClass then
            local canAdd = existingItem:GetMaxAddable() or 0
            if canAdd > 0 then
                local toAdd = math.min(remaining, canAdd)
                existingItem:AddQuantity(toAdd)
                remaining = remaining - toAdd
                table.insert(slotsToUpdate, i)
            end
        end
    end
    
    while remaining > 0 do
        local emptySlot = self:FindEmptySlot(startSlot, endSlot)
        if not emptySlot then break end
        
        local toAdd = math.min(remaining, maxStack)
        local newItem = gRust.CreateItem(itemClass, toAdd, wear)
        
        if newItem and IsValid(newItem) then
            self.Inventory[emptySlot] = newItem
            table.insert(slotsToUpdate, emptySlot)
            remaining = remaining - toAdd
        else
            break
        end
    end
    
    if #slotsToUpdate > 0 then
        self:SyncSlots(slotsToUpdate)
    end
    
    return remaining == 0
end

function ENT:CheckAndRemoveIfEmpty()
    if not self.Inventory then
        self:Remove()
        return
    end

    for i = 1, self.InventorySlots do
        if self.Inventory[i] and IsValid(self.Inventory[i]) then
            return
        end
    end

    self:Remove()
end

function ENT:CreateStashOnDestroy()
    if not self.Inventory then return end

    local hasItems = false
    local itemCount = 0

    for i = 1, self.InventorySlots do
        if self.Inventory[i] and IsValid(self.Inventory[i]) then
            hasItems = true
            itemCount = itemCount + 1
        end
    end

    if not hasItems then return end

    local stash = ents.Create("rust_stash")
    if not IsValid(stash) then return end

    stash:SetPos(self:GetPos())
    stash:SetAngles(self:GetAngles())

    local requiredSlots = math.max(itemCount, 30)
    stash.InventorySlots = requiredSlots
    stash:Spawn()
    stash:Activate()

    local sourceInventory = table.Copy(self.Inventory)
    local sourceSlots = self.InventorySlots

    timer.Simple(0, function()
        if not IsValid(stash) then return end

        stash:CreateInventory(requiredSlots)

        local transferredCount = 0
        for i = 1, sourceSlots do
            if sourceInventory[i] and IsValid(sourceInventory[i]) then
                local emptySlot = stash:FindEmptySlot()
                if emptySlot then
                    stash:SetSlot(sourceInventory[i], emptySlot)
                    transferredCount = transferredCount + 1
                end
            end
        end

        if transferredCount > 0 then
            stash:SyncInventory()
        else
            stash:Remove()
        end
    end)
end

function ENT:SetSaveItems(save)
    self.SaveItems = save
end

function ENT:Interact(pl)
    pl:RequestInventory(self)
end


function ENT:SetInteractable(interactable)
    self.Interactable = interactable
end

function ENT:SetDamageable(damageable)
    self.Damageable = damageable
end

function ENT:SetDisplayName(name)
    self.DisplayName = name
end

function ENT:SetMeleeDamage(multiplier)
    self.MeleeDamage = multiplier
end

function ENT:SetBulletDamage(multiplier)
    self.BulletDamage = multiplier
end

function ENT:SetExplosiveDamage(multiplier)
    self.ExplosiveDamage = multiplier
end

function ENT:Save()
    if not self.Inventory then return {} end

    local saveData = {
        InventorySlots = self.InventorySlots,
        InventoryName = self.InventoryName,
        Items = {}
    }

    for i = 1, self.InventorySlots do
        local item = self.Inventory[i]
        if item and IsValid(item) then
            saveData.Items[i] = {
                item = item:GetItem(),
                quantity = item:GetQuantity()
            }
        end
    end

    return saveData
end

function ENT:Load(data)
    if not data then return end

    self.InventorySlots = data.InventorySlots or 16
    self.InventoryName = data.InventoryName or "Loot"
    
    self:CreateInventory(self.InventorySlots)

    if data.Items then
        for slot, itemData in pairs(data.Items) do
            if itemData.item and itemData.quantity then
                local item = gRust.CreateItem(itemData.item, itemData.quantity)
                if item and IsValid(item) then
                    self:SetSlot(item, slot)
                end
            end
        end
    end
end

function ENT:OnRemove()
    if self.SaveData then
        self:SaveData()
    end
end

function ENT:OnTakeDamage(dmginfo)
    if not self.Damageable then return end

    local damage = dmginfo:GetDamage()

    if dmginfo:IsDamageType(DMG_CLUB) or dmginfo:IsDamageType(DMG_SLASH) then
        damage = damage * (self.MeleeDamage or 1.0)
    elseif dmginfo:IsDamageType(DMG_BULLET) then
        damage = damage * (self.BulletDamage or 1.0)
    elseif dmginfo:IsDamageType(DMG_BLAST) then
        damage = damage * (self.ExplosiveDamage or 1.0)
    end

    local newHealth = self:Health() - damage
    if newHealth <= 0 then
        self.DestroyedByDamage = true
        self:CreateStashOnDestroy()
        self:Remove()
    else
        self:SetHealth(newHealth)
    end
end
