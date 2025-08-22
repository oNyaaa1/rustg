DEFINE_BASECLASS("rust_storage")

include("shared.lua")



function ENT:Draw()

	self:DrawModel()

end



local Container

local Slot1

local InputCost

function ENT:ConstructInventory(panel, data, rows)

	local scrw, scrh = ScrW(), ScrH()



	if (IsValid(Container)) then

		Slot1:SetItem(self.Inventory[1])

		InputCost:Update()

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



	local ButtonContainer = Container:Add("gRust.Inventory.Slot")

	ButtonContainer:Dock(BOTTOM)

	ButtonContainer:SetTall(scrh * 0.075)

	ButtonContainer:DockMargin(0, scrh * 0.005, 0, 0)

	ButtonContainer:DockPadding(scrh * 0.0075, scrh * 0.0075, scrh * 0.0075, scrh * 0.0075)

	ButtonContainer.Paint = function(me, w, h)

		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)

	end



	local Repair = ButtonContainer:Add("gRust.Button")

	Repair:Dock(RIGHT)

	Repair:SetWide(scrw * 0.075)

	Repair:SetDefaultColor(Color(115, 141, 69))

	Repair:SetHoveredColor(Color(105, 141, 42))

	Repair:SetActiveColor(Color(134, 180, 55))

	Repair:SetText("REPAIR")

	Repair.DoClick = function()

		net.Start("gRust.Repair")

		net.WriteEntity(self)

		net.SendToServer()

	end



	local CTall = scrh * 0.175



	Slot2 = Scrap



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



	InputCost = InputInfo:Add("DLabel")

	InputCost:DockMargin(scrh * 0.035, scrh * 0.035, scrh * 0.035, scrh * 0.035)

	InputCost:SetText("")

	InputCost:SetContentAlignment(5)

	InputCost:Dock(FILL)

	InputCost:SetFont("gRust.32px")

	InputCost.Update = function(me)

		InputCost:SetText("")

		InputCost:SetColor(Color(200, 200, 200))



		local Item = self.Inventory[1]

		if (!Item) then return end



		local RepairCost = Item:GetRepairCost()

		if (!RepairCost) then

			InputCost:SetText("This item cannot be repaired")

			InputCost:SetColor(gRust.Colors.Primary)

			return

		end



		local ID = gRust.Items[Item:GetItem()]

		local WearFrac = Item:GetWear() / 1000

		if (WearFrac > 0.8) then

			InputCost:SetText("This item does not need repaired")

			InputCost:SetColor(gRust.Colors.Primary)

			return

		end



		local Cost = {}

		for k, v in ipairs(RepairCost) do

			Cost[k] = string.format("%i 	%s", v.Amount, gRust.Items[v.Class]:GetName())

		end



		InputCost:SetText(table.concat(Cost, "\n"))

	end

	InputCost:Update()



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

	InfoIcon:SetMaterial(Material("ui/icons/info.png","smooth mips"))



	local Info = Info:Add("DLabel")

	Info:Dock(FILL)

	Info:DockMargin(scrw * 0.01, 0, 0, 0)

	Info:SetColor(color_grey)

	Info:SetWrap(true)

	Info:SetFont("gRust.28px")

	Info:SetContentAlignment(4)

	Info:SetText("Use the repair bench to repair worn items")



	local Name = Container:Add("Panel")

	Name:Dock(BOTTOM)

	Name:SetTall(ScrH() * 0.03)

	Name:DockMargin(0, 0, 0, ScrH() * 0.001)

	Name.Paint = function(me, w, h)

		if (!IsValid(self)) then Container:Remove() end



		surface.SetDrawColor(80, 76, 70, 175)

		surface.DrawRect(0, 0, w, h)



		draw.SimpleText("REPAIR BENCH", "gRust.38px", w * 0.01, h * 0.5, Color(255, 255, 255, 200), 0, 1)

	end

end