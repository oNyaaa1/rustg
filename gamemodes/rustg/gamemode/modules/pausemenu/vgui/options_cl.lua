local PANEL = {}

local OpenTab

local ButtonHeight = ScrH() * 0.06
local OptionHeight = ScrH() * 0.0425
local HeaderHeight = ScrH() * 0.085

function PANEL:Init()
    local LeftPanel = self:Add("Panel")
    LeftPanel:Dock(LEFT)
    LeftPanel:SetWide(ScrH() * 0.3)
    LeftPanel.Paint = function(me, w, h)
        surface.SetDrawColor(70, 130, 180, 50)
        surface.DrawRect(0, 0, w, h)
    end

    local RootPanel = self:Add("Panel")
    RootPanel:Dock(FILL)
    RootPanel:DockPadding(ScrH() * 0.03, ScrH() * 0.03, ScrH() * 0.03, ScrH() * 0.03)
    RootPanel.Paint = function(me, w, h)
        surface.SetDrawColor(37, 36, 32, 150)
        surface.DrawRect(0, 0, w, h)
    end

    local OptionNamePanel = RootPanel:Add("Panel")
    OptionNamePanel:Dock(LEFT)

    RootPanel.PerformLayout = function(me, w, h)
        OptionNamePanel:SetWide(w * 0.5)
    end

    local MainPanel = RootPanel:Add("Panel")
    MainPanel:Dock(FILL)

    local LastBtn

    local function AddButton(name, cback)
        local btn = LeftPanel:Add("DButton")
        btn:Dock(TOP)
        btn:SetTall(ButtonHeight)
        btn:SetFont("gRust.54px")
        btn:SetText(name .. "   ")
        btn:DockMargin(ScrH() * 0.025, 0, 0, 0)
        btn:SetContentAlignment(6)
        btn:SetColor(Color(255, 255, 255, 225))
        
        btn.Paint = function(me, w, h)
            if me.Selected then
                surface.SetDrawColor(0, 0, 0, 200)
            elseif me:IsHovered() then
                surface.SetDrawColor(0, 0, 0, 175)
            else
                surface.SetDrawColor(0, 0, 0, 0)
            end
            surface.DrawRect(0, 0, w, h)
        end

        btn.DoClick = function(me)
            btn.Selected = true
            
            if IsValid(LastBtn) then
                LastBtn.Selected = false
            end
            
            for k, v in ipairs(OptionNamePanel:GetChildren()) do
                v:Remove()
            end
            
            for k, v in ipairs(MainPanel:GetChildren()) do
                v:Remove()
            end

            LastBtn = btn
            OpenTab = name
            cback()
        end

        if OpenTab == name then
            btn.Selected = true
            LastBtn = btn
            cback()
        end

        LeftPanel.PerformLayout = function(me, w, h)
            local childCount = #me:GetChildren()
            local totalHeight = childCount * ButtonHeight
            local paddingTop = (h * 0.5) - (totalHeight * 0.5)
            me:DockPadding(0, paddingTop, 0, 0)
        end
    end

    local function AddHeader(name)
        local Text = OptionNamePanel:Add("DLabel")
        Text:Dock(TOP)
        Text:SetFont("gRust.100px")
        Text:SetTall(HeaderHeight)
        Text:SetContentAlignment(4)
        Text:SetText(name)
        Text:SetColor(color_white)
        Text:NoClipping(true)
        
        Text.Paint = function(me, w, h)
            draw.SimpleText(name, me:GetFont(), 0, h * 0.5, me:GetColor(), 0, 1)
            return true
        end

        local Dummy = MainPanel:Add("Panel")
        Dummy:Dock(TOP)
        Dummy:SetTall(HeaderHeight)
    end

    local function AddOption(name, type, convar)
        local Text = OptionNamePanel:Add("DLabel")
        Text:DockMargin(0, 0, 0, 4)
        Text:Dock(TOP)
        Text:SetFontInternal("gRust.48px")
        Text:SetTall(OptionHeight)
        Text:SetContentAlignment(4)
        Text:SetText(name)

        local Option = MainPanel:Add(type)
        Option:DockMargin(0, 0, 0, 4)
        Option:SetTall(OptionHeight)
        Option:Dock(TOP)

        local state
        if type == "gRust.Toggle" then
            state = GetConVar(convar):GetBool()
        elseif type == "gRust.Option" then
            state = GetConVar(convar):GetInt() + 1
        else
            state = 0
        end

        Option:SetState(state)
        Option.OnChanged = function(me, st)
            if type == "gRust.Toggle" then
                local value = st and 1 or 0
                RunConsoleCommand(convar, value)
            elseif type == "gRust.Option" then
                RunConsoleCommand(convar, st - 1)
            end
        end

        return Option
    end
    
    AddButton("OPTIONS", function()
        AddHeader("OPTIONS")
        AddOption("LEFT HANDED", "gRust.Toggle", "grust_lefthand")
        AddOption("SHOW LEGS", "gRust.Toggle", "cl_legs")
    end)

    AddButton("USER INTERFACE", function()
        AddHeader("USER INTERFACE")
        AddOption("GAME HINTS", "gRust.Toggle", "grust_gamehints")
        AddOption("SHOW NAMETAGS", "gRust.Toggle", "grust_nametags")
        AddOption("INVENTORY PLAYER MODEL", "gRust.Toggle", "grust_inventorymodel")
    end)

    AddButton("AUDIO", function()
        AddHeader("AUDIO")
    end)

    AddButton("CONTROLS", function()
        AddHeader("CONTROLS")
    end)

    AddButton("GRAPHICS", function()
        AddHeader("GRAPHICS")
    end)
