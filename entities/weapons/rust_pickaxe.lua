--[[
gamemodes/rust/entities/weapons/rust_pickaxe.lua
--]]
SWEP.Base               = "rust_melee"

SWEP.ViewModel          = "models/weapons/darky_m/rust/c_iron_pickaxe.mdl"
SWEP.WorldModel         = "models/weapons/darky_m/rust/w_iron_pickaxe.mdl"

SWEP.DownPos            = Vector(-5, 0, -4)

SWEP.Damage             = 23

SWEP.SwingDelay         = 0.39
SWEP.SwingInterval      = 1.9
SWEP.SwingSound         = "darky_rust.pickaxe-attack"
SWEP.StrikeSound        = "darky_rust.pickaxe-strike"

SWEP.HarvestAmount =
{
	["rust_ore"] = 2,
	["tree"] = 0,
}

