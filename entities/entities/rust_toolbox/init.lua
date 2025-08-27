AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("rust_storage")

function ENT:Initialize()
    if CLIENT then return end

    self:SetModel("models/environment/crates/toolbox.mdl")
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

    self:CreateInventory(6)
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
        {
            itemid = "hatchet",
            amount = {1, 1},
            chance = 0.25,
        },
        {
            itemid = "pickaxe",
            amount = {1, 1},
            chance = 0.25,
        },
        {
            itemid = "fuse",
            amount = {1, 1},
            chance = 0.10,
        },
        {
            itemid = "rope",
            amount = {1, 3},
            chance = 0.18,
        },
        {
            itemid = "scrap",
            amount = {5, 5},
            chance = 100.0,
        },
        {
            itemid = "metalpipe",
            amount = {1, 6},
            chance = 0.03,
        },
        {
            itemid = "gears",
            amount = {2, 4},
            chance = 0.15,
        }
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

    local itemCount = math.random(2, 2)
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
    local respawnTime = 600 -- 5m

    timer.Remove("CheckEmpty_" .. self:EntIndex())
    
    self:Remove()

    local timerName = "toolCrateRespawn_" .. tostring(pos.x) .. "_" .. tostring(pos.y) .. "_" .. tostring(pos.z)
    timer.Create(timerName, respawnTime, 1, function()
        local newCrate = ents.Create("rust_toolbox")
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