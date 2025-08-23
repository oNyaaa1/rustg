--[[
gamemodes/rust/entities/weapons/rust_melee/shared.lua
--]]
local BaseClass = baseclass.Get("rust_base")
SWEP.Base = "rust_base"
SWEP.Author = "Down"
SWEP.Primary.Automatic = true
SWEP.Range = 65
SWEP.SwingDelay = 0.5
SWEP.SwingInterval = 1.6
SWEP.SwingSound = "tools/rock_swing.mp3"
SWEP.StrikeSound = "tools/rock_strike_%i.mp3"
SWEP.ThrowAngle = Angle(12, 0, 0)
SWEP.HarvestAmount = {
    ["rust_ore"] = 1,
    ["tree"] = 1,
}

function SWEP:SetupDataTables(...)
    BaseClass.SetupDataTables(self)
    self:NetworkVar("Float", 0, "NextStrike")
end

function SWEP:Throw()
    if self.Thrown then return end
    local pl = self:GetOwner()
    if not IsValid(pl) then return end
    local ang = pl:GetAimVector():Angle()
    self:PlayAnimation("Throw")
    self.Thrown = true
    if CLIENT then return end
    timer.Simple(0.1, function()
        if not IsValid(self) or not IsValid(pl) then return end
        local selectedSlotIndex = pl.SelectedSlotIndex
        if not selectedSlotIndex then
            self.Thrown = false
            return
        end

        local slot = pl.Inventory[selectedSlotIndex]
        if not slot then
            self.Thrown = false
            return
        end

        local expectedItem = self.Ammo or self.ThrowableItem
        if expectedItem and slot:GetItem() ~= expectedItem then
            self.Thrown = false
            return
        end

        local ent = ents.Create("rust_projectile")
        if not IsValid(ent) then
            self.Thrown = false
            return
        end

        ent:SetOwner(pl)
        ent:SetPos(pl:GetShootPos())
        ent:SetAngles(ang + (self.ThrowAngle or Angle(0, 0, 0)))
        ent:SetItem(slot:Copy())
        ent:SetInteractable(true)
        ent:Spawn()
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then phys:SetMass(0.75) end
        ent:SetModel(self.WorldModel or "models/weapons/w_grenade.mdl")
        ent:Activate()
        ent:Throw(ang:Forward(), self.ThrowForce or 4000)
        if slot:GetQuantity() > 1 then
            slot:SetQuantity(slot:GetQuantity() - 1)
            pl:SyncSlot(selectedSlotIndex)
            local updatedSlot = pl.Inventory[selectedSlotIndex]
            if updatedSlot and self.SetClip then updatedSlot:SetClip(updatedSlot:GetQuantity()) end
        else
            pl:RemoveSlot(selectedSlotIndex)
            timer.Simple(0.1, function() if IsValid(pl) then ClearPlayerWeapon(pl) end end)
        end

        if self.Damage then ent.Damage = self.Damage end
        if self.StickOnHit then ent:SetStick(true) end
        if self.FuseTime then ent:SetFuse(CurTime() + self.FuseTime) end
        local oldPhysicsCollide = ent.PhysicsCollide
        ent.PhysicsCollide = function(self, coldata, collider)
            if oldPhysicsCollide then oldPhysicsCollide(self, coldata, collider) end
            local owner = self:GetOwner()
            local hit = coldata.HitEntity
            if IsValid(hit) and hit ~= owner then
                local dmg = DamageInfo()
                dmg:SetDamage(self.Damage or 50)
                dmg:SetAttacker(IsValid(owner) and owner or self)
                dmg:SetInflictor(self)
                dmg:SetDamageType(DMG_CLUB)
                dmg:SetDamagePosition(coldata.HitPos)
                hit:TakeDamageInfo(dmg)
                if self.HitSound then sound.Play(self.HitSound, coldata.HitPos, 75, 100) end
            end
        end

        self.Thrown = false
        if self.ThrowSound then pl:EmitSound(self.ThrowSound) end
        if self.ThrowDelay then self:SetNextPrimaryFire(CurTime() + self.ThrowDelay) end
    end)
end

function SWEP:PrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.Thrown then return end
    if self.Throwing then
        self:Throw()
        return
    end

    local pl = self:GetOwner()
    pl:SetAnimation(PLAYER_ATTACK1)
    self:EmitSound(self.SwingSound)
    self:PlayAnimation("SwingMiss")
    self:SetNextStrike(CurTime() + self.SwingDelay)
    self:SetNextPrimaryFire(CurTime() + self.SwingInterval)
end

function SWEP:SecondaryAttack()
end

local Mins = Vector(-4, -4, -4)
local Maxs = Vector(4, 4, 4)
function SWEP:Think()
    BaseClass.Think(self)
    local pl = self:GetOwner()
    local NextStrike = self:GetNextStrike()
    if NextStrike ~= 0 and CurTime() >= NextStrike then
        self:SetNextStrike(0)
        local tr = {}
        tr.start = pl:EyePos()
        tr.endpos = pl:EyePos() + pl:GetAimVector() * self.Range
        tr.filter = pl
        tr.mins = Mins
        tr.maxs = Maxs
        tr = util.TraceHull(tr)
        if tr.Hit then
            self:EmitSound(string.format(self.StrikeSound, math.random(1, 4)))
            self:PlayAnimation("SwingHit")
            if CLIENT then
                if tr.HitWorld then
                    self.WorldHits = self.WorldHits or 0
                    if self.WorldHits == 3 then
                        self.WorldHits = 0
                    else
                        self.WorldHits = self.WorldHits + 1
                    end
                else
                    self.WorldHits = 0
                end
            end

            if SERVER then
                local dmg = DamageInfo()
                dmg:SetDamage(self.Damage)
                dmg:SetAttacker(pl)
                dmg:SetDamageType(DMG_CLUB)
                dmg:SetInflictor(self)
                dmg:SetDamagePosition(tr.HitPos)
                if tr.Entity:IsPlayer() then
                    pl:LagCompensation(true)
                    local eyetr = pl:GetEyeTraceNoCursor()
                    pl:LagCompensation(false)
                    GAMEMODE:ScalePlayerDamage(tr.Entity, eyetr.HitGroup, dmg)
                end

                tr.Entity:TakeDamageInfo(dmg)
                self:GetInventorySlot():SetWear(self:GetInventorySlot():GetWear() - 8)
                pl:SyncSlot(self.InventorySlot)
                local Harvest = self.HarvestAmount[tr.Entity:GetClass()]
                if Harvest and Harvest > 0 then tr.Entity:Harvest(dmg, Harvest, self.BypassWeakspot) end
            end
        end

        pl:HaltSprint(0.6)
    end

    if pl:KeyDown(IN_ATTACK2) then
        if not self.Throwing then
            self:PlayAnimation("PullPin")
            self.Throwing = true
        end
    else
        if self.Throwing then
            self:PlayAnimation("SecondaryAttack")
            self.Throwing = false
        end
    end
end

function SWEP:Deploy()
    BaseClass.Deploy(self)
    self.Throwing = false
    self.Thrown = false
    self:SetHoldType("melee2")
end