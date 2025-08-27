-- COPYRIGHT DOWN 2021, ALL RIGHTS RESERVED
include("shared.lua")
function ENT:Draw()
	self:DrawModel()
end

local Container
local Slot
function ENT:ConstructInventory(panel, data, rows)
	if IsValid(Container) then
		Slot:SetItem(self.Inventory[1])
		if table.IsEmpty(data) then Container:Remove() end
		return
	end

	local Rows = rows or (self.InventorySlots / 6)
	Container = panel:Add("Panel")
	Container:Dock(FILL)
	local LeftMargin = ScrW() * 0.02
	local RightMargin = ScrW() * 0.05
	local Box = Container:Add("Panel")
	Box:Dock(BOTTOM)
	Box:DockMargin(0, 0, 0, ScrH() * 0.2)
	Box:SetTall(ScrH() * 0.1)
	Box:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.175)
	Box.PerformLayout = function(me) me:DockPadding(me:GetWide() * 0.5 - ScrH() * 0.05, 0, 0, 0) end
	Slot = Box:Add("gRust.Inventory.Slot")
	Slot:Dock(LEFT)
	Slot:SetEntity(self)
	Slot:SetID(1)
	Slot:SetWide(ScrH() * 0.1)
	Slot:SetItem(self.Inventory[1])
	PrintTable(self.Inventory)
	local Name = Container:Add("Panel")
	Name:Dock(BOTTOM)
	Name:SetTall(ScrH() * 0.03)
	Name:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.01)
	Name.Paint = function(me, w, h)
		if not IsValid(self) then Container:Remove() end
		surface.SetDrawColor(80, 76, 70, 175)
		surface.DrawRect(0, 0, w, h)
		if not self.InventoryName then return end
		draw.SimpleText(string.upper(self.InventoryName), "gRust.38px", w * 0.01, h * 0.5, Color(255, 255, 255, 200), 0, 1)
	end

	local Loot = Container:Add("DLabel")
	Loot:Dock(BOTTOM)
	Loot:SetFont("gRust.58px")
	Loot:SetText("LOOT")
	Loot:SetColor(Color(255, 255, 255, 225))
	Loot:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.008)
	Loot:SetTall(ScrH() * 0.025)
end