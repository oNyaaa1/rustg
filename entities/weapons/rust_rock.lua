--[[
gamemodes/rust/entities/weapons/rust_rock.lua
--]]
SWEP.Base = "rust_melee"
SWEP.ViewModel = "models/weapons/darky_m/rust/c_rock.mdl"
SWEP.WorldModel = "models/weapons/darky_m/rust/w_rock.mdl"
SWEP.DownPos = Vector(-5, 0, -4)
SWEP.Damage = 10
SWEP.Stick = true
SWEP.SwingDelay = 0.525
SWEP.SwingInterval = 1.75
SWEP.SwingSound = "tools/rock_swing.mp3"
SWEP.StrikeSound = "tools/rock_strike_%i.mp3"
SWEP.HarvestAmount = {
	["rust_ore"] = 1,
	["tree"] = 1,
}