util.AddNetworkString("gRust.NetReady")
net.Receive("gRust.NetReady", function(len, ply)
    if IsValid(ply) then
        ply.Hunger = 200
        ply.Thirst = 200
        local randomHealth = math.random(50, 60)
        ply:SetHealth(randomHealth)
        ply:SyncMetabolism()
        ply:CreateInventory(36)
        local sleepingBag = FindPlayerSleepingBag(ply)
        if IsValid(sleepingBag) then
            local bagPos = sleepingBag:GetPos()
            ply:SetPos(bagPos + Vector(0, 0, 50))
            ply:SetEyeAngles(Angle(0, 0, 0))
            timer.Simple(0.1, function() if IsValid(ply) and IsValid(sleepingBag) then TransferSleepingBagToPlayer(ply, sleepingBag) end end)
        else
            ply:GiveItem("rock", 1)
            ply:Give("rust_hands")
            ply:SelectWeapon("rust_hands")
        end
    end
end)

local models = {"models/player/Group01/male_01.mdl", "models/player/Group01/male_02.mdl", "models/player/Group01/male_03.mdl", "models/player/Group01/male_04.mdl", "models/player/Group01/male_05.mdl", "models/player/Group01/male_06.mdl", "models/player/Group01/male_07.mdl", "models/player/Group01/male_08.mdl", "models/player/Group01/male_09.mdl",}
local function InitializeDatabase()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS grust_player_models (
            steamid TEXT PRIMARY KEY,
            model TEXT NOT NULL
        )
    ]])
end

local function LoadPlayerModel(steamID)
    local query = sql.QueryValue("SELECT model FROM grust_player_models WHERE steamid = " .. sql.SQLStr(steamID))
    return query
end

local function SavePlayerModel(steamID, model)
    local query = sql.Query("INSERT OR REPLACE INTO grust_player_models (steamid, model) VALUES (" .. sql.SQLStr(steamID) .. ", " .. sql.SQLStr(model) .. ")")
    return true
end

local function LoadAllPlayerModels()
    local query = sql.Query("SELECT steamid, model FROM grust_player_models")
    local result = {}
    if query then
        for i = 1, #query do
            result[query[i].steamid] = query[i].model
        end
    end
    return result
end

InitializeDatabase()
local PLAYER = FindMetaTable("Player")
function PLAYER:CanInteractWith(ent)
    if not IsValid(ent) or not IsValid(self) then return false end
    if self:GetPos():Distance(ent:GetPos()) > 150 then return false end
    return true
end

function PLAYER:GetAssignedModel()
    local steamID = self:SteamID()
    local savedModel = LoadPlayerModel(steamID)
    if savedModel then
        return savedModel
    else
        local model = models[math.random(#models)]
        return model
    end
end

hook.Add("PlayerSpawn", "gRust.AssignRandomModel", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then
            local model = ply:GetAssignedModel()
            ply:SetModel(model)
        end
    end)
end)

hook.Add("PlayerInitialSpawn", "gRust.InitialModelAssign", function(ply) timer.Simple(0, function() if IsValid(ply) then ply:GetAssignedModel() end end) end)
concommand.Add("spawnent", function(ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
    local entityClass = args[1] or "prop_physics"
    local maxDistance = tonumber(args[2]) or 500
    local trace = ply:GetEyeTrace()
    local spawnPos = trace.HitPos
    local distance = ply:GetPos():Distance(spawnPos)
    if distance > maxDistance then return end
    local entity = ents.Create(entityClass)
    if IsValid(entity) then
        entity:SetPos(spawnPos + trace.HitNormal * 5)
        entity:SetAngles(ply:GetAngles())
        entity:Spawn()
        local phys = entity:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
    else
    end
end)
