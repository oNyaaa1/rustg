--[[
gamemodes/rust/entities/weapons/rust_spear.lua
--]]
SWEP.Base               = "rust_melee"

SWEP.ViewModel          = "models/weapons/darky_m/rust/c_wooden_spear.mdl"
SWEP.WorldModel         = "models/weapons/darky_m/rust/w_wooden_spear.mdl"

SWEP.DownPos            = Vector(-5, 0, -6)

SWEP.Damage             = 20

SWEP.Range = 80
SWEP.SwingDelay         = 0.25
SWEP.SwingInterval      = 1.6
SWEP.SwingSound         = "darky_rust.spear-attack"
SWEP.StrikeSound        = "darky_rust.spear-strike-soft"

SWEP.Stick				= true

SWEP.HarvestAmount =
{
	["rust_ore"] = 0,
	["tree"] = 0,
}

