AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local JunkpileModels = {
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
    local randomModel = JunkpileModels[math.random(#JunkpileModels)]
    self:SetModel(randomModel)
    
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    self:PrecacheGibs()

    -- Spawn barrels at max 2 or boxes around it
    -- rust_barrel.lua
    for i = 1, math.random(1, 2) do
        local barrel = ents.Create("rust_barrel")
        if IsValid(barrel) then
            barrel:SetPos(self:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 0))
            barrel:Spawn()
            barrel:DropToFloor()
        end
    end

    -- rust_woodencrate.lua
    for i = 1, math.random(0, 1) do
        local crate = ents.Create("rust_woodencrate")
        if IsValid(crate) then
            crate:SetPos(self:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 0))
            crate:Spawn()
            crate:DropToFloor()
        end
    end
end
