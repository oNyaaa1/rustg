-- init.lua

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

function SWEP:Initialize()
    self:SetHoldType(self.HoldType or "normal")
    if self.SetupDataTables then
        self:SetupDataTables()
    end
end

function SWEP:Deploy()
    self:PlayAnimation("Deploy")
    if SERVER then
        local slot = self:GetInventorySlot()
        if slot and slot.GetClip then
            self:SetClip1(slot:GetClip())
        end
        self:SetNextPrimaryFire(CurTime() + (self.DrawTime or 1))
    end
    if self.HoldType then
        self:SetHoldType(self.HoldType)
    end
    return true
end

function SWEP:Holster()
    return true
end
