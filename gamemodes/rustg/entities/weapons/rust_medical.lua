AddCSLuaFile()

SWEP.Base = "rust_base"

SWEP.VMPos = Vector()
SWEP.VMAng = Vector()

SWEP.DownPos = Vector(0, 0, -2)

SWEP.Delay      = 3.85
SWEP.AddHealth  = 10

function SWEP:PrimaryAttack()
    self:PlayAnimation("PrimaryAttack")
    self.NextUse = CurTime() + self.Delay
    self:SetNextPrimaryFire(self.NextUse)
end

function SWEP:Think()
    if SERVER and self.NextUse and self.NextUse < CurTime() then
        self.NextUse = nil

        local pl = self:GetOwner()
        if not IsValid(pl) then return end

        local selectedSlotIndex = pl.SelectedSlotIndex
        if not selectedSlotIndex then return end

        local slot = pl.Inventory[selectedSlotIndex]
        if not slot then return end

        if slot:GetQuantity() > 1 then
            slot:SetQuantity(slot:GetQuantity() - 1)
            pl:SyncSlot(selectedSlotIndex)
        else
            pl:RemoveSlot(selectedSlotIndex)
            
            timer.Simple(0.1, function()
                if IsValid(pl) then
                    ClearPlayerWeapon(pl)
                end
            end)
        end

        pl:SetHealth(math.min(pl:Health() + self.AddHealth, pl:GetMaxHealth()))
    end
end

function SWEP:Holster()
    self.NextUse = nil
    return true
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DEPLOY)
end
