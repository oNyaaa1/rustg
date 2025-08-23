
local PANEL = {}

function PANEL:Init()
    self.TabContainer = self:Add("Panel")
    self.TabContainer:Dock(TOP)
    self.TabContainer:SetTall(30)
    local margin = 8
    self.TabContainer:DockMargin(margin, margin, margin, margin)
end

local PANEL_COLOR = Color(27, 31, 29, 230)
function PANEL:Paint(w, h)
    gRust.DrawPanelColored(0, 0, w, h, PANEL_COLOR)
end

function PANEL:AddTab(title, class)
    self.Tabs = self.Tabs or {}
    
    local tab = self.TabContainer:Add("DButton")
    tab:Dock(LEFT)
    tab:SetWide(100)
    tab:SetCursor("hand")
    tab:SetContentAlignment(5)
    tab:SetText("")
    tab.Alpha = 25
    
    tab.Paint = function(me, w, h)
        if (me:IsHovered()) then
            me.Alpha = Lerp(FrameTime() * 25, me.Alpha, 100)
        else
            me.Alpha = Lerp(FrameTime() * 25, me.Alpha, 25)
        end
        draw.SimpleText(title, "gRust.32px", w * 0.5, h * 0.5, Color(130, 201, 36, me.Alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    table.insert(self.Tabs, {title = title, class = class, tab = tab})
    

    local tabIndex = #self.Tabs
    tab.DoClick = function()
        self:SelectTab(tabIndex)
    end
    
    if (#self.Tabs == 1) then
        self:SelectTab(1)
    end
end


function PANEL:SelectTab(i)
    if (IsValid(self.OpenedTab)) then
        self.OpenedTab:Remove()
    end

    local tab = self.Tabs[i]
    if (!tab) then return end
    
    self.OpenedTab = self:Add(tab.class)
    self.OpenedTab:Dock(FILL)
end

vgui.Register("gRust.DevTools", PANEL, "EditablePanel")