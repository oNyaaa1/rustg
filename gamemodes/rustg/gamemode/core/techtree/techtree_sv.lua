util.AddNetworkString("gRust.TechTreeBuy")
util.AddNetworkString("gRust.UpdateTechTree")
util.AddNetworkString("gRust.OpenTechTree")
util.AddNetworkString("gRust.SyncBlueprints")

local function CreateBlueprintTable()
    local query = [[
        CREATE TABLE IF NOT EXISTS player_blueprints (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT NOT NULL,
            blueprint TEXT NOT NULL,
            learned_date INTEGER DEFAULT 0,
            UNIQUE(steamid, blueprint)
        )
    ]]
    
    sql.Query(query)
    if sql.LastError() then
    end
end

local function SavePlayerBlueprint(steamid, blueprint)
    if not steamid or not blueprint then return false end
    
    CreateBlueprintTable()
    
    local query = string.format([[
        INSERT OR IGNORE INTO player_blueprints (steamid, blueprint, learned_date) 
        VALUES (%s, %s, %d)
    ]], sql.SQLStr(steamid), sql.SQLStr(blueprint), os.time())
    
    local result = sql.Query(query)
    if sql.LastError() then
        return false
    end
    
    return true
end

local function SyncPlayerBlueprints(ply)
    if not IsValid(ply) then return end
    
    net.Start("gRust.SyncBlueprints")
    net.WriteTable(ply.Blueprints or {})
    net.Send(ply)
end

local function AddBasicBlueprints(ply)
    if not IsValid(ply) then return end
    
    if not ply.Blueprints then
        ply.Blueprints = {}
    end
    
    for itemClass, itemData in pairs(gRust.Items) do
        if not itemData:GetBlueprint() then
            if not ply.Blueprints[itemClass] then
                ply:AddBlueprint(itemClass)
                ply.Blueprints[itemClass] = true
                SavePlayerBlueprint(ply:SteamID(), itemClass)
            end
        end
    end
end

