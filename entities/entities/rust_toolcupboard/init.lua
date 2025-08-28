AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
DEFINE_BASECLASS("rust_storage")
if SERVER then util.AddNetworkString("gRust.Authorize") end
ENT.InventorySlots = 24
ENT.InventoryName = "TOOL CUPBOARD"
ENT.Base = "rust_storage"
ENT.ShowHealth = true
ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/tool_cupboard.mdl"
ENT.Deploy.Sound = "deploy/tool_cupboard_deploy.wav"
ENT.Deploy.OnDeploy = function(pl, ent, tr)
    ent:Authorize(pl)
    ent.TC_Owner = pl
end

ENT.Pickup = "tool_cupboard"
-- Authorized players
function ENT:Initialize()
    BaseClass.Initialize(self)
    self.AuthorizedPlayers = {}
end

function ENT:Authorize(ply)
    if not IsValid(ply) then return end
    local sid = ply:SteamID64()
    if not table.HasValue(self.AuthorizedPlayers, sid) then
        table.insert(self.AuthorizedPlayers, sid)
        ply:ChatPrint("You are now authorized on this Tool Cupboard.")
    end
end

net.Receive("gRust.Authorize", function(len, ply)
    local ent = ply:GetEyeTrace().Entity
    if IsValid(ent) and ent:GetClass() == "rust_toolcupboard" then
        ent:Authorize(ply)
        ent:SetBodygroup(2, 1)
    end
end)

function ENT:IsAuthorized(ply)
    if not IsValid(ply) then return false end
    return table.HasValue(self.AuthorizedPlayers, ply:SteamID64())
end

function ENT:ClearAuthorized()
    self.AuthorizedPlayers = {}
end

-- Network upkeep values
function ENT:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar("Int", 0, "WoodUpkeep")
    self:NetworkVar("Int", 1, "StoneUpkeep")
    self:NetworkVar("Int", 2, "MetalUpkeep")
    self:NetworkVar("Int", 3, "HQUpkeep")
    self:NetworkVar("String", 0, "ProtectedFor")
    self:NetworkVar("Bool", 0, "Opened") -- optional
    self:NetworkVar("Bool", 1, "Locked") -- this controls whether TC locks the door
end

-- Example upkeep tick (runs every 60 seconds)
function ENT:Think()
    if not self.NextUpkeepCheck or self.NextUpkeepCheck < CurTime() then
        self.NextUpkeepCheck = CurTime() + 60
        self:CalculateUpkeep()
    end

    self:NextThink(CurTime() + 1)
    return true
end

function ENT:CalculateUpkeep()
    -- Placeholder logic: you’d calculate based on building pieces owned
    self:SetWoodUpkeep(1000)
    self:SetStoneUpkeep(500)
    self:SetMetalUpkeep(250)
    self:SetHQUpkeep(50)
    self:SetProtectedFor("24h") -- show in UI
end

-- Networking for clear/deauthorize
util.AddNetworkString("gRust.ClearAuthlist")
util.AddNetworkString("gRust.Deauthorize")
net.Receive("gRust.ClearAuthlist", function(len, ply)
    local ent = ply:GetEyeTraceNoCursor().Entity
    if IsValid(ent) and ent:GetClass() == "rust_toolcupboard" then
        if ent:IsAuthorized(ply) then
            ent:ClearAuthorized()
            ply:ChatPrint("Authorized list cleared.")
        end
    end
end)

net.Receive("gRust.Deauthorize", function(len, ply)
    local ent = ply:GetEyeTraceNoCursor().Entity
    if IsValid(ent) and ent:GetClass() == "rust_toolcupboard" then
        local sid = ply:SteamID64()
        for i, v in ipairs(ent.AuthorizedPlayers) do
            if v == sid then
                table.remove(ent.AuthorizedPlayers, i)
                ply:ChatPrint("You have been deauthorized from this Tool Cupboard.")
                break
            end
        end
    end
end)