DEFINE_BASECLASS("rust_storage")

include("shared.lua")



function ENT:Draw()

    self:DrawModel()

end



function ENT:Interact()

	LocalPlayer():RequestInventory(self)



    gRust.OpenInventory(self)

end



function ENT:Toggle()

    net.Start("gRust.ProcessToggle")

    net.WriteEntity(self)

    net.SendToServer()

end