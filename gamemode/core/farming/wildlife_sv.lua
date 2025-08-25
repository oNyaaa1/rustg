local CREATURE_LOOT = {
    ["npc_vj_f_killerchicken"] = {
        health = 100, -- How much damage needed to kill it
        loot = {
            {item = "cloth", min = 1, max = 2, name = "Cloth"},
            {item = "fat.animal", min = 1, max = 3, name = "Animal Fat"}
        }
    }

}

-- Helper function to make creature fall as a corpse (like in Rust)
local function MakeCreatureCorpse(ent, damageForce)
    if not IsValid(ent) then 
        return 
    end
    
    -- Store creature information
    local creaturePos = ent:GetPos()
    local creatureAngles = ent:GetAngles()
    local creatureModel = ent:GetModel()
    local creatureClass = ent:GetClass()
    
    -- Find ground position to prevent falling through
    local traceData = {
        start = creaturePos + Vector(0, 0, 50),
        endpos = creaturePos - Vector(0, 0, 100),
        filter = ent
    }
    local trace = util.TraceLine(traceData)
    local groundPos = trace.Hit and trace.HitPos or creaturePos
    groundPos = groundPos + Vector(0, 0, 10) -- Lift 10 units above ground
    
    -- Create a static prop as corpse (like in Rust)
    local corpse = ents.Create("prop_physics")
    if not IsValid(corpse) then
        return
    end
    
    corpse:SetModel(creatureModel)
    corpse:SetPos(groundPos)
    corpse:SetAngles(creatureAngles)
    
    -- Try spawning with error handling
    local success, err = pcall(function()
        corpse:Spawn()
        corpse:Activate()
    end)
    
    if not success then
        if IsValid(corpse) then corpse:Remove() end
        return
    end
    
    -- Make it fall down and settle properly
    local phys = corpse:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMaterial("flesh") -- Set material to prevent bouncing
        
        -- Apply gentle downward force
        phys:ApplyForceCenter(Vector(0, 0, -500))
        
        -- After settling, make it static and ensure it doesn't fall through
        timer.Simple(3, function()
            if IsValid(corpse) and IsValid(phys) then
                -- Do another ground check to make sure it's positioned correctly
                local finalTrace = {
                    start = corpse:GetPos() + Vector(0, 0, 20),
                    endpos = corpse:GetPos() - Vector(0, 0, 50),
                    filter = corpse
                }
                local finalGroundTrace = util.TraceLine(finalTrace)
                if finalGroundTrace.Hit then
                    corpse:SetPos(finalGroundTrace.HitPos + Vector(0, 0, 5))
                end
                
                phys:EnableMotion(false)
                corpse:SetMoveType(MOVETYPE_NONE)
                corpse:SetSolid(SOLID_VPHYSICS)
            end
        end)
    else
        -- If no physics, just make sure it's positioned correctly
        corpse:SetMoveType(MOVETYPE_NONE)
        corpse:SetSolid(SOLID_VPHYSICS)
    end
    
    -- Mark as mineable corpse
    corpse.isCreatureCorpse = true
    corpse.creatureType = creatureClass
    corpse.miningHealth = CREATURE_LOOT[creatureClass].health
    corpse.maxMiningHealth = CREATURE_LOOT[creatureClass].health
    
    -- Make it slightly darker to show it's dead
    corpse:SetColor(Color(180, 180, 180, 255))
    
    -- Remove the corpse after 10 minutes (like in Rust)
    timer.Simple(600, function()
        if IsValid(corpse) then
            corpse:Remove()
        end
    end)
    
    return corpse
end

-- Expose function for external use
gRust.Mining.SpawnCreatureCorpse = function(ent)
    return MakeCreatureCorpse(ent)
end

gRust.Mining.MineCreatures = function(ply, ent, weapon, class)
    -- Only handle creature corpses
    if ent.isCreatureCorpse and ent.creatureType then
        local creatureData = CREATURE_LOOT[ent.creatureType]
        if not creatureData then return end
        
        -- Initialize mining health if not set
        if not ent.miningHealth then
            ent.miningHealth = creatureData.health
        end
        
        -- Reduce health
        ent.miningHealth = ent.miningHealth - 10
        
        -- Give loot only from corpses
        for _, lootItem in pairs(creatureData.loot) do
            local amount = math.random(lootItem.min, lootItem.max)
            ply:GiveItem(lootItem.item, amount)
            ply:SendNotification(lootItem.name, NOTIFICATION_PICKUP, "materials/icons/pickup.png", "+" .. amount)
        end
        
        ply:SyncInventory()
        
        -- Remove corpse when fully mined
        if ent.miningHealth <= 0 then
            ent:Remove()
        end
    end
end

