
util.AddNetworkString("Store.RequestRefresh")
util.AddNetworkString("Store.PlayerDataLoaded")


local function CreateInventoryTables()
    local result = sql.Query([[
        CREATE TABLE IF NOT EXISTS player_inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT NOT NULL,
            itemid TEXT NOT NULL,
            title TEXT,
            subtitle TEXT,
            description TEXT,
            icon TEXT,
            thumbnail TEXT,
            expires INTEGER,
            from_store INTEGER DEFAULT 1,
            granted_at INTEGER NOT NULL,
            UNIQUE(steamid, itemid)
        )
    ]])
    
    if result == false then 
    else
    end
end


CreateInventoryTables()

function LoadPlayerInventory(ply)
    local steamid = ply:SteamID64()
    
    if not sql.TableExists("player_inventory") then
        CreateInventoryTables()
    end

    local storePurchases = {}
    if PlayerData[steamid] and PlayerData[steamid].ownedItems then
        for itemId, owned in pairs(PlayerData[steamid].ownedItems) do
            if owned then
                local itemData = GetStoreItemData(itemId)
                if itemData then
                    table.insert(storePurchases, {
                        itemid = itemId,
                        title = itemData.title,
                        subtitle = itemData.subtitle,
                        description = itemData.description,
                        icon = itemData.icon,
                        thumbnail = itemData.thumbnail,
                        from_store = true,
                        expires = nil
                    })
                end
            end
        end
    end

    local inventoryQuery = "SELECT * FROM player_inventory WHERE steamid = " .. SQLStr(steamid)
    local inventoryData = sql.Query(inventoryQuery)
    
    local temporaryItems = {}
    if inventoryData and inventoryData ~= false then
        for _, item in ipairs(inventoryData) do
            if not item.expires or tonumber(item.expires) > os.time() then
                table.insert(temporaryItems, {
                    itemid = item.itemid,
                    title = item.title or "TEMPORARY ITEM",
                    subtitle = item.subtitle or "LIMITED TIME", 
                    description = item.description or "Temporary donated item",
                    icon = item.icon,
                    thumbnail = item.thumbnail,
                    from_store = tobool(item.from_store),
                    expires = tonumber(item.expires)
                })
            else
                local deleteQuery = string.format(
                    "DELETE FROM player_inventory WHERE steamid = %s AND itemid = %s",
                    SQLStr(steamid), SQLStr(item.itemid)
                )
                sql.Query(deleteQuery)
            end
        end
    end

    local allItems = {}
    for _, item in ipairs(storePurchases) do
        table.insert(allItems, item)
    end
    for _, item in ipairs(temporaryItems) do
        table.insert(allItems, item)
    end
    
    return allItems
end

function AddTemporaryItem(ply, itemId, duration, itemData)
    local steamid = ply:SteamID64()
    local currentTime = os.time()
    local expiresAt = duration and (currentTime + duration) or nil

    local storeItem = GetStoreItemData and GetStoreItemData(itemId) or itemData or {}

    local insertQuery = string.format(
        "INSERT OR REPLACE INTO player_inventory (steamid, itemid, title, subtitle, description, icon, thumbnail, expires, from_store, granted_at) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 0, %d)",
        SQLStr(steamid),
        SQLStr(itemId),
        SQLStr(storeItem.title or "TEMPORARY ITEM"),
        SQLStr(storeItem.subtitle or "LIMITED TIME"),
        SQLStr(storeItem.description or "Temporary donated item"),
        SQLStr(storeItem.icon or ""),
        SQLStr(storeItem.thumbnail or ""),
        expiresAt and tostring(expiresAt) or "NULL",
        currentTime
    )

    
    local result = sql.Query(insertQuery)
    if result == false then
        return false
    end

    return true
end



hook.Add("PlayerInitialSpawn", "DonateInventory.InitPlayer", function(ply)
    timer.Simple(3, function()
        if not IsValid(ply) then return end

        local inventory = LoadPlayerInventory(ply)

        net.Start("Store.PlayerDataLoaded")
        net.WriteTable(inventory)
        net.Send(ply)
    end)
end)

net.Receive("Store.RequestRefresh", function(len, ply)
    if not IsValid(ply) then return end
    
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        
        local inventory = LoadPlayerInventory(ply)
        
        net.Start("Store.PlayerDataLoaded")
        net.WriteTable(inventory)
        net.Send(ply)
    end)
end)

hook.Add("Store.PlayerPurchased", "DonateInventory.OnPurchase", function(ply, item)

    timer.Simple(1, function()
        if IsValid(ply) then
            local inventory = LoadPlayerInventory(ply)
            
            net.Start("Store.PlayerDataLoaded")
            net.WriteTable(inventory)
            net.Send(ply)
        end
    end)
end)

concommand.Add("inventory_add_temp", function(ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
    
    local targetName = args[1]
    local itemId = args[2]
    local duration = tonumber(args[3]) or 86400
    
    if not targetName or not itemId then
        ply:ChatPrint("Usage: inventory_add_temp <player> <item_id> [duration_seconds]")
        return
    end
    
    local target = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        ply:ChatPrint("Player not found!")
        return
    end
    
    -- Получаем данные предмета из магазина
    local itemData = GetStoreItemData(itemId)
    if not itemData then
        ply:ChatPrint("Item not found in store data!")
        return
    end
    
    if AddTemporaryItem(target, itemId, duration, itemData) then
        ply:ChatPrint("Added temporary item " .. itemId .. " to " .. target:Name() .. " for " .. duration .. " seconds")
        target:ChatPrint("You received a temporary item: " .. (itemData.title or itemId))
        
        -- Обновляем инвентарь игрока
        timer.Simple(0.5, function()
            if IsValid(target) then
                local inventory = LoadPlayerInventory(target)
                net.Start("Store.PlayerDataLoaded")
                net.WriteTable(inventory)
                net.Send(target)
            end
        end)
    else
        ply:ChatPrint("Failed to add temporary item!")
    end
end)


timer.Create("DonateInventory.Cleanup", 1800, 0, function()
    local currentTime = os.time()
    local cleanupQuery = "DELETE FROM player_inventory WHERE expires IS NOT NULL AND expires < " .. currentTime
    
    local result = sql.Query(cleanupQuery)
    if result ~= false then
    end
end)

function GetPlayerInventory(ply)
    return LoadPlayerInventory(ply)
end

function PlayerHasItem(ply, itemId)
    local steamid = ply:SteamID64()

    if PlayerData[steamid] and PlayerData[steamid].ownedItems and PlayerData[steamid].ownedItems[itemId] then
        return true
    end

    local query = string.format(
        "SELECT expires FROM player_inventory WHERE steamid = %s AND itemid = %s",
        SQLStr(steamid), SQLStr(itemId)
    )
    
    local result = sql.Query(query)
    if result and result[1] then
        local expires = tonumber(result[1].expires)
        if not expires or expires > os.time() then
            return true
        end
    end
    
    return false
end

_G.GetPlayerInventory = GetPlayerInventory
_G.PlayerHasItem = PlayerHasItem
_G.AddTemporaryItem = AddTemporaryItem
