local scrw, scrh = ScrW(), ScrH()

local Spacing = scrh * 0.002
local Padding = scrh * 0.0035

local Width, Height = scrh * 0.266, (scrh * 0.1125 - Spacing) / 3
local Margin = scrh * 0.0225
local Tall = scrh * 0.6

local NotificationTime = 2


function gRust.ReloadNotifications()
    if (IsValid(gRust.NotificationPanel)) then
        gRust.NotificationPanel:Remove()
    end

    local Panel = vgui.Create("Panel")
    Panel:SetPos(scrw - Width - Margin, scrh - (Height * 3) - Padding * 2 - Margin - Tall)
    Panel:SetSize(Width, Tall)
    Panel:NoClipping(true)
    
    gRust.NotificationPanel = Panel
end

local InAnimTime = 0.175
local OutAnimTime = 0.25

function gRust.AddNotification(value, type, icon, side)
    if (isfunction(side)) then
        side = side()
    end

    local Type = gRust.NotificationTypes[type]
    if (!Type) then
        error("Tried to create unknown notification type: " .. type)
        return
    end

    local Panel = gRust.NotificationPanel:Add("Panel")
    Panel:SetTall(Height)
    Panel:SetWide(Width)

    local NotifCount = #gRust.NotificationPanel:GetChildren()

    Panel.StartY = Tall - ((Height + Spacing) * (NotifCount - 1))
    Panel:SetZPos(100 - NotifCount)
    Panel:SetAlpha(0)
    Panel:SetPos(0, Panel.StartY)
    Panel:MoveTo(0, Panel.StartY - Height, InAnimTime, 0)
    Panel:AlphaTo(255, InAnimTime, 0)

    Panel.Start = SysTime()
    Panel.Value = string.upper(value)
    Panel.Side = side
    Panel.NotificationType = type
    Panel.Icon = icon

    if type == NOTIFICATION_CRAFT then
        Panel.IconAngle = 0
        Panel.IconSize = Height * 0.6
    end

    Panel.Close = function(me)
        me:AlphaTo(0, OutAnimTime, 0)
        me:MoveTo(0, me.StartY, OutAnimTime, 0, -1, function()
            me:Remove()
        end)
    end

Panel.Paint = function(me, w, h)
    surface.SetDrawColor(Type.Color)
    surface.DrawRect(0, 0, w, h)

    if type == NOTIFICATION_CRAFT then
        local iconToUse = Type.Icon
        
        if iconToUse  then
            surface.SetDrawColor(Type.IconColor)
            surface.SetMaterial(iconToUse)
            
            local iconSize = me.IconSize or h
            local centerX = iconSize / 2
            local centerY = h / 2
            
            local matrix = Matrix()
            matrix:Translate(Vector(centerX, centerY, 0))
            matrix:Rotate(Angle(0, 0, me.IconAngle))
            matrix:Translate(Vector(-centerX, -centerY, 0))
            
            cam.PushModelMatrix(matrix)
            surface.DrawTexturedRect(0, 0, iconSize, iconSize)
            cam.PopModelMatrix()
        end
        
        draw.SimpleText(me.Value, "gRust.34px", (me.IconSize or h) + Spacing, h * 0.5, Color(255, 255, 255, 255), 0, 1)
        draw.SimpleText(me.Side, "gRust.30px", w - Padding * 3, h * 0.5, Color(255, 255, 255, 255), 2, 1)
    
    else
        if (me.Icon and me.Icon != "") then
            local iconMat = Material(me.Icon)
            if (iconMat and not iconMat:IsError()) then
                surface.SetDrawColor(Type.IconColor or Color(255, 255, 255))
                surface.SetMaterial(iconMat)
                surface.DrawTexturedRect(0, 0, h, h)
            end
        else
            surface.SetDrawColor(Type.IconColor)
            surface.SetMaterial(Type.Icon)
            surface.DrawTexturedRect(0, 0, h, h)
        end

        draw.SimpleText(me.Value, "gRust.34px", h + Spacing, h * 0.5, Color(255, 255, 255, 255), 0, 1)
        draw.SimpleText(me.Side, "gRust.30px", w - Padding * 3, h * 0.5, Color(255, 255, 255, 255), 2, 1)
    end
end


    Panel.Think = function(me)
        if (Type.Think) then
            Type.Think(me)
        end

        if type == NOTIFICATION_CRAFT then
            me.IconAngle = (me.IconAngle + FrameTime() * 180) % 360
        end

        if (Type.Time and me.Start + Type.Time < SysTime()) then
            me:Close()
        end
    end
end


function gRust.ClearNotifications(notificationType)
    if (!IsValid(gRust.NotificationPanel)) then return end
    
    for _, panel in pairs(gRust.NotificationPanel:GetChildren()) do
        if (notificationType == 0 or panel.NotificationType == notificationType) then
            panel:Close()
        end
    end
end

net.Receive("gRust.Notify", function()
    local text = net.ReadString()
    local notificationType = net.ReadUInt(4)
    local icon = net.ReadString()
    local side = net.ReadString()
    
    gRust.AddNotification(text, notificationType, icon, side)
end)

net.Receive("gRust.ClearNotifications", function()
    local notificationType = net.ReadUInt(4)
    gRust.ClearNotifications(notificationType)
end)

gRust.ReloadNotifications()
