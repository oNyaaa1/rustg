hook.Add("InitPostEntity", "gRust.SendNetReady", function()
    timer.Simple(1, function()
        gRust.LoadHotbar(ScrW() - (ScrW() * 0.365 + ScrW() * 0.35), ScrW() * 0.365 - ScrW() * 0.0055, ScrH() * 0.0055)
        net.Start("gRust.NetReady")
        net.SendToServer()
    end)
end)

local PLAYER = FindMetaTable("Player")
function PLAYER:Interact(ent)
    ent = ent or self:GetEyeTraceNoCursor().Entity
    net.Start("gRust.Interact")
    net.WriteEntity(ent)
    net.SendToServer()
end
