-- rust_trees/init.lua
if SERVER then AddCSLuaFile() end

ENT.Type = "anim"
ENT.Base = "base_anim"

local TREE_MODELS = {
    ["models/props_foliage/ah_super_large_pine002.mdl"] = 220,
    ["models/props_foliage/ah_large_pine.mdl"] = 190,
    ["models/props/cs_militia/tree_large_militia.mdl"] = 140
}

function ENT:Initialize()
    self:SetModel("models/props_foliage/tree_pine04.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)

    self.TreeHealth = TREE_MODELS[self:GetModel()] or 200
end

function ENT:OnTakeDamage(dmg)
    local ply = dmg:GetAttacker()
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    local class = wep:GetClass()

    -- Only allow valid woodcutting tools
    if not gRust.Mining.IsValidWoodcuttingTool(class) then
        dmg:SetDamage(0)
        return true
    end

    -- Reduce health
    self.TreeHealth = self.TreeHealth - dmg:GetDamage()

    -- Send hit position to the player
    local trace = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 150,
        filter = ply
    })

    if trace.Hit and trace.Entity == self then
        ply:SetNWEntity("treeEnt", self)
        ply:SetNWVector("treeHitPos", trace.HitPos)
        -- Optional: send net message for hit effect
        net.Start("gRust.TreeEffects")
        net.WriteVector(trace.HitPos)
        net.WriteEntity(self)
        net.Send(ply)
    end

    -- Remove tree if dead
    if self.TreeHealth <= 0 then
        self:Remove()
    end

    -- Call mining function
    gRust.Mining.MineTrees(ply, self, TREE_MODELS[self:GetModel()] or 200, wep, class)
end
