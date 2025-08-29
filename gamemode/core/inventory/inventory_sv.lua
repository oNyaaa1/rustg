util.AddNetworkString("gRust.Inventory.Move")
util.AddNetworkString("gRust.Inventory.Request")
util.AddNetworkString("gRust.Inventory.SyncSlot")
util.AddNetworkString("gRust.Inventory.Remove")
util.AddNetworkString("gRust.Inventory.SyncAll")
util.AddNetworkString("gRust.Inventory.Create")
util.AddNetworkString("gRust.Inventory.Close")
util.AddNetworkString("gRust.Drop")
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")
function ENTITY:SetSlotsLocked(locked, startSlot, endSlot)
    self.SlotsLocked = locked or false
    self.LockedStartSlot = startSlot or 7
    self.LockedEndSlot = endSlot or 12
end

function ENTITY:GetSlotsLocked()
    return self.SlotsLocked or false
end

function ENTITY:IsSlotLocked(slot)
    if not self:GetSlotsLocked() then return false end
    local startSlot = self.LockedStartSlot or 7
    local endSlot = self.LockedEndSlot or 12
    return slot >= startSlot and slot <= endSlot
end

function ENTITY:CanPlaceInSlot(slot, item)
    return not self:IsSlotLocked(slot)
end

function ENTITY:SetSlot(item, slot)
    if not self.Inventory or not slot then return false end
    if slot > self.InventorySlots or slot < 1 then return false end
    self.Inventory[slot] = item
    self:SyncSlot(slot)
    if slot >= 31 and slot <= 36 and item and self:IsPlayer() and self:IsClothingItem(item) then self:ApplyClothing(item, slot) end
    return true
end

function PLAYER:GetAttireType(item)
    if not item then return nil end
    local itemClass = item:GetItem()
    local itemData = gRust.Items[itemClass]
    if not itemData then return nil end
    local attireId = itemData:GetAttire()
    if not attireId then return nil end
    local attireData = gRust.Attire[attireId]
    if not attireData then return nil end
    return attireData.type
end

function PLAYER:HasConflictingClothing(item, targetSlot)
    if not item then return false end
    local newItemType = self:GetAttireType(item)
    if newItemType == nil then return false end
    for slot = 31, 36 do
        if slot ~= targetSlot and self.Inventory[slot] then
            local existingType = self:GetAttireType(self.Inventory[slot])
            if existingType == newItemType then return true end
        end
    end
    return false
end

function PLAYER:CanPlaceInSlot(slot, item)
    if self:IsSlotLocked(slot) then return false end
    if slot >= 31 and slot <= 36 then
        if not self:IsClothingItem(item) then return false end
        if self:HasConflictingClothing(item, slot) then return false end
    end
    return true
end

function PLAYER:RemoveClothing(slot)
    if not self.EquippedAttire or not self.EquippedAttire[slot] then return end
    self.EquippedAttire[slot] = nil
    local hasOtherAttire = false
    local newModel = self.OriginalModel
    for slotNum, equippedAttire in pairs(self.EquippedAttire) do
        if equippedAttire and gRust.Attire[equippedAttire] then
            local attireData = gRust.Attire[equippedAttire]
            if attireData.model then
                newModel = attireData.model
                hasOtherAttire = true
                break
            end
        end
    end

    self:SetModel(newModel)
    if not hasOtherAttire then
        self.ArmorHead = nil
        self.ArmorBody = nil
        self.ArmorArms = nil
        self.ArmorLegs = nil
    end
end

function PLAYER:ApplyClothing(item, slot)
    if not self.OriginalModel then self.OriginalModel = self:GetModel() end
    local itemClass = item:GetItem()
    local itemData = gRust.Items[itemClass]
    if not itemData then return end
    local attireId = itemData:GetAttire()
    if not attireId then return end
    local attireData = gRust.Attire[attireId]
    if not attireData then return end
    if attireData.model then self:SetModel(attireData.model) end
    if attireData.hands then
        self.CurrentHandsModel = attireData.hands
        self:SetupHands()
    end

    if attireData.head then self.ArmorHead = attireData.head end
    if attireData.body then self.ArmorBody = attireData.body end
    if attireData.arms then self.ArmorArms = attireData.arms end
    if attireData.legs then self.ArmorLegs = attireData.legs end
    self.EquippedAttire = self.EquippedAttire or {}
    self.EquippedAttire[slot] = attireId
