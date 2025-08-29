function gRust.OpenKitsMenu()
	if gRust.KitsMenu then gRust.KitsMenu:Remove() end
	local scrw, scrh = ScrW(), ScrH()
	local Wide, Tall = scrw * 0.6, scrh * 0.6
	local Frame = vgui.Create("Panel")
	Frame:SetSize(Wide, Tall)
	Frame:MakePopup()
	Frame:Center()
	local Padding = scrh * 0.005
	Frame:DockPadding(Padding, Padding, Padding, Padding)
	Frame.Paint = function(me, w, h)
		surface.SetDrawColor(0, 0, 0, 235)
		surface.DrawRect(0, 0, w, h)
	end

	Frame:SetAlpha(0)
	Frame:AlphaTo(255, 0.075, 0)
	local HeaderTall = scrh * 0.04
	local HeaderPadding = Padding * 0.75
	local Header = Frame:Add("Panel")
	Header:Dock(TOP)
	Header:DockPadding(HeaderPadding, HeaderPadding, HeaderPadding, HeaderPadding)
	Header:SetTall(HeaderTall)
	Header.Paint = function(me, w, h)
		surface.SetDrawColor(34, 34, 34, 255)
		surface.DrawRect(0, 0, w, h)
	end

	local Title = Header:Add("DLabel")
	Title:Dock(FILL)
	Title:SetText(" Kits")
	Title:SetFont("gRust.42px")
	Title:SetColor(Color(255, 255, 255))
	local CloseButton = Header:Add("gRust.Button")
	CloseButton:Dock(RIGHT)
	CloseButton:SetWide(HeaderTall)
	CloseButton:SetTextColor(Color(255, 255, 255))
	CloseButton:SetDefaultColor(Color(216, 85, 64))
	CloseButton:SetHoveredColor(Color(212, 95, 77))
	CloseButton:SetActiveColor(Color(202, 62, 40))
	CloseButton:SetText("X")
	CloseButton.DoClick = function() Frame:AlphaTo(0, 0.075, 0, function() Frame:Remove() end) end
	local KitsContainer = Frame:Add("Panel")
	KitsContainer:Dock(FILL)
	local KitCount = table.Count(gRust.Kits)
	local KitMargin = 10
	local count = 0
	for k, v in SortedPairsByMemberValue(gRust.Kits, "order") do
		count = count + 1
		local KitWide = (Wide - (KitMargin * 2 * (KitCount - 1))) / KitCount
		local Kit = KitsContainer:Add("DPanel")
		Kit:Dock(LEFT)
		Kit:DockPadding(Padding, Padding, Padding, Padding)
		Kit:SetWide(KitWide)
		Kit:DockMargin(count ~= 1 and KitMargin or 0, KitMargin, KitMargin ~= KitCount and KitMargin or 0, 0)
		Kit.Paint = function(me, w, h)
			surface.SetDrawColor(34, 34, 34, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local KitTitle = Kit:Add("Panel")
		KitTitle:Dock(TOP)
		KitTitle:SetTall(scrh * 0.035)
		KitTitle.Paint = function(me, w, h)
			surface.SetDrawColor(208, 137, 34)
			surface.DrawRect(0, 0, w, h)
		end

		local KitLabel = KitTitle:Add("DLabel")
		KitLabel:Dock(FILL)
		KitLabel:SetFont("gRust.32px")
		KitLabel:SetColor(Color(255, 255, 255))
		KitLabel:SetText(v.name .. " Kit")
		KitLabel:SetContentAlignment(5)
		local KitIcon = Kit:Add("DImage")
		KitIcon:Dock(TOP)
		if v.icon then KitIcon:SetImage(v.icon) end
		KitIcon.PerformLayout = function() KitIcon:SetTall(KitIcon:GetWide()) end
		local IconPadding = scrh * 0.05
		KitIcon:DockMargin(IconPadding, IconPadding * 0.2, IconPadding, IconPadding)
		local KitItemsContainer = Kit:Add("DScrollPanel")
		KitItemsContainer:Dock(FILL)
		KitItemsContainer:DockPadding(Padding, Padding, Padding, Padding)
		KitItemsContainer.Paint = function(me, w, h)
			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, w, h)
		end

		local rows = 4
		local itemcount = #v.items
		local KitItemGrid = KitItemsContainer:Add("DGrid")
		KitItemGrid:Dock(FILL)
		KitItemGrid:SetCols(rows)
		KitItemGrid:SetColWide(KitWide / rows - (scrh * 0.01))
		KitItemGrid:SetRowHeight(KitWide / rows - (scrh * 0.01))
		KitItemGrid:DockMargin(Padding * 2, 0, 0, 0)
		for k, v in ipairs(v.items) do
			--[[local item = KitItemGrid:Add("DLabel")

			item:Dock(TOP)

			item:SetFont("NotificationFont")

			item:SetTall(scrh * 0.02)

			item:SetColor(Color(255, 255, 255))

			item:SetText(string.format("%s (x%i)", Rust.Items[v.id].name, v.amount))

		

			KitItemGrid:AddItem(item)]]
			--Item:SetText(Rust.Items)
			local ItemData = gRust.Items[v.id]
			if not ItemData then continue end
			local Item = vgui.Create("DImage")
			Item:SetImage(ItemData:GetIcon())
			Item:SetSize(KitWide / rows - (scrh * 0.02), KitWide / rows - (scrh * 0.02))
			local OldPaint = Item.Paint
			Item.Paint = function(me, w, h)
				OldPaint(me, w, h)
				surface.SetFont("gRust.32px")
				local textw, texth = surface.GetTextSize(v.amount)
				draw.SimpleText("x" .. v.amount, "gRust.32px", w, h - texth, Color(255, 255, 255), 2, 0)
			end

			KitItemGrid:AddItem(Item)
		end

		local KitButtonsContainer = Kit:Add("Panel")
		KitButtonsContainer:Dock(BOTTOM)
		KitButtonsContainer:SetTall(scrh * 0.0425)
		KitButtonsContainer:DockPadding(0, Padding, 0, 0)
		local KitBuy = KitButtonsContainer:Add("gRust.Button")
		KitBuy:SetTextColor(Color(255, 255, 255))
		KitBuy:SetDefaultColor(Color(106, 104, 56))
		KitBuy:SetHoveredColor(Color(124, 122, 55))
		KitBuy:SetActiveColor(Color(151, 148, 51))
		KitBuy:SetText("Activate")
		KitBuy:Dock(FILL)
		KitBuy.DoClick = function(me)
			net.Start("Rust.ActivateKit")
			net.WriteString(k)
			net.SendToServer()
		end
	end

	gRust.KitsMenu = Frame
end

net.Receive("gRust.OpenKitMenu", gRust.OpenKitsMenu)