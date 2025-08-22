AddCSLuaFile("shared.lua")
AddCSLuaFile("config.lua")
include("shared.lua")
include("config.lua")
resource.AddWorkshop("3517690325")
local BASE_HOSTNAME = "★ [RU] gRust | Vanilla | Wiped %d days ago | 7 Day Wipe"
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
    local newHostname = string.format(BASE_HOSTNAME, daysSinceWipe)
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
            timer.Simple(0, function()
                UpdateHostname()
                local stats = GetWipeStats()
            end)
        else
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