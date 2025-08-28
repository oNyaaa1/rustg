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

hook.Add("EntityTakeDamage", "gRust.ResourceHits", function(ent, dmg)
    local ply = dmg:GetAttacker()
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
        net.Start("gRust.TreeEffects")
        net.WriteVector(ply:GetEyeTrace().HitPos)
        net.WriteEntity(ent)
        net.Send(ply)
        gRust.Mining.MineTrees(ply, ent, maxHP, weapon, class)
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