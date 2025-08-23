AddCSLuaFile()

ENT.Base = "rust_droppeditem"

AccessorFunc(ENT, "Fuse", "Fuse", FORCE_NUMBER)
AccessorFunc(ENT, "Stick", "Stick", FORCE_BOOL)

function ENT:Initialize()
    if (CLIENT) then return end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
        phys:Wake()
        phys:SetDamping(1, 5)
    end

    self.Fuse = nil

    timer.Simple(120, function()
        if IsValid(self) then self:Remove() end
    end)
end

function ENT:Throw(direction, force)
    if CLIENT then return end

    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end

    self:SetStick(true)
    phys:SetVelocityInstantaneous(direction * force)
end

function ENT:FuseCallback()
end

function ENT:PhysicsCollide(coldata, collider)
    local owner = self:GetOwner()
    local hit = coldata.HitEntity

        local dmg = DamageInfo()
        dmg:SetDamage(self.Damage or 100) 
        dmg:SetAttacker(owner or self)
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_CLUB)
        dmg:SetDamagePosition(coldata.HitPos)
        hit:TakeDamageInfo(dmg)

    if self:GetStick() and not self.Stuck then
        self:SetMoveType(MOVETYPE_NONE)
        self.Stuck = true
        self:SetPos(coldata.HitPos)
        self:SetAngles(coldata.HitNormal:Angle() )
    end
end

function ENT:Think()
    if self:GetFuse() and CurTime() > self:GetFuse() then
        self:FuseCallback()
        self:Remove()
    end
end

function ENT:Draw()
    self:DrawModel()
end
