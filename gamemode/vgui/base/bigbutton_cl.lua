local PANEL = {}
function PANEL:Init()
    self.Icon = self:Add("DImage")
    self.Icon:SetImage(gRust.GetIcon("loot"):GetName())
    self.Icon:Dock(LEFT)
    self.Icon:SetImageColor(Color(255, 255, 255, 175))
    local MainPanel = self:Add("Panel")
    MainPanel:Dock(FILL)
    self.Title = MainPanel:Add("DLabel")
    self.Title:SetText("")
    self.Title:SetFont("gRust.42px")
    self.Title:Dock(TOP)
    self.Title:SetTextColor(color_white)
    self.Title:SetContentAlignment(4)
    self.Description = MainPanel:Add("DLabel")
    self.Description:SetText("")
    self.Description:SetFont("gRust.18px")
    self.Description:Dock(FILL)
    self.Description:SetWrap(true)
    self.Description:SetAutoStretchVertical(false)
    self.Description:SetTextColor(Color(200, 200, 200))
    self.Description:SetContentAlignment(4)
    self.ButtonOverlay = self:Add("DButton")
    self.ButtonOverlay.IsHovered = self.IsHovered
    self.ButtonOverlay.DoClick = function() self:DoClick() end
    self.ButtonOverlay.Paint = function(me, w, h) return true end
end

function PANEL:SetTitle(title)
    self.Title:SetText(title)
end

function PANEL:SetDescription(desc)
    self.Description:SetText(desc)
end

function PANEL:SetColor(col)
    self.Color = col
    local ncol = Color(col.r + 100, col.g + 100, col.b + 100)
    self.Icon:SetImageColor(ncol)
    self.Title:SetColor(Color(255, 255, 255, 225))
    self.Description:SetColor(ncol)
end

function PANEL:GetColor()
    return self.Color
end

function PANEL:SetIcon(icon)
    self.Icon:SetImage(icon)
end

function PANEL:PerformLayout(w, h)
    local pad = h * 0.125
    self:DockPadding(pad, pad, pad, pad)
    self.Icon:SetWide(h - pad * 2)
    self.Icon:DockMargin(0, 0, pad, 0)
    self.Title:SetTall(h * 0.25)
    self.ButtonOverlay:SetSize(w, h)
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
    surface.SetDrawColor(self.Color)
    surface.DrawRect(0, 0, w, h)
    if self.ButtonOverlay:IsHovered() then
        if not self.Hovered then
            self.HoverStart = CurTime()
            self.Hovered = true
        end

        if self.ButtonOverlay:IsDown() then
            surface.SetDrawColor(255, 255, 255, 40)
        else
            surface.SetDrawColor(255, 255, 255, Lerp((CurTime() - self.HoverStart) / 0.1, 0, 30))
        end
    else
        if self.Hovered then
            self.HoverStart = CurTime()
            self.Hovered = false
        end

        surface.SetDrawColor(255, 255, 255, Lerp((CurTime() - (self.HoverStart or 0)) / 0.1, 25, 0))
    end

    surface.DrawRect(0, 0, w, h)
    return true
end

vgui.Register("gRust.BigButton", PANEL, "DButton")