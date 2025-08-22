--[[
gamemodes/rust/entities/weapons/rust_scard/shared.lua
--]]
AddCSLuaFile()

SWEP.Base    = "rust_base"

SWEP.WorldModel     = "models/darky_m/rust/puzzle/access_card.mdl"
SWEP.ViewModel      = "models/weapons/darky_m/rust/c_keycard.mdl"

SWEP.DownPos = Vector(0, 0, -3)

function SWEP:Deploy()
    self:GetOwner():GetViewModel():SetSubMaterial(0, "models/darky_m/rust/puzzle/scard")
end

function SWEP:Holster()
    return true
end

function SWEP:OnRemove()
    return true
end

