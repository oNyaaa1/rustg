AddCSLuaFile()
ENT.Base = "rust_authorizer"
ENT.Bodygroup = 2
ENT.AuthorizeOnDeploy = true
ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/key_lock.mdl"
ENT.Deploy.Sound = "keypad.deploy"
ENT.Deploy.Socket = "lock"
function ENT:Initialize()
    self:SetModel("models/deployable/key_lock.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
end