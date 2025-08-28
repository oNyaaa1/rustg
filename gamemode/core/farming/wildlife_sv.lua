local CREATURE_LOOT = {
    ["npc_rust_chicken"] = {
        health = 100, -- How much damage needed to kill it
        loot = {
            {item = "bone.fragments", min = 1, max = 1, name = "Bone Fragments"},
            {item = "fat.animal", min = 1, max = 1, name = "Animal Fat"}
        }
    },
    ["npc_rust_deer"] = {
        health = 150, -- How much damage needed to kill it
        loot = {
            {item = "bone.fragments", min = 1, max = 2, name = "Bone Fragments"},
            {item = "fat.animal", min = 1, max = 2, name = "Animal Fat"}
        }
    },
    ["npc_rust_bear"] = {
        health = 200, -- How much damage needed to kill it
        loot = {
            {item = "bone.fragments", min = 1, max = 3, name = "Bone Fragments"},
            {item = "fat.animal", min = 1, max = 3, name = "Animal Fat"}
        }
    }

}

-- Helper function to make creature fall as a corpse (like in Rust)
local function MakeCreatureCorpse(ent, damageForce)
    if not IsValid(ent) then 
        return 
    end
    
    -- Safety check - make sure this is actually a creature we handle
    if not CREATURE_LOOT[ent:GetClass()] then
        return
    end
    
    -- Store creature information
    local creaturePos = ent:GetPos()
    local creatureAngles = ent:GetAngles()
    local creatureModel = ent:GetModel()
    local creatureClass = ent:GetClass()
    
    -- Store the entity index for safety
    local originalEntIndex = ent:EntIndex()
    
    -- Find ground position to prevent falling through
    local traceData = {
        start = creaturePos + Vector(0, 0, 50),
        endpos = creaturePos - Vector(0, 0, 100),
        filter = ent
    }
    local trace = util.TraceLine(traceData)
    local groundPos = trace.Hit and trace.HitPos or creaturePos
    -- Start the corpse higher in the air so it falls down naturally
    local spawnPos = groundPos + Vector(0, 0, 10) -- Start 100 units above ground
    
    -- Create a creature corpse entity (like in Rust)
    local corpse = ents.Create("rust_creature_corpse")
    if not IsValid(corpse) then
        return
    end
    
    corpse:SetModel(creatureModel)
    corpse:SetPos(spawnPos) -- Spawn in the air
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
    
    -- Set up the corpse with proper health and type
    corpse:SetHealth(CREATURE_LOOT[creatureClass].health)
    corpse:SetMaxHealth(CREATURE_LOOT[creatureClass].health)
    corpse:SetCreatureType(creatureClass)
    
    -- Make it slightly darker to show it's dead
    corpse:SetColor(Color(180, 180, 180, 255))
    
    -- Remove the corpse after 10 minutes (like in Rust)
    timer.Simple(600, function()
        if IsValid(corpse) then
            corpse:Remove()
        end
    end)
    
    -- Remove ONLY the original creature that died (safety check)
    if IsValid(ent) and ent:EntIndex() == originalEntIndex then
        ent:Remove()
    end
    
    return corpse
end

-- Expose function for external use
gRust.Mining.SpawnCreatureCorpse = function(ent)
    return MakeCreatureCorpse(ent)
end

gRust.Mining.MineCreatures = function(ply, ent, weapon, class)
    if not ply.Wood_Cutting_Tool then ply.Wood_Cutting_Tool = 0 end
    if ply.Wood_Cutting_Tool > CurTime() then return end
    ply.Wood_Cutting_Tool = CurTime() + 1
    -- Only handle creature corpses
    if ent:GetClass() == "rust_creature_corpse" then
        local creatureType = ent:GetCreatureType()
        local creatureData = CREATURE_LOOT[creatureType]
        if not creatureData then return end
        
        -- Reduce health using rust_base system
        local currentHealth = ent:Health()
        local newHealth = currentHealth - 10
        ent:SetHealth(newHealth)
        
        -- Give loot only from corpses
        for _, lootItem in pairs(creatureData.loot) do
            local amount = math.random(lootItem.min, lootItem.max)
            ply:GiveItem(lootItem.item, amount)
            ply:SendNotification(lootItem.name, NOTIFICATION_PICKUP, "materials/icons/pickup.png", "+" .. amount)
        end
        
        ply:SyncInventory()
        
        -- Remove corpse when fully mined
        if newHealth <= 0 then
            ent:Remove()
        end
    end
end

