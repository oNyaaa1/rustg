AddCSLuaFile()
DEFINE_BASECLASS("rust_base")

ENT.Base = "rust_base"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true

ENT.PrintName = "garage"
ENT.Category = "Dev Stuff"

ENT.Mins = Vector(-58, 2, -120)
ENT.Maxs = Vector(58,  5,  0)

ENT.MeleeDamage     = 0.0
ENT.BulletDamage    = 0.0
ENT.ExplosiveDamage = 0.25

ENT.LockPos = Vector(-55, 5.2, -60)
ENT.ManualAuthorization = true

ENT.Deploy          = {}
ENT.Deploy.Model    = "models/building/garage_door.mdl"
ENT.Deploy.Socket   = "garage"

ENT.Pickup   	= "garage_door"
ENT.DisplayIcon = gRust.GetIcon("gear")
ENT.ShowHealth	= true

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Bool", 15, "Opened")
end

function ENT:Initialize()
	self.PhysCollide = CreatePhysCollideBox(self.Mins, self.Maxs)
	self.Authorized = nil

	self:SetDisplayName("OPEN")
	self:SetInteractable(true)

	self:SetDamageable(true)

	if (SERVER) then
		self:SetHealth(300)
		self:SetMaxHealth(300)
	end

	self:SetOpened(false)

	if SERVER then
		self:SetModel("models/building/garage_door.mdl")
		//self:PhysicsInitBox(self.Mins, self.Maxs)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
	end

	self:EnableCustomCollisions(true)
end

local TimeToOpen = 2.4
function ENT:Interact(pl)
	if (CLIENT) then return end
	if (self.Authorized and !self.Authorized[pl:SteamID()]) then return end

	if (!self.Moving) then
		if (self:GetOpened()) then
			self:ResetSequence("close")
			self:SetOpened(false)
			self.Mins.z = -120
		else
			self:ResetSequence("open")
			self:SetOpened(true)
			self.Mins.z = -10
		end

		self.Moving = true
		timer.Simple(TimeToOpen, function()
			self.Moving = false
		end)
	end

	self.PhysCollide = CreatePhysCollideBox(self.Mins, self.Maxs)
	//self:PhysicsInitBox(self.Mins, self.Maxs)
end

function ENT:Think()
	if (SERVER) then
		self:NextThink(CurTime())
		return true
	else
		local opened = self:GetOpened()
		if (!opened) then
			self.Mins.z = -120
		else
			self.Mins.z = -10
		end

		if (!self.WasOpened || opened != self.WasOpened) then
			self.PhysCollide = CreatePhysCollideBox(self.Mins, self.Maxs)
		end

		self.WasOpened = opened
	end
end

function ENT:TestCollision(startpos, delta, isbox, extents)
    if not IsValid(self.PhysCollide) then return end

    -- TraceBox expects the trace to begin at the center of the box, but TestCollision is bad
    local max = extents
    local min = -extents
    max.z = max.z - min.z
    min.z = 0

    local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), startpos, startpos + delta, min, max)

    if not hit then return end

    return { 
        HitPos = hit,
        Normal  = norm,
        Fraction = frac,
    }
end

function ENT:Authorize(pl)
	self.Authorized = self.Authorized or {}
	self.Authorized[pl:SteamID()] = true
end

function ENT:SetAuthorizeEntity(ent)
	self.AuthorizeEntity = ent
end

/*function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Int", 5, "Z_Open")
	self:NetworkVar("Int", 6, "Status")
end

function ENT:Initialize()
	self.PhysCollide = CreatePhysCollideBox(self.Mins, self.Maxs)

	self:SetZ_Open(0)
	self:SetStatus(0)
	self:SetDisplayName("OPEN")
	self:SetInteractable(true)

	self.NextMove = 0

	if SERVER then
		self:SetModel("models/building_re/garage_door.mdl")
		self:PhysicsInitBox(self.Mins, self.Maxs)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
	end

	self:EnableCustomCollisions(true)
end

function ENT:Think()
	local status = self:GetStatus()
	local getz = self:GetZ_Open()
	
	if status == 1 or status == 3 then
		if self.NextMove < CurTime() then
			local move = -4.5

			if status == 3 then
				move = 4
			end

			self:SetZ_Open(getz + move)
			self.NextMove = CurTime() + 0.1

			self.Mins = Vector(-58, 2, getz)
			self:SetCollisionBounds(self.Mins, self.Maxs)

			if SERVER then self:PhysicsInitBox(self.Mins, self.Maxs) end
			
			self:SetMoveType(MOVETYPE_NONE) -- PhysicsInitBox resets it
			self:SetSolid(SOLID_VPHYSICS) -- PhysicsInitBox resets it
		end
	end

	if status == 1 and getz == 120 then
		self:SetStatus(2)
	end

	if status == 3 and getz == 0 then
		self:SetStatus(0)
		self:UnstuckPlayers()
	end

	if SERVER then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:TestCollision(startpos, delta, isbox, extents)
    if not IsValid(self.PhysCollide) then return end

    -- TraceBox expects the trace to begin at the center of the box, but TestCollision is bad
    local max = extents
    local min = -extents
    max.z = max.z - min.z
    min.z = 0

    local hit, norm, frac = self.PhysCollide:TraceBox(self:GetPos(), self:GetAngles(), startpos, startpos + delta, min, max)

    if not hit then return end

    return { 
        HitPos = hit,
        Normal  = norm,
        Fraction = frac,
    }
end

function ENT:Interact(pl)
	pl:ChatPrint("Interacted with door")
	if self:GetStatus() == 2 then
		self:ResetSequence("close")
		self:SetStatus(3)
	elseif self:GetStatus() == 0 then
		self:ResetSequence("open")
		self:SetStatus(1)
	end
end

function ENT:Draw()
	self:DrawModel()
	-- render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self.Mins, self.Maxs, Color(255, 0, 0), true)
	render.DrawWireframeSphere(self:GetPos()+Vector(0,0,60), 60, 15, 15)
end

function ENT:UnstuckPlayers()
	if CLIENT then return end

	local stuckers = ents.FindInSphere(self:GetPos()+Vector(0,0,60), 60)
	local tPlayers = {}
	local iPlayers = 0
	
	for i = 1, #stuckers do
		if stuckers[i]:IsPlayer() then
			iPlayers = iPlayers + 1
			tPlayers[iPlayers] = stuckers[i]
		end
	end

	for i = 1, #tPlayers do
		local pos = tPlayers[i]:GetPos()

		local tr = {
			start = pos,
			endpos = pos,
			mins = Vector(-9, -9, 12),
			maxs = Vector(9, 9, 65)
		}

		local hullTrace = util.TraceHull(tr)

		if hullTrace.Hit then
			local right = self:GetRight()
			local optimal = pos:Distance(pos+right*20) < pos:Distance(pos+right*-20) and 20 or -20 -- vec:Distance(vec) is expensive

			tPlayers[i]:SetPos(pos+right*optimal)
		end
	end
end

-- 0: closed
-- 1: opening
-- 2: opened
-- 3: closing*/