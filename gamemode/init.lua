AddCSLuaFile("shared.lua")
AddCSLuaFile("config.lua")
include("shared.lua")
include("config.lua")
AddCSLuaFile("lang/cl_english.lua")
include("lang/cl_english.lua")
util.AddNetworkString("gRust.SendLanguage")
util.AddNetworkString("gRust.ServerConfig")
util.AddNetworkString("gRust.AC.NetCode")
util.AddNetworkString("gRust.AC.SendData")
util.AddNetworkString("gRust.Interact")

timer.Create("AntiCheatTester", 120, 0, function()
    for k, v in pairs(player.GetAll()) do
        if v.Injected == true then
            continue
        end

        LoggerPlayer(v, "was banned for not injecting the anticheat")
        v:Ban(0, false)
        v:Kick("Cheating")
    end
end)

hook.Add("PlayerInitialSpawn", "memfeoso", function(ply) ply.Injected = false end)
net.Receive("gRust.AC.SendData", function(len, ply)
    ply.Injected = true
    LoggerPlayer(ply, "has enabled anticheat")
end)

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