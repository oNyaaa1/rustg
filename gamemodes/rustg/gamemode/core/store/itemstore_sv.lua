util.AddNetworkString("Store.RequestData")
util.AddNetworkString("Store.UpdateData")
util.AddNetworkString("Store.BuyItem")
util.AddNetworkString("Store.PurchaseResponse")
StoreItems = {
    {
        id = "ak47_tempered",
        title = "TEMPERED",
        subtitle = "ITEM SKIN",
        price = 250,
        category = "limited",
        description = "A rare tempered skin for the AK-47 assault rifle with unique metallic finish.",
        icon = "materials/store/weapons/ak47_tempered.png",
        thumbnail = "materials/zohart/store/1/icon.png"
    },
    {
        id = "knife_carrot",
        title = "CARROT",
        subtitle = "ITEM SKIN",
        price = 50,
        category = "limited",
        description = "A novelty knife skin that looks like a carrot.",
        icon = "materials/zohart/store/4/icon.png"
    },
    {
        id = "furnace_2",
        title = "PANDA",
        subtitle = "ITEM SKIN",
        price = 50,
        category = "general",
        description = "bla bla bla bla bla bla ",
        icon = "materials/zohart/store/2/icon.png"
    },
    {
        id = "sleepingbag1",
        title = "CAT",
        subtitle = "ITEM SKIN",
        price = 50,
        category = "general",
        description = "bla bla bla bla bla bla ",
        icon = "materials/zohart/store/3/icon.png"
    }
}

PlayerData = PlayerData or {}
local function CreateTables()
    sql.Query([[
        CREATE TABLE IF NOT EXISTS player_balances (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT NOT NULL UNIQUE,
            balance INTEGER NOT NULL DEFAULT 1000
        )
    ]])
    sql.Query([[
        CREATE TABLE IF NOT EXISTS store_purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT NOT NULL,
            itemid TEXT NOT NULL,
            price INTEGER NOT NULL,
            purchased_at INTEGER NOT NULL,
            UNIQUE(steamid, itemid)
        )
    ]])
end

CreateTables()
function GetStoreItemData(itemId)
    for _, item in ipairs(StoreItems) do
        if item.id == itemId then return item end
    end
    return nil
end

function GetAllStoreItems()
    return StoreItems
end

function LoadPlayerData(ply)
    local steamid = ply:SteamID64()
    if not sql.TableExists("player_balances") then CreateTables() end
    local balanceQuery = "SELECT balance FROM player_balances WHERE steamid = " .. SQLStr(steamid)
    local balanceData = sql.Query(balanceQuery)
    if balanceData == true and balanceData[1] then
        PlayerData[steamid].balance = tonumber(balanceData[1].balance) or 1000
    else
        local insertBalance = string.format("INSERT INTO player_balances (steamid, balance) VALUES (%s, %d)", SQLStr(steamid), 1000)
        sql.Query(insertBalance)
    end

    local purchasesQuery = "SELECT itemid FROM store_purchases WHERE steamid = " .. SQLStr(steamid)
    local purchaseData = sql.Query(purchasesQuery)
    if purchaseData == false then return end
    if purchaseData then
        for _, purchase in ipairs(purchaseData) do
            PlayerData[steamid].ownedItems[purchase.itemid] = true
        end
    end
end

function SavePlayerData(ply)
    if not IsValid(ply) then return end
    local steamid = ply:SteamID64()
    local data = PlayerData[steamid]
    if not data then return end
    if not sql.TableExists("player_balances") then CreateTables() end
    local updateBalance = string.format("UPDATE player_balances SET balance = %d WHERE steamid = %s", data.balance, SQLStr(steamid))
    sql.Query(updateBalance)
end

_G.StoreItems = StoreItems
_G.GetStoreItemData = GetStoreItemData
_G.GetAllStoreItems = GetAllStoreItems
hook.Add("PlayerInitialSpawn", "Store.InitPlayer", function(ply)
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        local steamid = ply:SteamID64()
        if not PlayerData[steamid] then
            PlayerData[steamid] = {
                balance = 0,
                ownedItems = {},
                lastPurchase = 0,
                purchases = {},
                lastUpdate = 0
            }
        else
            PlayerData[steamid].ownedItems = PlayerData[steamid].ownedItems or {}
            PlayerData[steamid].purchases = PlayerData[steamid].purchases or {}
            PlayerData[steamid].balance = PlayerData[steamid].balance or 1000
            PlayerData[steamid].lastPurchase = PlayerData[steamid].lastPurchase or 0
            PlayerData[steamid].lastUpdate = PlayerData[steamid].lastUpdate or 0
        end

        LoadPlayerData(ply)
    end)
end)

hook.Add("PlayerDisconnected", "Store.CleanupPlayer", function(ply)
    local steamid = ply:SteamID64()
    if PlayerData[steamid] then
        SavePlayerData(ply)
        PlayerData[steamid] = nil
    end
end)

