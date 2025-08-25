--
Logger("Loading mining system")
hook.Add("PlayerSpawn", "FixSpawnShiz", function(ply)
    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 10)) do
        if v:GetClass() == "rust_ore" then ply:SetPos(v:GetPos() + Vector(v:OBBMins().x, v:OBBMins().y, v:OBBMins().z + 12)) end
    end
end)

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

local ORE_WEAPONS = {
    ["rust_rock"] = {
        ["metal.ore"] = 1,
        ["sulfur.ore"] = 1,
        ["stone"] = 1
    },
    ["rust_stonepickaxe"] = {
        ["metal.ore"] = 1.94,
        ["sulfur.ore"] = 2.57,
        ["stone"] = 2.11733
    },
    ["rust_pickaxe"] = {
        ["metal.ore"] = 2.4,
        ["sulfur.ore"] = 3,
        ["stone"] = 2.667
    },
    ["rust_jackhammer"] = {
        ["metal.ore"] = 2.4,
        ["sulfur.ore"] = 3,
        ["stone"] = 2.667
    }
}

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

local WOOD_SEQ = {6, 14, 22, 32, 43, 55, 68, 83, 99, 128}
local ORE_SEQ = {
    [1] = {
        item = "metal.ore",
        seq = {25, 25, 25, 25, 25, 25, 25, 25, 25, 25}
    },
    [2] = {
        item = "sulfur.ore",
        seq = {10, 10, 10, 10, 10, 10, 10, 10, 10, 10}
    },
    [3] = {
        item = "stone",
        seq = {39, 39, 38, 38, 38, 37, 37, 37, 36, 36}
    }
}

-- Helper function to make trees fall and fade away
local function MakeTreeFall(ent)
    if not IsValid(ent) then return end
    -- Convert to physics object and make it fall
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS) -- Keep solid for world collision
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS) -- Don't collide with players but still with world
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(500) -- Make it heavy enough to fall nicely
        -- Add a slight random impulse to make it fall in a direction
        local impulse = Vector(math.random(-200, 200), math.random(-200, 200), -100)
        phys:ApplyForceCenter(impulse)
    end

    -- Start transparency fade after 2 seconds
    timer.Simple(2, function()
        if IsValid(ent) then
            local alpha = 255
            local fadeTimer = "tree_fade_" .. ent:EntIndex()
            timer.Create(fadeTimer, 0.1, 30, function()
                if IsValid(ent) then
                    alpha = alpha - 8.5 -- Fade over 3 seconds (30 * 0.1 = 3s)
                    ent:SetColor(Color(255, 255, 255, math.max(0, alpha)))
                    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
                    if alpha <= 0 then
                        timer.Remove(fadeTimer)
                        ent:Remove()
                    end
                else
                    timer.Remove(fadeTimer)
                end
            end)
        end
    end)
end

hook.Add("EntityTakeDamage", "gRust.ResourceHits", function(ent, dmg)
    local ply = dmg:GetAttacker()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    local class = wep:GetClass()
    local notify = nil
    local maxHP = TREE_MODELS[ent:GetModel()]
    if maxHP then
        local tool = WOOD_WEAPONS[class]
        if not tool then return end
        if not ent.treeHealth then ent.treeHealth, ent.treeHits = maxHP, 0 end
        ent.treeHealth, ent.treeHits = ent.treeHealth - 20, ent.treeHits + 1
        local idx = math.min(ent.treeHits, #WOOD_SEQ)
        local reward = math.Round(WOOD_SEQ[idx] * tool.mult)
        ply:GiveItem("wood", reward)
        ply:SyncInventory()
        ply:SendNotification("Wood", NOTIFICATION_PICKUP, "materials/icons/pickup.png", "+" .. reward)
        if ent.treeHealth <= 0 then MakeTreeFall(ent) end
        return
    end

    if ent:GetClass() == "npc_vj_f_killerchicken" then
        local animalFatReward = math.random(4, 7) -- Give 1-3 animal fat per hit
        ply:GiveItem("cloth", animalFatReward)
        ply:SyncInventory()
        ply:SendNotification("Cloth", NOTIFICATION_PICKUP, "materials/icons/pickup.png", "+" .. animalFatReward)
        for k, v in pairs(ents.FindInSphere(ent:GetPos(), 200)) do
            if v:IsNPC() and v:GetClass() == "npc_vj_f_killerchicken" and v ~= ent then
                v:SetEnemy(ply)
                v:AddEntityRelationship(ply, D_HT, 99)
                v.HasDeathRagdoll = true
            end
        end
        return
    end

    if ent:GetClass() ~= "rust_ore" then return end
    local tool = ORE_WEAPONS[class]
    if not tool then return end
    local seq = ORE_SEQ[ent:GetSkin()] or ORE_SEQ[1]
    if not ent.oreHealth then ent.oreHealth, ent.oreHits = #seq.seq, 0 end
    ent.oreHealth, ent.oreHits = ent.oreHealth - 1, ent.oreHits + 1
    local idx = math.min(ent.oreHits, #seq.seq)
    local multForOre = tool[seq.item] or 1
    local reward = math.Round(seq.seq[idx] * multForOre)
    local itemClass = seq.item
    local itemData = gRust.Items[itemClass]
    local itemName = itemData and itemData:GetName() or itemClass
    ply:GiveItem(seq.item, reward)
    ply:SendNotification(itemName, NOTIFICATION_PICKUP, "materials/icons/pickup.png", "+" .. reward)
    if ent.oreHealth <= 0 then
        local pos = ent:GetPos()
        ent:Remove()
        timer.Simple(math.random(300, 600), function()
            local e = ents.Create("rust_ore")
            if IsValid(e) then
                e:SetPos(pos)
                e:SetSkin(math.random(1, 3))
                e:Spawn()
                e:Activate()
            end
        end)

        if ent:GetClass() == "rust_hemp" then
            local pos = ent:GetPos()
            timer.Simple(math.random(60, 120), function()
                local e = ents.Create("rust_hemp")
                if IsValid(e) then
                    e:SetPos(pos)
                    e:Spawn()
                    e:Activate()
                end
            end)
        end
    end
end)