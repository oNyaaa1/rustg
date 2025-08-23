include("shared.lua")

SWEP.UseHands       = true
SWEP.SwayScale      = -0.75
SWEP.BobScale       = 0

SWEP.DownSpeed = 0.1
function SWEP:UpdateDown()
	local pl = self:GetOwner()

	self.DownProgress = self.DownProgress or 0

	if (pl:IsSprinting() and pl.CanSprint and pl:GetVelocity():LengthSqr() > pl:GetWalkSpeed()^2) then
		self.DownProgress = Lerp(
			FrameTime() / self.DownSpeed,
			self.DownProgress,
			1
		)

		self.WeaponDown = true
	else
		self.DownProgress = Lerp(
			FrameTime() / self.DownSpeed,
			self.DownProgress,
			0
		)

		self.WeaponDown = false
	end
end

function SWEP:DoWeaponSway(pos, ang)
	local pl = self:GetOwner()

	return pos, ang
end

SWEP.WeaponBobScale = 1
SWEP.WeaponBobSpeed = 12.5
function SWEP:DoWeaponBob(pos, ang, intensity)
	local pl = self:GetOwner()
	
	self.BobProgress = self.BobProgress or 0
	self.BobProgress = self.BobProgress * self.WeaponBobScale

	local Velocity = pl:GetVelocity():Length()
	if (pl:GetVelocity() ~= Vector()) then
		local Mul = Velocity / pl:GetWalkSpeed() * 0.5
		if (pl:IsSprinting() and pl.CanSprint and Velocity > pl:GetWalkSpeed()) then
			Mul = 1
		end

		local Forward   = ang:Forward()
		local Right     = ang:Right()
		local Up        = ang:Up()

		if (!pl:IsOnGround()) then
			self.BobProgress = Lerp(0.1, self.BobProgress, 0)
		else
			self.BobProgress = Lerp(0.1, self.BobProgress, 1)
		end

		local Speed = self.WeaponBobSpeed
		ang:RotateAroundAxis(ang:Up(), math.sin(SysTime() * Speed) * (2 * Mul) * self.BobProgress)
		ang:RotateAroundAxis(ang:Forward(), math.sin(SysTime() * Speed) * (3 * Mul) * self.BobProgress)
	else
		self.BobProgress = Lerp(0.1, self.BobProgress, 0)
	end

	return pos, ang
end

function SWEP:ModifyViewModel(pos, ang)
	return pos, ang
end

function SWEP:GetViewModelPosition(pos, ang)
	--
	-- Vars
	--

	local pl = self:GetOwner()
	local Forward   = ang:Forward()
	local Right     = ang:Right()
	local Up        = ang:Up()

	--
	-- Hold down
	--

	self:UpdateDown()
	
	local Down = self.DownProgress
	pos = pos + (Forward * self.DownPos.x) * Down
	pos = pos + (Right * self.DownPos.y) * Down
	pos = pos + (Up * self.DownPos.z) * Down

	ang:RotateAroundAxis(ang:Right(), self.DownAng.x * Down)
	ang:RotateAroundAxis(ang:Forward(), self.DownAng.y * Down)
	ang:RotateAroundAxis(ang:Up(), self.DownAng.z * Down)

	pos = pos + (Forward * self.VMPos.x)
	pos = pos + (Right * self.VMPos.y)
	pos = pos + (Up * self.VMPos.z)

	--
	-- Crouch close thing
	--

	do
		local EyeAng = pl:EyeAngles()

		self.CrouchProgress = self.CrouchProgress or 0
		if (pl:KeyDown(IN_DUCK)) then
			self.CrouchProgress = Lerp(0.075, self.CrouchProgress, 1)
		else
			self.CrouchProgress = Lerp(0.075, self.CrouchProgress, 0)
		end

		pos = pos - (Forward * (math.max(0, EyeAng.x) / 90) * 10) * self.CrouchProgress
	end

	pos, ang = self:DoWeaponSway(pos, ang)
	pos, ang = self:DoWeaponBob(pos, ang)

	return self:ModifyViewModel(pos, ang)
end