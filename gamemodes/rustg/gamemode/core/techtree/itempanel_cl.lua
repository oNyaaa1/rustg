local PANEL = {}



AccessorFunc(PANEL, "Item", "Item", FORCE_STRING)

AccessorFunc(PANEL, "Locked", "Locked", FORCE_BOOL)

AccessorFunc(PANEL, "Selected", "Selected", FORCE_BOOL)

AccessorFunc(PANEL, "Learned", "Learned", FORCE_BOOL)



function PANEL:SetLearned(b, animate)

	self.Learned = b

	if (b and animate) then

		self.LearnedStart = CurTime()

	end

end



local Panels = {}

function PANEL:Init()

	self.Connections = {}

	self:NoClipping(true)

end



function PANEL:OnRemove()

	if (!self.ID) then return end

	Panels[self.ID] = nil

end



function PANEL:SetID(id)

	Panels[id] = self

	self.ID = id

end



function PANEL:Connect(id)

	if (!Panels[id]) then return end

	self.Connections[#self.Connections + 1] = Panels[id]



	return Panels[id]

end



local Border = 3

function PANEL:Paint(w, h)

	for k, v in ipairs(self.Connections) do

		local rw, rh = 0, 0

		if (self:GetX() == v:GetX()) then

			rh = -self:GetTall() * 0.5

		elseif (self:GetY() == v:GetY()) then

			rw = -self:GetWide() * 0.5

		else

			if (self:GetX() < v:GetX() + v:GetWide() * 0.5 and self:GetX() > v:GetX() - v:GetWide() * 0.5) then

				rw = 0

				rh = -self:GetTall() * 0.5

				goto done

			end



			if (self:GetX() > v:GetX()) then

				rw = -self:GetWide() * 0.5

			else

				rw = self:GetWide() * 0.5

			end

		end



		::done::

		if (self:GetLearned()) then

			surface.SetDrawColor(gRust.Colors.Secondary)

		end

		Draw.StraightLine(w * 0.5, h * 0.5, (w * 0.5) - self:GetX() + v:GetX() - rw, (h * 0.5) - self:GetY() + v:GetY() - rh)

	end



	if (self:GetSelected()) then

		surface.SetDrawColor(76, 136, 183)

	elseif (self:GetLearned()) then

		--surface.SetDrawColor(108, 111, 82)

		surface.SetDrawColor(150, 150, 150)

	else

		surface.SetDrawColor(150, 150, 150)

	end

	surface.DrawRect(0, 0, w, h)

	

	if (self:GetLearned() and !self:GetSelected()) then

		surface.SetDrawColor(108, 111, 82)

		local Progress = Lerp((CurTime() - (self.LearnedStart or 1)) / 0.2, 0, 1)

		surface.DrawRect(0, self:GetTall(), w, h * -Progress)

	end



	if (self:GetSelected()) then

		surface.SetDrawColor(45, 79, 103)

	elseif (self:GetLearned()) then

		--surface.SetDrawColor(62, 64, 40)

		surface.SetDrawColor(10, 10, 10)

	else

		surface.SetDrawColor(10, 10, 10)

	end

	surface.DrawRect(Border, Border, w - Border * 2, h - Border * 2)

	

	if (self:GetLearned() and !self:GetSelected()) then

		surface.SetDrawColor(62, 64, 40)

		local Progress = Lerp((CurTime() - (self.LearnedStart or 1)) / 0.2, 0, 1)

		surface.DrawRect(Border, (Border) + self:GetTall() - Border * 2, w - Border * 2, (h - Border * 2) * -Progress)

	end



	local Locked = self:GetLocked()
	if self:GetItem() then
		local Padding = self:GetTall() * 0.125
		local ID = gRust.Items[self:GetItem()]
		
		if not ID then return end -- Safety check for missing items
		
		surface.SetMaterial(Material(ID:GetIcon(), "smooth"))
		if Locked then
			surface.SetDrawColor(255, 255, 255, 10)
		else
			surface.SetDrawColor(255, 255, 255)
		end
		surface.DrawTexturedRect(Padding, Padding, w - Padding * 2, h - Padding * 2)
	end



	if (Locked) then

		local Padding = self:GetTall() * 0.3

		surface.SetMaterial(gRust.GetIcon("lock"))

		surface.SetDrawColor(200, 200, 200)

		surface.DrawTexturedRect(Padding, Padding, w - Padding * 2, h - Padding * 2)

	end



	return true

end



local SelectedPanel

function PANEL:DoClick()

	if (IsValid(SelectedPanel)) then

		SelectedPanel:SetSelected(false)

	end



	self:SetSelected(true)

	SelectedPanel = self

	gRust.TechTreeMenu.SelectedItem = self:GetItem()

end



vgui.Register("gRust.TechTree.Item", PANEL, "DButton")