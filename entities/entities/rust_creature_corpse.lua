AddCSLuaFile()
ENT.Base = "rust_base"
ENT.ShowHealth = true
ENT.DisplayIcon = gRust.GetIcon("gear")

function ENT:Initialize()
    if CLIENT then return end
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetDamageable(true)
    self:SetDamageSound(true)
    
    -- Enable physics so the corpse can fall down
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(true)
        phys:EnableGravity(true)
    end
    
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