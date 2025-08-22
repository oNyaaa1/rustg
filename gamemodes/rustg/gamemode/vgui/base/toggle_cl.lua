local PANEL = {}

AccessorFunc(PANEL, "Selected", "Selected", FORCE_NUMBER)
AccessorFunc(PANEL, "Color", "Color")

local ActiveColor = Color(75, 69, 57)
local InactiveColor = Color(29, 27, 23, 200)
function PANEL:Init()
    self.Activated = false
    
    self:SetColor(InactiveColor)

    self.Button = self:Add("DButton")
    self.Button:Dock(FILL)
    self.Button:SetFont("gRust.42px")
    self.Button:SetContentAlignment(5)
    self.Button:SetText("OFF")
    self.Button:SetColor(Color(200, 200, 200, 200))
    self.Button.Paint = function(me)
    end
    self.Button.DoClick = function(me)
        self.Activated = !self.Activated
        if (self.Activated) then
            self.Button:SetColor(Color(225, 225, 225, 255))
            self.Button:SetText("ON")
            self:ColorTo(ActiveColor, 0.065, 0)
            self:OnChanged(true)
        else
            self.Button:SetColor(Color(200, 200, 200, 225))
            self.Button:SetText("OFF")
            self:ColorTo(InactiveColor, 0.065, 0)
            self:OnChanged(false)
        end
    end
end

function PANEL:OnChanged()
end

function PANEL:SetState(state)
    self.Activated = state
    self.Button:SetText(state and "ON" or "OFF")
    self.Button:SetColor(state and Color(225, 225, 225, 255) or Color(200, 200, 200, 225))
    self:SetColor(state and ActiveColor or InactiveColor)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self:GetColor())
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("gRust.Toggle", PANEL, "Panel")