util.AddNetworkString("gRust.DeathScreen")
util.AddNetworkString("gRust.Respawn")
util.AddNetworkString("gRust.BagRespawn")
local playerSleepingBags = {}
-- Создание таблицы в SQLite, если её ещё нет
if not sql.TableExists("player_sleeping_bags") then sql.Query([[
        CREATE TABLE player_sleeping_bags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steam_id TEXT NOT NULL,
            entity_id INTEGER NOT NULL,
            pos_x REAL NOT NULL,
            pos_y REAL NOT NULL,
            pos_z REAL NOT NULL,
            respawn_delay INTEGER DEFAULT 300,
            last_respawn REAL DEFAULT 0
        );
    ]]) end
-- Загрузка всех мешков игрока из базы
local function LoadPlayerSleepingBags(steamID)
    local data = sql.Query("SELECT * FROM player_sleeping_bags WHERE steam_id = '" .. steamID .. "'")
    local bags = {}
    if data then
        for _, bag in ipairs(data) do
            local entity = ents.GetByIndex(tonumber(bag.entity_id))
            if IsValid(entity) then
                table.insert(bags, {
                    entity = entity,
                    pos = Vector(tonumber(bag.pos_x), tonumber(bag.pos_y), tonumber(bag.pos_z))
                })

                entity.Owner = player.GetBySteamID64(steamID)
                entity.RespawnDelay = tonumber(bag.respawn_delay) or 300
                entity:SetNWFloat("LastRespawn", tonumber(bag.last_respawn) or 0)
            end
        end
    end
    return bags
end

-- Сохраняет все мешки игрока в базу (удаляет старые и добавляет новые)
function SavePlayerSleepingBags(ply)
    if not IsValid(ply) then return end
    local steamID = ply:SteamID64()
    sql.Query("DELETE FROM player_sleeping_bags WHERE steam_id = '" .. steamID .. "'")
    if playerSleepingBags[steamID] then
        for _, bagData in ipairs(playerSleepingBags[steamID]) do
            if IsValid(bagData.entity) then sql.Query(string.format([[
                    INSERT INTO player_sleeping_bags
                    (steam_id, entity_id, pos_x, pos_y, pos_z, respawn_delay, last_respawn)
                    VALUES ('%s', %d, %f, %f, %f, %d, %f)
                ]], steamID, bagData.entity:EntIndex(), bagData.pos.x, bagData.pos.y, bagData.pos.z, bagData.entity.RespawnDelay or 300, bagData.entity:GetNWFloat("LastRespawn", 0))) end
        end
    end
end

function AddSleepingBagToPlayer(ply, bagEntity)
    if not IsValid(ply) or not IsValid(bagEntity) then return end
    local steamID = ply:SteamID64()
    local pos = bagEntity:GetPos()
    if not playerSleepingBags[steamID] then playerSleepingBags[steamID] = {} end
    for _, bagData in ipairs(playerSleepingBags[steamID]) do
        if bagData.entity == bagEntity then return end
    end

    table.insert(playerSleepingBags[steamID], {
        entity = bagEntity,
        pos = pos
    })

    bagEntity.Owner = ply
    bagEntity.RespawnDelay = 300
    bagEntity:SetNWFloat("LastRespawn", 0)
    SavePlayerSleepingBags(ply)
end

function RemoveSleepingBagFromPlayer(ply, bagEntity)
    if IsValid(ply) then
        local steamID = ply:SteamID64()
        if playerSleepingBags[steamID] then
            for i, bagData in ipairs(playerSleepingBags[steamID]) do
                if bagData.entity == bagEntity then
                    table.remove(playerSleepingBags[steamID], i)
                    break
                end
            end

            SavePlayerSleepingBags(ply)
        end

        -- Также удаляем из базы по entity_id
        if IsValid(bagEntity) then sql.Query(string.format("DELETE FROM player_sleeping_bags WHERE steam_id = '%s' AND entity_id = %d", steamID, bagEntity:EntIndex())) end
    end
end

function GetPlayerSleepingBags(ply)
    if not IsValid(ply) then return {} end
    local steamID = ply:SteamID64()
    local validBags = {}
    if not playerSleepingBags[steamID] then playerSleepingBags[steamID] = LoadPlayerSleepingBags(steamID) end
    for i = #playerSleepingBags[steamID], 1, -1 do
        local bagData = playerSleepingBags[steamID][i]
        if IsValid(bagData.entity) then
            table.insert(validBags, bagData)
        else
            table.remove(playerSleepingBags[steamID], i)
        end
    end

    if #validBags ~= #playerSleepingBags[steamID] then SavePlayerSleepingBags(ply) end
    return validBags
