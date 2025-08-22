local PANEL = {}
AccessorFunc(PANEL, "TextColor", "TextColor")
AccessorFunc(PANEL, "Icon", "Icon")
AccessorFunc(PANEL, "IconColor", "IconColor")
AccessorFunc(PANEL, "DefaultColor", "DefaultColor")
AccessorFunc(PANEL, "HoveredColor", "HoveredColor")
AccessorFunc(PANEL, "ActiveColor", "ActiveColor")
function PANEL:Init()
    self.DefaultColor = Color(255, 255, 255, 8)
    self.HoveredColor = Color(255, 255, 255, 15)
    self.ActiveColor = Color(228, 228, 228, 25)
    self.IconColor = Color(255, 255, 255, 200)
    self:SetColor(self.DefaultColor)
    self.BackgroundMaterial = Material("ui/background.png", "noclamp smooth")
    self:SetText("")
    self:SetTextColor(Color(255, 255, 255))
    self:SetFont("gRust.32px")
end

function PANEL:PerformLayout()
    self:SetColor(self.DefaultColor)
end

function PANEL:OnMousePressed(code)
    DButton.OnMousePressed(self, code)
    self:ColorTo(self.ActiveColor, 0.1, 0)
end

function PANEL:OnMouseReleased(code)
    DButton.OnMouseReleased(self, code)
    self:ColorTo(self.HoveredColor, 0.1, 0)
end

function PANEL:OnCursorEntered()
    self:ColorTo(self.HoveredColor, 0.1, 0)
end

function PANEL:OnCursorExited()
    self:ColorTo(self.DefaultColor, 0.1, 0)
end

function PANEL:Paint(w, h)
    local AddSize = Anim.Bounce(Lerp((SysTime() - (self.BounceStart or SysTime())) / 0.075, 0, 1)) * 5
    local backgroundMaterial = Material("ui/background.png", "noclamp smooth")
    local scale = 1 / 768
    local uScale = w * scale
    local vScale = h * scale
    surface.SetDrawColor(126, 126, 126, 39)
    surface.SetMaterial(backgroundMaterial)
    surface.DrawTexturedRectUV(-AddSize, -AddSize, w + AddSize * 2, h + AddSize * 2, 0, 0, uScale, vScale)
    surface.SetDrawColor(self:GetColor())
    surface.DrawRect(0, 0, w, h)
    draw.SimpleText(self:GetText(), self:GetFont(), w * 0.5, h * 0.5, self.TextColor, 1, 1)
    if self.Icon then
        local pad = h * 0.375
        surface.SetMaterial(self.Icon)
        surface.SetDrawColor(self.IconColor)
        surface.DrawTexturedRect(((w - h) * 0.5) + pad * 0.5, pad * 0.5, h - pad, h - pad)
    end
    return true
end

vgui.Register("gRust.Button", PANEL, "DButton")