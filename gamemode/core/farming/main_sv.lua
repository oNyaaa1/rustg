gRust = gRust or {}
gRust.Mining = gRust.Mining or {}
util.AddNetworkString("gRust.TreeEffects")
local TREE_MODELS = {
    ["models/props_foliage/ah_super_large_pine002.mdl"] = 220,
    ["models/props_foliage/ah_large_pine.mdl"] = 190,
    ["models/props/cs_militia/tree_large_militia.mdl"] = 140,
    ["models/props_foliage/ah_medium_pine.mdl"] = 220,
    ["models/brg_foliage/tree_scotspine1.mdl"] = 160,
    ["models/props_foliage/ah_super_pine001.mdl"] = 180,
    ["models/props_foliage/ah_ash_tree001.mdl"] = 190,
    ["models/props_foliage/ah_ash_tree_cluster1.mdl"] = 140,
    ["models/props_foliage/ah_ash_tree_med.mdl"] = 170,
    ["models/props_foliage/ah_hawthorn_sm_static.mdl"] = 150,
    ["models/props_foliage/coldstream_cedar_trunk.mdl"] = 170,
    ["models/props_foliage/ah_ash_tree_lg.mdl"] = 190
}

local CREATURES_ENTITIES = {
    ["npc_vj_f_killerchicken"] = true
}

local HOTSPOT_RADIUS = 30
local function SendTreeHit(ply, ent)
    local tr = ply:GetEyeTrace()
    if not tr.Hit or tr.Entity ~= ent then return end
    local hitPos = tr.HitPos
    -- Offset the hitpos randomly around the tree
    local radius = 1 -- adjust for how far the X can move around
    local randomOffset = VectorRand() * radius
    randomOffset.z = math.Rand(-10, 10) -- smaller vertical offset
    hitPos = hitPos + randomOffset
    ent.HotspotPos = hitPos
    net.Start("gRust.TreeEffects")
    net.WriteVector(hitPos)
    net.WriteAngle(ply:GetAngles())
    net.WriteEntity(ent)
    net.Broadcast()
end

local WOOD_WEAPONS = {
    ["rust_rock"] = {
        mult = 1
    },
    ["rust_stonehatchet"] = {
        mult = 1.3
    },
    ["rust_hatchet"] = {
        mult = 1.8
    }
}

hook.Add("EntityTakeDamage", "gRust.ResourceHits", function(ent, dmg)
    local ply = dmg:GetAttacker()
    if not ply.DamageCoolDown then ply.DamageCoolDown = 0 end
    if not ply.TreeDamageCoolDown then ply.TreeDamageCoolDown = 0 end
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    local class = wep:GetClass()
    local maxHP = TREE_MODELS[ent:GetModel()]
    if maxHP then
        local validTool = gRust.Mining.IsValidWoodcuttingTool(class)
        if not validTool then
            dmg:SetDamage(0)
            return true
        end

        LoggerPlayer(ply, "is damaging a tree")
        --SendTreeHit(ply, ent)
        local attacker = dmg:GetAttacker()
        if not IsValid(attacker) or not attacker:IsPlayer() then return end
        local hitPos = dmg:GetDamagePosition()
        if ent.HotspotPos and hitPos:DistToSqr(ent.HotspotPos) <= (HOTSPOT_RADIUS * HOTSPOT_RADIUS) and ply.TreeDamageCoolDown < CurTime() then
            ply.TreeDamageCoolDown = CurTime() + 0.5
            gRust.Mining.MineTrees(ply, ent, maxHP, weapon, class)
        end

        -- Spawn a new hotspot after each hit
        SendTreeHit(ply, ent)
        if ply.DamageCoolDown < CurTime() then
            ply.DamageCoolDown = CurTime() + 0.5
            gRust.Mining.MineTrees(ply, ent, maxHP, weapon, class)
        end
    end

    local isCreature = CREATURES_ENTITIES[ent:GetClass()]
    if ent:GetClass() == "rust_creature_corpse" then gRust.Mining.MineCreatures(ply, ent, weapon, class) end
    if ent:GetClass() == "rust_ore" then
        local validTool = gRust.Mining.IsValidMiningTool(class)
        if not validTool then return true end
        LoggerPlayer(ply, "is mining ore.")
        gRust.Mining.MineOres(ply, ent, weapon, class)
    end
end)

-- Hook to spawn corpses when creatures die naturally
hook.Add("OnNPCKilled", "gRust.CreatureCorpses", function(npc, attacker, inflictor)
    if CREATURES_ENTITIES[npc:GetClass()] then
        -- Import the function from wildlife_sv.lua
        if gRust.Mining and gRust.Mining.SpawnCreatureCorpse then gRust.Mining.SpawnCreatureCorpse(npc) end
    end
end)