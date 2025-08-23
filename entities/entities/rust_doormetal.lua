AddCSLuaFile()

ENT.Base = "rust_door"

ENT.Model       = "models/deployable/metal_door.mdl"
ENT.MaxHealth   = 250

ENT.MeleeDamage     = 0
ENT.BulletDamage    = 0.0
ENT.ExplosiveDamage = 0.25

ENT.DoorSound   = "metal"

ENT.Deploy          = {}
ENT.Deploy.Rotation = -10
ENT.Deploy.Model    = "models/deployable/metal_door.mdl"
ENT.Deploy.Sound    = "deploy/metal_door_deploy.wav"
ENT.Deploy.Socket   = "door"

ENT.metalupkeep = 50

ENT.Pickup = "metal_door"