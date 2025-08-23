    util.AddNetworkString("gRust.Notify")
    util.AddNetworkString("gRust.ClearNotifications")

    local PlayerCraftNotifications = {}
    local NotificationCooldowns = {}

    local function SendNotification(player, text, notificationType, icon, side)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local steamID = player:SteamID64()
        local notifKey = steamID .. "_" .. text .. "_" .. notificationType .. "_" .. (side or "")
        local currentTime = CurTime()

        if NotificationCooldowns[notifKey] and (currentTime - NotificationCooldowns[notifKey]) < 0.5 then
            return
        end

        NotificationCooldowns[notifKey] = currentTime

        net.Start("gRust.Notify")
        net.WriteString(tostring(text or ""))
        net.WriteUInt(notificationType, 4)
        net.WriteString(tostring(icon or ""))
        net.WriteString(tostring(side or ""))
        net.Send(player)
    end

    local function ClearPlayerNotifications(player, notificationType)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        net.Start("gRust.ClearNotifications")
        net.WriteUInt(notificationType or 0, 4)
        net.Send(player)
    end

    local function TrackCraftNotification(player, itemClass, index)
        local steamID = player:SteamID64()
        PlayerCraftNotifications[steamID] = PlayerCraftNotifications[steamID] or {}
        PlayerCraftNotifications[steamID][index] = {
            itemClass = itemClass,
            time = CurTime()
        }
    end

    local function ClearCraftNotificationTracking(player, index)
        local steamID = player:SteamID64()
        if PlayerCraftNotifications[steamID] and PlayerCraftNotifications[steamID][index] then
            PlayerCraftNotifications[steamID][index] = nil
            if table.IsEmpty(PlayerCraftNotifications[steamID]) then
                PlayerCraftNotifications[steamID] = nil
            end
        end
    end

    local PLAYER = FindMetaTable("Player")

    function PLAYER:SendNotification(text, notificationType, icon, side)
        SendNotification(self, text, notificationType, icon, side)
    end

    function PLAYER:ClearCraftNotifications() 
        local steamID = self:SteamID64()
        PlayerCraftNotifications[steamID] = nil
        ClearPlayerNotifications(self, NOTIFICATION_CRAFT)
    end

    if PLAYER.CancelCraft then
        local originalCancelCraft = PLAYER.CancelCraft
        function PLAYER:CancelCraft(index)
            ClearCraftNotificationTracking(self, index)
            ClearPlayerNotifications(self, NOTIFICATION_CRAFT)
            return originalCancelCraft(self, index)
        end
    end


    hook.Add("gRust.ItemPickedUp", "gRust.NotificationPickup", function(player, item, entity)
        if not IsValid(player) or not item then return end

        local itemClass = item:GetItem()
        local itemData = gRust.Items[itemClass]
        local itemName = itemData and itemData:GetName() or itemClass
        local quantity = item:GetQuantity()

        SendNotification(player, itemName, NOTIFICATION_PICKUP, "", "+" .. quantity)
    end)

    hook.Add("gRust.ItemDropped", "gRust.NotificationDrop", function(player, dropItem, itemEnt, slot)
        if not IsValid(player) or not dropItem then return end

        local itemClass = dropItem:GetItem()
        local itemData = gRust.Items[itemClass]
        local itemName = itemData and itemData:GetName() or itemClass
        local quantity = dropItem:GetQuantity()

        SendNotification(player, itemName, NOTIFICATION_REMOVE, "", "-" .. quantity)
    end)

    hook.Add("gRust.CraftStarted", "gRust.NotificationCraftStart", function(player, itemClass, craftTime, amount, index)
        if not IsValid(player) then return end

        local itemData = gRust.Items[itemClass]
        local itemName = itemData and itemData:GetName() or itemClass

        TrackCraftNotification(player, itemClass, index or 1)
        SendNotification(player, itemName, NOTIFICATION_CRAFT, "", tostring(math.ceil(craftTime)))
    end)

    hook.Add("gRust.CraftCompleted", "gRust.NotificationCraftComplete", function(player, itemClass, amount, index)
        if not IsValid(player) then return end

        ClearCraftNotificationTracking(player, index or 1)
        ClearPlayerNotifications(player, NOTIFICATION_CRAFT)

        local itemData = gRust.Items[itemClass]
        local itemName = itemData and itemData:GetName() or itemClass

        SendNotification(player, itemName, NOTIFICATION_PICKUP, "", "+" .. amount)
    end)

    hook.Add("gRust.CraftRemoved", "gRust.NotificationCraftRemove", function(player, itemClass, index)
        if not IsValid(player) then return end

        ClearCraftNotificationTracking(player, index or 1)
        ClearPlayerNotifications(player, NOTIFICATION_CRAFT)
    end)

    hook.Add("gRust.ItemGiven", "gRust.NotificationGiven", function(player, itemClass, amount)
        if not IsValid(player) or not itemClass then return end
        
        local itemData = gRust.Items[itemClass]
        local itemName = itemData and itemData:GetName() or itemClass
        
        SendNotification(player, itemName, NOTIFICATION_PICKUP, "", "+" .. amount)
    end)

    timer.Create("gRust.CleanupNotifications", 60, 0, function()
        local currentTime = CurTime()

        for key, time in pairs(NotificationCooldowns) do
            if (currentTime - time) > 5 then
                NotificationCooldowns[key] = nil
            end
        end

        for steamID, crafts in pairs(PlayerCraftNotifications) do
            local player = player.GetBySteamID64(steamID)
            if not IsValid(player) then
                PlayerCraftNotifications[steamID] = nil
            end
        end
    end)
