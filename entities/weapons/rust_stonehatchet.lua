--[[
gamemodes/rust/entities/weapons/rust_stonehatchet.lua
--]]
SWEP.Base               = "rust_melee"

SWEP.ViewModel          = "models/weapons/darky_m/rust/c_stone_hatchet.mdl"
SWEP.WorldModel         = "models/weapons/darky_m/rust/w_stone_hatchet.mdl"

SWEP.DownPos            = Vector(-5, 0, -4)

SWEP.Damage             = 15

SWEP.SwingDelay         = 0
SWEP.SwingInterval      = 0.95
SWEP.SwingSound         = "darky_rust.hatchet-stone-attack"
SWEP.StrikeSound        = "darky_rust.hatchet-stone-strike"

SWEP.HarvestAmount =
{
	["rust_ore"] = 0,
	["tree"] = 1,
}

