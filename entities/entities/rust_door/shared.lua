DEFINE_BASECLASS("rust_base")

ENT.Base = "rust_base"



ENT.AutomaticFrameAdvance = true



ENT.DisplayIcon = gRust.GetIcon("door")

ENT.DrawHalo    = true



function ENT:SetupDataTables()

    BaseClass.SetupDataTables(self)

    self:NetworkVar("Bool", 1, "Opened")

end



ENT.Deploy          = {}

ENT.Deploy.Model    = "models/deployable/door_wood.mdl"

ENT.Deploy.Socket   = "door"

ENT.Deploy.OnDeploy = function(pl, ent, tr)

end



ENT.CanPickup   = true



ENT.Options =

{

    {

        Name    = "Open/Close",

        Desc    = "Open or Closes the door",

        Icon    = gRust.GetIcon("door"),

        Func    = function(i, ent)

            LocalPlayer():Interact(ent)

        end

    },

    {

        Name    = "Pickup Lock",

        Desc    = "Open or Closes the door",

        Icon    = gRust.GetIcon("loot"),

        Func    = function(i, ent)

            net.Start("gRust.PickupLock")

            net.SendToServer()

        end,

        Condition = function(ent)

            return ent:GetBodygroup(2) ~= 0

        end,

    },

    {

        Name    = "Enter Code",

        Desc    = "Open or Closes the door",

        Icon    = gRust.GetIcon("unlock"),

        Func    = function(i, ent)

            gRust.NumQuery(function(i)

                net.Start("gRust.EnterCode")

                net.WriteUInt(tonumber(i), 15)

                net.SendToServer()

            end)

        end,

        Condition = function(ent)

            return ent:GetBodygroup(2) == 1

        end,

    },

    {

        Name    = "Set Code",

        Desc    = "Open or Closes the door",

        Icon    = gRust.GetIcon("changecode"),

        Func    = function(i, ent)

            gRust.NumQuery(function(i)

                net.Start("gRust.SetCode")

                net.WriteUInt(tonumber(i), 15)

                net.SendToServer()

            end)

        end,

        Condition = function(ent)

            return ent:GetBodygroup(2) == 1

        end,

    },

    {

        Name    = "Knock",

        Desc    = "Open or Closes the door",

        Icon    = gRust.GetIcon("knock"),

        Func    = function(i, ent)

            net.Start("gRust.knock")

            net.SendToServer()

        end

    },

    {

        Name    = "Pickup",

        Desc    = "Open or Closes the door",

        Icon    = gRust.GetIcon("give"),

        Func    = function(ent)

            net.Start("gRust.Pickup")

            net.WriteEntity(ent)

            net.SendToServer()

        end,

        Condition = function(ent)

            if (!IsValid(ent)) then return false end

            return ent:GetBodygroup(2) == 0

        end,

    },

}