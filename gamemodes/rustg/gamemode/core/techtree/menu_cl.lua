function gRust.OpenTechTree(ent)

    if (IsValid(gRust.TechTreeMenu)) then return end

    gRust.TechTreeMenu = vgui.Create("gRust.TechTree")

    gRust.TechTreeMenu.Entity = ent

    gRust.TechTreeMenu:SetTree(ent.TechTree)

end



function gRust.CloseTechTree()

    if (IsValid(gRust.TechTreeMenu)) then

        gRust.TechTreeMenu:Remove()

    end

end



function gRust.ToggleTechTree(ent)

    if (IsValid(gRust.TechTreeMenu)) then

        gRust.CloseTechTree()

    else

        gRust.OpenTechTree(ent)

    end

end



function gRust.UpdateTechTree()
    if (!IsValid(gRust.TechTreeMenu)) then return end
    gRust.TechTreeMenu:Update()
end

net.Receive("gRust.OpenTechTree", function()
    local ent = net.ReadEntity()
    if IsValid(ent) then
        gRust.ToggleTechTree(ent)
    end
end)

net.Receive("gRust.UpdateTechTree", gRust.UpdateTechTree)