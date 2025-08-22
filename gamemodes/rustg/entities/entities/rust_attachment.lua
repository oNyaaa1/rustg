AddCSLuaFile()

ENT.Base    = "base_anim"
ENT.Type    = "anim"

function ENT:Initialize()

end

function ENT:SetWeapon(wep)
	self.Weapon = wep
end

function ENT:Think()
	if (!IsValid(self.Weapon)) then return end

	local vm = self.Weapon:GetOwner():GetViewModel()
	self:SetPos(vm:LocalToWorld(PosOffset))
	self:SetAngles(vm:LocalToWorldAngles(AngOffset))
end