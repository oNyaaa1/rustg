
local Elements = {}
local PieMenuOpen = false
local Callback
local LinkedEnt

-- Constants
local surface = surface
local draw = draw

-- Selection
local SelectionIndex = 1
local DefaultRadius = ScrH() * 0.3365
local DefaultInnerRadius = ScrH() * 0.3425
local ArcWidth = ScrH() * 0.115
local IconSize = ScrH() * 0.075

-- Animation
local StartTime = 0
local EndTime = 0
local ChangeTime = 0
local AnimTime = 0.1
local AnimScale = 1.5
local LastSelectionIndex = 0

-- Circles initialization
local OuterCircle = Circles.New(CIRCLE_OUTLINED, DefaultRadius, ScrW() * 0.5, ScrH() * 0.5, ArcWidth)
local SelectCircle = Circles.New(CIRCLE_OUTLINED, DefaultInnerRadius, ScrW() * 0.5, ScrH() * 0.5, ArcWidth)

-- ============================================================================
-- ОСНОВНЫЕ ФУНКЦИИ PIE MENU
-- ============================================================================

function gRust.OpenPieMenu(tbl, cback, linkedent)
    if (PieMenuOpen) then return end

    if not tbl or type(tbl) ~= "table" or #tbl == 0 then
        return
    end
    
    Elements = tbl
    Callback = cback
    LinkedEnt = linkedent
    
    LocalPlayer():EmitSound("ui.piemenu.open")
    gui.EnableScreenClicker(true)
    
    PieMenuOpen = true
    StartTime = SysTime()
    EndTime = 0
    
    SelectCircle = Circles.New(CIRCLE_OUTLINED, DefaultInnerRadius, ScrW() * 0.5, ScrH() * 0.5, ArcWidth)
end

function gRust.ClosePieMenu(selected)
    if (!PieMenuOpen or EndTime ~= 0) then return end
    
    if (selected) then
        LocalPlayer():EmitSound("ui.piemenu.select")
    else
        LocalPlayer():EmitSound("ui.piemenu.cancel")
    end
    
    gui.EnableScreenClicker(false)
    EndTime = SysTime()
end

-- ============================================================================
-- ОСНОВНАЯ ФУНКЦИЯ ОТРИСОВКИ С ИСПРАВЛЕНИЯМИ
-- ============================================================================

