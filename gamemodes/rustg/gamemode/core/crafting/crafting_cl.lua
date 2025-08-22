gRust.CraftQueue = gRust.CraftQueue or {}



function gRust.RequestCraft(item, amount, skin)

    net.Start("gRust.Craft")

        net.WriteString(item)

        net.WriteUInt(amount, 7)

        net.WriteString(skin)

    net.SendToServer()

end
