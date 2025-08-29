local InitialPos = ScrW() * 0.1
local LeftMargin, RightMargin = ScrW() * 0.05575, ScrW() * 0.0675
local TopMargin, BottomMargin = ScrH() - ((ScrW() * 0.95) * 0.525), ScrH() * 0.1615
local DivMargin = bit.band((ScrH() * 0.0035) + 1, -2)
local DivMargin2 = bit.band((ScrH() * 0.006) + 1, -2)
local Width = ScrW() - LeftMargin - RightMargin
local Height = ScrH() - TopMargin - BottomMargin
gRust.ScalingInfluence = 0.0
gRust.Scaling = (ScrH() / 1440) * gRust.ScalingInfluence + (1 - gRust.ScalingInfluence) * ScrW() / 2560
local QueueButtons = {}
local CraftAmount = 1
local SelectedItem = "rock"
local SelectedCategory = "Items"
local SelectedSkin = ""
local FavoriteColor = Color(255, 215, 0, 255)
local plyMeta = FindMetaTable("Player")
local BackgroundMaterial = Material("materials/ui/background.png")
surface.CreateFont("gRust.Crafting.Description", {
	font = "Roboto Condensed",
	size = 32 * gRust.Scaling,
	weight = 500,
	antialias = true
})

local function InventoryButton()
	local Frame = gRust.CraftingMenu
	local Margin = ScrW() * 0.01
	local Width = ScrW() * 0.2025
	local Button = Frame:Add("gRust.Button")
	Button:SetWide(Width - Margin * 0.5)
	Button:SetTall(ScrH() * 0.0675)
	Button:SetPos(ScrW() * 0.5 - (Width * 0.5) - Margin * 0.5)
	Button.DoClick = function(me)
		gRust.CloseCrafting()
		gRust.OpenInventory()
	end

	Button.PaintOver = function(me, w, h)
		draw.SimpleText("INVENTORY", "gRust.54px", w * 0.55, h * 0.5, Color(243, 243, 243, 150), 1, 1)
		local Padding = h * 0.15
		surface.SetDrawColor(243, 243, 243, 150)
		surface.SetMaterial(gRust.GetIcon("exit"))
		surface.DrawTexturedRect(Padding * 2, Padding, h - Padding * 2, h - Padding * 2)
	end
end

function PaintBackground(me, w, h)
	surface.SetMaterial(BackgroundMaterial)
	surface.SetDrawColor(126, 126, 126, 39)
	surface.DrawTexturedRect(0, 0, w, h)
	surface.SetDrawColor(175, 175, 175, 0)
	surface.DrawRect(0, 0, w, h)
end

local ImagePadding = Height * 0.015
function AddQueueItem(id, time, index)
	local CraftQueue = gRust.CraftingMenu and gRust.CraftingMenu:GetChildren()[1]:GetChildren()[1]
	if not IsValid(CraftQueue) then return end
	local QueuePadding = DivMargin2 * 2
	local XPadding = QueuePadding * 2
	local item = CraftQueue:Add("DButton")
	item:Dock(RIGHT)
	item:SetWide(CraftQueue:GetTall() - QueuePadding * 2)
	item:SetText("")
	local ProgressCircle = Circles.New(CIRCLE_FILLED, 200, 100, 100)
	ProgressCircle:SetRotation(90)
	item.Paint = function(me, w, h)
		surface.SetMaterial(Material(id:GetIcon(), "smooth"))
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(0, 0, w, h)
		if me:IsHovered() then
			surface.SetDrawColor(255, 86, 35)
			surface.SetMaterial(gRust.GetIcon("x"))
			surface.DrawTexturedRect(XPadding * 0.5, XPadding * 0.5, w - XPadding, h - XPadding)
		end

		local x, y = me:GetPos()
		surface.SetDrawColor(133, 228, 70)
		draw.NoTexture()
		ProgressCircle:SetRadius(h * 0.15)
		ProgressCircle:SetStartAngle(((CurTime() - time) / id:GetCraftTime()) * 360)
		ProgressCircle:SetPos(w * 0.75, h * 0.75)
		ProgressCircle()
	end

	item.DoClick = function(me)
		if gRust.RemoveCraftNotifications then gRust.RemoveCraftNotifications() end
		net.Start("gRust.CraftRemove")
		net.WriteUInt(index, 6)
		net.SendToServer()
	end
	return item
end

