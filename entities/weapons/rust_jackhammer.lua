DEFINE_BASECLASS("rust_melee")

SWEP.Base               = "rust_melee"



SWEP.ViewModel          = "models/weapons/darky_m/rust/c_jackhammer.mdl"

-- TODO: Port worldmodel

SWEP.WorldModel         = "models/weapons/darky_m/rust/c_jackhammer.mdl"



SWEP.DownPos            = Vector(-0, 0, -3)



SWEP.Damage             = 15



SWEP.Primary.Automatic = true

SWEP.SwingDelay         = 0.1

SWEP.SwingInterval      = 0.2

SWEP.SwingSound         = ""

SWEP.StrikeSound        = "tools/rock_strike_%i.mp3"

SWEP.BypassWeakspot		= true



SWEP.HarvestAmount =

{

	["rust_ore"] = 2,

	["tree"] = 0,

}



function SWEP:PrimaryAttack()

	BaseClass.PrimaryAttack(self)

	

	local pl = self:GetOwner()

	local tr = pl:GetEyeTraceNoCursor()

	if (tr.HitPos:DistToSqr(pl:EyePos()) > 5000) then return end



	local ed = EffectData()

	ed:SetOrigin(tr.HitPos)

	ed:SetEntity(tr.Entity)

	ed:SetNormal(tr.Normal)

	util.Effect("Impact", ed)

end

function SWEP:PrimaryAttack()

end

function SWEP:Throw()

end



function SWEP:Think()

	BaseClass.Think(self)

	if (self:GetOwner():KeyDown(IN_ATTACK)) then

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

		if (!self.LoopSound) then

			self.LoopSound = self:StartLoopingSound("weapons/rust_mp3/jackhammer_loop.wav")

		end

	else

		self:SendWeaponAnim(ACT_VM_IDLE)

		if (self.LoopSound) then

			self:StopLoopingSound(self.LoopSound)

			self.LoopSound = nil

		end

	end

end