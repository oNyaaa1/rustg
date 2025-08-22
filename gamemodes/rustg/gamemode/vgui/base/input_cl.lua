local PANEL = {}

AccessorFunc(PANEL, "Placeholder", "Placeholder", FORCE_STRING)
AccessorFunc(PANEL, "PlaceholderColor", "PlaceholderColor")
AccessorFunc(PANEL, "Font", "Font", FORCE_STRING)
AccessorFunc(PANEL, "TextColor", "TextColor")
AccessorFunc(PANEL, "BackgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "Color", "Color")

function PANEL:Init()
    self:SetPlaceholderColor(Color(209, 209, 209, 200))
    self:SetTextColor(Color(209, 209, 209))
    self:SetBackgroundColor(Color(150, 150, 150, 100))
    self:SetColor(self:GetBackgroundColor())
    self:SetFont("gRust.14px")

    self.TextEntry = self:Add("DTextEntry")
    self.TextEntry:Dock(FILL)
    self.TextEntry:SetFont(self:GetFont())
    self.TextEntry:SetPlaceholderText(self:GetPlaceholder())
    self.TextEntry:SetCursor("hand")

    self.TextEntry.DoClick = function(me, w, h)
    end

    self.TextEntry.Paint = function(me, w, h)
        local col = self:GetTextColor()
        me:DrawTextEntryText(col, col, col)

        if (self.TextEntry:GetText() == "" && !me:IsEditing()) then
            draw.SimpleText(self:GetPlaceholder(), self:GetFont(), w * 0.02, h * 0.5, self:GetPlaceholderColor(), 0, 1)
        end
    end

    self.TextEntry.OnTextChanged = function(...)
        self:OnTextChanged(self.TextEntry:GetText())
    end
end

function PANEL:SetFont(font)
    self.Font = font
    if (self.TextEntry) then
        self.TextEntry:SetFont(font)
    end
end

function PANEL:SetContentAlignment(align)
    self.TextEntry:SetContentAlignment(align)
end

function PANEL:OnPressed() end
function PANEL:OnReleased() end
function PANEL:OnTextChanged() end

function PANEL:Think()
    if (input.IsMouseDown(107)) then
        local hoveredPanel = vgui.GetHoveredPanel()
        
        if (IsValid(hoveredPanel) and hoveredPanel ~= self.TextEntry) then
            local className = hoveredPanel:GetClassName()
            if (className ~= "TextEntry") then
                if (!self.MouseDown) then
                    self:OnReleased()
                    self:ColorTo(self:GetBackgroundColor(), 0.1)
                    self.MouseDown = true
                    return
                end
            end
        end

        if (!self.MouseDown and IsValid(hoveredPanel) and hoveredPanel == self.TextEntry) then
            self:OnPressed()
            self:ColorTo(ColorAlpha(self:GetBackgroundColor(), 225), 0.1)
            self.MouseDown = true
        end
    else
        self.MouseDown = false
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self:GetColor())
    surface.DrawRect(0, 0, w, h)
    return true
end

vgui.Register("gRust.Input", PANEL, "Panel")
