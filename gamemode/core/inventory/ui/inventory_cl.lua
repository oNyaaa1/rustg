local InitialPos = -(ScrW() * 0.1)
local LeftWidth, RightWidth = ScrW() * 0.365, ScrW() * 0.3550
local LeftShift, RightShift = ScrW() * 0.0055, 0
local OpenItemMenu
CreateClientConVar("grust_inventorymodel", "1", true, false)
local Margin = ScrH() * 0.0055
local function LeftPanel()
	if not gRust.Team then return end
	local Frame = gRust.Inventory
	local scrw, scrh = ScrW(), ScrH()
	local Panel = Frame:Add("Panel")
	Panel:Dock(LEFT)
	Panel:SetWide(LeftWidth - LeftShift)
	Panel.DropPanel = true
	local TeamButton = Panel:Add("gRust.Button")
	TeamButton:SetY(scrh - scrh * 0.1)
	TeamButton:SetWide(scrh * 0.11)
	TeamButton:SetHeight(scrh * 0.03)
	TeamButton:SetX(Panel:GetWide() - scrh * 0.125)
	if #gRust.Team == 0 then
		TeamButton:SetText("Create Team")
	else
		TeamButton:SetText("Leave Team")
	end

	TeamButton.DoClick = function(me)
		if #gRust.Team == 0 then
			me:SetText("Leave Team")
			gRust.CreateTeam()
		else
			me:SetText("Create Team")
			gRust.LeaveTeam()
		end
	end

	local BottomMargin = scrh * 0.161
	local GridContainer = Panel:Add("Panel")
	GridContainer:Dock(BOTTOM)
	GridContainer:SetTall(scrh * 0.0800)
	GridContainer:DockMargin(scrh * 0.0725, 0, scrh * 0.0135, BottomMargin)
	local Grid = GridContainer:Add("gRust.Inventory.SlotGrid")
	Grid:Dock(FILL)
	Grid:SetCols(7)
	Grid:SetRows(1)
	Grid:SetEntity(LocalPlayer())
	Grid:SetInventoryOffset(30)
	Grid:SetMargin(Margin)
	Frame.Attire = Grid
	if GetConVar("grust_inventorymodel"):GetBool() then
		local PlayerModel = Panel:Add("DModelPanel")
		PlayerModel:Dock(FILL)
		PlayerModel:SetModel(LocalPlayer():GetModel())
		PlayerModel.DropPanel = true
		PlayerModel.LayoutEntity = function(me, ent)
			ent:SetAngles(Angle(0, 55, 0))
			ent:SetPos(Vector(20, 10, 0))
		end

		PlayerModel.Think = function(me) me:SetModel(LocalPlayer():GetModel()) end
	end
end

local ItemMenu
local function MiddlePanel()
	local Frame = gRust.Inventory
	local Panel = Frame:Add("Panel")
	Panel.DropPanel = true
	Panel:Dock(FILL)
	local Tall = ScrW() - (LeftWidth + RightWidth)
	local Grid = Panel:Add("gRust.Inventory.SlotGrid")
	Grid:Dock(BOTTOM)
	Grid:SetCols(6)
	Grid:SetRows(4)
	Grid:SetTall(Tall - (Tall / 3) + (Margin * 2))
	Grid:DockMargin(0, 0, 0, ScrH() * 0.1175)
	Grid:SetMargin(Margin)
	Grid:SetEntity(LocalPlayer())
	Grid:SetInventoryOffset(6)
	local InventoryText = Panel:Add("gRust.Label")
	InventoryText:Dock(BOTTOM)
	InventoryText:SetText("INVENTORY")
	InventoryText:SetTextSize(48)
	InventoryText:SetTall(36)
	InventoryText:DockMargin(4, 0, 0, 0)
	local Button = Panel:Add("gRust.Button")
	Button:Dock(TOP)
	Button:SetTall(ScrH() * 0.0675)
	Button:DockMargin(ScrW() * 0.05, 0, ScrW() * 0.041, 0)
	Button.DoClick = function(me)
		gRust.CloseInventory()
		gRust.OpenCrafting()
	end

	Button.PaintOver = function(me, w, h)
		draw.SimpleText("CRAFTING", "gRust.54px", w * 0.393, h * 0.5, Color(243, 243, 243, 150), 1, 1)
		local Padding = h * 0.15
		surface.SetDrawColor(192, 192, 192, 8)
		surface.SetMaterial(gRust.GetIcon("enter"))
		surface.DrawTexturedRect(w - h - Padding * 0.5, Padding, h - Padding * 2, h - Padding * 2)
	end

	OpenItemMenu = function(ent, i)
		local Item = ent.Inventory[i]
		if Item == nil then return end
		local Removed = false
		if IsValid(ItemMenu) then
			Removed = true
			ItemMenu:Remove()
		end

		ItemMenu = Panel:Add("gRust.ItemData")
		ItemMenu:SetItemData(ent, i)
		if not Removed then
			ItemMenu:SetAlpha(0)
			ItemMenu:AlphaTo(255, 0.1, 0)
		end
	end

	Frame.Slots = Grid