end

function PLAYER:DropItem(slot, amount)
    if not self.Inventory or not slot then return false end
    if slot > self.InventorySlots or slot < 1 then return false end
    local item = self.Inventory[slot]
    if not item then return false end
    amount = amount or item:GetQuantity()
    amount = math.min(amount, item:GetQuantity())
    if amount <= 0 then return false end
    local dropItem
    if amount >= item:GetQuantity() then
        dropItem = item
        self:RemoveSlot(slot)
        if slot >= 31 and slot <= 36 then self:RemoveClothing(slot) end
    else
        dropItem = item:Split(amount)
        if dropItem then
            self:SyncSlot(slot)
        else
            return false
        end
    end

    local itemEnt = ents.Create("rust_droppeditem")
    if not IsValid(itemEnt) then
        if amount >= item:GetQuantity() then
            self:SetSlot(dropItem, slot)
        else
            item:AddQuantity(amount)
            self:SyncSlot(slot)
        end
        return false
    end

    itemEnt:SetItem(dropItem)
    itemEnt:SetPos(self:GetPos() + self:GetForward() * 50 + Vector(0, 0, 30))
    itemEnt:SetAngles(Angle(0, math.random(0, 360), 0))
    itemEnt:Spawn()
    local phys = itemEnt:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        local force = self:GetAimVector() * 300 + Vector(0, 0, 100)
        force = force + VectorRand() * 50
        phys:ApplyForceCenter(force)
        phys:AddAngleVelocity(VectorRand() * 100)
    end

    local itemData = gRust.Items[dropItem:GetItem()]
    if itemData and itemData:GetSound() then self:EmitSound(gRust.RandomGroupedSound(string.format("drop.%s", itemData:GetSound()))) end
    hook.Call("gRust.ItemDropped", nil, self, dropItem, itemEnt, slot)
    return true
end

net.Receive("gRust.Inventory.SyncSlot", function()
    local ent = net.ReadEntity()
    local slot = net.ReadUInt(6)
    local item = net.ReadItem()
    -- Update your local representation
    ent.Inventory[slot] = item
    -- Refresh the UI if it's open
    if gRust.Inventory.Container then gRust.Inventory.UpdateContainer() end
end)

function PLAYER:IsClothingItem(item)
    if not item then return false end
    local itemClass = item:GetItem()
    local itemData = gRust.Items[itemClass]
    if not itemData then return false end
    return itemData:GetCategory() == "Clothing"
end

-- ИСПРАВЛЕННАЯ ФУНКЦИЯ СИНХРОНИЗАЦИИ
function ENTITY:SyncSlot(slot)
    if not self.Inventory or not slot then return end
    local item = self.Inventory[slot]
    -- Для игроков
    if self:IsPlayer() then
        if item then
            net.Start("gRust.Inventory.SyncSlot")
            net.WriteEntity(self)
            net.WriteUInt(slot, 6)
            net.WriteItem(item)
            net.Send(self)
        else
            net.Start("gRust.Inventory.Remove")
            net.WriteEntity(self)
            net.WriteUInt(slot, 6)
            net.Send(self)
        end
        return
    end

    -- Для контейнеров - находим всех ближайших игроков
    local recipients = {}
    for _, pl in pairs(player.GetAll()) do
        if IsValid(pl) and pl:GetPos():Distance(self:GetPos()) <= 200 then table.insert(recipients, pl) end
    end

    if #recipients > 0 then
        if item then
            net.Start("gRust.Inventory.SyncSlot")
            net.WriteEntity(self)
            net.WriteUInt(slot, 6)
            net.WriteItem(item)
            net.Send(recipients)
        else
            net.Start("gRust.Inventory.Remove")
            net.WriteEntity(self)
            net.WriteUInt(slot, 6)
            net.Send(recipients)
        end
    end
end

function ENTITY:RemoveSlot(slot)
    if not self.Inventory or not slot then return end
    self.Inventory[slot] = nil
    self:SyncSlot(slot)
end

function PLAYER:RemoveSlot(slot)
    if not self.Inventory or not slot then return end
    if slot >= 31 and slot <= 36 then self:RemoveClothing(slot) end
    self.Inventory[slot] = nil
    self:SyncSlot(slot)
end