function GM:DrawPieMenu()
    if (!PieMenuOpen) then return end

    if not Elements or type(Elements) ~= "table" or #Elements == 0 then
        gRust.ClosePieMenu(false)
        return
    end
    
    local AngOffset = #Elements == 2 and 45 or 0
    local mx, my = input.GetCursorPos()
    local Increment = 360 / #Elements
    local RelativePosX = mx - ScrW() * 0.5
    local RelativePosY = my - ScrH() * 0.5

    if ((SysTime() - StartTime) > AnimTime and (SysTime() - EndTime) > AnimTime) then
        local ang = math.deg(math.atan2(RelativePosY, RelativePosX)) - AngOffset

        if (ang < 0) then
            ang = 360 + ang
        end

        SelectionIndex = math.floor(ang / Increment)

        if (SelectionIndex == 0) then
            SelectionIndex = #Elements
        end

        if (LastSelectionIndex ~= SelectionIndex) then
            ChangeTime = SysTime()
            LocalPlayer():EmitSound("ui.blip")
        end
    end

    local scrw, scrh = ScrW(), ScrH()
    
    if SelectionIndex < 1 or SelectionIndex > #Elements then
        SelectionIndex = 1
    end
    
    local Element = Elements[SelectionIndex]
    if (!Element) then 
        return 
    end

    local StartLerp = Lerp((SysTime() - StartTime) / AnimTime, 0, 1)
    local OuterLerp = Lerp((SysTime() - StartTime) / AnimTime, DefaultRadius * 1.5, DefaultRadius)
    local SelectLerp = Lerp((SysTime() - StartTime) / AnimTime, DefaultInnerRadius * 1.5, DefaultRadius)

    if (EndTime ~= 0) then
        if (SysTime() - EndTime > AnimTime) then
            PieMenuOpen = false
        end

        StartLerp = Lerp((SysTime() - EndTime) / AnimTime, 1, 0)
        OuterLerp = Lerp((SysTime() - EndTime) / AnimTime, DefaultRadius, DefaultRadius * 1.5)
        SelectLerp = Lerp((SysTime() - EndTime) / AnimTime, DefaultRadius, DefaultRadius * 1.5)
    end

    draw.NoTexture()
    surface.SetDrawColor(40, 38, 35, StartLerp * 220)
    surface.DrawRect(0, 0, scrw, scrh)

    surface.SetDrawColor(220, 205, 200, StartLerp * 255)
    OuterCircle:SetRadius(DefaultRadius + Anim.Bounce(Lerp((SysTime() - ChangeTime) / 0.125, 0, 1)) * 12)

    if ((SysTime() - StartTime) < AnimTime or (SysTime() - EndTime) < AnimTime) then
        OuterCircle:SetRadius(OuterLerp)
    end

    OuterCircle()

    -- Отрисовка круга выбора
    if (Element.Condition and (IsValid(LinkedEnt) and !Element.Condition(LinkedEnt))) then
        surface.SetDrawColor(115, 115, 115, StartLerp * 100)
    else
        surface.SetDrawColor(187, 58, 40, StartLerp * 255)
    end

    if ((SysTime() - StartTime) < AnimTime or (SysTime() - EndTime) < AnimTime) then
        -- SelectCircle:SetRadius(SelectLerp)
        -- SelectCircle:SetRotation(Lerp(0.6, SelectCircle:GetRotation(), 0))
    else
        SelectCircle:SetRotation(Lerp(0.2, SelectCircle:GetRotation(), SelectionIndex * Increment))
    end

    SelectCircle:SetOutlineWidth(ArcWidth)
    SelectCircle:SetEndAngle((360 / #Elements) + AngOffset)
    SelectCircle:SetStartAngle(AngOffset)
    SelectCircle()

    local Icon = (isstring(Element.Icon)) and Material(Element.Icon, "smooth") or Element.Icon
    local ImageSize = ScrH() * 0.07
    local YOffset = ScrH() * -0.12

    surface.SetDrawColor(187, 58, 40, StartLerp * 255)
    surface.SetMaterial(Icon)
    surface.DrawTexturedRect(ScrW() * 0.5 - ImageSize, YOffset + ScrH() * 0.5 - ImageSize, ImageSize * 2, ImageSize * 2)

    draw.SimpleText(Element.Name or "Unknown", "gRust.84px", ScrW() * 0.5, ScrH() * 0.4725, Color(255, 255, 255, StartLerp * 255), 1, 1)

    if (Element.Foot) then
        draw.SimpleText(Element.Foot, "gRust.26px", ScrW() * 0.5, ScrH() * 0.65, Color(255, 255, 255, StartLerp * 150), 1, 1)
    end

    -- Отрисовка иконок по кругу
    for i = 1, #Elements do
        local CurrentElement = Elements[i]

        if not CurrentElement then
            continue
        end
        
        local Condition = CurrentElement.Condition and IsValid(LinkedEnt) and CurrentElement.Condition(LinkedEnt)
        
        local ElementIcon = (isstring(CurrentElement.Icon)) and Material(CurrentElement.Icon, "smooth") or CurrentElement.Icon
        local n = math.rad(Increment * i + Increment * 0.5 + AngOffset)
        local c = (ScrW() * 0.5) + math.cos(n) * (OuterCircle:GetRadius() - ArcWidth * 0.5)
        local s = (ScrH() * 0.5) + math.sin(n) * (OuterCircle:GetRadius() - ArcWidth * 0.5)

        if (SelectionIndex == i) then
            surface.SetDrawColor(220, 205, 200, StartLerp * 255)
        else
            if (Condition == false) then
                surface.SetDrawColor(185, 185, 185, StartLerp * 255)
            else
                surface.SetDrawColor(187, 58, 40, StartLerp * 255)
            end
        end

        surface.SetMaterial(ElementIcon)
        surface.DrawTexturedRect(c - IconSize * 0.5, s - IconSize * 0.5, IconSize, IconSize)
    end


    if (input.IsMouseDown(107)) then
        if (!PieMenuOpen or EndTime ~= 0) then return end

        local SelectedElement = Elements[SelectionIndex]

        if not SelectedElement then
            LastSelectionIndex = SelectionIndex
            return
        end
        
        local Condition = SelectedElement.Condition and SelectedElement.Condition(LinkedEnt)

        if (Condition == false) then 
            LastSelectionIndex = SelectionIndex 
            return 
        end

        gRust.ClosePieMenu(true)

        if (Callback) then
            Callback(SelectionIndex, LinkedEnt)
        end
    end

    LastSelectionIndex = SelectionIndex
end

-- ============================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================


local function GetElementsCount()
    return Elements and type(Elements) == "table" and #Elements or 0
end

local function IsPieMenuValid()
    return Elements and type(Elements) == "table" and #Elements > 0
end

local function GetElementSafe(index)
    if not IsPieMenuValid() or index < 1 or index > #Elements then
        return nil
    end
    return Elements[index]
end
