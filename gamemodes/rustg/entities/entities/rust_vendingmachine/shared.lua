DEFINE_BASECLASS("rust_storage")

ENT.Base = "rust_storage"



ENT.Deploy = {}

ENT.Deploy.Model = "models/deployable/vending_machine.mdl"

ENT.Deploy.Socket = "vending_machine"



ENT.Options =

{

    {

        Name    = "Toggle Broadcasting",

        Desc    = "",

        Icon    = gRust.GetIcon("power"),

        Func    = function(ent)

			net.Start("gRust.ToggleBroadcasting")

				net.WriteEntity(ent)

			net.SendToServer()

        end

    },

    {

        Name    = "Open",

        Desc    = "",

        Icon    = gRust.GetIcon("open"),

        Func    = function(ent)

            ent:Interact(LocalPlayer())

        end

    },

    {

        Name    = "Administrate",

        Desc    = "",

        Icon    = gRust.GetIcon("gear"),

        Func    = function(ent)

            ent:AdminMenu(LocalPlayer())

        end

    },

}



function ENT:SetupDataTables()

    BaseClass.SetupDataTables(self)

    self:NetworkVar("Bool", 1, "Vending")

end