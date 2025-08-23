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

    timer.Simple(0.1, function()
        if IsValid(self) then
            self.SpawnPosition = self:GetPos()
            self.SpawnAngles = self:GetAngles()
            self:PopulateWithItems()
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
            itemid = "metalblade",
            amount = {1, 5},
            chance = 0.20,
        },
        {
            itemid = "rope",
            amount = {1, 3},
            chance = 0.18,
        },
        {
            itemid = "semibody",
            amount = {1, 2},
            chance = 0.15,
        },
        {
            itemid = "metalspring",
            amount = {1, 2},
            chance = 0.15,
        },
        {
            itemid = "sheetmetal",
            amount = {1, 1},
            chance = 0.17,
        },
        {
            itemid = "scrap",
            amount = {10, 10},
            chance = 100.0,
        },
        {
            itemid = "metalpipe",
            amount = {1, 6},
            chance = 0.03,
        },
        {
            itemid = "machete",
            amount = {1, 1},
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
    
    if #availableItems == 0 then
        return
    end
    
    if self.Inventory then
        for i = 1, self.InventorySlots do
            if self.Inventory[i] then
                self:RemoveSlot(i)
            end
        end
    end
    
    local itemCount = math.random(2, 5)
    
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
        if addedItems >= itemCount then
            break
        end
        
        if currentSlot > self.InventorySlots then
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
            self:CheckAndRespawnIfEmpty()
        end
    end)
end

function ENT:CheckAndRespawnIfEmpty()
    if not self.Inventory then
        self:ScheduleRespawn()
        return
    end

    local hasItems = false
    for i = 1, self.InventorySlots do
        if self.Inventory[i] then
            hasItems = true
            break
        end
    end

    if not hasItems then
        self:ScheduleRespawn()
    end
end

function ENT:ScheduleRespawn()
    local pos = self.SpawnPosition or self:GetPos()
    local ang = self.SpawnAngles or self:GetAngles()
    
    self:Remove()
    
    timer.Create("WoodenCrateRespawn_" .. tostring(pos), 10, 1, function()
        local newCrate = ents.Create("rust_woodencrate")
        if IsValid(newCrate) then
            newCrate:SetPos(pos)
            newCrate:SetAngles(ang)
            newCrate:Spawn()
            newCrate:Activate()
        end
    end)
end

function ENT:Use(activator, caller)
    BaseClass.Use(self, activator, caller)
end
