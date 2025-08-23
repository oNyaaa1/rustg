
AddCSLuaFile()



ENT.Base = "rust_droppeditem"



AccessorFunc(ENT, "Fuse", "Fuse", FORCE_NUMBER)

AccessorFunc(ENT, "Stick", "Stick", FORCE_BOOL)



function ENT:Initialize()

	if (CLIENT) then return end



	self:SetModel("models/environment/misc/loot_bag.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)

	self:SetSolid(SOLID_VPHYSICS)



	local phys = self:GetPhysicsObject()

	if (IsValid(phys)) then

		phys:Wake()

		phys:SetMass(4)

	end



	self.Fuse = nil



	timer.Simple(120, function()

		if (IsValid(self)) then

			self:Remove()

		end

	end)

end



function ENT:Throw(direction, force)

	if (CLIENT) then return end



	local phys = self:GetPhysicsObject()

	if (!IsValid(phys)) then return end



	--phys:ApplyForceCenter(direction * force)

	phys:SetVelocityInstantaneous(direction * force)

end



function ENT:FuseCallback()

end



function ENT:PhysicsCollide(coldata, collider)

	if (self:GetStick() and !self.Stuck) then

		self:SetMoveType(MOVETYPE_NONE)



		local tr = {}

		tr.start = self:GetPos()

		tr.endpos = self:GetPos() + self:GetForward() * 50

		tr.filter = self

		debugoverlay.Text(tr.start, "Start", 25, false)

		debugoverlay.Line(tr.start, tr.endpos, 25, Color(255, 0, 0), true)

		debugoverlay.Text(tr.endpos, "End", 25, false)

		tr = util.TraceLine(tr)

		self.Stuck = true



		self:SetPos(tr.HitPos)

		self:SetAngles(tr.HitNormal:Angle() + Angle(90, 0, 0))

	end

end



function ENT:Think()

	if (self:GetFuse() and CurTime() > self:GetFuse()) then

		self:FuseCallback()

		self:Remove()

	end

end



function ENT:Draw()

	self:DrawModel()

end

