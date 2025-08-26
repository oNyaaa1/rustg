AddCSLuaFile()
ENT.Base = "rust_authorizer"
ENT.Bodygroup = 1
ENT.AuthorizeOnDeploy = true
ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/keypad.mdl"
ENT.Deploy.Sound = "keypad.deploy"
ENT.Deploy.Socket = "keypad"
function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/deployable/keypad.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Interact(pl)
    print(pl)
end