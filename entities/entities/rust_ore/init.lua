AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local matr = {
    "models/blacksnow/rust_rock",
    "models/blacksnow/rock_ore"
}

function ENT:Initialize()
    self:SetModel("models/environment/ores/ore_node_stage1.mdl")
    self:SetSkin(math.random(1,3))

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
        phys:SetMass(50)
    end

    self:SetMaxHealth(300)
    self:SetHealth(300)

    self.AttacksRock = 0
    constraint.Weld(self, game.GetWorld(), 0, 0, 0, true, true)
    self.SpawnTime = CurTime()
end

function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    local ent = ents.Create("rust_ore")
    ent:SetPos(tr.HitPos + tr.HitNormal * 32)
    ent:Spawn()
    ent:Activate()
    return ent
end

function ENT:RecoveryTime(pos)
    timer.Simple(3, function()
        if not util.IsInWorld(pos) then return end
        local ent = ents.Create("rust_ore")
        ent:SetPos(pos)
        ent:Spawn()
        ent:Activate()
    end)
end

function ENT:OnTakeDamage(dmg)
    if not IsValid(self) then return end
    local attacker = dmg:GetAttacker()
    if not (IsValid(attacker) and attacker:IsPlayer()) then return end

    attacker:EmitSound("tools/rock_strike_1.mp3")

    self:SetHealth(self:Health() - dmg:GetDamage())
    self.AttacksRock = self.AttacksRock + dmg:GetDamage()

    if self.AttacksRock >= 50 then
        self:SetModel("models/environment/ores/ore_node_stage2.mdl")
    end
    if self.AttacksRock >= 100 then
        self:SetModel("models/environment/ores/ore_node_stage3.mdl")
    end
    if self.AttacksRock >= 170 then
        self:SetModel("models/environment/ores/ore_node_stage4.mdl")
    end

    if self:Health() <= 0 then
        self:RecoveryTime(self:GetPos())
        self:Remove()
    end
end

function ENT:Think()         end
function ENT:Use(btn, ply)   end
function ENT:StartTouch(ent) return false end
function ENT:EndTouch(ent)   return false end
function ENT:Touch(ent)      return false end