local function LoadPlayerBlueprints(ply)
    if not IsValid(ply) then return end
    
    CreateBlueprintTable()
    
    local steamid = ply:SteamID()
    local query = string.format([[
        SELECT blueprint FROM player_blueprints WHERE steamid = %s
    ]], sql.SQLStr(steamid))
    
    local data = sql.Query(query)
    if sql.LastError() then
        print("Ошибка загрузки чертежей для " .. ply:Nick() .. ": " .. sql.LastError())
        return
    end
    
    if not ply.Blueprints then
        ply.Blueprints = {}
    end
    
    if data then
        for _, row in pairs(data) do
            ply.Blueprints[row.blueprint] = true
            ply:AddBlueprint(row.blueprint)
        end
        print("Загружено " .. #data .. " чертежей для " .. ply:Nick())
    end
    
    AddBasicBlueprints(ply)
    
    timer.Simple(1, function()
        if IsValid(ply) then
            SyncPlayerBlueprints(ply)
        end
    end)
end

local function HasPathToItem(ply, tree, targetItem, visited)
    visited = visited or {}
    
    for k, v in ipairs(tree) do
        if (!v.Item) then continue end
        
        if (visited[v.Item]) then continue end
        visited[v.Item] = true
        
        if (v.Item == targetItem) then
            return true
        end
        
        if (ply:HasBlueprint(v.Item) and v.Branch) then
            if (HasPathToItem(ply, v.Branch, targetItem, visited)) then
                return true
            end
        end
        
        if (!v.RequiredItem or ply:HasBlueprint(v.RequiredItem)) then
            if (v.Branch and HasPathToItem(ply, v.Branch, targetItem, visited)) then
                return true
            end
        end
    end
    
    return false
end

local function GetItemCost(itemClass)
    return gRust.TechTree[itemClass] or 0
end

local function HasEnoughScrap(ply, cost)
    if (!ply.Inventory) then return false end
    
    local scrapAmount = 0
    
    for i = 1, ply.InventorySlots do
        local item = ply.Inventory[i]
        if (item and item:GetItem() == "scrap") then
            scrapAmount = scrapAmount + item:GetQuantity()
        end
    end
    
    return scrapAmount >= cost
end

local function TakeScrap(ply, amount)
    if (!ply.Inventory) then return false end
    
    local remaining = amount
    
    for i = 1, ply.InventorySlots do
        local item = ply.Inventory[i]
        if (item and item:GetItem() == "scrap" and remaining > 0) then
            local itemAmount = item:GetQuantity()
            local toTake = math.min(itemAmount, remaining)
            
            if (ply:RemoveItem("scrap", toTake)) then
                remaining = remaining - toTake
            end
            
            if (remaining <= 0) then break end
        end
    end
    
    return remaining <= 0
end

net.Receive("gRust.TechTreeBuy", function(len, ply)
    local itemClass = net.ReadString()
    local entity = net.ReadEntity()
    
    if (!IsValid(ply) or !IsValid(entity)) then return end
    if (!itemClass or itemClass == "") then return end
    
    if (entity:GetPos():Distance(ply:GetPos()) > 200) then
        //ply:ChatPrint("Вы слишком далеко от стола исследований!")
        return
    end
    
    local itemData = gRust.Items[itemClass]
    if (!itemData) then
        //ply:ChatPrint("Неизвестный предмет!")
        return
    end
    
    if (!itemData:GetBlueprint()) then
        //ply:ChatPrint("Этот предмет не требует изучения!")
        return
    end
    
    if (ply:HasBlueprint(itemClass)) then
        //ply:ChatPrint("Вы уже знаете этот чертеж!")
        return
    end
    
    local techTree = entity.TechTree
    if (!techTree) then
        //ply:ChatPrint("У этого стола исследований нет дерева технологий!")
        return
    end
    
    if (!HasPathToItem(ply, techTree, itemClass)) then
        //ply:ChatPrint("Вы не можете изучить этот предмет! Изучите необходимые предыдущие технологии.")
        return
    end
    
    local cost = GetItemCost(itemClass)
    if (cost <= 0) then
        //ply:ChatPrint("Стоимость предмета не определена!")
        return
    end
    
    if (!HasEnoughScrap(ply, cost)) then
        //ply:ChatPrint("У вас недостаточно скрапа! Требуется: " .. cost)
        return
    end
    
    if (!TakeScrap(ply, cost)) then
        //ply:ChatPrint("Не удалось списать скрап!")
        return
    end
    
    ply:AddBlueprint(itemClass)
    ply.Blueprints[itemClass] = true
    
    SavePlayerBlueprint(ply:SteamID(), itemClass)
    
    //ply:ChatPrint("Вы изучили: " .. itemData:GetName() .. " за " .. cost .. " скрапа!")
    
    SyncPlayerBlueprints(ply)
    
    net.Start("gRust.UpdateTechTree")
    net.Send(ply)
    
    ply:EmitSound("buttons/button14.wav", 50, 100)
end)

hook.Add("PlayerUse", "gRust.TechTreeUse", function(ply, ent)
    if (!ent.TechTree) then return end
    
    if not ply.TechTreeCooldown then
        ply.TechTreeCooldown = 0
    end
    
    if 1 < ply.TechTreeCooldown then
        return false
    end
    
    ply.TechTreeCooldown = 1
    
    net.Start("gRust.OpenTechTree")
    net.WriteEntity(ent)
    net.Send(ply)
    
    return false
end)

hook.Add("PlayerAuthed", "gRust.LoadPlayerBlueprints", function(ply, steamid)
    timer.Simple(3, function()
        if IsValid(ply) then
            LoadPlayerBlueprints(ply)
        end
    end)
end)

hook.Add("Initialize", "gRust.InitBlueprintDB", function()
    CreateBlueprintTable()
end)

CreateBlueprintTable()
