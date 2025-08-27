AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/deployable/key_lock.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    
    self.Authorized = {}
    self.ManualAuthorization = true
    self.AuthorizeOnDeploy = true
end

function ENT:SetAuthorizeEntity(ent)
    self.AuthorizeEntity = ent
end

function ENT:GetAuthorizeEntity()
    return self.AuthorizeEntity
end

function ENT:Authorize(pl)
    if not IsValid(pl) then return end
    self.Authorized[pl:SteamID()] = true
end

function ENT:Unauthorize(pl)
    if not IsValid(pl) then return end
    self.Authorized[pl:SteamID()] = nil
end

function ENT:IsAuthorized(pl)
    if not IsValid(pl) then return false end
    return self.Authorized[pl:SteamID()] == true
end

function ENT:ClearAuthorization()
    self.Authorized = {}
end

function ENT:OnRemove()
    local parent = self:GetParent()
    if IsValid(parent) then
        parent:SetNW2Bool("gRust.InUse", false)
        if parent.SetBodygroup then
            parent:SetBodygroup(2, 0)
        end
        if parent.ClearAuthorization then
            parent:ClearAuthorization()
        end
    end
end

function ENT:Interact(pl)
    if not IsValid(pl) then return end
    
    local parent = self:GetParent()
    if not IsValid(parent) then return end
    
    if parent.Interact then
        parent:Interact(pl)
    end
end
