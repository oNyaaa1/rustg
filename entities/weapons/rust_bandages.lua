AddCSLuaFile()

SWEP.Base = "rust_base"

SWEP.PrintName = "Bandages"
SWEP.Instructions = "Left click to heal yourself"

SWEP.ViewModel = "models/weapons/darky_m/c_bandages.mdl"
SWEP.WorldModel = "models/weapons/darky_m/w_bandages.mdl"

SWEP.VMPos = Vector()
SWEP.VMAng = Vector()
SWEP.DownPos = Vector(0, 0, -2)

SWEP.HoldType = "knife"
SWEP.DrawTime = 1

SWEP.Delay = 4 -- Time to apply bandage
SWEP.AddHealth = 15 -- Health restored per bandage

function SWEP:PrimaryAttack()
    local pl = self:GetOwner()
    if not IsValid(pl) then return end
    
    -- Check if player is already at full health
    if pl:Health() >= pl:GetMaxHealth() then
        if SERVER then
            pl:ChatPrint("You are already at full health!")
        end
        return
    end
    
    self:PlayAnimation("PrimaryAttack")
    self.NextUse = CurTime() + self.Delay
    self:SetNextPrimaryFire(self.NextUse)
    
    if SERVER then
        pl:ChatPrint("Applying bandage...")
    end
end

function SWEP:Think()
    if SERVER and self.NextUse and self.NextUse < CurTime() then
        self.NextUse = nil

        local pl = self:GetOwner()
        if not IsValid(pl) then return end

        -- Heal the player
        self:Heal(pl)
    end
end

function SWEP:Heal(target)
    local Owner = self:GetOwner()
    
    local selectedSlotIndex = Owner.SelectedSlotIndex
    if not selectedSlotIndex then return end
    
    local slot = Owner.Inventory[selectedSlotIndex]
    if not slot then return end

    -- Apply healing
    target:SetHealth(math.min(target:GetMaxHealth(), target:Health() + self.AddHealth))
    
    -- Play healing sound TODO: Replace
    Owner:EmitSound("items/smallmedkit1.wav")
    

    -- Consume one bandage (same logic as syringe)
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
end

function SWEP:Holster()
    self.NextUse = nil
    return true
end

function SWEP:SecondaryAttack()
    -- No secondary attack for bandages
end