-- Базовая информация о SWEP
SWEP.Base = "rust_base"
SWEP.PrintName = "Hammer"
SWEP.Author = "Dev Team"
SWEP.Instructions = "Right mouse for pie menu - upgrade, rotate, demolish"
SWEP.Category = "GRust"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = "models/weapons/darky_m/rust/c_hammer.mdl"
SWEP.WorldModel = "models/weapons/darky_m/rust/w_hammer.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false


SWEP.ShootSound = Sound("Metal.SawbladeStick")

SWEP.isUsable = true

function isBuilding(ent)
    if(ent:GetNetworkedString("buildtier") ~= nil && ent:GetNetworkedString("buildtier") ~= "") then
        return true
    else
        return false
    end
end

function SWEP:Initialize()
    self:SetNetworkedBool("isUsable", true)
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end