function PLAYER:CreateInventory(slots)
    slots = slots or 30
    self.Inventory = {}
    self.InventorySlots = slots
    self.EquippedAttire = {}
    net.Start("gRust.Inventory.Create")
    net.WriteUInt(slots, 6)
    net.Send(self)
end

function PLAYER:SyncInventory()
    if not self.Inventory then return end
    for i = 31, 36 do
        local item = self.Inventory[i]
        if item and self:IsClothingItem(item) then self:ApplyClothing(item, i) end
    end

    net.Start("gRust.Inventory.SyncAll")
    local validItems = {}
    for i = 1, self.InventorySlots do
        if self.Inventory[i] then
            table.insert(validItems, {
                slot = i,
                item = self.Inventory[i]
            })
        end
    end

    net.WriteUInt(#validItems, 6)
    for _, data in pairs(validItems) do
        net.WriteUInt(data.slot, 6)
        net.WriteItem(data.item)
    end

    net.WriteUInt(self.InventorySlots, 6)
    net.Send(self)
end

function PLAYER:FindEmptySlot(startSlot, endSlot, item)
    startSlot = startSlot or 1
    endSlot = endSlot or self.InventorySlots
    if item and item:IsStackable() then
        for i = startSlot, endSlot do
            local existingItem = self.Inventory[i]
            if existingItem and existingItem:CanStack(item) then return i end
        end
    end

    for i = startSlot, endSlot do
        if not self.Inventory[i] then return i end
    end
end

function PLAYER:RequestInventory(entity)
    if not IsValid(entity) or not entity.Inventory then return end
    if entity:GetPos():Distance(self:GetPos()) > 200 then return end
    net.Start("gRust.Inventory.Request")
    net.WriteEntity(entity)
    local validItems = {}
    for i = 1, entity.InventorySlots do
        if entity.Inventory[i] then
            table.insert(validItems, {
                slot = i,
                item = entity.Inventory[i]
            })
        end
    end

    net.WriteUInt(#validItems, 6)
    for _, data in pairs(validItems) do
        net.WriteUInt(data.slot, 6)
        net.WriteItem(data.item)
    end

    net.WriteUInt(entity.InventorySlots, 6)
    net.Send(self)
end

function PLAYER:GiveItem(itemOrClass, amount, slot, wear, clip)
    if not self.Inventory or not itemOrClass then return false end
    if type(itemOrClass) == "table" and itemOrClass.GetItem then
        local item = itemOrClass
        local targetSlot = slot
        if targetSlot then
            if targetSlot < 1 or targetSlot > self.InventorySlots then return false end
            local existingItem = self.Inventory[targetSlot]
            if existingItem then
                if existingItem:CanStack(item) then
                    local success, overflow = existingItem:Merge(item)
                    if success then
                        self:SyncSlot(targetSlot) -- исправлена опечатка
                        return true
                    end
                end
                return false
            else
                self:SetSlot(item:Copy(), targetSlot)
                return true
            end
        else
            for i = 1, self.InventorySlots do
                local existingItem = self.Inventory[i]
                if existingItem and existingItem:CanStack(item) then
                    local success, overflow = existingItem:Merge(item)
                    if success then
                        self:SyncSlot(i)
                        return true
                    end
                end
            end

            targetSlot = self:FindEmptySlot(1, self.InventorySlots, item)
            if targetSlot then
                self:SetSlot(item:Copy(), targetSlot)
                return true
            end
        end
        return false
    end

    local itemClass = itemOrClass
    if not gRust.Items[itemClass] then return false end
    amount = amount or 1
    local remaining = amount
    local ItemData = gRust.Items[itemClass]
    local maxStack = ItemData:GetStack()
    if slot then
        if slot < 1 or slot > self.InventorySlots then return false end
        local existingItem = self.Inventory[slot]
        if existingItem then
            if existingItem:GetItem() == itemClass and existingItem:CanAddQuantity(remaining) then
                existingItem:AddQuantity(remaining)
                if wear and existingItem.SetWear then existingItem:SetWear(wear) end
                if clip and existingItem.SetClip then existingItem:SetClip(clip) end
                self:SyncSlot(slot)
                return true
            end
            return false
        else
            local newItem = gRust.CreateItem(itemClass, remaining, wear)
            if clip and newItem.SetClip then newItem:SetClip(clip) end
            self:SetSlot(newItem, slot)
            return true
        end
    end

    while remaining > 0 do
        local targetSlot = nil
        for i = 1, self.InventorySlots do
            local existingItem = self.Inventory[i]
            if existingItem and existingItem:GetItem() == itemClass and existingItem:CanAddQuantity(1) then
                targetSlot = i
                break
            end
        end

        if not targetSlot then targetSlot = self:FindEmptySlot(1, self.InventorySlots, gRust.CreateItem(itemClass, 1)) end
        if not targetSlot then break end
        local existingItem = self.Inventory[targetSlot]
        if existingItem then
            local maxAddable = existingItem:GetMaxAddable()
            local toAdd = math.min(remaining, maxAddable)
            existingItem:AddQuantity(toAdd)
            remaining = remaining - toAdd
            self:SyncSlot(targetSlot)
        else
            local toAdd = math.min(remaining, maxStack)
            local newItem = gRust.CreateItem(itemClass, toAdd, wear)
            if clip and newItem.SetClip then newItem:SetClip(clip) end
            if newItem then
                self:SetSlot(newItem, targetSlot)
                remaining = remaining - toAdd
            else
                break
            end
        end
    end
    return remaining == 0
end

function PLAYER:RemoveItem(itemClass, amount)
    if not self.Inventory or not itemClass then return false end
    amount = amount or 1
    if not self:HasItem(itemClass, amount) then return false end
    local remaining = amount
    for i = 1, self.InventorySlots do
        if remaining <= 0 then break end
        local invItem = self.Inventory[i]
        if invItem and invItem:GetItem() == itemClass then
            local currentQty = invItem:GetQuantity()
            local takeAmount = math.min(remaining, currentQty)
            invItem:RemoveQuantity(takeAmount)
            remaining = remaining - takeAmount
            if invItem:GetQuantity() <= 0 then
                self:RemoveSlot(i)
            else
                self:SyncSlot(i)
            end
        end
    end
    return remaining == 0
end

function PLAYER:HasItem(itemClass, amount)
    if not self.Inventory or not itemClass then return false end
    amount = amount or 1
    local totalAmount = 0
    for i = 1, self.InventorySlots do
        local invItem = self.Inventory[i]
        if invItem and invItem:GetItem() == itemClass then totalAmount = totalAmount + invItem:GetQuantity() end
    end
    --print(totalAmount)
    return totalAmount >= amount
end

function PLAYER:ItemCount(itemType)
    local count = 0
    if not self.Inventory then return 0 end
    for _, item in pairs(self.Inventory) do
        if item:GetItem() == itemType then
            if item.GetAmount then
                count = count + item:GetQuantity()
            else
                count = count + 1
            end
        end
    end
    return count
end

function PLAYER:GetItemCount(itemClass)
    if not self.Inventory or not itemClass then return 0 end
    local total = 0
    for i = 1, self.InventorySlots do
        local invItem = self.Inventory[i]
        if invItem and invItem:GetItem() == itemClass then total = total + invItem:GetQuantity() end
    end
    return total
end

function HandleMoveSlot(_, pl)
    local fromEnt = net.ReadEntity()
    local toEnt = net.ReadEntity()
    local oldSlot = net.ReadUInt(6)
    local newSlot = net.ReadUInt(6)
    local amount = net.ReadUInt(20)
    if not (IsValid(pl) and pl:Alive()) then return end
    if not (IsValid(fromEnt) and IsValid(toEnt)) then return end
    if not (fromEnt.Inventory and toEnt.Inventory) then return end
    if oldSlot < 1 or newSlot < 1 or oldSlot > fromEnt.InventorySlots or newSlot > toEnt.InventorySlots then return end
    if amount == 0 then return end
    local fromItem = fromEnt.Inventory[oldSlot]
    if not fromItem then return end
    if not toEnt:CanPlaceInSlot(newSlot, fromItem) then return end
    amount = math.min(amount, fromItem:GetQuantity())
    local toItem = toEnt.Inventory[newSlot]
    if toItem then
        if toItem:CanStack(fromItem) and toItem:CanAddQuantity(amount) then
            toItem:AddQuantity(amount)
            fromItem:RemoveQuantity(amount)
            if fromItem:GetQuantity() <= 0 then
                fromEnt:RemoveSlot(oldSlot)
            else
                fromEnt:SyncSlot(oldSlot)
            end

            toEnt:SyncSlot(newSlot)
        else
            fromEnt.Inventory[oldSlot] = toItem
            toEnt.Inventory[newSlot] = fromItem
            fromEnt:SyncSlot(oldSlot)
            toEnt:SyncSlot(newSlot)
        end
    else
        if amount >= fromItem:GetQuantity() then
            toEnt.Inventory[newSlot] = fromItem
            fromEnt:RemoveSlot(oldSlot)
            toEnt:SyncSlot(newSlot)
        else
            local split = fromItem:Split(amount)
            if not split then return end
            toEnt.Inventory[newSlot] = split
            fromEnt:SyncSlot(oldSlot)
            toEnt:SyncSlot(newSlot)
        end
    end

    if fromEnt:IsPlayer() and oldSlot >= 31 and oldSlot <= 36 then
        if fromEnt.Inventory[oldSlot] and fromEnt:IsClothingItem(fromEnt.Inventory[oldSlot]) then
            fromEnt:ApplyClothing(fromEnt.Inventory[oldSlot], oldSlot)
        else
            fromEnt:RemoveClothing(oldSlot)
        end
    end

    if toEnt:IsPlayer() and newSlot >= 31 and newSlot <= 36 then if toEnt:IsClothingItem(toEnt.Inventory[newSlot]) then toEnt:ApplyClothing(toEnt.Inventory[newSlot], newSlot) end end
    hook.Run("gRust.ItemMoved", pl, fromEnt, toEnt, oldSlot, newSlot)
end

function HandleItemDrop(len, pl)
    local ent = net.ReadEntity()
    local slot = net.ReadUInt(6)
    local amount = net.ReadUInt(20)
    if not IsValid(pl) or not pl:Alive() then return end
    if not IsValid(ent) then return end
    if ent ~= pl and ent:GetPos():Distance(pl:GetPos()) > 200 then return end
    if not ent.Inventory then return end
    if ent:IsPlayer() and ent ~= pl then
        pl:ChatPrint("ИДИ НАХУЙ ПИДОР Я ВСЁ ПОФИКСИЛ")
        return
    end

    if ent:IsPlayer() then
        ent:DropItem(slot, amount)
    else
        if slot < 1 or slot > ent.InventorySlots then return end
        local item = ent.Inventory[slot]
        if not item then return end
        amount = math.min(amount, item:GetQuantity())
        if amount <= 0 then return end
        local dropItem
        if amount >= item:GetQuantity() then
            dropItem = item
            ent.Inventory[slot] = nil
            ent:SyncSlot(slot)
        else
            dropItem = item:Split(amount)
            if dropItem then
                ent:SyncSlot(slot)
            else
                return
            end
        end

        local itemEnt = ents.Create("rust_droppeditem")
        if IsValid(itemEnt) then
            itemEnt:SetItem(dropItem)
            itemEnt:SetPos(ent:GetPos() + Vector(0, 0, 30) + VectorRand() * 20)
            itemEnt:SetAngles(Angle(0, math.random(0, 360), 0))
            itemEnt:Spawn()
            local phys = itemEnt:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:ApplyForceCenter(VectorRand() * 200 + Vector(0, 0, 100))
            end
        end
    end
end

function HandleInventoryRequest(len, pl)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if not ent.Inventory then return end
    if ent ~= pl and ent:GetPos():Distance(pl:GetPos()) > 200 then return end
    net.Start("gRust.Inventory.Request")
    net.WriteEntity(ent)
    local validItems = {}
    for i = 1, ent.InventorySlots do
        if ent.Inventory[i] then
            table.insert(validItems, {
                slot = i,
                item = ent.Inventory[i]
            })
        end
    end

    net.WriteUInt(#validItems, 6)
    for _, data in pairs(validItems) do
        net.WriteUInt(data.slot, 6)
        net.WriteItem(data.item)
    end

    net.WriteUInt(ent.InventorySlots, 6)
    net.Send(pl)
end

-- HOOKS
hook.Add("PlayerDisconnected", "gRust.Inventory.PlayerDisconnect", function(pl)
    if pl.Inventory then
        local hasItems = false
        for i = 1, 36 do
            if pl.Inventory[i] then
                hasItems = true
                break
            end
        end

        if hasItems then
            local playerData = {
                steamID = pl:SteamID(),
                name = pl:Nick(),
                pos = pl:GetPos(),
                inventory = {}
            }

            for i = 1, 36 do
                if pl.Inventory[i] then playerData.inventory[i] = pl.Inventory[i] end
            end

            local lootEnt = ents.Create("rust_sleepingplayer")
            if IsValid(lootEnt) then
                lootEnt:SetPos(playerData.pos + Vector(0, 0, 10))
                lootEnt:SetAngles(Angle(0, math.random(0, 360), 0))
                lootEnt:Spawn()
                lootEnt.OwnerSteamID = playerData.steamID
                lootEnt.OwnerName = playerData.name
                lootEnt:SetNWString("OwnerSteamID", lootEnt.OwnerSteamID)
                lootEnt:SetNWString("OwnerName", lootEnt.OwnerName)
                local itemCount = 0
                for i = 1, 36 do
                    if playerData.inventory[i] then
                        lootEnt:SetSlot(playerData.inventory[i], i)
                        itemCount = itemCount + 1
                    end
                end
            end
        end

        pl.Inventory = {}
    end
end)

hook.Add("PlayerDeath", "gRust.Inventory.PlayerDeath", function(pl)
    if pl.Inventory then
        local hasItems = false
        for i = 1, 36 do
            if pl.Inventory[i] then
                hasItems = true
                break
            end
        end

        if hasItems then
            local playerData = {
                steamID = pl:SteamID(),
                name = pl:Nick(),
                pos = pl:GetPos(),
                inventory = {}
            }

            for i = 1, 36 do
                if pl.Inventory[i] then playerData.inventory[i] = pl.Inventory[i] end
            end

            local lootEnt = ents.Create("rust_sleepingplayer")
            if IsValid(lootEnt) then
                lootEnt:SetPos(playerData.pos + Vector(0, 0, 10))
                lootEnt:SetAngles(Angle(0, math.random(0, 360), 0))
                lootEnt:Spawn()
                lootEnt.OwnerSteamID = playerData.steamID
                lootEnt.OwnerName = playerData.name
                lootEnt:SetNWString("OwnerSteamID", lootEnt.OwnerSteamID)
                lootEnt:SetNWString("OwnerName", lootEnt.OwnerName)
                local itemCount = 0
                for i = 1, 36 do
                    if playerData.inventory[i] then
                        lootEnt:SetSlot(playerData.inventory[i], i)
                        itemCount = itemCount + 1
                    end
                end
            end
        end

        pl.Inventory = {}
        pl.EquippedAttire = {}
        pl:SetModel("models/player/Group01/Male_01.mdl")
        pl.ArmorHead = nil
        pl.ArmorBody = nil
        pl.ArmorArms = nil
        pl.ArmorLegs = nil
        timer.Simple(0, function()
            if IsValid(pl) then
                pl:SyncInventory()
                pl:GiveItem("rock", 1)
            end
        end)
    end
end)

function FindPlayerSleepingBag(player)
    local steamID = player:SteamID()
    for _, ent in pairs(ents.FindByClass("rust_sleepingplayer")) do
        if IsValid(ent) and ent.OwnerSteamID == steamID then return ent end
    end
    return nil
end

function TransferSleepingBagToPlayer(player, sleepingBag)
    if not IsValid(player) or not IsValid(sleepingBag) then return false end
    local transferred = false
    local transferredItems = 0
    for i = 1, sleepingBag.InventorySlots do
        local item = sleepingBag.Inventory[i]
        if item then
            local success = player:GiveItem(item)
            if success then
                transferred = true
                transferredItems = transferredItems + 1
                sleepingBag:RemoveSlot(i)
            end
        end
    end

    if transferred then
        sleepingBag:Remove()
        return true
    end
    return false
end

-- NET RECEIVERS
net.Receive("gRust.Inventory.Move", HandleMoveSlot)
net.Receive("gRust.Inventory.Request", HandleInventoryRequest)
net.Receive("gRust.Drop", HandleItemDrop)
-- CONSOLE COMMANDS
concommand.Add("giveitem", function(pl, cmd, args)
    if not pl:IsSuperAdmin() then return end
    local item = args[1]
    local amount = tonumber(args[2]) or 1
    local slot = tonumber(args[3])
    if pl:GiveItem(item, amount, slot) then
        pl:ChatPrint("Gave " .. amount .. "x " .. item)
    else
        pl:ChatPrint("Failed to give item - inventory full or invalid slot")
    end
end)