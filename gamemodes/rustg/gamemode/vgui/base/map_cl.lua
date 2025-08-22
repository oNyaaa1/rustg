local boundw = -14587

local boundwmax = 14659

	

local boundh = 15101

local boundhmax = -14929



function gRust.VectorToMap(vec)

	local x = math.Remap(vec.x, boundw, boundwmax, ScrW() * 0.2332, ScrW() * 0.7664)

	local y = math.Remap(vec.y, boundh, boundhmax, ScrH() * 0.0069, ScrH() * 0.9861)



	return x, y

end



function gRust.MapToVector(x, y)

	local scrw, scrh = ScrW(), ScrH()

	

	x = math.Remap(x, (scrw - scrh) * 0.5, scrw - ((scrw - scrh) * 0.5), boundw, boundwmax)

	y = math.Remap(y, 0, scrh, boundh, boundhmax)



	return Vector(x, y, 0)

end



timer.Simple(0, function()

	gRust.Map = gRust.Map or {}

	

	local PANEL = {}

	

	local MaxScroll = 500

	

	AccessorFunc(PANEL, "m_Scroll", "Scroll", FORCE_NUMBER)

	

	function PANEL:Init()

		self:SetWide(ScrW())

		self:SetTall(ScrH())



		self:SetAlpha(0)

		self:AlphaTo(255, 0.075, 0)



		self.Zoom = 0

		self:SetZPos(100)

	

		self:SetScroll(0)

	

		self:SetMouseInputEnabled( true )

	

		self.MarkerX = gRust.Map and gRust.Map.MarkerX

		self.MarkerY = gRust.Map and gRust.Map.MarkerY

	end

	

	function PANEL:OnMouseWheeled(sc)

		self:SetScroll(math.Clamp(self:GetScroll() + (sc * 100), 0, MaxScroll))

	end

	

	function PANEL:Exit()

		self:AlphaTo(0, 0.075, 0, function()

			self:Remove()

		end)

	end

		

	function PANEL:OnClicked(x, y)

		if (self.MarkerX == x && self.MarkerY == y) then

			gRust.Map.MarkerX = nil

			gRust.Map.MarkerY = nil

			self.MarkerX = nil

			self.MarkerY = nil

			return

		end

	

		gRust.Map.MarkerX = x

		gRust.Map.MarkerY = y

		self.MarkerX = x

		self.MarkerY = y

	

		surface.PlaySound("piemenu/piemenu_selectionchange.wav")

	end

	

	function surface.DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )

		

		local c = math.cos( math.rad( rot ) )

		local s = math.sin( math.rad( rot ) )

		

		local newx = y0 * s - x0 * c

		local newy = y0 * c + x0 * s

		

		surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )

		

	end

	

	local WaypointIcon = gRust.GetIcon("waypoint")

	local WaypointSize = ScrH() * 0.03

	

	local DeathIcon = gRust.GetIcon("death_marker")

	local DeathIconSize = ScrH() * 0.045

	

	local MapMaterial = Material("materials/misc/map.png")

	

	local PlayerIcon = gRust.GetIcon("player_marker")

	local PlayerIconSize = ScrH() * 0.015

	function PANEL:Paint(w, h)

		local ar = w / h

		local sc = 0--self:GetScroll()

	

		surface.SetDrawColor(255, 255, 255)

		surface.SetMaterial(MapMaterial)

		surface.DrawTexturedRect(-sc * 0.75, -sc * 0.5, (w + sc * ar), (h + sc))

	

		if (gRust.DeathPosX && gRust.DeathPosY) then

			surface.SetDrawColor(255, 255, 255)

			surface.SetMaterial(DeathIcon)

			surface.DrawTexturedRect(gRust.DeathPosX - DeathIconSize * 0.5, gRust.DeathPosY - DeathIconSize, DeathIconSize, DeathIconSize)

		end

	

		if (self.MarkerX && self.MarkerY) then

			surface.SetDrawColor(255, 255, 255)

			surface.SetMaterial(WaypointIcon)

			surface.DrawTexturedRect(self.MarkerX - WaypointSize * 0.5, self.MarkerY - WaypointSize, WaypointSize, WaypointSize)

		end

	

		local pl = LocalPlayer()

	

		local pos = pl:GetPos()

		local x, y = gRust.VectorToMap(pos)



		surface.SetDrawColor(255, 255, 255)

		surface.SetMaterial(PlayerIcon, "smooth")

		surface.DrawTexturedRectRotatedPoint(x, y, PlayerIconSize, PlayerIconSize, pl:GetAngles().y - 90, 0, 0)

	

		if (gRust.Team) then

			for k, v in pairs(gRust.TeamCache) do

				local member = player.GetByAccountID(k)

				if (member == pl or !IsValid(member)) then continue end

	

				local pos = member:GetPos()

				local x, y = gRust.VectorToMap(pos)



				local size = 12

	

				surface.SetMaterial(Material("ui/hud/crosshair.png"))

	

				surface.SetDrawColor(0, 0, 0)

				surface.DrawTexturedRect(x - (size * 0.5), y - (size * 0.5), size, size)

	

				size = 8

	

				surface.SetDrawColor(0, 126, 0)

				surface.DrawTexturedRect(x - (size * 0.5), y - (size * 0.5), size, size)

	

				draw.SimpleTextOutlined(member:Name(), "gRust.18px", x, y, Color(0, 173, 0), 1, 0, 2, Color(0, 0, 0))

			end

		end

	

		if (input.IsMouseDown(107)) then

			if (self.Clicked) then return end

			self.Clicked = true

	

			self:OnClicked(input.GetCursorPos())

		else

			self.Clicked = false

		end

	end

	

	function PANEL:Think()

		if (!gRust.MapMenu || !gRust.MapMenu:IsValid()) then self:Remove() end

		--self:HandleScroll()

	end



	function PANEL:OnMouseWheeled(delta)

		if (true) then return end

		if (delta > 0) then

			delta = 1.1

		else

			delta = 0.9

		end



		self:SetWide(self:GetWide() * delta)

		self:SetTall(self:GetTall() * delta)



		local mx, my = input.GetCursorPos()

		mx = mx + self:GetX()

		self:SetX(ScrW() - mx - (ScrW() * 0.5))

	end

	

	function PANEL:HandleScroll()

		if (input.IsMouseDown(108)) then

			if (!self.Dragging) then

				self.Dragging = true

				self.DragPosX, self.DragPosY = input.GetCursorPos()

			end



			self.DragPosX, self.DragPosY = input.GetCursorPos()

		else

			if (self.Dragging) then

				self.Dragging = false

			end





		end

	end

	

	vgui.Register("gRust.Map", PANEL, "Panel")

	

	hook.Add("entity_killed", "gRust.SetDeathMarker", function(data)

		local pl = LocalPlayer()

		if (data.entindex_killed ~= pl:EntIndex()) then return end

	

		local boundw = -14587

		local boundwmax = 14659

	

		local boundh = 15101

		local boundhmax = -14929

	

		local deathpos = pl:GetPos()

		gRust.DeathPosX, gRust.DeathPosY = gRust.VectorToMap(deathpos)

	end)

end)