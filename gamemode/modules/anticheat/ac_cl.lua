gRust.AC = gRust.AC or {

    netStart = net.Start,

    netSendToServer = net.SendToServer,

}



hook.Add("InitPostEntity", "gRust.AC.InitPostEntity", function()

    gRust.AC.netStart("gRust.AC.SendData")

    gRust.AC.netSendToServer()

end)



net.Receive("gRust.AC.SendData", function()

    gRust.AC.NetCode = net.ReadString()

end)