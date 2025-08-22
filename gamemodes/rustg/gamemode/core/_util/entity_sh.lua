local ENTITY = FindMetaTable("Entity")
local UpOffset = Vector(0, 0, 5)
function ENTITY:InValidPos()
	local ModelBounds = self:GetModelBounds()
	local pos = self:GetPos()
	local point1 = pos + self:GetRight() * ModelBounds + self:GetForward() * ModelBounds.x - self:GetUp() * ModelBounds.z
	local point2 = pos - self:GetRight() * ModelBounds.y - self:GetForward() * ModelBounds.x
	local point3 = pos - self:GetRight() * ModelBounds.y + self:GetForward() * ModelBounds.x - self:GetUp() * ModelBounds.z
	local point4 = point1 - self:GetForward() * ModelBounds.y
	local tr1 = {}
	tr1.start = point1 + UpOffset
	tr1.endpos = point2 + UpOffset
	tr1.filter = self
	tr1 = util.TraceLine(tr1)
	local tr2 = {}
	tr2.start = point3 + UpOffset
	tr2.endpos = point4 + UpOffset
	tr2.filter = self
	tr2 = util.TraceLine(tr2)
	--[[hook.Add("HUDPaint", "uhiuashiuas", function()

		local p1 = point1:ToScreen()

		local p2 = tr1.HitPos:ToScreen()

		local p3 = point3:ToScreen()

		local p4 = tr2.HitPos:ToScreen()

		surface.SetDrawColor(174, 0, 255)

		surface.DrawLine(p1.x, p1.y, p2.x, p2.y)

		surface.SetMaterial(Material("ui/hud/crosshair.png"))

		surface.DrawTexturedRect(p1.x - 12, p1.y - 12, 24, 24)

		surface.SetDrawColor(255, 89, 227)

		surface.DrawTexturedRect(p2.x - 12, p2.y - 12, 24, 24)

		surface.SetDrawColor(0, 60, 255)

		surface.DrawLine(p3.x, p3.y, p4.x, p4.y)

		surface.SetMaterial(Material("ui/hud/crosshair.png"))

		surface.DrawTexturedRect(p3.x - 12, p3.y - 12, 24, 24)

		surface.SetDrawColor(89, 128, 255)

		surface.DrawTexturedRect(p4.x - 12, p4.y - 12, 24, 24)

	end)]]
	return not (tr1.Hit or tr2.Hit)
end

local VECTOR = FindMetaTable("Vector")
function VECTOR:ValidModelPos(ent)
	local ModelBounds = ent:GetModelBounds()
	local point1 = self + ent:GetRight() * ModelBounds + ent:GetForward() * ModelBounds.x - ent:GetUp() * ModelBounds.z
	local point2 = self - ent:GetRight() * ModelBounds.y - ent:GetForward() * ModelBounds.x
	local point3 = self - ent:GetRight() * ModelBounds.y + ent:GetForward() * ModelBounds.x - ent:GetUp() * ModelBounds.z
	local point4 = point1 - ent:GetForward() * ModelBounds.y
	local tr1 = {}
	tr1.start = point1 + UpOffset
	tr1.endpos = point2 + UpOffset
	tr1.filter = ent
	tr1 = util.TraceLine(tr1)
	local tr2 = {}
	tr2.start = point3 + UpOffset
	tr2.endpos = point4 + UpOffset
	tr2.filter = ent
	tr2 = util.TraceLine(tr2)
	return not (tr1.Hit or tr2.Hit)
end