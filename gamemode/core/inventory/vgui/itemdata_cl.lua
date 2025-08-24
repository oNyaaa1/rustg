local PANEL = {}

surface.CreateFont("gRust.ItemDescription", {
    font = "Roboto Condensed",
    size = 28 * gRust.Scaling,
    weight = 500,
    antialias = true
})

function PANEL:Init()
    self:NoClipping(true)
	self:Dock(BOTTOM)
	self:SetTall(ScrH() * 0.365)
	self:DockMargin(0, 0, 0, ScrH() * 0.01)
end

function PANEL:SetItemData(ent, i)
	self.Entity = ent
	self.ItemIndex = i
	
	local Item = ent.Inventory[i]
	if (Item == nil) then return end
	local ItemData = gRust.Items[Item:GetItem()]
	
	local Text = self:Add("gRust.Label")
	Text:Dock(TOP)
	Text:SetText(ItemData:GetName())
	Text:SetTextSize(40)
	Text:SetTall(ScrH() * 0.03)
	
    local Container = self:Add("Panel")
    Container:Dock(BOTTOM)
    Container:SetTall(ScrH() * 0.250)


    local DescriptionMargin = 20 * gRust.Scaling
    local DescriptionText = self:Add("gRust.Label")
    DescriptionText:Dock(FILL)
    DescriptionText:SetFont("gRust.ItemDescription")
    DescriptionText:DockMargin(DescriptionMargin, DescriptionMargin, 110 * gRust.Scaling, DescriptionMargin)
    DescriptionText:SetText(ItemData:GetDescription())
    DescriptionText:SetContentAlignment(7)
    DescriptionText:SetTextColor(ColorAlpha(gRust.Colors.Text, 100))
    DescriptionText:SetWrap(true)

	local Actions = Container:Add("Panel")
	Actions:Dock(RIGHT)
	Actions:SetWide(ScrH() * 0.2)
	Actions:DockMargin(ScrH() * 0.003, ScrH() * 0.003, 0, 0)
	Actions.Paint = function(me, w, h)
		surface.SetMaterial(Material("materials/ui/background.png"))
		surface.SetDrawColor(126, 126, 126, 39)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	
	local ActionsPanel = Actions:Add("Panel")
	ActionsPanel:Dock(TOP)
	ActionsPanel:SetSize(ScrH() * 0.01, ScrH() * 0.025)
	ActionsPanel.Paint = function(me, w, h)
		surface.SetMaterial(Material("materials/ui/background.png"))
		surface.SetDrawColor(192, 192, 192, 20)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	local ActionsPanelText = ActionsPanel:Add("gRust.Label")
	ActionsPanelText:Dock(TOP)
	ActionsPanelText:SetText("ACTIONS")	
	ActionsPanelText:SetTextSize(24)
	ActionsPanelText:SetTall(ScrH() * 0.025)
	ActionsPanelText:DockMargin(5, 0, 0, 0)

	if (ItemData.Actions) then
		for k, v in ipairs(ItemData.Actions) do
			local Button = Actions:Add("gRust.Button")
			Button:SetText(v.Name)
			Button:Dock(BOTTOM)
			Button:SetTall(ScrH() * 0.045)
			Button:DockMargin(0, 1, 0, 0)
			Button.DoClick = function()
				v.Func(ent, i)
			end
		end
	end

	local Spacing = Container:Add("Panel")
	Spacing:Dock(FILL)
	Spacing.Paint = function(me, w, h)
		surface.SetMaterial(Material("materials/ui/background.png"))
		surface.SetDrawColor(126, 126, 126, 39)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	if (ItemData:GetAttachments() or 0 > 0) then
		local Attachments = Spacing:Add("Panel")
		Attachments:Dock(BOTTOM)
		Attachments:SetTall(ScrH() * 0.0525)
		Attachments:DockMargin(ScrH() * 0.02, 0, ScrH() * 0.0600, ScrH() * 0.025)
		Attachments.Paint = function(me, w, h)
			surface.SetDrawColor(255, 255, 255, 0)
			surface.DrawRect(0, 0, w, h)
		end

		Attachments.Slots = {}
		local count = 4
		for j = 1, count do
			local Slot = Attachments:Add("gRust.Inventory.Slot")
			Slot:Dock(LEFT)
			Slot:SetEntity(ent)
			Slot.Attachment = j
			Slot.Weapon = i
			if (Item.Mods[j]) then
				Slot:SetItem(Item.Mods[j])
			end
			Slot.OnDropped = function(me, other, mcode)
				
			end
			Attachments.Slots[#Attachments.Slots + 1] = Slot
		end

		Attachments.PerformLayout = function(me)
			for k, v in ipairs(Attachments.Slots) do
				v:SetWide(me:GetTall())
				v:DockMargin(0, 0, (me:GetWide() - (me:GetTall() * count)) / (count - 1), 0)
			end
		end
	end

	local Info = self:Add("DPanel")
	Info:Dock(FILL)
	Info.Paint = function(me, w, h)
		surface.SetMaterial(Material("materials/ui/background.png"))
		surface.SetDrawColor(126, 126, 126, 39)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	
	local Icon = Info:Add("DImage")
	Icon:Dock(RIGHT)
	Icon:SetImage(ItemData:GetIcon())
	Icon:SetWide(ScrH() * 0.08)
	local IconMargin = ScrH() * 0.005
	Icon:DockMargin(IconMargin, IconMargin, IconMargin, IconMargin)
end

vgui.Register("gRust.ItemData", PANEL, "Panel")
