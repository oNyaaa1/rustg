AddCSLuaFile()



ENT.Base 			= "base_nextbot"

ENT.Spawnable		= true

/*



function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "ActiveWeapon" )

end



function ENT:Give(wepname)

	if CLIENT then return end

	if self:GetActiveLuaWeapon():IsValid() then self:GetActiveLuaWeapon():Remove() end



	local wep = ents.Create(wepname)

	

	if IsValid(wep) then

		wep:SetPos(self:GetPos())

		wep:SetOwner(self)

		wep:Spawn()

		wep:Activate()

		return self:SetupWeapon(wep)

	end

end



function ENT:GetActiveLuaWeapon()

	return self.m_ActualWeapon or NULL

end



function ENT:SetupWeapon(wep)

	if !IsValid(wep) then return end



	self:SetActiveWeapon(wep)



	self.m_ActualWeapon = wep



	local actwep = self:GetActiveLuaWeapon()

	

	wep:SetVelocity(vector_origin)

	wep:RemoveSolidFlags(FSOLID_TRIGGER)

	wep:SetOwner(self)

	wep:RemoveEffects(EF_ITEM_BLINK)

	wep:PhysicsDestroy()

	

	wep:SetParent(self)

	wep:SetMoveType(MOVETYPE_NONE)

	wep:AddEffects(EF_BONEMERGE)

	wep:AddSolidFlags(FSOLID_NOT_SOLID)

	wep:SetLocalPos(vector_origin)

	wep:SetLocalAngles(angle_zero)

	

	wep:SetTransmitWithParent(true)

	wep.CurAmmo = wep.Capacity

	wep.Reloading = false

	return actwep

end



function ENT:Initialize()

	self:SetModel("models/player/darky_m/rust/scientist.mdl")

	

	self.LoseTargetDist	= 2200

	self.SearchRadius 	= 500

	self:Give("rust_rock")

	self:SetHealth(200)



	self.NextFire = CurTime()

	self.NextSound = CurTime()+1

	self.NextFootstep = CurTime()

	self.NextCrouch = CurTime()



	self.Healing = false

	self.Foot = false



	self.InitialSpawnPos = self:GetPos()

end



function ENT:SetEnemy(ent)

	self.Enemy = ent

end



function ENT:GetEnemy()

	return self.Enemy

end



local ignore = GetConVar("ai_ignoreplayers")

local disableai = GetConVar("ai_disabled")



function ENT:HaveEnemy()

	if ignore:GetBool() then return end

	if self:GetEnemy() and IsValid(self:GetEnemy()) then

		if self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist then

			return self:FindEnemy()

		elseif self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() then

			return self:FindEnemy()

		end	

		return true

	else

		return self:FindEnemy()

	end

end



function ENT:FindEnemy(radius)

	if ignore:GetBool() then return end

	local rs = radius or self.SearchRadius

	local _ents = ents.FindInSphere(self:GetPos(), rs)

	for k,v in ipairs(_ents) do

		if v:IsPlayer() and v:Alive() then

			self:SetEnemy(v)

			return true

		end

	end	

	self:SetEnemy(nil)

	return false

end



function ENT:RunBehaviour()

	local wep = self:GetActiveLuaWeapon()

	while true do

		if not disableai:GetBool() then 

			if self:HaveEnemy() then

				self:StartActivity(ACT_HL2MP_WALK_REVOLVER)

				self:Give("rust_ak47")

				self:SetPoseParameter("aim_pitch",0)

				self.loco:SetDesiredSpeed(50)

				self.NextFire = CurTime()+2

				self:GoAwayFromEnemy()

			else

				self:StartActivity(ACT_HL2MP_WALK_DUEL)

				self:Give("scientist_geiger")

				self:SetPoseParameter("aim_pitch",40)

				self.loco:SetDesiredSpeed(50)

				self:MoveToPos(self:GetPos() + Vector(1, 1, 0) * 50)

				self:StartActivity(ACT_HL2MP_IDLE_DUEL)

			end

		else

			self:StartActivity(ACT_HL2MP_WALK_DUEL )

		end

		coroutine.wait(2)

	end

end	



function ENT:BodyUpdate()

	self:BodyMoveXY()

end



function ENT:GoAwayFromEnemy()

	local path = Path("Follow")

	path:SetMinLookAheadDistance(0)

	path:SetGoalTolerance(20)

	path:Compute(self, self:GetEnemy():GetPos()+Vector(0,0,50))

	

	if not path:IsValid() then return "failed" end



	while path:IsValid() and self:HaveEnemy() do

		if path:GetAge() > 0.1 then

			local vec = vec or self:GetPos()

			vec = (self:GetPos() - self:GetEnemy():GetPos()):Angle():Forward()*100

			path:Compute(self, self:GetPos()+vec)



			local tr = {}

			tr.start = self:GetPos()

			tr.endpos = self:GetEnemy():GetPos()

			tr.filter = {self:GetEnemy(), self}

			tr = util.TraceLine(tr)



			if (!tr.HitWorld) then

				self:WeaponPrimaryAttack()

			end

			

			self.loco:FaceTowards(self:GetEnemy():GetPos())

			if self.NextCrouch < CurTime() then

				self.NextCrouch = CurTime() + 5

				if math.random(1,4) == 2 then 

					self:StartActivity(ACT_HL2MP_WALK_CROUCH_REVOLVER)

					self.loco:SetDesiredSpeed(38)

				else

					self:StartActivity(ACT_HL2MP_WALK_REVOLVER)

					self.loco:SetDesiredSpeed(60)

				end

			end

		end

		path:Update(self)

		self.loco:FaceTowards(self:GetEnemy():GetPos())



		if (self.loco:IsStuck()) then

			self:HandleStuck()

			return "stuck"

		end



		coroutine.yield()

	end



	return "ok"

end



function ENT:OnInjured(info)

	self.Enemy = info:GetAttacker()

	self:FindEnemy()

	self.NextFire = CurTime()+0.1

	

	self:SetEnemy(info:GetAttacker())

	self:WeaponPrimaryAttack()

end



function ENT:OnKilled(dmginfo)

	local rag = self:BecomeRagdoll(dmginfo)

	hook.Call("OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor())



	timer.Simple(10, function()

		if (rag && rag:IsValid()) then

			rag:Remove()

		end

	end)



	local pos = self.InitialSpawnPos

	local ang = self:GetAngles()



	SafeRemoveEntityDelayed(self, 0.05)

end



local CreateRespawn

CreateRespawn = function(class, pos, ang, time)

	timer.Simple(time, function()

		local ent = ents.Create(class)

		if (!IsValid(ent)) then

			CreateRespawn(class, pos, ang, time)

			return

		end

		ent:SetPos(pos)

		ent:SetAngles(ang)

		ent:Spawn()

		ent.DontSave = true

		ent.ShouldRespawn = true

	end)

end



function ENT:OnRemove()

	if (CLIENT) then return end

	CreateRespawn(self:GetClass(), self.InitialSpawnPos, self:GetAngles(), 180)

end



function ENT:Reload()

	local wep = self:GetActiveLuaWeapon()

	if wep.Reloading then return end

	self:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)

	wep.Reloading = true

	timer.Simple(2.5, function()

		if self:IsValid() and wep:IsValid() then

			wep.CurAmmo = wep.Capacity

			wep.Reloading = false

		end

	end)



	return

end



function ENT:GetActiveWeapon()

	return self:GetActiveLuaWeapon()

end



function ENT:Name()

	return "Scientist"

end



local syringesInstalled = weapons.Get("rust_syringe") and true or false 



function ENT:WeaponPrimaryAttack()

	if self.NextFire > CurTime() then return end

	if not self:HaveEnemy() then return end

	if self.Healing then return end



	local wep = self:GetActiveLuaWeapon()



	if wep.CurAmmo <= 0 then

		self:Reload()

		return

	end

	if self:Health()<=30 and syringesInstalled then

		self:Heal()

	end



	self:SetPoseParameter("aim_pitch",0)



	ProtectedCall(function() 

		self.NextFire = CurTime()+1/self:GetActiveLuaWeapon().RPM

		wep:EmitSound(wep.ShootSound)

		self:RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL)

		local bullet = {}

		bullet.Attacker = self

		bullet.Num		= 1

		bullet.Src		= wep:GetPos()+Vector(0,0,50)

		bullet.Dir		= self:GetEnemy():GetPos()-wep:GetPos()

		bullet.Spread	= Vector(60, 60, 0)

		bullet.Tracer	= 1

		bullet.Force	= 1

		bullet.Damage	= 10

		bullet.AmmoType = "pistol"



		wep:FireBullets(bullet)

		wep.CurAmmo = wep.CurAmmo -1

		wep:MuzzleFlash()

	end)

end



function ENT:OnTakeDamage(dmg)

	GAMEMODE:ScalePlayerDamage(self, dmg:GetDamagePosition().z > self:GetPos().z + 60 and HITGROUP_HEAD or HITGROUP_GENERIC, dmg)

end



function ENT:Heal()

	if self.Healing or self:GetActiveLuaWeapon().Reloading then return end

	self:RemoveAllGestures()

	self:AddGesture(ACT_HL2MP_GESTURE_RELOAD_PISTOL)

	self:EmitSound("syringe.inject")

	self:Give("rust_syringe")

	self.Healing = true

	timer.Simple(2, function()

		if self:IsValid() then

			self.Healing = false

			self:Give("rust_mp5")

			self:SetHealth(50)

		end

	end)



	return

end	
*/


function ENT:Think()

end

