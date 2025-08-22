AddCSLuaFile()



ENT.Base = "rust_storage"



ENT.InventorySlots  = 2

ENT.InventoryName   = "Wood Box"



ENT.Deploy = {}

ENT.Deploy.Model = "models/deployable/wooden_box.mdl"

ENT.Deploy.Sound	= "deploy/small_wooden_box_deploy.wav"



ENT.Pickup			= "wood_box"

ENT.DisplayIcon 	= gRust.GetIcon("open")

ENT.ShowHealth	= true



function ENT:Initialize()

    if (CLIENT) then return end



    self:SetModel("models/deployable/wooden_box.mdl")

    self:PhysicsInitStatic(SOLID_VPHYSICS)

    self:SetMoveType(MOVETYPE_NONE)

    self:SetSolid(SOLID_VPHYSICS)

    self:CreateInventory(12)

    //self:SetSaveItems(true)



    self:SetInteractable(true)

    

    self:SetDamageable(true)

    self:SetHealth(150)

    self:SetMaxHealth(150)



    self:SetMeleeDamage(0.2)

    self:SetBulletDamage(0.2)

    self:SetExplosiveDamage(0.4)



end