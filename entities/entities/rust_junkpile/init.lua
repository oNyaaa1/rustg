AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local RoadSignModels = {
    "models/environment/junkpiles/b.mdl",
    "models/environment/junkpiles/a.mdl",
    "models/environment/junkpiles/c.mdl",
    "models/environment/junkpiles/d.mdl",
    "models/environment/junkpiles/e.mdl",
    "models/environment/junkpiles/f.mdl",
    "models/environment/junkpiles/g.mdl"
}

function ENT:Initialize()
    if CLIENT then return end
    
    -- Pick a random roadsign model
    local randomModel = RoadSignModels[math.random(#RoadSignModels)]
    self:SetModel(randomModel)
    
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    
    self:PrecacheGibs()
end
