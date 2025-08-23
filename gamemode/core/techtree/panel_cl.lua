local PANEL = {}



local CanvasWide = ScrW() * 10

local CanvasTall = ScrH() * 10

function PANEL:Init()

	self.ItemCache = {}



	local scrw, scrh = ScrW(), ScrH()

	self:MakePopup()

	self:Dock(FILL)



	local Canvas = self:Add("Panel")

	Canvas:SetWide(CanvasWide)

	Canvas:SetTall(CanvasTall)

	Canvas:SetX(CanvasWide * -0.5)

	Canvas:SetY(CanvasTall * -0.5)

	Canvas.Think = function(me)

		local mx, my = input.GetCursorPos()



		if (me.LastMouseX and input.IsMouseDown(108)) then

			local newx = me:GetX() + mx - me.LastMouseX

			local newy = me:GetY() + my - me.LastMouseY



			me:SetX(newx)

			me:SetY(newy)

		end



		me.LastMouseX = mx

		me.LastMouseY = my

	end

	self.Canvas = Canvas



	local MiddleX = CanvasWide * 0.5 + (scrw * 0.5 - scrh * 0.175) - self:GetWide()

	local MiddleY = CanvasTall * 0.5 + scrh * 0.25 - self:GetWide()




	local Info = self:Add("Panel")

	Info:Dock(RIGHT)

	Info:SetWide(scrw * 0.175)

	Info:DockPadding(scrh * 0.01, scrh * 0.01, scrh * 0.01, scrh * 0.01)

	Info.Paint = function(me, w, h)

		surface.SetDrawColor(gRust.Colors.Background)

		surface.DrawRect(0, 0, w, h)

	end



	local ScrapContainer = Info:Add("Panel")

	ScrapContainer:Dock(BOTTOM)

	ScrapContainer:SetTall(scrh * 0.05)



	local Scrap = ScrapContainer:Add("gRust.Label")

	Scrap:Dock(LEFT)

	Scrap:SetColor(Color(35, 35, 35))

	Scrap:SetTextSize(26)

	Scrap.PerformLayout = function()

		Scrap:SetWide(scrh * 0.125)

	end

	Scrap.Think = function(me)

		if (!self.SelectedItem) then return end

		Scrap:SetText(gRust.TechTree[self.SelectedItem])

	end
	local OldScrapPaint = Scrap.Paint
	local ScrapPadding = scrh * 0.0035
	Scrap.Paint = function(me, w, h)
		if OldScrapPaint then
			OldScrapPaint(me, w, h)
		end
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(Material(gRust.Items["scrap"]:GetIcon(), "smooth mips"))
		surface.DrawTexturedRect(ScrapPadding, ScrapPadding, h - ScrapPadding * 2, h - ScrapPadding * 2)
	end



	local Unlock = ScrapContainer:Add("gRust.Button")

	Unlock:SetText("UNLOCK")

	Unlock:Dock(FILL)

	Unlock.DoClick = function(me)

		if (!me.Path) then return end

		

		self.LastLearnedItem = self.SelectedItem

		LocalPlayer():EmitSound("techtree.unlock")

		net.Start("gRust.TechTreeBuy")

		net.WriteString(self.SelectedItem)

		net.WriteEntity(self.Entity)

		net.SendToServer()

	end

	Unlock.Think = function(me)

		if (self.ItemCache and self.ItemCache[self.SelectedItem]) then

			if (me.Path or me.Path == nil) then

				Unlock:SetDefaultColor(Color(102, 59, 39))

				Unlock:SetHoveredColor(Color(136, 87, 47))

				Unlock:SetActiveColor(Color(177, 68, 49))

				Unlock:SetText("NO PATH")

			end



			me.Path = false

		else

			if (!me.Path) then

				Unlock:SetDefaultColor(Color(46, 53, 36))

				Unlock:SetHoveredColor(Color(65, 74, 40))

				Unlock:SetActiveColor(Color(81, 94, 51))

				Unlock:SetText("UNLOCK")

			end



			me.Path = true

		end

	end



	local Close = Info:Add("gRust.Button")

	Close:Dock(TOP)

	Close:SetTall(scrh * 0.05)

	Close.Paint = function(me, w, h)

		local col = gRust.Colors.Surface

		if (me:IsHovered()) then

			col = color_white

		end

		draw.SimpleText("CLOSE", "gRust.52px", w * 0.5, h * 0.5, col, 1, 1)

	end

	Close.DoClick = function(me)

		self:Remove()

	end



	local ItemInfo = Info:Add("Panel")

	ItemInfo:Dock(TOP)

	ItemInfo:DockMargin(0, scrh * 0.1, 0, 0)

	ItemInfo:SetTall(scrh * 0.1)



	local ItemIcon = ItemInfo:Add("Panel")

	ItemIcon:Dock(LEFT)

	ItemIcon.PerformLayout = function(me)

		me:SetWide(me:GetTall())

	end

	ItemIcon.Paint = function(me, w, h)

		if (!self.SelectedItem) then return end

		surface.SetDrawColor(255, 255, 255)

		surface.SetMaterial(Material(gRust.Items[self.SelectedItem]:GetIcon(), "smooth mips"))

		surface.DrawTexturedRect(0, 0, w, h)

	end



	local ItemLabel = ItemInfo:Add("DLabel")

	ItemLabel:Dock(FILL)

	ItemLabel:SetContentAlignment(5)

	ItemLabel:SetFont("gRust.40px")

	ItemLabel.Think = function(me)

		if (!self.SelectedItem) then return end

		me:SetText(gRust.Items[self.SelectedItem]:GetName())

	end

