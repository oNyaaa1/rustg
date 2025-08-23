AddCSLuaFile()



ENT.Base = "rust_storage"



ENT.InventorySlots = 5

ENT.InventoryName   = "Large Wood Box"



ENT.Deploy = {}

ENT.Deploy.Model = "models/deployable/large_wooden_box.mdl"



ENT.Pickup			= "large_wood_box"

ENT.DisplayIcon 	= gRust.GetIcon("open")

ENT.ShowHealth	= true



function ENT:Initialize()

    if (CLIENT) then return end



    self:SetModel("models/deployable/large_wooden_box.mdl")

    self:PhysicsInitStatic(SOLID_VPHYSICS)

    self:SetMoveType(MOVETYPE_NONE)

    self:SetSolid(SOLID_VPHYSICS)

    self:CreateInventory(30)

    self:SetSaveItems(true)



    self:SetInteractable(true)

    

    self:SetDamageable(true)

    self:SetHealth(200)

    self:SetMaxHealth(200)



    self:SetMeleeDamage(0.2)

    self:SetBulletDamage(0.05)

    self:SetExplosiveDamage(0.4)



    self:SetDisplayName("OPEN")

end