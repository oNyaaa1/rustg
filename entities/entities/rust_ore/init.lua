AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local matr = {"models/blacksnow/rust_rock", "models/blacksnow/rock_ore",}
function ENT:Initialize()
    self.Entity:SetModel("models/environment/ores/ore_node_stage1.mdl") --"..math.random(1,4).."
    --self.Entity:SetMaterial( table.Random( matr ) )
    -- 1 metal, 2 sulfur, 3 rock
    self:SetSkin(math.random(1, 3))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:EnableMotion(false)
    end

    constraint.Weld(self, Entity(0), 0, 0, 0, true, true)
    self.Ent_Health = 300
    --self:SetMaterial("Model/effects/vol_light001")
    self:DrawShadow()
    self.SpawnTime = 0
    self.EntCount = 0
end

function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    local ent = ents.Create("rust_ore")
    ent:SetPos(tr.HitPos + tr.HitNormal * 32)
    ent:Spawn()
    ent:Activate()
    return ent
end

function ENT:Think()
end

function ENT:RecoveryTime(pos)
    timer.Simple(3, --60 * math.random(28,32),
        function()
        local ent = ents.Create("rust_ore")
        ent:SetPos(pos)
        ent:Spawn()
        ent:Activate()
    end)
end

function ENT:OnTakeDamage(dmg)
    local ply = dmg:GetAttacker()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsValid(ply:GetActiveWeapon()) then return end
    local wep = ply:GetActiveWeapon()
   
    if not IsValid(self) then return end
    if IsValid(ply) and IsValid(wep) then
        -- 1 metal, 2 sulfur, 3 Rock
        if self.AttacksRock == nil then self.AttacksRock = 0 end
        ply:EmitSound("tools/rock_strike_1.mp3")
        self.AttacksRock = self.AttacksRock + 10
        if self.AttacksRock >= 100 then self.Entity:SetModel("models/environment/ores/ore_node_stage2.mdl") end
        if self.AttacksRock >= 150 then self.Entity:SetModel("models/environment/ores/ore_node_stage3.mdl") end
        if self.AttacksRock >= 200 then
            self:RecoveryTime(self:GetPos())
            self:Remove()
        end
    end
end

function ENT:Use(btn, ply)
end

function ENT:StartTouch(entity)
    return false
end

function ENT:EndTouch(entity)
    return false
end

function ENT:Touch(entity)
    return false
end