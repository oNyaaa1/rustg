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

local WOOD_SEQ = {6, 14, 22, 32, 43, 55, 68, 83, 99, 128}
-- Function to check if a weapon is a valid woodcutting tool
gRust.Mining.IsValidWoodcuttingTool = function(weaponClass) return WOOD_WEAPONS[weaponClass] ~= nil end
-- Helper function to make trees fall and fade away
local function MakeTreeFall(ent)
    if not IsValid(ent) then return end
    -- Store tree information for respawn
    local treePos = ent:GetPos()
    local treeAngles = ent:GetAngles()
    local treeModel = ent:GetModel()
    -- Convert to physics object and make it fall
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetSolid(SOLID_VPHYSICS) -- Keep solid for world collision
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS) -- Don't collide with players but still with world
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(800) -- Realistic tree weight
        -- Choose a random direction to fall (like wind direction)
        local fallDirection = Angle(0, math.random(0, 360), 0):Forward()
        fallDirection.z = 0 -- Keep it horizontal
        fallDirection:Normalize()
        -- Apply torque to make it tip over from the base (like a real tree)
        local torque = Vector(fallDirection.y, -fallDirection.x, 0) * 3000
        phys:ApplyTorqueCenter(torque)
        -- Small initial push in the fall direction
        local push = fallDirection * 100
        push.z = -50 -- Slight downward force
        phys:ApplyForceCenter(push)
        -- Set the tree's center of mass higher to make it tip more naturally
        phys:SetMass(800)
    end

    -- Start transparency fade after 3 seconds (give more time to see the fall)
    timer.Simple(3, function()
        if IsValid(ent) then
            local alpha = 255
            local fadeTimer = "tree_fade_" .. ent:EntIndex()
            timer.Create(fadeTimer, 0.1, 40, function()
                -- Slower fade (4 seconds)
                if IsValid(ent) then
                    alpha = alpha - 6.375 -- Fade over 4 seconds (40 * 0.1 = 4s)
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

    -- Respawn tree after 10-15 minutes
    timer.Simple(math.random(600, 900), function()
        local newTree = ents.Create("rust_trees")
        if IsValid(newTree) then
            newTree:SetModel(treeModel)
            newTree:SetPos(treePos)
            newTree:SetAngles(treeAngles)
            newTree:Spawn()
            newTree:Activate()
            -- Reset tree health so it can be chopped again
            newTree.treeHealth = nil
            newTree.treeHits = nil
        end
    end)
end

gRust.Mining.MineTrees = function(ply, ent, maxHP, weapon, class)
     if not ply.Wood_Cutting_Tool then ply.Wood_Cutting_Tool = 0 end
    if ply.Wood_Cutting_Tool > CurTime() then return end
    ply.Wood_Cutting_Tool = CurTime() + 1
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
end