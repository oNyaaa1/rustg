AddCSLuaFile()
ENT.Base = "rust_base"
ENT.ShowHealth = true

local RoadSignModels = {
    "models/environment/roadsigns/roadsign_b.mdl",
    "models/environment/roadsigns/roadsign_c.mdl",
    "models/environment/roadsigns/roadsign_d.mdl",
    "models/environment/roadsigns/roadsign_e.mdl",
    "models/environment/roadsigns/roadsign_f.mdl",
    "models/environment/roadsigns/roadsign_g.mdl"
}

function ENT:Initialize()
    if CLIENT then return end
    
    -- Pick a random roadsign model
    local randomModel = RoadSignModels[math.random(#RoadSignModels)]
    self:SetModel(randomModel)
    
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetDamageable(true)
    self:SetDamageSound(true)
    
    -- Roadsign health settings
    self:SetHealth(200)
    self:SetMaxHealth(200)
    
    self:SetRespawnTime(300) -- 5 minutes respawn
    self:PrecacheGibs()
    
    -- Damage multipliers
    self:SetMeleeDamage(1)
    self:SetBulletDamage(1.5)
    self:SetExplosiveDamage(3)
end

local LootItems = {
    {
        Item = "roadsigns",
        Min = 1,
        Max = 1,
        Chance = 100
    },
    {
        Item = "metalpipe",
        Min = 1,
        Max = 2,
        Chance = 60
    }
}

function ENT:OnDestroyed()
    if CLIENT then return end
    
    local pos = self:GetPos()
    
    -- Drop loot
    for _, loot in ipairs(LootItems) do
        if math.random(100) <= loot.Chance then
            local quantity = math.random(loot.Min, loot.Max)
            gRust.SpawnLoot(loot.Item, quantity, pos + Vector(0, 0, 20))
        end
    end
    
    -- Gib effects
    self:GibBreakClient(Vector(0, 0, 1))
    
    -- Remove and respawn
    self:Remove()
    self:ScheduleRespawn()
end

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Health")
    self:NetworkVar("Float", 1, "MaxHealth")
end

function ENT:GetDisplayName()
    return "Road Sign"
end