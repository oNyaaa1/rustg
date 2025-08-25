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

-- Specific spawn positions for chickens
local ChickenSpawns = {Vector(-10086.757812, -1517.123901, 356.723083), Vector(-10238.172852, 3229.971924, 77.139420), Vector(-11358.462891, 6314.304688, 244.818039), Vector(-12388.674805, 3743.877197, -35.847244), Vector(-4437.209961, -3557.703857, 379.447418), Vector(3143.381348, -6675.172363, 616.711182), Vector(8566.035156, -4198.000977, 648.662415), Vector(13396.972656, 115.953125, 548.455688), Vector(11363.718750, 9256.590820, 117.697304)}
local HempSpawns = {Vector(-11058.115234, -6512.728516, 214.830872), Vector(-12056.284180, -5738.638672, 68.120911), Vector(-13522.346680, -3184.525391, 52.638458), Vector(9211.952148, -6645.867676, 665.192566), Vector(9146.557617, -6520.742188, 663.467651), Vector(3965.124023, -3692.874756, 1074.324463), Vector(4169.557617, -3764.491211, 1110.414917), Vector(9592.265625, 4066.606445, 698.195251), Vector(11030.259766, 8594.771484, -7.365372), Vector(10944.160156, 8669.303711, 4.855194), Vector(11363.718750, 9256.590820, 117.697304), Vector(11184.333984, 9180.905273, 115.433807), Vector(11869.405273, 2157.108643, 316.215576), Vector(8410.625000, -2039.801392, 652.791870), Vector(12489.331055, -13450.316406, 23.788017), Vector(13477.965820, -11818.242188, 39.495201)}
local Rocks = {Vector(-3792.029785, -13264.387695, 65.724213), Vector(-4732.778809, -12192.792969, 64.281883), Vector(-6023.077637, -11482.048828, 64.471962), Vector(-6175.088379, -8771.442383, 64.318481), Vector(-8370.460938, -8906.120117, 64.314789), Vector(-7750.162598, -8850.724609, 64.325745), Vector(-6746.119629, -6735.162109, 380.331543), Vector(-7906.496094, -7104.460449, 378.431458), Vector(-12137.454102, -8889.194336, 64.000000), Vector(-13335.008789, -9066.532227, 64.000000), Vector(-13982.030273, -7890.173340, 64.463791), Vector(-13345.028320, -5918.994141, 35.097015), Vector(-12744.553711, -5142.339844, -76.042664), Vector(-11933.133789, -4659.244141, 74.814331), Vector(-11952.909180, -3372.570068, 829.525818), Vector(-11843.196289, -2357.978271, 1290.089355), Vector(-12466.872070, -2715.189941, 966.382324), Vector(-13598.750977, -2917.436279, -36.283661), Vector(-13749.448242, -784.154480, 75.134445), Vector(-13833.723633, 188.831635, 78.870346), Vector(-12736.406250, 84.946991, 214.518463), Vector(-12124.357422, 972.153015, 109.831573), Vector(-11559.940430, 1670.888184, 580.784851), Vector(-11341.621094, 1510.524048, 571.431030), Vector(-11509.252930, 1989.509155, 553.785034), Vector(-12053.763672, 2110.306396, 466.886292), Vector(-13337.833008, 2182.638428, 373.732788), Vector(-13698.062500, 2232.120850, 346.850006), Vector(-13552.906250, 4259.112793, 198.381378), Vector(-13298.310547, 3599.663574, 47.413574), Vector(-11518.709961, 5186.253906, 653.307861), Vector(-11021.034180, 5118.391113, 636.657532), Vector(-11380.618164, 6983.821289, 121.168274), Vector(-11149.829102, 7065.470703, 120.310913), Vector(-10918.248047, 6832.576172, 146.922333), Vector(-11276.931641, 6732.702637, 147.424255), Vector(-13752.251953, 6995.145020, 54.102722), Vector(-12860.452148, 7662.895020, 64.000000), Vector(-12412.913086, 9323.971680, 66.117065), Vector(-13072.476563, 10471.338867, 137.365601), Vector(-12256.421875, 10701.719727, 172.460083), Vector(-12505.175781, 12077.799805, 329.833984), Vector(-12020.638672, 13352.511719, 296.025879), Vector(-12947.544922, 13109.598633, 306.036133), Vector(-13005.170898, 13190.652344, 304.226318), Vector(-13475.166016, 13144.341797, 309.927979), Vector(-10158.509766, 13041.804688, 301.397461), Vector(-9756.407227, 11388.702148, 281.751831), Vector(-9710.455078, 11602.249023, 285.597656), Vector(-8665.368164, 12799.264648, 270.393799), Vector(-7471.099609, 12740.222656, 294.491211), Vector(-7274.795898, 11857.035156, 274.667480), Vector(-6397.540039, 12973.703125, 338.349609), Vector(-5508.079102, 9679.667969, 1016.264282), Vector(-4308.176270, 10948.097656, 928.120850), Vector(-3109.807129, 12161.245117, 43.228271), Vector(616.483032, 13069.073242, -84.261475), Vector(1900.366943, 14126.562500, 2.662720), Vector(4186.648926, 13136.594727, -177.090576), Vector(5168.194336, 13222.214844, -41.343994), Vector(5758.153320, 13245.737305, 20.605713), Vector(3676.581787, 12119.033203, -250.824097), Vector(2816.996094, 10366.689453, -160.387817), Vector(2068.279541, 8406.601563, 269.866211), Vector(1664.959106, 4170.344238, 343.465820), Vector(900.118286, 4511.813477, 434.998535), Vector(-824.082764, 4549.255859, 460.692261), Vector(-938.046265, 3112.515869, 346.073364), Vector(-1389.783203, 2402.519287, 371.245850), Vector(-932.081421, 2264.290771, 402.416138), Vector(-1068.246460, 2746.209961, 376.329712), Vector(-1787.427002, -6188.718262, 518.310059), Vector(-2192.178223, -4340.336914, 453.588623), Vector(2489.278076, -11912.118164, 1177.813232), Vector(1601.207153, -12110.789063, 1064.248169), Vector(890.053101, -11856.150391, 1072.020996), Vector(-1280.326538, -12059.571289, 381.525391), Vector(-2627.217529, -12274.012695, 387.006836), Vector(-4866.550293, -12597.089844, 56.148926), Vector(731.321777, -8660.633789, 1176.302002), Vector(413.713043, -8707.464844, 1093.942627), Vector(88.274612, -8813.232422, 1068.673584),}
hook.Add("InitPostEntity", "SpawnRockyss", function()
    timer.Simple(5, function()
        if game.GetMap() == "rust_highland_v1_3a" then
            -- Spawn rocks at predefined positions
            for k, v in pairs(Rocks) do
                if not isvector(v) then continue end
                local ent = ents.Create("rust_ore")
                if IsValid(ent) then
                    ent:SetPos(v)
                    ent:SetSkin(math.random(1, 3))
                    ent:Spawn()
                    ent:Activate()
                    Logger("[Spawn] Rock at position: " .. tostring(v))
                end
            end

            -- Spawn chickens at specific positions
            for i, pos in ipairs(ChickenSpawns) do
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

            for i, pos in ipairs(HempSpawns) do
                local ent2 = ents.Create("rust_hemp")
                if IsValid(ent2) then
                    ent2:SetPos(pos)
                    ent2:Spawn()
                    ent2:Activate()
                    ent2:DropToFloor()
                    Logger("[Spawn] Hemp at position: " .. tostring(ent2:GetPos()))
                else
                    LoggerErr("[Spawn] Failed to create hemp entity at: " .. tostring(pos))
                end
            end
        end
    end)

    if game.GetMap() ~= "rust_highland_v1_3a" then game.ConsoleCommand("changelevel rust_highland_v1_3a\n") end
end)