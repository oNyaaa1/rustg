AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local JunkpileModels = {
    "models/environment/junkpiles/a.mdl",
    "models/environment/junkpiles/b.mdl",
    "models/environment/junkpiles/c.mdl",
    "models/environment/junkpiles/d.mdl",
    "models/environment/junkpiles/e.mdl",
    "models/environment/junkpiles/f.mdl",
    "models/environment/junkpiles/g.mdl"
}

function ENT:Initialize()
    if CLIENT then return end
    
    -- Pick a random junkpile model
    local randomModel = JunkpileModels[math.random(#JunkpileModels)]
    self:SetModel(randomModel)
    
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    
    -- Properly drop to ground using trace
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:DropToGround()
            -- Spawn containers after dropping to ground
            timer.Simple(0.1, function()
                if IsValid(self) then
                    self:SpawnLootContainers()
                end
            end)
        end
    end)
end

function ENT:DropToGround()
    local pos = self:GetPos()
    
    -- Trace down to find the ground
    local trace = util.TraceLine({
        start = pos + Vector(0, 0, 50), -- Start a bit higher
        endpos = pos + Vector(0, 0, -2000),
        filter = self,
        mask = MASK_SOLID_BRUSHONLY
    })
    
    if trace.Hit then
        -- Set position on the ground
        local groundPos = trace.HitPos
        self:SetPos(groundPos)
        
        -- Force the entity to settle on ground
        timer.Simple(0.05, function()
            if IsValid(self) then
                local phys = self:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(false)
                    phys:Sleep()
                end
            end
        end)
    end
end

function ENT:SpawnLootContainers()
    local junkpilePos = self:GetPos()
    local junkpileAng = self:GetAngles()
    
    -- Get junkpile bounds to calculate safe spawn distance
    local junkpileMins, junkpileMaxs = self:GetModelBounds()
    local junkpileRadius = math.max(math.abs(junkpileMins.x), math.abs(junkpileMaxs.x), math.abs(junkpileMins.y), math.abs(junkpileMaxs.y))
    -- Allow some overlap but not too much - containers can be partially in the junkpile
    local minDistance = junkpileRadius * 0.6 -- Allow 40% overlap with junkpile
    local maxDistance = junkpileRadius -- Close range for realistic Rust look

    -- Spawn 1-3 barrels around the junkpile
    local barrelCount = math.random(1, 3)
    local usedAngles = {} -- Track used angles to prevent overlap
    
    for i = 1, barrelCount do
        local barrel = ents.Create("rust_barrel")
        if IsValid(barrel) then
            -- Find a good angle that doesn't overlap with existing containers
            local angle
            local attempts = 0
            repeat
                angle = math.random(0, 360)
                attempts = attempts + 1
            until (self:IsAngleClear(angle, usedAngles, 45) or attempts > 10)
            
            table.insert(usedAngles, angle)
            
            local distance = math.random(minDistance, maxDistance)
            local offset = Vector(
                math.cos(math.rad(angle)) * distance,
                math.sin(math.rad(angle)) * distance,
                50 -- Start higher to ensure proper ground detection
            )
            
            local spawnPos = junkpilePos + offset
            barrel:SetPos(spawnPos)
            barrel:SetAngles(junkpileAng + Angle(0, math.random(0, 360), 0))
            barrel:Spawn()
            
            -- Properly drop barrel to ground
            timer.Simple(0.1, function()
                if IsValid(barrel) then
                    self:DropEntityToGround(barrel)
                end
            end)
            
            -- Store reference to track spawned containers
            self.SpawnedContainers = self.SpawnedContainers or {}
            table.insert(self.SpawnedContainers, barrel)
        end
    end

    -- Spawn 0-2 wooden crates around it
    local crateCount = math.random(0, 1)
    for i = 1, crateCount do
        local crate = ents.Create("rust_woodencrate")
        if IsValid(crate) then
            -- Find a good angle that doesn't overlap with barrels
            local angle
            local attempts = 0
            repeat
                angle = math.random(0, 360)
                attempts = attempts + 1
            until (self:IsAngleClear(angle, usedAngles, 60) or attempts > 10)
            
            table.insert(usedAngles, angle)
            
            local distance = math.random(junkpileRadius * 0.8, maxDistance + 15) -- Crates can overlap even more, up to 20% overlap
            local offset = Vector(
                math.cos(math.rad(angle)) * distance,
                math.sin(math.rad(angle)) * distance,
                50 -- Start higher to ensure proper ground detection
            )
            
            local spawnPos = junkpilePos + offset
            crate:SetPos(spawnPos)
            crate:SetAngles(junkpileAng + Angle(0, math.random(0, 360), 0))
            crate:Spawn()
            
            -- Properly drop crate to ground
            timer.Simple(0.1, function()
                if IsValid(crate) then
                    self:DropEntityToGround(crate)
                end
            end)
            
            -- Store reference to track spawned containers
            self.SpawnedContainers = self.SpawnedContainers or {}
            table.insert(self.SpawnedContainers, crate)
        end
    end
end

-- Helper function to check if an angle is clear of other containers
function ENT:IsAngleClear(newAngle, usedAngles, minSeparation)
    for _, usedAngle in ipairs(usedAngles) do
        local angleDiff = math.abs(newAngle - usedAngle)
        -- Handle angle wraparound (e.g., 350° and 10° are only 20° apart)
        if angleDiff > 180 then
            angleDiff = 360 - angleDiff
        end
        
        if angleDiff < minSeparation then
            return false
        end
    end
    return true
end

function ENT:DropEntityToGround(entity)
    if not IsValid(entity) then return end
    
    local pos = entity:GetPos()
    
    -- Trace down to find the ground
    local trace = util.TraceLine({
        start = pos + Vector(0, 0, 10), -- Start a bit higher
        endpos = pos + Vector(0, 0, -2000),
        filter = {self, entity},
        mask = MASK_SOLID_BRUSHONLY
    })
    
    if trace.Hit then
        -- Set position on the ground
        local groundPos = trace.HitPos
        entity:SetPos(groundPos)
        
        -- Force settle the entity
        timer.Simple(0.05, function()
            if IsValid(entity) then
                local phys = entity:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(false)
                    phys:Sleep()
                end
            end
        end)
    end
end

function ENT:OnRemove()
    -- Clean up spawned containers when junkpile is removed
    if self.SpawnedContainers then
        for _, container in ipairs(self.SpawnedContainers) do
            if IsValid(container) then
                container:Remove()
            end
        end
    end
end
