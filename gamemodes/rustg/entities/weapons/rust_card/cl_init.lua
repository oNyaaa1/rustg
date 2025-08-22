--[[
gamemodes/rust/entities/weapons/rust_card/cl_init.lua
--]]
include("shared.lua")

SWEP.VMPos = Vector(-2, -1, 0.5)
SWEP.VMAng = Vector(0, 0, 0)

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1.5)
    
    if (self:GetInventorySlot():GetWear() <= 0) then return end
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