end

vgui.Register("gRust.Options", PANEL, "Panel")

local PANEL = {}

function PANEL:Init()
    self.m_mMaterial = nil
    self.m_cMaterialColor = Color(255, 255, 255)
    self.m_iMaterialRatio = 1
    self.m_iMaterialSize = nil
    
    self.imageX = 0
    self.imageY = 0
    self.imageW = 0
    self.imageH = 0
end

function PANEL:SetMaterial(material)
    self.m_mMaterial = material
    self:InvalidateLayout()
end

function PANEL:GetMaterial()
    return self.m_mMaterial
end

function PANEL:SetMaterialColor(color)
    self.m_cMaterialColor = color or Color(255, 255, 255)
end

function PANEL:GetMaterialColor()
    return self.m_cMaterialColor
end

function PANEL:SetMaterialRatio(ratio)
    self.m_iMaterialRatio = ratio or 1
    self:InvalidateLayout()
end

function PANEL:GetMaterialRatio()
    return self.m_iMaterialRatio
end

function PANEL:SetMaterialSize(size)
    self.m_iMaterialSize = size
    self:InvalidateLayout()
end

function PANEL:GetMaterialSize()
    return self.m_iMaterialSize
end

function PANEL:Paint(w, h)
    local material = self:GetMaterial()
    if not material then return end
    
    if not self.imageX then return end
    
    surface.SetDrawColor(self:GetMaterialColor())
    surface.SetMaterial(material)
    surface.DrawTexturedRect(self.imageX, self.imageY, self.imageW, self.imageH)
end

function PANEL:PerformLayout(w, h)
    local size = self:GetMaterialSize()
    local ratio = self:GetMaterialRatio()
    
    local imageW, imageH
    
    if ratio == 1 then
        size = size or w
        imageW = size
        imageH = size
    elseif ratio < 1 then
        size = size or w
        imageW = size
        imageH = size / ratio
    else
        size = size or h
        imageW = size * ratio
        imageH = size
    end
    
    self.imageX = (w - imageW) / 2
    self.imageY = (h - imageH) / 2
    self.imageW = imageW
    self.imageH = imageH
end

vgui.Register('gRust.Image', PANEL, 'Panel')