function GetPlayerStoreData(ply)
    local steamid = ply:SteamID64()
    if not PlayerData[steamid] then
        PlayerData[steamid] = {
            balance = 1000,
            ownedItems = {},
            lastPurchase = 0,
            purchases = {},
            lastUpdate = 0
        }
    end
    return PlayerData[steamid]
end

function GetStoreItemsForPlayer(ply)
    local data = GetPlayerStoreData(ply)
    local itemsWithOwnership = {}
    for _, item in ipairs(StoreItems) do
        local itemCopy = table.Copy(item)
        itemCopy.owned = data.ownedItems[item.id] or false
        table.insert(itemsWithOwnership, itemCopy)
    end
    return itemsWithOwnership
end

net.Receive("Store.RequestData", function(len, ply)
    if not IsValid(ply) then return end
    local data = GetPlayerStoreData(ply)
    local items = GetStoreItemsForPlayer(ply)
    net.Start("Store.UpdateData")
    net.WriteTable(items)
    net.WriteInt(data.balance, 32)
    net.Send(ply)
end)

net.Receive("Store.BuyItem", function(len, ply)
    if not IsValid(ply) then return end
    local itemId = net.ReadString()
    local data = GetPlayerStoreData(ply)
    local currentTime = CurTime()
    if (currentTime - data.lastPurchase) < 3 then
        local remainingTime = math.ceil(3 - (currentTime - data.lastPurchase))
        net.Start("Store.PurchaseResponse")
        net.WriteBool(false)
        net.WriteString("Please wait " .. remainingTime .. " seconds before making another purchase!")
        net.WriteInt(data.balance, 32)
        net.Send(ply)
        return
    end

    local item = nil
    for _, storeItem in ipairs(StoreItems) do
        if storeItem.id == itemId then
            item = storeItem
            break
        end
    end

    if not item then
        net.Start("Store.PurchaseResponse")
        net.WriteBool(false)
        net.WriteString("Item not found!")
        net.WriteInt(data.balance, 32)
        net.Send(ply)
        return
    end

    if data.ownedItems[itemId] then
        net.Start("Store.PurchaseResponse")
        net.WriteBool(false)
        net.WriteString("You already own this item!")
        net.WriteInt(data.balance, 32)
        net.Send(ply)
        return
    end

    if data.balance < item.price then
        net.Start("Store.PurchaseResponse")
        net.WriteBool(false)
        net.WriteString("Insufficient funds!")
        net.WriteInt(data.balance, 32)
        net.Send(ply)
        return
    end

    data.lastPurchase = currentTime
    data.balance = data.balance - item.price
    data.ownedItems[itemId] = true
    local steamid = ply:SteamID64()
    -- Используем INSERT OR IGNORE чтобы избежать дублирования
    local insertPurchase = string.format("INSERT OR IGNORE INTO store_purchases (steamid, itemid, price, purchased_at) VALUES (%s, %s, %d, %d)", SQLStr(steamid), SQLStr(itemId), item.price, math.floor(currentTime))
    local insertResult = sql.Query(insertPurchase)
    if insertResult == false then
        print("[Store] Error inserting purchase: " .. sql.LastError())
    else
        print("[Store] Purchase saved successfully for " .. ply:Name() .. ": " .. itemId)
    end

    SavePlayerData(ply)
    net.Start("Store.PurchaseResponse")
    net.WriteBool(true)
    net.WriteString("Successfully purchased " .. item.title .. "!")
    net.WriteInt(data.balance, 32)
    net.Send(ply)
    print("[Store] Triggering Store.PlayerPurchased hook")
    hook.Run("Store.PlayerPurchased", ply, item)
end)

concommand.Add("store_add_balance", function(ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
    local targetName = args[1]
    local amount = tonumber(args[2]) or 0
    if not targetName or amount <= 0 then
        ply:ChatPrint("Usage: store_add_balance <player> <amount>")
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

    local data = GetPlayerStoreData(target)
    data.balance = data.balance + amount
    SavePlayerData(target)
    ply:ChatPrint("Added " .. amount .. " balance to " .. target:Name())
    target:ChatPrint("You received " .. amount .. " balance!")
end)

concommand.Add("store_reset_all", function(ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
    -- Подтверждение
    if args[1] ~= "confirm" then
        ply:ChatPrint("WARNING: This will delete ALL store and inventory data!")
        ply:ChatPrint("Use: store_reset_all confirm")
        return
    end

    -- Очищаем временные предметы
    sql.Query("DELETE FROM player_inventory")
    -- Очищаем покупки магазина
    PlayerData = {}
    ply:ChatPrint("ALL store and inventory data has been cleared!")
    -- Обновляем всех игроков
    for _, p in ipairs(player.GetAll()) do
        timer.Simple(0.5, function()
            if IsValid(p) then
                local inventory = LoadPlayerInventory(p)
                net.Start("Store.PlayerDataLoaded")
                net.WriteTable(inventory)
                net.Send(p)
            end
        end)
    end
end)