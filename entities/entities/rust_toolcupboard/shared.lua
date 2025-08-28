ENT.Base = "rust_storage"
ENT.ShowHealth = true
ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/tool_cupboard.mdl"
ENT.Deploy.Sound = "deploy/tool_cupboard_deploy.wav"
ENT.Deploy.OnDeploy = function(pl, ent, tr) ent:Authorize(pl) end
ENT.Pickup = "tool_cupboard"
ENT.Options = {
    {
        Name = "Clear Authorized List",
        Desc = "Clears the authorize list",
        Icon = gRust.GetIcon("clearlist"),
        Func = function()
            net.Start("gRust.ClearAuthlist")
            net.SendToServer()
        end
    },
    {
        Name = "Open",
        Desc = "View the contents of this tool cupboard",
        Icon = gRust.GetIcon("open"),
        Func = function()
            local ent = LocalPlayer():GetEyeTraceNoCursor().Entity
            if not ent.gRust then return end
            ent:Interact()
        end
    },
    {
        Name = "Authorize",
        Desc = "Add yourself to the authorize list",
        Icon = gRust.GetIcon("deauthorize"),
        Func = function()
            net.Start("gRust.Authorize")
            net.SendToServer()
        end
    },
    {
        Name = "Deauthorize",
        Desc = "Removes yourself from the authorize list",
        Icon = gRust.GetIcon("deauthorize"),
        Func = function()
            net.Start("gRust.Deauthorize")
            net.SendToServer()
        end
    }
}
