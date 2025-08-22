AddCSLuaFile()

SWEP.Base = "rust_medical"

SWEP.ViewModel = "models/weapons/darky_m/rust/c_syringe_v2.mdl"
SWEP.WorldModel = "models/weapons/darky_m/rust/w_syringe_v2.mdl"

SWEP.Delay = 2.65
SWEP.AddHealth = 25
SWEP.ViewModelFOV = 55

SWEP.Insert = 0

SWEP.Animations = {
    ["Deploy"] = ACT_VM_DRAW,
    ["PrimaryAttack"] = ACT_VM_THROW,
    ["PrimaryAttackEmpty"] = ACT_VM_PRIMARYATTACK_1,
    ["SecondaryAttack"] = ACT_VM_SECONDARYATTACK,
    ["Reload"] = ACT_VM_RELOAD,
    ["ShotgunReloadFinish"] = ACT_SHOTGUN_RELOAD_FINISH,
    ["Throw"] = ACT_VM_THROW,
    ["SwingHit"] = ACT_VM_SWINGHIT,
    ["SwingMiss"] = ACT_VM_SWINGMISS,
    ["PullPin"] = ACT_VM_PULLPIN,
}



function SWEP:SecondaryAttack()
    local Owner = self:GetOwner()
    if self.Insert != 0 then return end
    
    local selectedSlotIndex = Owner.SelectedSlotIndex
    if not selectedSlotIndex then return end
    
    local slot = Owner.Inventory[selectedSlotIndex]
    if not slot then return end
    
    local Traced = self:CheckTrace()
    if IsValid(Traced) and (Traced:IsPlayer() or Traced:IsNPC()) then
        Owner:DoAnimationEvent(ACT_GMOD_GESTURE_MELEE_SHOVE_1HAND)
        if CLIENT then return end
        
        local CT = CurTime()
        self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
        self.Friend = Traced
        self.TraceCheckTimer = CurTime() + 0.2
        self.Insert = 2
        self.InsertTimer = CT + Owner:GetViewModel():SequenceDuration()
        self.SoundTimer = CT + 0.3
    end
end

function SWEP:CheckTrace()
    local Owner = self:GetOwner()
    Owner:LagCompensation(true)
    
    local Trace = util.TraceLine({
        start = Owner:GetShootPos(),
        endpos = Owner:GetShootPos() + Owner:GetAimVector() * 64,
        filter = Owner
    })
    
    Owner:LagCompensation(false)
    return Trace.Entity
end

function SWEP:Heal(target)
    local Owner = self:GetOwner()
    self.Insert = 0

    local selectedSlotIndex = Owner.SelectedSlotIndex
    if not selectedSlotIndex then return end
    
    local slot = Owner.Inventory[selectedSlotIndex]
    if not slot then return end

    if slot:GetQuantity() > 1 then
        slot:SetQuantity(slot:GetQuantity() - 1)        
        Owner:SyncSlot(selectedSlotIndex)
    else
        Owner:RemoveSlot(selectedSlotIndex)
        timer.Simple(0.1, function()
            if IsValid(Owner) then
                ClearPlayerWeapon(Owner)
            end
        end)
    end

    target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + self.AddHealth))
end

function SWEP:CancelHeal()
    self.Insert = 0
    self.Friend = nil
end

function SWEP:Think()
    local CT = CurTime()
    local Owner = self:GetOwner()
    
    if CLIENT then return end

    if self.NextUse and self.NextUse > CT then
        return
    end

    if self.SoundTimer and self.SoundTimer <= CT then
        if self.Insert == 2 then
            Owner:EmitSound("darky_rust.syringe-inject-friend")
            self.SoundTimer = nil   
        end
    end

    if self.Insert == 2 then
        if self.InsertTimer <= CT then
            self:Heal(self.Friend)
            self.TraceCheckTimer = nil

            self.NextUse = CurTime() + self.Delay
        end
        
        if self.TraceCheckTimer and self.TraceCheckTimer <= CT then
            if self:CheckTrace() != self.Friend then
                self:CancelHeal()
            else
                self.TraceCheckTimer = CurTime() + 0.2
            end
        end
    end
end

function SWEP:Holster()
    self.NextUse = nil
    self.Insert = 0
    self.Friend = nil
    return true
end
