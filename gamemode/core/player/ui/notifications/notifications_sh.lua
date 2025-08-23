gRust.NotificationTypes = gRust.NotificationTypes or {}

NOTIFICATION_SUCCESS = 0
NOTIFICATION_PICKUP = 1  
NOTIFICATION_REMOVE = 2
NOTIFICATION_CRAFT = 4

gRust.NotificationTypes[NOTIFICATION_SUCCESS] = {
    Color = Color(80, 92, 51),
    IconColor = Color(139, 228, 2),
    Icon = Material("icon16/tick.png"),
    Time = 3
}

gRust.NotificationTypes[NOTIFICATION_PICKUP] = {
    Color = Color(80, 92, 51),
    IconColor = Color(139, 228, 2),
    Icon = Material("materials/icons/pickup.png"),
    Time = 2
}

gRust.NotificationTypes[NOTIFICATION_REMOVE] = {
    Color = Color(111, 46, 35),
    IconColor = Color(224, 74, 46),
    Icon = Material("materials/icons/close.png"),
    Time = 2
}


gRust.NotificationTypes[NOTIFICATION_CRAFT] = {
    Color = Color(40, 106, 144),
    IconColor = Color(79, 148, 190, 255),
    Icon = Material("materials/icons/gear.png"),
    Time = nil,
    Think = function(panel)
        local time = SysTime() - panel.Start
        if panel.Side and tonumber(panel.Side) then
            local remaining = tonumber(panel.Side) - time
            if remaining > 0 then
                panel.Side = tostring(math.ceil(remaining))
            end
        end
    end
}
