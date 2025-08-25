gRust.Mining.MineCreatures = function(ply, ent)
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
    end

    -- Handle creature damage
end
