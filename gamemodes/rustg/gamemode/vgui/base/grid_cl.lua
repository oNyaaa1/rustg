local PANEL = {}

AccessorFunc(PANEL, "Rows", "Rows", FORCE_NUMBER)
AccessorFunc(PANEL, "RowTall", "RowTall", FORCE_NUMBER)
AccessorFunc(PANEL, "Cols", "Cols", FORCE_NUMBER)
AccessorFunc(PANEL, "ColWide", "ColWide", FORCE_NUMBER)
AccessorFunc(PANEL, "Margin", "Margin", FORCE_NUMBER)

AccessorFunc(PANEL, "Dirty", "Dirty", FORCE_BOOL)

function PANEL:Init()
	self:SetDirty(true)

	self.RowPanels = {}
	self.ColPanels = {}

	self.Rows = 2
	self.RowTall = 200
	self.Cols = 2
	self.ColWide = 200
end

function PANEL:Think()
	if (self:GetDirty()) then
		self:SetDirty(false)

		local Wide, Tall = self:GetWide(), self:GetTall()
		local Cols, Rows = self:GetCols(), self:GetRows()
		local ColWide, RowTall = self:GetColWide(), self:GetRowTall()

		for k, v in ipairs(self.RowPanels) do
			v:Remove()
		end

		local i = 0
		local x = 1
		while (true) do
			local Spacing = self:GetMargin()
			local Row = vgui.Create("Panel", self)
			Row:SetTall(RowTall)
			Row:DockMargin(0, 0, 0, Spacing)
			Row:Dock(TOP)
			
			self.RowPanels[x] = Row

			x = x + 1

			for y = 1, Cols do
				i = i + 1

				local Col = self.ColPanels[i]
				if (!IsValid(Col)) then return end
				Col:SetParent(Row)
				Col:Dock(LEFT)
				Col:SetWide(RowTall)
				Col:DockMargin(y > 1 and Spacing or 0, 0, 0, 0)
			end
		end
	end
end

function PANEL:PerformLayout(w, h)
	self:SetRowTall((w / self:GetCols()) - (self:GetMargin() * ((self:GetCols() - 1) / self:GetCols())))
	self:SetDirty(true)
end

function PANEL:Reset()
	for k, v in ipairs(self.ColPanels) do
		v:Remove()
	end
	for k, v in ipairs(self.RowPanels) do
		v:Remove()
	end

	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:Add(c)
	if (!self:GetDirty()) then
		for k, v in ipairs(self.ColPanels) do
			v:Remove()
			self.ColPanels[k] = nil
		end
	end
	
	local Panel = vgui.Create(c, self)
	self.ColPanels[#self.ColPanels + 1] = Panel

	self:SetDirty(true)

	return Panel
end

function PANEL:Paint(w, h)

end

vgui.Register("gRust.Grid", PANEL, "Panel")