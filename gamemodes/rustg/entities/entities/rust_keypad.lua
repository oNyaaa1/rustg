AddCSLuaFile()



ENT.Base = "rust_authorizer"



ENT.Bodygroup = 1

ENT.AuthorizeOnDeploy = true




ENT.Deploy = {}

ENT.Deploy.Model = "models/deployable/keypad.mdl"

ENT.Deploy.Sound = "keypad.deploy"

ENT.Deploy.Socket = "keypad"



function ENT:Initialize()

    self:SetModel("models/deployable/keypad.mdl")



    self:SetMoveType(MOVETYPE_NONE)

    self:SetSolid(SOLID_VPHYSICS)

end



function ENT:Interact(pl)

end