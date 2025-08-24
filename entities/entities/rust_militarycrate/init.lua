AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("rust_storage")

function ENT:Initialize()
    if CLIENT then return end

    self:SetModel("models/environment/crates/crate2.mdl")
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

    timer.Create("CheckEmpty_" .. self:EntIndex(), 2, 0, function()
        if IsValid(self) then
            self:CheckAndRespawnIfEmpty()
        else
            timer.Remove("CheckEmpty_" .. self:EntIndex())
        end
    end)
end

function ENT:PopulateWithItems()
    local militaryLootItems = {
        {
            itemid = "smgbody",
            amount = {1, 1},
            chance = 0.17,
        },
        {
            itemid = "techparts",
            amount = {2, 3},
            chance = 0.17,
        },
        {
            itemid = "metalpipe",
            amount = {5, 5},
            chance = 0.17,
        },
        {
            itemid = "metal.refined",
            amount = {15, 24},
            chance = 0.17,
        },
        {
            itemid = "riflebody",
            amount = {1, 1},
            chance = 0.16,
        },
        {
            itemid = "gears",
            amount = {1, 1},
            chance = 0.09,
        },
        {
            itemid = "sewingkit",
            amount = {1, 1},
            chance = 0.07,
        },
        {
            itemid = "supply.signal",
            amount = {1, 1},
            chance = 0.01,
        },
        {
            itemid = "syringe.medical",
            amount = {1, 1},
            chance = 0.01,
        },
        {
            itemid = "weapon.mod.holosight",
            amount = {1, 1},
            chance = 0.01,
        },
        {
            itemid = "pistol.semiauto",
            amount = {1, 1},
            chance = 0.01,
        },
        {
            itemid = "weapon.mod.muzzlebrake",
            amount = {1, 1},
            chance = 0.01,
        },
        {
            itemid = "grenade.beancan",
            amount = {1, 1},
            chance = 0.01,
        },
        {
            itemid = "rifle.semiauto",
            amount = {1, 1},
            chance = 0.01,
        },
        {
            itemid = "rocket.launcher",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "shotgun.pump",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "pistol.python",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "smg.thompson",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "rifle.ak",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "rifle.bolt",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "rifle.l96",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "rifle.lr300",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "shotgun.spas12",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "shotgun.double",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "smg.2",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "smg.mp5",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "pistol.revolver",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "pistol.m92",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "pistol.nailgun",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "pistol.eoka",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "bow.hunting",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "crossbow",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "knife.combat",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "lmg.m249",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "explosive.satchel",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "explosive.timed",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "weapon.mod.silencer",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "weapon.mod.8x.scope",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "weapon.mod.16x.scope",
            amount = {1, 1},
            chance = 0.005,
        },
        {
            itemid = "bandage",
            amount = {2, 5},
            chance = 0.005,
        },
        {
            itemid = "roadsigns",
            amount = {1, 3},
            chance = 0.005,
        },
        {
            itemid = "metalspring",
            amount = {1, 5},
            chance = 0.005,
        },
        {
            itemid = "sheetmetal",
            amount = {1, 4},
            chance = 0.005,
        },
        {
            itemid = "semibody",
            amount = {1, 2},
            chance = 0.005,
        },
        {
            itemid = "rope",
            amount = {1, 5},
            chance = 0.005,
        },
        {
            itemid = "explosives",
            amount = {1, 5},
            chance = 0.005,
        },
    }
    
    local availableItems = {}
    for _, itemData in ipairs(militaryLootItems) do
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
    
    local currentSlot = 1
    
    if gRust.Items["scrap"] then
        local scrapItem = gRust.CreateItem("scrap", 8)
        if scrapItem then
            self:SetSlot(scrapItem, currentSlot)
            currentSlot = currentSlot + 1
        end
    end
    
    local additionalItemCount = math.random(1, 5)
    
    local shuffledItems = {}
    for i = 1, #availableItems do
        table.insert(shuffledItems, availableItems[i])
    end
    
    for i = #shuffledItems, 2, -1 do
        local j = math.random(i)
        shuffledItems[i], shuffledItems[j] = shuffledItems[j], shuffledItems[i]
    end
    
    local addedItems = 0
    
    for _, itemData in ipairs(shuffledItems) do
        if addedItems >= additionalItemCount then
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
    
    timer.Remove("CheckEmpty_" .. self:EntIndex())
    
    self:Remove()
    
    timer.Create("MilitaryCrateRespawn_" .. tostring(pos), 10, 1, function()
        local newCrate = ents.Create("rust_militarycrate")
        if IsValid(newCrate) then
            newCrate:SetPos(pos)
            newCrate:SetAngles(ang)
            newCrate:Spawn()
            newCrate:Activate()
        end
    end)
end

function ENT:OnRemove()
    timer.Remove("CheckEmpty_" .. self:EntIndex())
end

function ENT:Use(activator, caller)
    BaseClass.Use(self, activator, caller)
end
