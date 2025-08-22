DEFINE_BASECLASS("rust_base")
ENT.Base = "rust_base"

ENT.Pickup = "tv"

ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/rustTV.mdl"
ENT.Deploy.ModelScale = 1.5
ENT.Deploy.GetPosition = function(pl)
	local tr = {}
	tr.start = pl:EyePos()
	tr.endpos = pl:EyePos() + pl:GetAimVector() * 125
	tr.filter = pl
	tr = util.TraceLine(tr)

	if (tr.Hit) then
		return tr.HitPos, tr.HitNormal:Angle()
	else
		return tr.HitPos, Angle(0, pl:EyeAngles().y + 180, 0)
	end
end
ENT.Deploy.CanDeploy = function(pl, ent)
	local tr = {}
	tr.start = pl:EyePos()
	tr.endpos = pl:EyePos() + pl:GetAimVector() * 125
	tr.filter = pl
	tr = util.TraceLine(tr)

	local nrm = tr.HitNormal
	return tr.Hit and nrm.z < 0.5
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetworkVar("String", 1, "VideoID")
	self:NetworkVar("Int", 0, "Start")
end

ENT.Options =
{
    {
        Name    = "Set URL",
        Desc    = "",
        Icon    = gRust.GetIcon("health"),
        Func    = function(ent)
            ent:Interact(LocalPlayer())
        end
    },
    {
        Name    = "Stop Video",
        Desc    = "",
        Icon    = gRust.GetIcon("x"),
        Func    = function(ent)
			net.Start("gRust.UpdateTV")
				net.WriteEntity(ent)
				net.WriteString("")
			net.SendToServer()
        end
    }
}