local function LeftPanel()
	local Frame = gRust.CraftingMenu
	local Panel = Frame:Add("Panel")
	Panel:Dock(LEFT)
	Panel:SetWide((gRust.CraftingMenu:GetWide() - LeftMargin - RightMargin) * 0.5)
	Panel:DockMargin(0, 0, DivMargin * 0.5, 0)
	local QueuePadding = DivMargin2 * 2
	local CraftQueue = Panel:Add("DPanel")
	CraftQueue:Dock(BOTTOM)
	CraftQueue:SetTall(Height * 0.15)
	CraftQueue:DockMargin(0, DivMargin, 0, 0)
	CraftQueue:DockPadding(QueuePadding, QueuePadding, QueuePadding, QueuePadding)
	CraftQueue.Paint = function(me, w, h)
		PaintBackground(me, w, h)
		draw.SimpleText("CRAFTING QUEUE", "gRust.120px", DivMargin2 * 2, h * 0.5, Color(100, 100, 100, 100), 0, 1)
	end

	net.Receive("gRust.Crafting", function()
		local cls = net.ReadString()
		local index = net.ReadUInt(6)
		local craftTime = net.ReadFloat()
		gRust.CraftQueue = gRust.CraftQueue or {}
		gRust.CraftQueue[index] = {
			item = cls,
			time = CurTime(),
			craftTime = craftTime
		}

		if IsValid(gRust.CraftingMenu) then QueueButtons[index] = AddQueueItem(gRust.Items[cls], CurTime(), index) end
	end)

	net.Receive("gRust.CraftRemove", function()
		local index = net.ReadUInt(6)
		if gRust.RemoveCraftNotifications then gRust.RemoveCraftNotifications() end
		if gRust.CraftQueue then gRust.CraftQueue[index] = nil end
		if IsValid(QueueButtons[index]) then
			QueueButtons[index]:Remove()
			QueueButtons[index] = nil
		end
	end)

	net.Receive("gRust.CraftComplete", function()
		local index = net.ReadUInt(6)
		local item = net.ReadString()
		local amount = net.ReadUInt(7)
		if gRust.CraftQueue then gRust.CraftQueue[index] = nil end
		if IsValid(QueueButtons[index]) then
			QueueButtons[index]:Remove()
			QueueButtons[index] = nil
		end
	end)

	gRust.CraftQueue = gRust.CraftQueue or {}
	for k, v in pairs(gRust.CraftQueue) do
		if v.item and v.time and gRust.Items[v.item] then QueueButtons[k] = AddQueueItem(gRust.Items[v.item], v.time, k) end
	end

	local Container = Panel:Add("Panel")
	Container:Dock(FILL)
	local Categories = Container:Add("Panel")
	Categories:Dock(LEFT)
	Categories:SetWide(Width * 0.125)
	Categories:DockMargin(0, 0, DivMargin, 0)
	Categories.Paint = PaintBackground
	local ItemContainer = Container:Add("Panel")
	ItemContainer:Dock(FILL)
	local SearchBar = ItemContainer:Add(vgui.GetControlTable("gRust.Input") and "gRust.Input" or "DPanel")
	SearchBar:DockMargin(0, DivMargin, 0, 0)
	if vgui.GetControlTable("gRust.Input") then
		SearchBar:SetPlaceholder("Search...")
		SearchBar:SetFont("gRust.42px")
		SearchBar.Paint = function(me, w, h)
			surface.SetDrawColor(255, 255, 255, 15)
			surface.DrawRect(0, 0, w, h)
			me:DrawTextEntryText(color_white, Color(92, 192, 192), color_white)
		end

		SearchBar.OnPressed = function(me) gRust.CraftingMenu:MakePopup() end
		SearchBar.OnReleased = function(me) gRust.CraftingMenu:SetKeyboardInputEnabled(false) end
		SearchBar.OnTextChanged = function(me, txt)
			txt = string.lower(txt)
			if txt == "" then
				gRust.CraftingMenu.OpenCategory(SelectedCategory)
				return
			end

			local items = {}
			for k, v in pairs(gRust.Items) do
				if not v:GetCraft() then continue end
				if v:GetBlueprint() and not LocalPlayer():HasBlueprint(v:GetClass()) then continue end
				if util.FuzzySearch(string.lower(v:GetName()), txt) then items[#items + 1] = v end
			end

			gRust.CraftingMenu.LoadItems(items)
		end
	end

	SearchBar:Dock(BOTTOM)
	SearchBar:SetTall(Height * 0.0625)
	local ItemPanel = ItemContainer:Add("Panel")
	ItemPanel:Dock(FILL)
	ItemPanel.Paint = PaintBackground
	local Items
	gRust.CraftingMenu.LoadItems = function(items)
		if IsValid(Items) then Items:Remove() end
		local ItemMargin = Height * 0.025
		Items = ItemPanel:Add("gRust.Grid")
		Items:Dock(FILL)
		Items:SetCols(5)
		Items:SetMargin(ItemMargin)
		Items:DockMargin(ItemMargin, ItemMargin, ItemMargin, ItemMargin)
		Items:InvalidateLayout(true)
		Items:Think()
		for k, v in ipairs(items) do
			items[k] = v
		end

		local sorted = {}
		for i = 1, #items do
			local item = items[i]
			if LocalPlayer():CanCraft(item) then
				table.remove(items, i)
				table.insert(items, 1, item)
			end
		end

		for i = 1, #items do
			local item = items[i]
			if LocalPlayer():CanCraft(item) and gRust.IsFavorited(item) then
				table.remove(items, i)
				table.insert(items, 1, item)
			end
		end

		for k, v in ipairs(items) do
			if not v:GetVisible() then continue end
			local item = Items:Add("DButton")
			local favorite = item:Add("DButton")
			favorite:SetWide(Height * 0.025)
			favorite:SetTall(Height * 0.025)
			favorite:SetPos(Height * 0.005, Height * 0.005)
			favorite.Paint = function(me, w, h)
				if item:IsHovered() or me:IsHovered() or gRust.IsFavorited(v) then
					surface.SetMaterial(gRust.GetIcon((me:IsHovered() or gRust.IsFavorited(v)) and "favorite_active" or "favorite_inactive"))
					surface.SetDrawColor((LocalPlayer():CanCraft(v) or me:IsHovered()) and FavoriteColor or ColorAlpha(FavoriteColor, 50))
					surface.DrawTexturedRect(0, 0, w, h)
				end
				return true
			end

			favorite.DoClick = function() end
			item.DoClick = function() Frame.SelectItem(v) end
			item.DoDoubleClick = function(me) gRust.RequestCraft(v:GetClass(), CraftAmount, SelectedSkin) end
			-- 👇 ADD THIS for right-click auto add
			item.DoRightClick = function(me)
				net.Start("gRust.Craft") -- or your inventory add net message
				net.WriteString(v:GetClass()) -- the item class
				net.WriteUInt(1, 7) -- amount (here 1)
				net.SendToServer()
			end

			item.DoDoubleClick = function(me) gRust.RequestCraft(v:GetClass(), CraftAmount, SelectedSkin) end
			local LockPadding = Height * 0.02
			item.Paint = function(me, w, h)
				if me:IsHovered() or favorite:IsHovered() then
					if me:IsDown() then
						surface.SetDrawColor(200, 200, 200, 50)
					else
						surface.SetDrawColor(200, 200, 200, 25)
					end

					surface.DrawRect(0, 0, w, h)
				end

				if LocalPlayer():CanCraft(v) then
					surface.SetDrawColor(255, 255, 255)
				else
					surface.SetDrawColor(255, 255, 255, 100)
				end

				surface.SetMaterial(Material(v:GetIcon(), "smooth"))
				surface.DrawTexturedRect(0, 0, w, h)
				if v:GetBlueprint() and not LocalPlayer():HasBlueprint(v:GetClass()) then
					surface.SetDrawColor(255, 255, 255, 150)
					surface.SetMaterial(gRust.GetIcon("lock"))
					surface.DrawTexturedRect(LockPadding * 0.5, LockPadding * 0.5, w - LockPadding, h - LockPadding)
				end
				return true
			end
		end
	end

	gRust.CraftingMenu.OpenCategory = function(catName)
		SelectedCategory = catName
		local filtered = {}
		for _, item in ipairs(gRust.CategoryItems[catName]) do
			if not item:GetVisible() then continue end
			if item:GetBlueprint() and not LocalPlayer():HasBlueprint(item:GetClass()) then
			else
				filtered[#filtered + 1] = item
			end
		end

		gRust.CraftingMenu.LoadItems(filtered)
	end

	Frame.OpenCategory(SelectedCategory)
	for k, v in ipairs(gRust.Categories) do
		local btn = Categories:Add("DButton")
		btn:Dock(TOP)
		btn:SetTall(Height * 0.0625)
		btn:SetText("")
		btn.Paint = function() return true end
		btn.DoClick = function()
			if SelectedCategory == v.name then return end
			Frame.OpenCategory(v.name)
			LocalPlayer():EmitSound("ui.piemenu.select")
		end

		local col = Color(145, 145, 145, 255)
		local img = btn:Add("DImage")
		img:SetImage(v.icon)
		img:Dock(LEFT)
		img:DockMargin(ImagePadding, ImagePadding, ImagePadding, ImagePadding)
		img.SetColor = img.SetImageColor
		img.GetColor = img.GetImageColor
		img:SetImageColor(ColorAlpha(col, 35))
		local txt = btn:Add("DLabel")
		txt:SetFont("gRust.30px")
		txt:Dock(FILL)
		txt:SetColor(col)
		txt:SetText(string.upper(v.name))
		btn.Think = function(me)
			if SelectedCategory == v.name and not me.Selected then
				txt:SetColor(Color(200, 200, 200, 255))
				img:SetColor(Color(175, 175, 175, 175))
				me.Selected = true
			elseif me.Selected then
				txt:SetColor(Color(200, 200, 200, 255))
				img:SetColor(Color(175, 175, 175, 175))
				me.Selected = false
			end
		end

		btn:NoClipping(true)
		local out = Height * 0.015
		btn.Paint = function(me, w, h)
			if SelectedCategory == v.name then
				if not me.SelectedCat then
					me.SelectedCat = true
					me.SelectTime = CurTime()
				end
			else
				if me.SelectedCat then
					me.SelectedCat = false
					me.DeselectTime = CurTime()
				end
			end

			surface.SetDrawColor(41, 141, 255, 100)
			if SelectedCategory == v.name then
				surface.DrawRect(-out * 0.5, -out * 0.5, (w + out) * Lerp((CurTime() - (me.SelectTime or 0)) / 0.075, 0, 1), h + out)
			else
				surface.DrawRect(-out * 0.5, -out * 0.5, (w + out) * Lerp((CurTime() - (me.DeselectTime or 0)) / 0.075, 1, 0), h + out)
			end
		end

		local learnedCount = 0
		for _, item in ipairs(gRust.CategoryItems[v.name]) do
			if not item:GetBlueprint() or LocalPlayer():HasBlueprint(item:GetClass()) then learnedCount = learnedCount + 1 end
		end

		local amt = btn:Add("DLabel")
		amt:SetFont("gRust.30px")
		amt:Dock(RIGHT)
		amt:SetColor(Color(0, 155, 175, 100))
		amt:SetText(learnedCount)
		amt:DockMargin(0, 0, DivMargin2, 0)
		amt:SetContentAlignment(6)
		amt:SetWide(32)
		btn.PerformLayout = function(me, w, h) img:SetWide(h - ImagePadding * 2) end
		btn.OnCursorEntered = function()
			txt:ColorTo(Color(200, 200, 200, 255), 0.1)
			img:ColorTo(Color(175, 175, 175, 175), 0.1)
		end

		btn.OnCursorExited = function(me)
			if SelectedCategory == v.name then return end
			txt:ColorTo(col, 0.1)
			img:ColorTo(ColorAlpha(col, 50), 0.1)
		end
	end
end

local function RightPanel()
	local Frame = gRust.CraftingMenu
	local Panel = Frame:Add("Panel")
	Panel:Dock(LEFT)
	Panel:SetWide((gRust.CraftingMenu:GetWide() - LeftMargin - RightMargin) * 0.5)
	Panel:DockMargin(DivMargin * 0.5, 0, 0, 0)
	local CraftPanel = Panel:Add("Panel")
	CraftPanel:Dock(BOTTOM)
	CraftPanel:DockPadding(DivMargin, DivMargin, DivMargin, DivMargin)
	CraftPanel:SetTall(Height * 0.285)
	CraftPanel:DockMargin(0, DivMargin, 0, 0)
	local CraftMargin = 2
	CraftPanel.Paint = PaintBackground
	local Tags = CraftPanel:Add("Panel")
	Tags:Dock(TOP)
	Tags:SetTall(Height * 0.03)
	Tags:DockMargin(0, 0, 0, CraftMargin)
	for i, j in ipairs({"AMOUNT", "ITEM TYPE", "TOTAL", "HAVE"}) do
		local tag = Tags:Add("DLabel")
		tag:SetFont("gRust.28px")
		tag:Dock(LEFT)
		tag:SetContentAlignment(5)
		tag:SetText(j)
	end

	Tags.PerformLayout = function(me, w, h)
		for i = 1, 4 do
			local tag = me:GetChildren()[i]
			tag:SetWide(i == 2 and w * 0.4 or w * 0.2)
		end
	end

	local CraftList = CraftPanel:Add("Panel")
	CraftList:Dock(FILL)
	CraftList:DockMargin(0, 0, 0, DivMargin)
	for i = 1, 4 do
		local row = CraftList:Add("Panel")
		row:Dock(TOP)
		row:DockMargin(0, 0, 0, CraftMargin)
		for i = 1, 4 do
			local col = row:Add("Panel")
			col:Dock(LEFT)
			col:DockMargin(0, 0, CraftMargin, 0)
			col.Paint = function(me, w, h)
				if #me:GetChildren() == 0 then
					surface.SetDrawColor(0, 0, 0, 75)
				else
					surface.SetDrawColor(0, 0, 0, 125)
				end

				surface.DrawRect(0, 0, w, h)
			end
		end

		row.PerformLayout = function(me, w, h)
			for k, v in ipairs(me:GetChildren()) do
				v:SetWide(k == 2 and w * 0.4 or w * 0.2)
			end
		end
	end

	CraftList.PerformLayout = function(me, w, h)
		for k, v in ipairs(me:GetChildren()) do
			v:SetTall((h / 4) - (CraftMargin * 0.5))
		end
	end

	local Options = CraftPanel:Add("Panel")
	Options:Dock(BOTTOM)
	Options:SetTall(Height * 0.055)
	local Dec = Options:Add("gRust.Button")
	Dec:Dock(LEFT)
	Dec:SetWide(Width * 0.035)
	Dec:SetIcon(gRust.GetIcon("subtract"))
	Dec.DoClick = function()
		CraftAmount = math.max(CraftAmount - 1, 1)
		if gRust.Items[SelectedItem] then Frame.SelectItem(gRust.Items[SelectedItem]) end
	end

	local Amount = Options:Add("Panel")
	Amount:Dock(LEFT)
	Amount:SetWide(Width * 0.05)
	Amount:DockMargin(DivMargin, 0, 0, 0)
	Amount.Paint = function(me, w, h)
		surface.SetDrawColor(55, 55, 55, 175)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText(CraftAmount, "gRust.32px", w * 0.5, h * 0.5, Color(255, 255, 255, 255), 1, 1)
	end

	local Inc = Options:Add("gRust.Button")
	Inc:Dock(LEFT)
	Inc:SetWide(Width * 0.035)
	Inc:SetIcon(gRust.GetIcon("add"))
	Inc:DockMargin(DivMargin, 0, 0, 0)
	Inc.DoClick = function()
		CraftAmount = math.min(CraftAmount + 1, 10)
		if gRust.Items[SelectedItem] then Frame.SelectItem(gRust.Items[SelectedItem]) end
	end

	local Max = Options:Add("gRust.Button")
	Max:Dock(LEFT)
	Max:SetWide(Width * 0.035)
	Max:DockMargin(DivMargin, 0, 0, 0)
	Max:SetIcon(gRust.GetIcon("forward"))
	Max.DoClick = function()
		CraftAmount = 10
		if gRust.Items[SelectedItem] then Frame.SelectItem(gRust.Items[SelectedItem]) end
	end

	local Craft = Options:Add("gRust.Button")
	Craft:Dock(RIGHT)
	Craft:SetWide(Width * 0.075)
	Craft:SetText("CRAFT")
	Craft:SetTextColor(Color(255, 255, 255, 175))
	Craft.DoClick = function(me) gRust.RequestCraft(SelectedItem, CraftAmount, SelectedSkin) end
	local MainPanel = Panel:Add("Panel")
	MainPanel:Dock(FILL)
	MainPanel:DockPadding(DivMargin, DivMargin, DivMargin, DivMargin)
	MainPanel.Paint = PaintBackground
	local TopPanel = MainPanel:Add("Panel")
	TopPanel:Dock(TOP)
	TopPanel:SetTall(Height * 0.1)
	local Image = TopPanel:Add("DImage")
	Image:Dock(LEFT)
	TopPanel.PerformLayout = function(me, w, h) Image:SetWide(h) end
	local Text = TopPanel:Add("DLabel")
	Text:Dock(FILL)
	Text:SetColor(color_white)
	Text:SetFont("gRust.50px")
	Text:SetContentAlignment(8)
	local Workbench = Text:Add("DPanel")
	Workbench:Dock(BOTTOM)
	Workbench:DockMargin(Height * 0.1, 0, Height * 0.1, 0)
	Workbench.Color = Color(114, 141, 70)
	Workbench.TextColor = Color(185, 221, 121)
	Workbench.Text = "WORKBENCH LEVEL 1 REQUIRED"
	Workbench.Font = "gRust.38px"
	Workbench.Paint = function(me, w, h)
		if not me.Text then return end
		draw.RoundedBox(8, 0, 0, w, h, me.Color)
		draw.SimpleText(me.Text, me.Font, w * 0.5, h * 0.5, me.TextColor, 1, 1)
	end

	Workbench.SetTier = function(me, tier)
		if not tier or tier == 0 then
			me.Color = Color(114, 141, 70)
			me.TextColor = Color(185, 221, 121)
			me.Text = nil
			Text:SetContentAlignment(5)
		else
			local colors = {
				{
					bg = Color(114, 141, 70),
					txt = Color(185, 221, 121)
				},
				{
					bg = Color(18, 75, 108),
					txt = Color(50, 162, 235)
				},
				{
					bg = Color(175, 55, 5),
					txt = Color(248, 130, 54)
				}
			}

			local col = colors[tier]
			me.Color = col.bg
			me.TextColor = col.txt
			me.Text = string.format("WORKBENCH LEVEL %s REQUIRED", tier)
			Text:SetContentAlignment(8)
			me:InvalidateLayout(true)
		end
	end

	Workbench.PerformLayout = function(me, w, h)
		if not me.Text then return end
		surface.SetFont(me.Font)
		local tw, th = surface.GetTextSize(Workbench.Text)
		local x = me:GetParent():GetWide() - tw - DivMargin2
		me:DockMargin(x * 0.5, 0, x * 0.5, 0)
		me:SetTall(th + DivMargin)
	end

	local CraftStats = TopPanel:Add("Panel")
	CraftStats:Dock(RIGHT)
	CraftStats:SetWide(Width * 0.065)
	local StatPaint = function(me, w, h)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, w, h)
	end

	local Time = CraftStats:Add("Panel")
	Time.Paint = StatPaint
	local TimeImg = Time:Add("DImage")
	TimeImg:Dock(LEFT)
	TimeImg:SetMaterial(Material("icons/stopwatch.png", "smooth mips"))
	TimeImg:SetImageColor(Color(255, 255, 255, 150))
	local TimeText = Time:Add("DLabel")
	TimeText:Dock(FILL)
	TimeText:SetFont("gRust.32px")
	TimeText:SetContentAlignment(5)
	TimeText:SetColor(Color(255, 255, 255, 100))
	local Amount = CraftStats:Add("Panel")
	Amount.Paint = StatPaint
	local AmtImg = Amount:Add("DImage")
	AmtImg:Dock(LEFT)
	AmtImg:SetMaterial(Material("icons/authorize.png", "smooth mips"))
	AmtImg:SetImageColor(Color(255, 255, 255, 150))
	local AmtText = Amount:Add("DLabel")
	AmtText:Dock(FILL)
	AmtText:SetFont("gRust.32px")
	AmtText:SetContentAlignment(5)
	AmtText:SetColor(Color(255, 255, 255, 100))
	CraftStats.PerformLayout = function(me, w, h)
		Workbench:SetTall(h * 0.5)
		Time:SetTall((h * 0.5) - DivMargin * 0.5)
		Time:SetWide(w)
		Amount:SetTall((h * 0.5) - DivMargin * 0.5)
		Amount:SetWide(w * 0.85)
		Amount:SetPos(w - (w * 0.85), (h * 0.5) + DivMargin * 0.5)
		TimeImg:SetWide((h * 0.5) - DivMargin * 0.5)
		AmtImg:SetWide((h * 0.5) - DivMargin * 0.5)
	end

	local DescriptionMargin = 24 * gRust.Scaling
	local Description = MainPanel:Add("gRust.Label")
	Description:Dock(FILL)
	Description:SetFont("gRust.Crafting.Description")
	Description:SetText("")
	Description:SetTextColor(color_white)
	Description:SetContentAlignment(7)
	Description:SetWrap(true)
	Description:DockMargin(DescriptionMargin, DescriptionMargin, DescriptionMargin, DescriptionMargin)
	local Label = MainPanel:Add("DLabel")
	Label:Dock(FILL)
	Label:SetText("")
	Label:SetContentAlignment(7)
	Label:SetFont("gRust.26px")
	Label:DockMargin(DivMargin2, DivMargin2, DivMargin2, DivMargin2)
	local function UpdateSkinPanelIcon()
	end

	gRust.CraftingMenu.SelectItem = function(item)
		SelectedItem = item:GetClass()
		Image:SetMaterial(Material(item:GetIcon(), "smooth"))
		Text:SetText(item:GetName())
		AmtText:SetText(item:GetCraftAmount())
		TimeText:SetText(item:GetCraftTime() .. ".0")
		Workbench:SetTier(item:GetTier())
		UpdateSkinPanelIcon()
		Description:SetText(item:GetDescription())
		for i = 1, 4 do
			for _, r in ipairs(CraftList:GetChildren()[i]:GetChildren()) do
				for _, g in ipairs(r:GetChildren()) do
					g:Remove()
				end
			end
		end

		for k, v in ipairs(item:GetCraft()) do
			local ID = gRust.Items[v.item]
			for i, j in ipairs(CraftList:GetChildren()[k]:GetChildren()) do
				local txt = j:Add("DLabel")
				txt:Dock(FILL)
				txt:SetFont("gRust.28px")
				txt:SetContentAlignment(5)
				if not LocalPlayer():HasItem(v.item, v.amount) then txt:SetColor(Color(255, 205, 98)) end
				if i == 1 then
					txt:SetText(v.amount)
				elseif i == 2 then
					txt:SetText(ID:GetName())
				elseif i == 3 then
					txt:SetText(v.amount * CraftAmount)
				else
					txt:SetText(LocalPlayer():ItemCount(v.item))
				end
			end
		end
	end

	Frame.SelectItem(gRust.Items[SelectedItem])
end

local MoveTime = 0.125
function gRust.OpenCrafting()
	if IsValid(gRust.CraftingMenu) then return end
	if IsValid(gRust.Inventory) then gRust.CloseInventory() end
	gRust.CraftQueue = gRust.CraftQueue or {}
	QueueButtons = {}
	local scrw, scrh = ScrW(), ScrH()
	local Frame = vgui.Create("EditablePanel")
	Frame:SetPopupStayAtBack(true)
	Frame:SetSize(scrw, scrh)
	Frame:SetAlpha(0)
	Frame:SetX(InitialPos)
	Frame:DockPadding(LeftMargin, TopMargin, RightMargin, BottomMargin)
	Frame:AlphaTo(255, MoveTime, 0)
	Frame:MoveTo(0, 0, MoveTime, 0, 0.5)
	Frame.Paint = function(me, w, h)
		surface.SetMaterial(BackgroundMaterial)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(26, 25, 22, 150)
		surface.DrawRect(0, 0, w, h)
		me:DrawBlur(4)
	end

	gui.EnableScreenClicker(true)
	gRust.CraftingMenu = Frame
	LeftPanel()
	RightPanel()
	InventoryButton()
	timer.Simple(0.1, function()
		if IsValid(gRust.CraftingMenu) then
			for index, craft in pairs(gRust.CraftQueue) do
				if craft.item and craft.time and gRust.Items[craft.item] and not IsValid(QueueButtons[index]) then QueueButtons[index] = AddQueueItem(gRust.Items[craft.item], craft.time, index) end
			end
		end
	end)
end

function gRust.CloseCrafting()
	local Frame = gRust.CraftingMenu
	if not IsValid(Frame) then return end
	gui.EnableScreenClicker(false)
	Frame:AlphaTo(0, MoveTime, 0)
	Frame:MoveTo(InitialPos, 0, MoveTime, 0, 0.5, function() Frame:Remove() end)
end

gRust.AddBind("+menu", function(pl)
	if IsValid(gRust.CraftingMenu) then
		gRust.CloseCrafting()
	else
		gRust.OpenCrafting()
	end
end)