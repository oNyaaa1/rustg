-- Spawning System for gRust
-- Handles spawning of all entities on the map

local SpawningSystem = {}

-- Configuration
local SPAWN_DELAY = 5 -- Seconds to wait after map load
local RANDOM_SPAWNS = 150 -- Number of random positions to find

-- Predefined spawn positions
local RoadSignSpawns = {
    {pos = Vector(7876.923828, 4310.765137, 636.311584), ang = Angle(-2.679643, 164.679718, 0.000000)},
    {pos = Vector(8776.530273, 1794.795044, 650.972290), ang = Angle(3.260353, -92.800308, 0.000000)},
    {pos = Vector(8537.921875, -908.605530, 640.918396), ang = Angle(10.740351, -72.780304, 0.000000)},
    {pos = Vector(10860.347656, -1018.629578, 640.031250), ang = Angle(10.300351, -0.620302, 0.000000)},
    {pos = Vector(13555.104492, -946.081726, 634.023682), ang = Angle(6.780344, -10.520297, 0.000000)},
    {pos = Vector(8694.571289, -4823.195801, 652.140930), ang = Angle(0.400345, -93.459991, 0.000000)},
    {pos = Vector(8510.013672, -9049.104492, 642.908264), ang = Angle(11.180354, -143.839966, 0.000000)},
    {pos = Vector(1117.237671, -7396.788086, 641.518311), ang = Angle(-2.899647, -174.199936, 0.000000)},
    {pos = Vector(-3560.072998, -6392.807617, 640.015930), ang = Angle(2.160353, 150.819962, 0.000000)},
    {pos = Vector(-8209.355469, -2536.942383, 646.270020), ang = Angle(3.920354, 102.639862, 0.000000)},
    {pos = Vector(-7312.624512, 4939.358398, 667.799438), ang = Angle(3.040354, 79.759804, 0.000000)},
    {pos = Vector(-6870.493164, 11190.271484, 406.339844), ang = Angle(5.900353, 93.399872, 0.000000)},
    {pos = Vector(-6139.575684, 14378.451172, 456.877289), ang = Angle(2.820352, 86.799835, 0.000000)}
}

-- Find random valid positions on the map
local function FindRandomPlacesOnMap(count)
    local positions = {}
    local attempts = 0
    local maxAttempts = count * 5 -- Try 5x more attempts than needed
    
    while #positions < count and attempts < maxAttempts do
        attempts = attempts + 1
        
        local pos = Vector(math.Rand(-14000, 14000), math.Rand(-14000, 14000), 5000)
        local tr = util.TraceLine({
            start = pos,
            endpos = pos - Vector(0, 0, 10000),
            mask = MASK_SOLID_BRUSHONLY
        })

        if tr.Hit and tr.HitPos.z > 50 and tr.HitPos.z < 1000 then 
            table.insert(positions, tr.HitPos + Vector(0, 0, 10))
        end
    end
    
    return positions
end

-- Spawn rocks/ore nodes
function SpawningSystem.SpawnRocks()
    local positions = FindRandomPlacesOnMap(RANDOM_SPAWNS)
    local spawnedCount = 0
    
    for _, pos in pairs(positions) do
        if not isvector(pos) then continue end
        
        local ent = ents.Create("rust_ore")
        if IsValid(ent) then
            ent:SetPos(pos)
            ent:SetSkin(math.random(1, 3))
            ent:Spawn()
            ent:Activate()
            ent:DropToFloor()
            spawnedCount = spawnedCount + 1
        end
    end
    
    Logger("[Spawning] Spawned " .. spawnedCount .. " rocks")
end

-- Spawn chickens
function SpawningSystem.SpawnChickens()
    local positions = FindRandomPlacesOnMap(RANDOM_SPAWNS)
    local spawnedCount = 0
    
    for _, pos in pairs(positions) do
        local ent = ents.Create("npc_vj_f_killerchicken")
        if IsValid(ent) then
            ent:SetPos(pos)
            ent:Spawn()
            ent:Activate()
            ent:SetModelScale(1.75, 0)
            ent:DropToFloor()
            spawnedCount = spawnedCount + 1
        end
    end
    
    Logger("[Spawning] Spawned " .. spawnedCount .. " chickens")
end

-- Spawn hemp plants
function SpawningSystem.SpawnHemp()
    local positions = FindRandomPlacesOnMap(RANDOM_SPAWNS)
    local spawnedCount = 0
    local pairCount = 0
    
    for _, pos in ipairs(positions) do
        -- Spawn first hemp plant
        local ent = ents.Create("rust_map_hemp")
        if IsValid(ent) then
            ent:SetPos(pos)
            ent:Spawn()
            ent:Activate()
            ent:DropToFloor()
            spawnedCount = spawnedCount + 1
            
            -- 30% chance to spawn second hemp plant nearby
            if math.random(1, 100) <= 30 then
                local offset = Vector(math.random(-80, 80), math.random(-80, 80), 0)
                local nearbyPos = pos + offset
                
                local ent2 = ents.Create("rust_map_hemp")
                if IsValid(ent2) then
                    ent2:SetPos(nearbyPos)
                    ent2:Spawn()
                    ent2:Activate()
                    ent2:DropToFloor()
                    spawnedCount = spawnedCount + 1
                    pairCount = pairCount + 1
                end
            end
        end
    end
    
    Logger("[Spawning] Spawned " .. spawnedCount .. " hemp plants (" .. pairCount .. " pairs)")
end

-- Spawn roadsigns
function SpawningSystem.SpawnRoadSigns()
    local spawnedCount = 0
    local failedCount = 0
    
    for i, spawn in ipairs(RoadSignSpawns) do
        local roadsign = ents.Create("rust_roadsign")
        if IsValid(roadsign) then
            roadsign:SetPos(spawn.pos)
            roadsign:SetAngles(spawn.ang)
            roadsign:Spawn()
            roadsign:Activate()
            spawnedCount = spawnedCount + 1
        else
            failedCount = failedCount + 1
        end
    end
    
    Logger("[Spawning] Roadsign spawning complete: " .. spawnedCount .. " spawned, " .. failedCount .. " failed")
end

-- Main spawning function
function SpawningSystem.SpawnAll()
    if game.GetMap() ~= "rust_highland_v1_3a" then
        Logger("[Spawning] Wrong map (" .. game.GetMap() .. "), changing to rust_highland_v1_3a")
        game.ConsoleCommand("changelevel rust_highland_v1_3a\n")
        return
    end
    
    Logger("[Spawning] Starting entity spawning on map: " .. game.GetMap())
    
    -- Spawn each type with a small delay between them
    SpawningSystem.SpawnRocks()
    
    timer.Simple(1, function()
        SpawningSystem.SpawnChickens()
    end)
    
    timer.Simple(2, function()
        SpawningSystem.SpawnHemp()
    end)
    
    timer.Simple(3, function()
        SpawningSystem.SpawnRoadSigns()
    end)
    
    timer.Simple(4, function()
        Logger("[Spawning] All entity spawning completed!")
    end)
end

-- Initialize spawning system
hook.Add("InitPostEntity", "gRust.SpawningSystem", function()
    timer.Simple(SPAWN_DELAY, function()
        SpawningSystem.SpawnAll()
    end)
end)

-- Export the system for external use
gRust = gRust or {}
gRust.SpawningSystem = SpawningSystem

-- Add console command for manual spawning (admin only)
concommand.Add("grust_spawn_all", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    SpawningSystem.SpawnAll()
end)

concommand.Add("grust_spawn_roadsigns", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    SpawningSystem.SpawnRoadSigns()
end)

Logger("Spawning system loaded")
