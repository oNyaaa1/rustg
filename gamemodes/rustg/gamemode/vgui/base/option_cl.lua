local PANEL = {}



AccessorFunc(PANEL, "Selected", "Selected", FORCE_NUMBER)



local ActiveColor = Color(75, 69, 57)

local InactiveColor = Color(75, 69, 57, 0)

function PANEL:Init()

    self.Selected = 1

    self.Options = {}



    self.LeftArrow = self:Add("DButton")

    self.LeftArrow:Dock(LEFT)

    self.LeftArrow:SetFont("gRust.42px")

    self.LeftArrow:SetColor(color_white)

    self.LeftArrow:SetText("<")

    self.LeftArrow.Paint = function(me, w, h)

        surface.SetDrawColor(self.Selected == 1 and InactiveColor or ActiveColor)

        surface.DrawRect(0, 0, w, h)

    end

    self.LeftArrow.DoClick = function(me)

        if (self.Selected == 1) then return end



        self.Selected = self.Selected - 1

        self.Label:SetText(self.Options[self.Selected])

        self:OnChanged(self.Selected)

    end



    self.RightArrow = self:Add("DButton")

    self.RightArrow:Dock(RIGHT)

    self.RightArrow:SetFont("gRust.42px")

    self.RightArrow:SetColor(color_white)

    self.RightArrow:SetText(">")

    self.RightArrow.Paint = function(me, w, h)

        surface.SetDrawColor(self.Selected == #self.Options and InactiveColor or ActiveColor)

        surface.DrawRect(0, 0, w, h)

    end

    self.RightArrow.DoClick = function(me)

        if (self.Selected == #self.Options) then return end



        self.Selected = self.Selected + 1

        self.Label:SetText(self.Options[self.Selected])

        self:OnChanged(self.Selected)

    end



    self.Label = self:Add("DLabel")

    self.Label:Dock(FILL)

    self.Label:SetFont("gRust.42px")

    self.Label:SetContentAlignment(5)

end



function PANEL:PerformLayout(w, h)

    self.LeftArrow:SetWide(h)

    self.RightArrow:SetWide(h)

end



function PANEL:AddOption(name)

    if (#self.Options == 0) then

        self.Label:SetText(name)

    end



    self.Options[#self.Options + 1] = name

    self.Label:SetText(self.Options[self.Selected] or "")

    return self

end



function PANEL:SetState(state)

    self.Selected = tonumber(state)

    self.Label:SetText(self.Options[self.Selected] or "")

end



function PANEL:OnChanged(n)

end



function PANEL:Paint(w, h)

    surface.SetDrawColor(65, 59, 43)

    surface.DrawRect(0, 0, w, h)

end



vgui.Register("gRust.Option", PANEL, "Panel")