AddCSLuaFile("shared.lua")
AddCSLuaFile("config.lua")
include("shared.lua")
include("config.lua")
AddCSLuaFile("lang/cl_english.lua")
include("lang/cl_english.lua")
util.AddNetworkString("gRust.SendLanguage")
util.AddNetworkString("gRust.ServerConfig")
local oldnets = net.Start
function net.Start(str, bool)
    if str == "vj_welcome" then return end
    return oldnets(str, bool)
end

local HOSTNAME_FILE = "grust/hostname.txt"
local BASE_HOSTNAME = "★ [RU] gRust | Wiped %d days ago | 7 Day Wipe"
local function EnsureGrustDir()
    if file and file.CreateDir then if not file.Exists("grust", "DATA") then file.CreateDir("grust") end end
end

concommand.Add("tele_rec", function(ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    ply:SetPos(Vector(8920.770508, -4912.804688, 820.12054))
end)

EnsureGrustDir()
local function LoadHostnameTemplate()
    if file and file.Exists and file.Read and file.Write then
        -- Check if file exists, if not create it with default content
        if not file.Exists(HOSTNAME_FILE, "DATA") then
            file.Write(HOSTNAME_FILE, BASE_HOSTNAME)
            Logger("Created hostname file with default template")
        end

        -- Read the file content
        local content = file.Read(HOSTNAME_FILE, "DATA")
        if content and string.Trim(content) ~= "" then
            Logger("Loaded hostname template from file: " .. string.Trim(content))
            return string.Trim(content)
        end
    end

    Logger("Using default hostname template")
    return BASE_HOSTNAME
end

local TABLE_NAME = "wipe_data"
local function InitializeDatabase()
    local query = string.format([[
        CREATE TABLE IF NOT EXISTS %s (
            id INTEGER PRIMARY KEY,
            wipe_time INTEGER NOT NULL,
            created_at INTEGER DEFAULT (strftime('%%s', 'now'))
        )
    ]], TABLE_NAME)
    local result = sql.Query(query)
    if result == false then return false end
    return true
end

local function SaveWipeDate()
    local currentTime = os.time()
    local deleteQuery = string.format("DELETE FROM %s", TABLE_NAME)
    local deleteResult = sql.Query(deleteQuery)
    if deleteResult == false then return false end
    local insertQuery = string.format([[
        INSERT INTO %s (wipe_time) VALUES (%d)
    ]], TABLE_NAME, currentTime)
    local insertResult = sql.Query(insertQuery)
    if insertResult == false then return false end
    return true
end

local function LoadWipeDate()
    local query = string.format("SELECT wipe_time FROM %s ORDER BY id DESC LIMIT 1", TABLE_NAME)
    local result = sql.QueryValue(query)
    if result == false then
        if SaveWipeDate() then
            return os.time()
        else
            return os.time()
        end
    elseif result == nil then
        if SaveWipeDate() then
            return os.time()
        else
            return os.time()
        end
    else
        local wipeTime = tonumber(result)
        if wipeTime and wipeTime > 0 then
            return wipeTime
        else
            if SaveWipeDate() then
                return os.time()
            else
                return os.time()
            end
        end
    end
end

local function GetDaysSinceWipe()
    local wipeTime = LoadWipeDate()
    local currentTime = os.time()
    local daysDiff = math.floor((currentTime - wipeTime) / 86400) + 1
    return math.max(1, daysDiff)
end

local function UpdateHostname()
    local daysSinceWipe = GetDaysSinceWipe()
    local hostnameTemplate = LoadHostnameTemplate()
    local newHostname = string.format(hostnameTemplate, daysSinceWipe)
    RunConsoleCommand("hostname", newHostname)
end

local function GetWipeStats()
    local countQuery = string.format("SELECT COUNT(*) FROM %s", TABLE_NAME)
    local count = sql.QueryValue(countQuery) or 0
    local lastQuery = string.format([[
        SELECT wipe_time, created_at FROM %s 
        ORDER BY id DESC LIMIT 1
    ]], TABLE_NAME)
    local lastResult = sql.Query(lastQuery)
    if lastResult and lastResult[1] then
        return {
            total_wipes = tonumber(count),
            last_wipe_time = tonumber(lastResult[1].wipe_time),
            record_created = tonumber(lastResult[1].created_at)
        }
    end
    return {
        total_wipes = tonumber(count),
        last_wipe_time = os.time(),
        record_created = os.time()
    }
end

hook.Add("InitPostEntity", "WipeStart", function()
    timer.Simple(2, function()
        if InitializeDatabase() then
            UpdateHostname()
            local stats = GetWipeStats()
        end
    end)
end)

timer.Create("WipeDailyUpdate", 86400, 0, function() UpdateHostname() end)
timer.Create("WipeHourlyCheck", 3600, 0, function()
    local currentDays = GetDaysSinceWipe()
    local currentHostname = GetConVar("hostname"):GetString()
    if not string.find(currentHostname, tostring(currentDays)) then UpdateHostname() end
end)

timer.Create("WipeMidnightUpdate", 60, 0, function()
    local currentTime = os.date("*t")
    if currentTime.hour == 0 and currentTime.min == 0 then UpdateHostname() end
end)

concommand.Add("!wipe", function(ply)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    local weapon = {}
    for _, pl in ipairs(player.GetAll()) do
        for _, wep in ipairs(pl:GetWeapons()) do
            if IsValid(wep) then
                weapon[wep] = true
                local vm = pl:GetViewModel()
                if IsValid(vm) then weapon[vm] = true end
                local hands = pl:GetHands()
                if IsValid(hands) then weapon[hands] = true end
            end
        end
    end

    local removedCount = 0
    for _, ent in pairs(ents.GetAll()) do
        if IsValid(ent) and not ent:IsPlayer() and not ent:IsWorld() and not ent:CreatedByMap() and not weapon[ent] then
            ent:Remove()
            removedCount = removedCount + 1
        end
    end

    if SaveWipeDate() then
        timer.Simple(1, UpdateHostname)
        local stats = GetWipeStats()
    else
    end
end)

local function FindRandomPlacesOnMap(amy)
    local positions = {}
    for i = 1, amy do
        local pos = Vector(math.Rand(-14000, 14000), math.Rand(-14000, 14000), 5000)
        local tr = util.TraceLine({
            start = pos,
            endpos = pos - Vector(0, 0, 10000),
            mask = MASK_SOLID_BRUSHONLY
        })

        if tr.Hit and tr.HitPos.z > 50 and tr.HitPos.z < 1000 then table.insert(positions, tr.HitPos + Vector(0, 0, 10)) end
    end
    return positions
end

hook.Add("InitPostEntity", "SpawnRockyss", function()
    timer.Simple(5, function()
        if game.GetMap() == "rust_highland_v1_3a" then
            -- Spawn rocks at predefined positions
            local rnd = FindRandomPlacesOnMap(150)
            for k, v in pairs(rnd) do
                if not isvector(v) then continue end
                local ent = ents.Create("rust_ore")
                if IsValid(ent) then
                    ent:SetPos(v)
                    ent:SetSkin(math.random(1, 3))
                    ent:Spawn()
                    ent:Activate()
                    ent:DropToFloor()
                    Logger("[Spawn] Rock at position: " .. tostring(v))
                end
            end

            -- Spawn chickens at specific positions
            local rnd = FindRandomPlacesOnMap(150)
            for i, pos in pairs(rnd) do
                --for i, pos in ipairs(ChickenSpawns) do
                local ent = ents.Create("npc_vj_f_killerchicken")
                if IsValid(ent) then
                    ent:SetPos(pos)
                    ent:Spawn()
                    ent:Activate()
                    ent:SetModelScale(1.75, 0) -- Scale the chicken a bit
                    ent:DropToFloor()
                    Logger("[Spawn] Chicken at position: " .. tostring(ent:GetPos()))
                else
                    LoggerErr("[Spawn] Failed to create chicken entity at: " .. tostring(pos))
                end
            end
            local rnd = FindRandomPlacesOnMap(150)
            for i, pos in ipairs(rnd) do // ipairs(HempSpawns) do
                -- Spawn first hemp plant
                local ent2 = ents.Create("rust_map_hemp")
                if IsValid(ent2) then
                    ent2:SetPos(pos)
                    ent2:Spawn()
                    ent2:Activate()
                    ent2:DropToFloor()
                    Logger("[Spawn] Hemp at position: " .. tostring(ent2:GetPos()))
                    
                    -- 30% chance to spawn second hemp plant nearby
                    if math.random(1, 100) <= 30 then
                        local offset = Vector(math.random(-80, 80), math.random(-80, 80), 0)
                        local nearbyPos = pos + offset
                        
                        local ent3 = ents.Create("rust_map_hemp")
                        if IsValid(ent3) then
                            ent3:SetPos(nearbyPos)
                            ent3:Spawn()
                            ent3:Activate()
                            ent3:DropToFloor()
                            Logger("[Spawn] Hemp pair at position: " .. tostring(ent3:GetPos()))
                        end
                    end
                else
                    LoggerErr("[Spawn] Failed to create hemp entity at: " .. tostring(pos))
                end
            end
            
            -- Spawn roadsigns at specific positions
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
            
            for i, spawn in ipairs(RoadSignSpawns) do
                local roadsign = ents.Create("rust_roadsign")
                if IsValid(roadsign) then
                    roadsign:SetPos(spawn.pos)
                    roadsign:SetAngles(spawn.ang)
                    roadsign:Spawn()
                    roadsign:Activate()
                    Logger("[Spawn] Roadsign at position: " .. tostring(roadsign:GetPos()))
                else
                    LoggerErr("[Spawn] Failed to create roadsign entity at: " .. tostring(spawn.pos))
                end
            end
        end
    end)

    if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end
end)