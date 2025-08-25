AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.gRust = true
AccessorFunc(ENT, "RespawnTime", "RespawnTime", FORCE_NUMBER)
AccessorFunc(ENT, "NextInteract", "NextInteract", FORCE_NUMBER)
AccessorFunc(ENT, "Damageable", "Damageable", FORCE_BOOL)
AccessorFunc(ENT, "DamageSound", "DamageSound", FORCE_BOOL)
AccessorFunc(ENT, "MeleeDamage", "MeleeDamage", FORCE_NUMBER)
AccessorFunc(ENT, "BulletDamage", "BulletDamage", FORCE_NUMBER)
AccessorFunc(ENT, "ExplosiveDamage", "ExplosiveDamage", FORCE_NUMBER)
AccessorFunc(ENT, "WoodUpkeep", "WoodUpkeep", FORCE_NUMBER)
AccessorFunc(ENT, "StoneUpkeep", "StoneUpkeep", FORCE_NUMBER)
AccessorFunc(ENT, "MetalUpkeep", "MetalUpkeep", FORCE_NUMBER)
AccessorFunc(ENT, "HQUpkeep", "HQUpkeep", FORCE_NUMBER)
ENT.Authorized = {}
ENT.WoodUpkeep = 0
ENT.StoneUpkeep = 0
ENT.MetalUpkeep = 0
ENT.HQUpkeep = 0
function ENT:Initialize()
	if self.Model then
		self:SetModel(self.Model)
		self:PhysicsInitStatic(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end

	self.MeleeDamage = 1
	self.BulletDamage = 1
	self.ExplosiveDamage = 1
	self.Damageable = false
	self.DamageSound = false
	self.MeleeDamage = 1
	self.BulletDamage = 1
	self.ExplosiveDamage = 1
end

--
-- Name: OnTakeDamage
-- Type: Base Override
-- Call: When the entity is setting up its data tables
--
function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Interactable")
	self:NetworkVar("String", 0, "DisplayName")
end

--
-- Name: Interact
-- Type: Overridable
-- Call: When somebody presses E on the entity
--
function ENT:Interact(pl)
end

--
-- Name: OnDestroyed
-- Type: Overridable
-- Call: When the entity gets destroyed by damage
--
function ENT:OnDestroyed(dmg)
end

--
-- Name: OnTakeDamage
-- Type: Base Override
-- Call: When the entity takes damage
--
function ENT:OnTakeDamage(dmg)
	if not self.Damageable then return end
	local Attacker = dmg:GetAttacker()
	if self.DamageSound and IsValid(Attacker) then Attacker:EmitSound("hit.default") end
	if dmg:GetDamageType() == DMG_CLUB then
		dmg:ScaleDamage(self:GetMeleeDamage())
	elseif dmg:GetDamageType() == DMG_BULLET then
		dmg:ScaleDamage(self:GetBulletDamage())
	elseif dmg:GetDamageType() == DMG_BLAST then
		dmg:ScaleDamage(self:GetExplosiveDamage())
	end

	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() <= 0 then
		self:Remove()
		self:OnDestroyed(dmg)
	end
end

function gRust.CreateRespawn(class, pos, ang, time)
	timer.Simple(time, function()
		local ent = ents.Create(class)
		if not IsValid(ent) then
			gRust.CreateRespawn(class, pos, ang, time)
			return
		end

		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
	end)
end

function ENT:AttachEntity(ent)
	self.AttachedEnts = self.AttachedEnts or {}
	self.AttachedEnts[#self.AttachedEnts + 1] = ent
end

--
-- Name: OnRemove
-- Type: Base Override
-- Call: When the entity is removed in any way
--
function ENT:OnRemove()
	if CLIENT then return end
	local RespawnTime = self:GetRespawnTime()
	if RespawnTime and RespawnTime > 0 then gRust.CreateRespawn(self:GetClass(), self:GetPos(), self:GetAngles(), RespawnTime) end
	if self.AttachedEnts then
		for k, v in ipairs(self.AttachedEnts) do
			if not IsValid(v) then continue end
			v:Remove()
		end
	end
end

--
-- Name: Harvest
-- Type: Overridable
-- Call: When somebody attempts to harvest items from the item
--
function ENT:Harvest(dmg)
end

--
-- Name: Authorize
-- Type: Method
-- Use: Adds a player to the authorized list
--
function ENT:Authorize(pl)
	self.Authorized[pl:SteamID()] = true
end

--
-- Name: Unauthorize
-- Type: Method
-- Use: Removes a player from the authorized list
--
function ENT:Unauthorize(pl)
	self.Authorized[pl:SteamID()] = nil
end

--
-- Name: IsAuthorized
-- Type: Get
-- Use: Returns if a player is on the authorized list
--
function ENT:IsAuthorized(pl)
	return self.Authorized[pl:SteamID()]
end

--
-- Name: HoldInteract
-- Type: Overridable
-- Call: When somebody holds [USE] on the entity
--
function ENT:HoldInteract(pl)
	if SERVER or not self.Options then return end
	gRust.OpenPieMenu(self.Options, function(i) self.Options[i].Func(self) end, self)
end

--
-- Name: ReleaseInteract
-- Type: Overridable
-- Call: When somebody releases [USE] on the entity 
--
function ENT:ReleaseInteract(pl)
	if SERVER or not self.Options then return end
	gRust.ClosePieMenu()
end

function ENT:Save(data)
	data.pos = self:GetPos()
	data.ang = self:GetAngles()
end

function ENT:Load(data)
	self:SetPos(data.pos)
	self:SetAngles(data.ang)
end

function ENT:GetDisplayName() 
	return ""
end