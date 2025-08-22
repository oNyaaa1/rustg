--[[
gamemodes/rust/entities/weapons/rust_hatchet.lua
--]]
SWEP.Base               = "rust_melee"

SWEP.ViewModel          = "models/weapons/darky_m/rust/c_iron_hatchet.mdl"
SWEP.WorldModel         = "models/weapons/darky_m/rust/w_iron_hatchet.mdl"

SWEP.DownPos            = Vector(-5, 0, -4)

SWEP.Damage             = 17

SWEP.SwingDelay         = 0
SWEP.SwingInterval      = 0.9
SWEP.SwingSound         = "darky_rust.hatchet-attack"
SWEP.StrikeSound        = "darky_rust.hatchet-strike-soft"

SWEP.HarvestAmount =
{
	["rust_ore"] = 0,
	["tree"] = 1.5,
}

