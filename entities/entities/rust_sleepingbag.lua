DEFINE_BASECLASS("rust_base")
AddCSLuaFile()
ENT.Base = "rust_base"
ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/sleeping_bag.mdl"
ENT.DisplayIcon = gRust.GetIcon("sleepingbag")
ENT.ShowHealth = true
ENT.RespawnDelay = 300
ENT.Pickup = "sleeping_bag"
function ENT:SetupDataTables()
    BaseClass.SetupDataTables(self)
    self:NetworkVar("String", 1, "BagName")
    self:SetBagName("Unnamed Bag")
    self:NetworkVar("Int", 1, "LastRespawn")
    self:SetLastRespawn(0)
end

function ENT:Initialize()
    self:SetInteractable(true)
    self:SetModel("models/deployable/sleeping_bag.mdl")
    if CLIENT then return end
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetDamageable(true)
    self:SetHealth(200)
    self:SetMaxHealth(200)
    self:SetMeleeDamage(0.2)
    self:SetBulletDamage(0.05)
    self:SetExplosiveDamage(0.4)
    if not self.BagIndex then self.BagIndex = self:EntIndex() end
    self.RespawnDelay = 0
    self:SetNWFloat("LastRespawn", 0)
end

function ENT:Interact(pl)
    if CLIENT then return end
end

function ENT:OnRemove()
    if SERVER and IsValid(self) and self.Owner then if IsValid(self.Owner) then RemoveSleepingBagFromPlayer(self.Owner, self) end end
end

function ENT:GetLastRespawn()
    return self:GetNWFloat("LastRespawn", 0)
end

function ENT:SetLastRespawn(time)
    self:SetNWFloat("LastRespawn", time)
end