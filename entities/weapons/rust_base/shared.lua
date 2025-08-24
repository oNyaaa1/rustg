SWEP.VMPos = Vector(-6, 0, -0.5)
SWEP.VMAng = Angle(0, 0, 0)
SWEP.DownPos = Vector(-5, 0, -4)
SWEP.DownAng = Angle(0, 0, 0)
SWEP.Author = "Down"
SWEP.DrawCrosshair = false
--Internal Vars
SWEP.m_WeaponDeploySpeed = 1
function SWEP:SetupDataTables()
end

function SWEP:PrimaryAttack()
    local pl = self:GetOwner()
    local coldata = pl:GetEyeTrace()
    if self.Weapon:HasAmmo() then
        if self:IsBroken() then
            pl:ChatPrint("Your weapon is broken!")
            self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
            return
        end

        self:PlayAnimation("PrimaryAttack")
        self:ShootBullet(self.Damage, self.Bullets, 0.1, self.Ammo, 1, 5)
        pl:SetAmmo(pl:GetAmmo()[3] - 1, self.Ammo)
        local slot = self:GetInventorySlot()
        if slot and slot.GetClip then
            self:SetClip1(slot:GetClip())
        end
    else
        self:PlayAnimation("PrimaryAttackEmpty")
        pl:ChatPrint("Out of ammo!")
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:GetInventorySlot()
    local owner = self:GetOwner()
    if not IsValid(owner) then return nil end
    if SERVER then
        if not owner.Inventory then return nil end
        return owner.Inventory[self.InventorySlot]
    else
        local lp = LocalPlayer()
        if not lp.Inventory then return nil end
        return lp.Inventory[owner.SelectedSlotIndex]
    end
end

function SWEP:IsBroken()
    if not self:GetInventorySlot().GetWear then -- TODO: Find out why this errors
        return
    end
    return self:GetInventorySlot():GetWear() <= 0
end

SWEP.Animations = {
    ["Deploy"] = ACT_VM_DEPLOY,
    ["PrimaryAttack"] = ACT_VM_PRIMARYATTACK,
    ["PrimaryAttackEmpty"] = ACT_VM_PRIMARYATTACK_1,
    ["SecondaryAttack"] = ACT_VM_SECONDARYATTACK,
    ["Reload"] = ACT_VM_RELOAD,
    ["ShotgunReloadFinish"] = ACT_SHOTGUN_RELOAD_FINISH,
    ["Throw"] = ACT_VM_THROW,
    ["SwingHit"] = ACT_VM_SWINGHIT,
    ["SwingMiss"] = ACT_VM_SWINGMISS,
    ["PullPin"] = ACT_VM_PULLPIN,
}

function SWEP:PlayAnimation(name)
    self:SendWeaponAnim(self.Animations[name])
end