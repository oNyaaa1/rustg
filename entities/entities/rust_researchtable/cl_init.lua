DEFINE_BASECLASS("rust_storage")

include("shared.lua")



function ENT:Draw()

	self:DrawModel()

end



local Container

local Slot1

local Slot2

function ENT:ConstructInventory(panel, data, rows)

	local scrw, scrh = ScrW(), ScrH()



	if (IsValid(Container)) then

		Slot1:SetItem(self.Inventory[1])

		Slot2:SetItem(self.Inventory[2])

		if (table.IsEmpty(data)) then

			Container:Remove()

		end

		return

	end



	Container = panel:Add("Panel")

	Container:Dock(FILL)

	Container:DockMargin(0, 0, 0, ScrH() * 0.165)

	

	local Container = Container:Add("Panel")

	Container:Dock(BOTTOM)

	Container:SetTall(ScrH() * 0.75)

	Container:DockMargin(scrw * 0.02, 0, scrw * 0.0335, scrh * 0.005)



	local ButtonContainer = Container:Add("DPanel")

	ButtonContainer:Dock(BOTTOM)

	ButtonContainer:SetTall(scrh * 0.075)
	ButtonContainer:DockMargin(0, scrh * 0.005, 0, 0)

	ButtonContainer:DockPadding(scrh * 0.0075, scrh * 0.0075, scrh * 0.0075, scrh * 0.0075)

	ButtonContainer.Paint = function(me, w, h)

		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)

	end



	local Research = ButtonContainer:Add("gRust.Button")

	Research:Dock(RIGHT)

	Research:SetWide(scrw * 0.075)

	Research:SetDefaultColor(Color(115, 141, 69))

	Research:SetHoveredColor(Color(105, 141, 42))

	Research:SetActiveColor(Color(134, 180, 55))

	Research:SetText("RESEARCH")

	Research.DoClick = function()

		net.Start("gRust.Research")

		net.WriteEntity(self)

		net.SendToServer()

	end


	local CTall = scrh * 0.175

	local ScrapContainer = Container:Add("Panel")

	ScrapContainer:Dock(BOTTOM)

	ScrapContainer:SetTall(CTall)

	

	local ScrapInfo = ScrapContainer:Add("DPanel")

	ScrapInfo:Dock(FILL)

	ScrapInfo:DockMargin(scrh * 0.005, 0, 0, 0)

	ScrapInfo.Paint = function(me, w, h)

		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)

	end



	local Scrap = ScrapContainer:Add("gRust.Inventory.Slot")

	Scrap:Dock(LEFT)

	Scrap:SetWide(CTall)

	Scrap:SetItem(self.Inventory[2])

	Scrap:SetEntity(self)

	Scrap:SetID(2)



	Slot2 = Scrap



	local ResearchContainer = Container:Add("Panel")

	ResearchContainer:Dock(BOTTOM)

	ResearchContainer:SetTall(scrh * 0.14)

	ResearchContainer:DockMargin(0, scrh * 0.005, 0, scrh * 0.005)



	local ResearchInfo = ResearchContainer:Add("Panel")

	ResearchInfo:Dock(FILL)

	ResearchInfo:DockMargin(0, 0, scrh * 0.005, 0)

	ResearchInfo.Paint = function(me, w, h)

		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)

	end



	local ResearchCost = ResearchContainer:Add("Panel")

	ResearchCost:Dock(RIGHT)

	ResearchCost:SetWide(scrw * 0.1)

	ResearchCost.Paint = function(me, w, h)

		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)



		local Slot = self.Inventory[1]

		local Cost = (Slot and gRust.Items[Slot:GetItem()].Blueprint) or "N/A"

		if (!isnumber(Cost)) then Cost = "N/A" end



		draw.SimpleText(Cost, "gRust.120px", w * 0.5, h * 0.5, Color(225, 225, 225), 1, 1)

	end



	local InputContainer = Container:Add("Panel")

	InputContainer:Dock(BOTTOM)

	InputContainer:SetTall(CTall)



	local Input = InputContainer:Add("gRust.Inventory.Slot")

	Input:Dock(LEFT)

	Input:SetWide(CTall)

	Input:SetEntity(self)

	Input:SetID(1)

	Input:SetItem(self.Inventory[1])



	Slot1 = Input



	local InputInfo = InputContainer:Add("Panel")

	InputInfo:Dock(FILL)

	InputInfo:DockMargin(scrw * 0.0025, 0, 0, 0)

	InputInfo.Paint = function(me, w, h)

		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)

	end



	local Info = Container:Add("Panel")

	Info:Dock(BOTTOM)

	Info:SetTall(scrh * 0.08)

	Info:DockMargin(0, scrh * 0.005, 0, scrh * 0.005)

	Info:DockPadding(scrh * 0.01, scrh * 0.01, scrh * 0.01, scrh * 0.01)

	Info.Paint = function(me, w, h)

		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)

	end



	local InfoIcon = Info:Add("DImage")

	InfoIcon:Dock(LEFT)

	InfoIcon:SetWide(scrh * 0.06)

	InfoIcon:SetImageColor(Color(200, 200, 200))

	InfoIcon:SetMaterial(Material("ui/icons/info.png"))



	local Info = Info:Add("DLabel")

	Info:Dock(FILL)

	Info:DockMargin(scrw * 0.01, 0, 0, 0)

	Info:SetColor(color_grey)

	Info:SetWrap(true)

	Info:SetFont("gRust.28px")

	Info:SetContentAlignment(4)

	Info:SetText("Use the research table to learn how to craft new items using scrap")



	local Name = Container:Add("Panel")

	Name:Dock(BOTTOM)

	Name:SetTall(ScrH() * 0.03)

	Name:DockMargin(0, 0, 0, ScrH() * 0.001)

	Name.Paint = function(me, w, h)

		if (!IsValid(self)) then Container:Remove() end



		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)



		draw.SimpleText("RESEARCH TABLE", "gRust.38px", w * 0.01, h * 0.5, Color(255, 255, 255, 200), 0, 1)

	end

end