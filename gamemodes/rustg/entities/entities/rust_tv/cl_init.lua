include("shared.lua")

ENT.DisplayIcon = gRust.GetIcon("health")

function ENT:Initialize()
	self:ReloadPanel()
	if (LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 100000) then
		self.ShouldDraw = true
	end
end

function ENT:ReloadPanel()
	if (IsValid(self.Panel)) then self.Panel:Remove() end

	local Panel = vgui.Create("Panel")
	Panel:SetSize(560, 339)
	Panel:SetPaintedManually(true)

	local Web = Panel:Add("DHTML")
	Web:Dock(FILL)
	Web:OpenURL("https://grust.co/youtube.php?v=" .. self:GetVideoID() .. "&start=" .. math.floor(CurTime() - self:GetStart()))
	self.CurrentVideoID = self:GetVideoID()

	self.Panel = Panel
end

function ENT:Think()
	if (self:GetVideoID() ~= self.CurrentVideoID) then
		self:ReloadPanel()
	else
		local pl = LocalPlayer()
		if (pl:GetPos():DistToSqr(self:GetPos()) > 100000) then
			if (IsValid(self.Panel)) then
				self.Panel:Remove()
				self.ShouldDraw = false
			end
		else
			if (!IsValid(self.Panel)) then
				local tr = {}
				tr.start = pl:EyePos()
				tr.endpos = self:GetPos() + self:OBBCenter()
				tr.filter = {pl, self}
				debugoverlay.Line(tr.start, tr.endpos, 1, color_white, true)
				tr = util.TraceLine(tr)

				if (!tr.Hit) then
					self:ReloadPanel()
					self.ShouldDraw = true
				end
			end
		end
	end
	
	self:SetNextClientThink(CurTime() + 2)
	return true
end

local PosOffset = Vector(3.5, -28, 16.5)
local AngOffset = Angle(0, 90, 90)
function ENT:Draw()
	self:DrawModel()

	if (!self.ShouldDraw) then return end

	cam.Start3D2D(self:LocalToWorld(PosOffset), self:LocalToWorldAngles(AngOffset), 0.1)
		self.Panel:PaintManual()
	cam.End3D2D()
end

function ENT:OnRemove()
	if (IsValid(self.Panel)) then
		self.Panel:Remove()
	end
end

function ENT:Interact()
	gRust.StringQuery("ENTER YOUTUBE URL", "CANCEL", "CHANGE VIDEO", function(str)
		net.Start("gRust.UpdateTV")
		net.WriteEntity(self)
		net.WriteString(str)
		net.SendToServer()
	end)
end