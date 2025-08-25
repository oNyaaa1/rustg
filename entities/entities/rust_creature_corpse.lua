AddCSLuaFile()
ENT.Base = "rust_base"
ENT.ShowHealth = true
ENT.DisplayIcon = gRust.GetIcon("gear")

function ENT:Initialize()
    if CLIENT then return end
    
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetDamageable(true)
    self:SetDamageSound(true)
    
    -- Default values - will be set when spawned
    self:SetHealth(100)
    self:SetMaxHealth(100)
    
    -- Damage multipliers
    self:SetMeleeDamage(1)
    self:SetBulletDamage(1)
    self:SetExplosiveDamage(1)
end

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Health")
    self:NetworkVar("Float", 1, "MaxHealth")
    self:NetworkVar("String", 0, "CreatureType")
end

function ENT:GetDisplayName() 
	return ""
end