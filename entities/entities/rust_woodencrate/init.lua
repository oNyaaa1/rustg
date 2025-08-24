AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("rust_storage")

function ENT:Initialize()
    if CLIENT then return end

    self:SetModel("models/environment/crates/crate.mdl")
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

    self:CreateInventory(12)
    self:SetInteractable(true)
    self:SetDamageable(false)

    self.SpawnPosition = self:GetPos()
    self.SpawnAngles = self:GetAngles()

    timer.Simple(0.1, function()
        if IsValid(self) then
            self:PopulateWithItems()
        end
    end)

    timer.Create("CheckEmpty_" .. self:EntIndex(), 2, 0, function()
        if IsValid(self) then
            self:CheckIfEmptyAndScheduleRespawn()
        else
            timer.Remove("CheckEmpty_" .. self:EntIndex())
        end
    end)
end
 
function ENT:PopulateWithItems()
    local woodenCrateLootItems = {
        { itemid = "wood", amount = {50, 150}, chance = 0.8 },
        { itemid = "stone", amount = {50, 200}, chance = 0.7 },
        { itemid = "metal.ore", amount = {20, 100}, chance = 0.6 },
        { itemid = "cloth", amount = {10, 50}, chance = 0.5 },
        { itemid = "leather", amount = {5, 30}, chance = 0.4 },
        { itemid = "fat.animal", amount = {10, 40}, chance = 0.4 },
        { itemid = "bone.fragments", amount = {20, 80}, chance = 0.4 },
        { itemid = "hammer", amount = {1, 1}, chance = 0.3 },
        { itemid = "hatchet", amount = {1, 1}, chance = 0.25 },
        { itemid = "pickaxe", amount = {1, 1}, chance = 0.25 },
        { itemid = "spear.wooden", amount = {1, 1}, chance = 0.2 },
        { itemid = "bow.hunting", amount = {1, 1}, chance = 0.15 },
        { itemid = "arrow.wooden", amount = {10, 30}, chance = 0.2 },
        { itemid = "burlap.shirt", amount = {1, 1}, chance = 0.25 },
        { itemid = "burlap.pants", amount = {1, 1}, chance = 0.25 },
        { itemid = "burlap.shoes", amount = {1, 1}, chance = 0.2 },
        { itemid = "hide.pants", amount = {1, 1}, chance = 0.15 },
        { itemid = "hide.vest", amount = {1, 1}, chance = 0.15 },
        { itemid = "apple", amount = {1, 5}, chance = 0.3 },
        { itemid = "mushroom", amount = {2, 8}, chance = 0.25 },
        { itemid = "corn", amount = {2, 10}, chance = 0.2 },
        { itemid = "bandage", amount = {1, 5}, chance = 0.3 },
        { itemid = "rope", amount = {1, 3}, chance = 0.2 },
        { itemid = "tarp", amount = {1, 2}, chance = 0.15 },
        { itemid = "sewingkit", amount = {1, 1}, chance = 0.1 },
        { itemid = "gunpowder", amount = {10, 50}, chance = 0.1 },
        { itemid = "lowgradefuel", amount = {20, 100}, chance = 0.1 },
        { itemid = "scrap", amount = {1, 10}, chance = 0.05 },
        { itemid = "pistol.eoka", amount = {1, 1}, chance = 0.05 },
        { itemid = "crossbow", amount = {1, 1}, chance = 0.03 },
        { itemid = "machete", amount = {1, 1}, chance = 0.03 },
        { itemid = "knife.bone", amount = {1, 1}, chance = 0.05 },
        { itemid = "torch", amount = {1, 3}, chance = 0.1 },
    }

    local availableItems = {}
    for _, itemData in ipairs(woodenCrateLootItems) do
        local itemDef = gRust.Items[itemData.itemid]
        if itemDef then
            table.insert(availableItems, itemData)
        end
    end

    if #availableItems == 0 then return end

    if self.Inventory then
        for i = 1, self.InventorySlots do
            if self.Inventory[i] then
                self:RemoveSlot(i)
            end
        end
    end

    local itemCount = math.random(3, 8)
    local shuffledItems = {}
    
    for i = 1, #availableItems do
        table.insert(shuffledItems, availableItems[i])
    end
    for i = #shuffledItems, 2, -1 do
        local j = math.random(i)
        shuffledItems[i], shuffledItems[j] = shuffledItems[j], shuffledItems[i]
    end

    local currentSlot = 1
    local addedItems = 0

    for _, itemData in ipairs(shuffledItems) do
        if addedItems >= itemCount or currentSlot > self.InventorySlots then
            break
        end

        local randomChance = math.random()
        if randomChance <= itemData.chance then
            local amount = 1
            if type(itemData.amount) == "table" then
                amount = math.random(itemData.amount[1], itemData.amount[2])
            else
                amount = itemData.amount
            end

            local item = gRust.CreateItem(itemData.itemid, amount)
            if item then
                self:SetSlot(item, currentSlot)
                currentSlot = currentSlot + 1
                addedItems = addedItems + 1
            end
        end
    end
end

function ENT:RemoveSlot(slot)
    BaseClass.RemoveSlot(self, slot)

    timer.Simple(0.1, function()
        if IsValid(self) then
            self:CheckIfEmptyAndScheduleRespawn()
        end
    end)
end

function ENT:IsInventoryEmpty()
    if not self.Inventory then return true end
    
    for i = 1, self.InventorySlots do
        if self.Inventory[i] then
            return false
        end
    end
    
    return true
end

function ENT:CheckIfEmptyAndScheduleRespawn()
    if self:IsInventoryEmpty() then
        self:ScheduleRespawn()
    end
end

function ENT:ScheduleRespawn()
    local pos = self.SpawnPosition or self:GetPos()
    local ang = self.SpawnAngles or self:GetAngles()
    local respawnTime = 300 -- 5m

    timer.Remove("CheckEmpty_" .. self:EntIndex())
    
    self:Remove()

    local timerName = "WoodenCrateRespawn_" .. tostring(pos.x) .. "_" .. tostring(pos.y) .. "_" .. tostring(pos.z)
    timer.Create(timerName, respawnTime, 1, function()
        local newCrate = ents.Create("rust_woodencrate")
        if IsValid(newCrate) then
            newCrate:SetPos(pos)
            newCrate:SetAngles(ang)
            newCrate:Spawn()
            newCrate:Activate()
            newCrate.SpawnPosition = pos
            newCrate.SpawnAngles = ang
        end
    end)
end

function ENT:Use(activator, caller)
    BaseClass.Use(self, activator, caller)
end

function ENT:OnDestroyed(dmg)
    if self.SpawnPosition then
        self:ScheduleRespawn()
    end
end

function ENT:OnRemove()
    timer.Remove("CheckEmpty_" .. self:EntIndex())
end