end



function PANEL:InsertTree(tree, parent, row, locked, dir)

	self.TreeItems = self.TreeItems or {}



	dir = dir or 1

	local scrw, scrh = ScrW(), ScrH()

	local MiddleX = CanvasWide * 0.5 + (scrw * 0.5 - scrh * 0.175)

	local MiddleY = CanvasTall * 0.5 + scrh * 0.25



	row = row and row + 1 or -1

	for k, v in ipairs(tree) do

		if (!v.Item) then continue end

		local Item = self.Canvas:Add("gRust.TechTree.Item")

		Item:SetID(v.Item)

		Item:SetX(MiddleX + k * (200 * dir))

		Item:SetY(MiddleY + row * 200)

		Item:SetWide(scrh * 0.1)

		Item:SetTall(scrh * 0.1)

		Item:SetLocked(locked and !LocalPlayer():HasBlueprint(v.Item))

		self.ItemCache[v.Item] = Item:GetLocked()

		Item:SetLearned(LocalPlayer():HasBlueprint(v.Item), (self.Opened and self.LastLearnedItem == v.Item))

		Item:SetItem(v.Item)

		if (parent) then

			Item:Connect(parent)

		end

		Item.DoDoubleClick = function(me)

			if (me:GetLocked()) then return end

			if (me:GetLearned()) then return end



			LocalPlayer():EmitSound("techtree.unlock")

			net.Start("gRust.TechTreeBuy")

			net.WriteString(me:GetItem())

			net.WriteEntity(self.Entity)

			net.SendToServer()

		end

		

		self.TreeItems[#self.TreeItems + 1] = Item



		if (v.Branch) then

			self:InsertTree(v.Branch, v.Item, row, locked or !LocalPlayer():HasBlueprint(v.Item), v.Direction or dir)

		end

	end



	self.Opened = true

end



function PANEL:SetTree(tree)

	local scrw, scrh = ScrW(), ScrH()



	self.RootTree = tree

	self:InsertTree(tree)

end



function PANEL:Update()

	for k, v in ipairs(self.TreeItems) do

		self.TreeItems[k] = nil

		if (!IsValid(v)) then continue end

		v:Remove()

	end



	self:InsertTree(self.RootTree)

end



function PANEL:Paint(w, h)

	self:DrawBlur(5)



	surface.SetDrawColor(ColorAlpha(gRust.Colors.Background, 225))

	surface.DrawRect(0, 0, w, h)

end



vgui.Register("gRust.TechTree", PANEL, "Panel")