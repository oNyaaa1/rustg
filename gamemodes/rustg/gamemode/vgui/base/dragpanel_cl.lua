local PANEL = {}



local Dragging = false

local DraggingPanel

local MouseCode



function PANEL:OnDropped(otherpanel)

end



function PANEL:OnDrag()

end



function PANEL:OnRelease(other)

end



function PANEL:OnMousePressed()

	self.StartMouseX, self.StartMouseY = input.GetCursorPos()

end



function PANEL:OnMouseReleased()

	self.StartMouseX, self.StartMouseY = nil, nil



	if (DraggingPanel) then

		self:OnDropped(DraggingPanel, MouseCode)

	end

end



function PANEL:CanDrag()

	return true

end



function PANEL:DrawDrag(x, y, w, h)

	surface.SetDrawColor(255, 255, 255)

	surface.DrawRect(x - (w * 0.5), y - (h * 0.5), w, h)

end



local function Distance(x1, x2, y1, y2)

	return (x2 - x1)^2 + (y2 - y1)^2

end



function PANEL:PaintOver(w, h)

	if (self.Dragging) then

		local mx, my = input.GetCursorPos()

		local lx, ly = self:LocalToScreen()

		mx = mx - lx

		my = my - ly



		self:DrawDrag(mx - (w * 0.5), my - (h * 0.5), w, h)

	end

end



local function IsMouseDown()

	return 	input.IsMouseDown(107) or

			input.IsMouseDown(108) or

			input.IsMouseDown(109)

end



function PANEL:Think()

	if (self.DraggingLast and !IsMouseDown()) then

		self:OnRelease(vgui.GetHoveredPanel())

	end



	self.DraggingLast = self.Dragging



	if ((self.Dragging or DraggingPanel) && !IsMouseDown()) then

		self.Dragging = false

		Dragging = false

		DraggingPanel = nil

	end



	if (!self.StartMouseX) then return end

	local mx, my = input.GetCursorPos()



	if (!Dragging && self:CanDrag() && Distance(self.StartMouseX, mx, self.StartMouseY, my) > 5^2) then

		self.StartMouseX, self.StartMouseY = nil, nil



		Dragging = true

		DraggingPanel = self

		self.Dragging = true

		self:OnDrag()



		if (input.IsMouseDown(107)) then

			MouseCode = 0

		end

		if (input.IsMouseDown(108)) then

			MouseCode = 1

		end

		if (input.IsMouseDown(109)) then

			MouseCode = 2

		end

	end

end



vgui.Register("gRust.DragPanel", PANEL, "Panel")