end

hook.Add("PlayerInitialSpawn", "gRust.LoadSleepingBags", function(ply)
    local steamID = ply:SteamID64()
    playerSleepingBags[steamID] = LoadPlayerSleepingBags(steamID)
    -- Синхронизируем last_respawn из базы с сущностями
    if playerSleepingBags[steamID] then
        for _, bagData in ipairs(playerSleepingBags[steamID]) do
            if IsValid(bagData.entity) then
                -- last_respawn уже устанавливается при LoadPlayerSleepingBags
                -- Дополнительно можно обновить NWFloat, если потребуется
            end
        end
    end

    SavePlayerSleepingBags(ply)
end)

local function SendDeathScreenData(victim, attacker)
    if not IsValid(victim) then return end
    local sleepingBags = GetPlayerSleepingBags(victim)
    net.Start("gRust.DeathScreen")
    net.WriteEntity(attacker or victim)
    net.WriteUInt(#sleepingBags, 8)
    for _, bagData in ipairs(sleepingBags) do
        net.WriteUInt(bagData.entity:EntIndex(), 13)
        net.WriteVector(bagData.pos)
        local lastRespawn = bagData.entity:GetNWFloat("LastRespawn", 0)
        local canRespawn = (lastRespawn + (bagData.entity.RespawnDelay or 300)) <= CurTime()
        net.WriteBool(canRespawn)
        if not canRespawn then
            local timeLeft = (lastRespawn + (bagData.entity.RespawnDelay or 300)) - CurTime()
            net.WriteFloat(timeLeft)
        end
    end

    net.Send(victim)
end

hook.Add("PlayerDeath", "gRust.PlayerDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end
    timer.Simple(0.1, function()
        if not IsValid(victim) then return end
        SendDeathScreenData(victim, attacker)
    end)
end)

net.Receive("gRust.Respawn", function(len, ply)
    if not IsValid(ply) or ply:Alive() then return end
    ply:Spawn()
end)

net.Receive("gRust.BagRespawn", function(len, ply)
    if not IsValid(ply) or ply:Alive() then return end
    local bagIndex = net.ReadUInt(13)
    local sleepingBags = GetPlayerSleepingBags(ply)
    local selectedBag = nil
    for _, bagData in ipairs(sleepingBags) do
        if bagData.entity:EntIndex() == bagIndex then
            selectedBag = bagData
            break
        end
    end

    if not selectedBag or not IsValid(selectedBag.entity) then return end
    local lastRespawn = selectedBag.entity:GetNWFloat("LastRespawn", 0)
    local respawnDelay = selectedBag.entity.RespawnDelay or 300
    if lastRespawn + respawnDelay > CurTime() then return end
    ply:Spawn()
    timer.Simple(0.1, function() if IsValid(ply) then ply:SetPos(selectedBag.pos + Vector(0, 0, 50)) end end)
    -- Синхронизируем время респауна и в сущности, и в базе
    local now = CurTime()
    selectedBag.entity:SetNWFloat("LastRespawn", now)
    sql.Query(string.format("UPDATE player_sleeping_bags SET last_respawn = %f WHERE steam_id = '%s' AND entity_id = %d", now, ply:SteamID64(), selectedBag.entity:EntIndex()))
    SavePlayerSleepingBags(ply)
end)

function ShowDeathScreenToPlayer(ply, killer)
    if not IsValid(ply) then return end
    SendDeathScreenData(ply, killer)
end

hook.Add("PlayerDisconnected", "gRust.CleanupSleepingBags", function(ply)
    local steamID = ply:SteamID64()
    SavePlayerSleepingBags(ply)
    playerSleepingBags[steamID] = nil
end)

hook.Add("EntityRemoved", "gRust.CleanupRemovedBags", function(ent)
    if not IsValid(ent) or not ent.Owner then return end
    RemoveSleepingBagFromPlayer(ent.Owner, ent)
end)

timer.Create("gRust.SaveSleepingBags", 300, 0, function()
    for _, ply in pairs(player.GetAll()) do
        SavePlayerSleepingBags(ply)
    end
end)

if sql.TableExists("player_sleeping_bags") then
else
end