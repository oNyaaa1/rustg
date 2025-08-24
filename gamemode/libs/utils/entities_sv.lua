concommand.Add("gr_entitytp", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not ply:IsSuperAdmin() then
        ply:ChatPrint("You must be a superadmin to use this command!")
        return
    end
    if not args[1] then
        ply:ChatPrint("Please specify an entity class. Example: tp_to_entity rust_ore")
        return
    end

    local class = args[1]
    local entsFound = ents.FindByClass(class)
    if #entsFound == 0 then
        ply:ChatPrint("No entities found with class: " .. class)
        return
    end

    local closest, dist, ppos = nil, math.huge, ply:GetPos()
    for _, ent in ipairs(entsFound) do
        if IsValid(ent) then
            local d = ppos:Distance(ent:GetPos())
            if d < dist then dist, closest = d, ent end
        end
    end

    LoggerAdmin("Player " .. ply:Nick() .. " teleported to nearest entity: " .. class)

    if IsValid(closest) then
        ply:SetPos(closest:GetPos() + Vector(0, 0, 50))
        ply:ChatPrint("Teleported to nearest entity: " .. class)
    else
        ply:ChatPrint("No valid entities found with class: " .. class)
    end
end)

concommand.Add("gr_entitycreate", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not ply:IsSuperAdmin() then
        ply:ChatPrint("You must be a superadmin to use this command!")
        return
    end
    if not args[1] then
        ply:ChatPrint("Please specify an entity class. Example: gr_entitycreate rust_ore")
        return
    end

    local class = args[1]
    local ent = ents.Create(class)
    if not IsValid(ent) then
        ply:ChatPrint("Failed to create entity: " .. class)
        return
    end

    LoggerAdmin("Player " .. ply:Nick() .. " created entity: " .. class)

    ent:SetPos(ply:GetPos() + Vector(0, 0, 50))
    ent:Spawn()
    ent:Activate()
    ply:ChatPrint("Created entity: " .. class)
end)