end

--Fix this code to update while dragging items
local Framezz = nil
local function RightPanel()
	if Framezz and IsValid(Framezz.RightPanel) then Framezz.RightPanel:Remove() end
	Framezz = gRust.Inventory
	local scrw, scrh = ScrW(), ScrH()
	local Panel = Framezz:Add("Panel")
	Panel:Dock(RIGHT)
	Panel:SetWide(RightWidth + RightShift)
	Panel.DropPanel = true
	if Framezz.Container then
		Framezz.UpdateContainer = function()
			if not Framezz.Container.ConstructInventory then return end
			Framezz.Container:ConstructInventory(Panel, {
				margin = Margin,
				wide = RightWidth + RightShift,
				entity = Framezz.Container.Entity,
			})
		end
	end

	Framezz.RightPanel = Panel
end

local MoveTime = 0.125
function gRust.OpenInventory(ent)
	if IsValid(gRust.Inventory) or not LocalPlayer():Alive() then return end
	if IsValid(gRust.CraftingMenu) then gRust.CloseCrafting() end
	gRust.QuickSwapQueue = 0
	local scrw, scrh = ScrW(), ScrH()
	local Frame = vgui.Create("Panel")
	Frame:SetX(InitialPos)
	Frame:SetSize(scrw, scrh)
	Frame:SetAlpha(0)
	Frame:AlphaTo(255, MoveTime, 0)
	Frame:MoveTo(0, 0, MoveTime, 0, 0.5)
	Frame.Container = ent
	Frame.Paint = function(me, w, h)
		surface.SetMaterial(Material("materials/ui/background.png"))
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(26, 25, 22, 150)
		surface.DrawRect(0, 0, w, h)
		me:DrawBlur(4)
	end

	Frame.OnSelection = function(me, ent, i) OpenItemMenu(ent, i) end
	gui.EnableScreenClicker(true)
	gRust.Inventory = Frame
	LeftPanel()
	RightPanel()
	MiddlePanel()
end

function gRust.CloseInventory()
	if not IsValid(gRust.Inventory) then return end
	gui.EnableScreenClicker(false)
	local Frame = gRust.Inventory
	Frame:AlphaTo(0, MoveTime, 0)
	Frame:MoveTo(InitialPos, 0, MoveTime, 0, nil, function() Frame:Remove() end)
	if IsValid(LocalPlayer().SelectedSlot) then LocalPlayer().SelectedSlot:SetSelected(false) end
end

function GM:ScoreboardShow()
	if IsValid(gRust.Inventory) then
		gRust.CloseInventory()
	else
		gRust.OpenInventory()
	end
end

function GM:ScoreboardHide()
end

-- HUETA
hook.Add("Think", "DeathInv", function() if IsValid(gRust.Inventory) and not LocalPlayer():Alive() then gRust.CloseInventory() end end)