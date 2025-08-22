gRust.Categories = {}

gRust.CategoryItems = {}

function gRust.CreateCategory(name, icon)

    gRust.Categories[#gRust.Categories + 1] = {name = name, icon = icon}

    gRust.CategoryItems[name] = {}

end



--gRust.CreateCategory("Common", "icons/servers.png")

gRust.CreateCategory("Favorite", "icons/favorite_inactive.png")

gRust.CreateCategory("Construction", "icons/construction.png")

gRust.CreateCategory("Items", "icons/extinguish.png")

gRust.CreateCategory("Resources", "icons/servers.png")

gRust.CreateCategory("Clothing", "icons/servers.png")

gRust.CreateCategory("Tools", "icons/tools.png")

gRust.CreateCategory("Medical", "icons/medical.png")

gRust.CreateCategory("Weapons", "icons/weapon.png")

gRust.CreateCategory("Attachments", "icons/servers.png")

gRust.CreateCategory("Ammo", "icons/ammo.png")

gRust.CreateCategory("Explosives", "icons/servers.png")

gRust.CreateCategory("Electrical", "icons/electric.png")

--gRust.CreateCategory("Other", "icons/dots.png")



if (CLIENT) then

    sql.Query([[

        CREATE TABLE IF NOT EXISTS grust_craftfavorites(

            item VARCHAR(32) NOT NULL PRIMARY KEY

        )

    ]])



    gRust.Favorites = gRust.Favorites or {}

    function gRust.FavoriteItem(item)

        gRust.Favorites[item:GetClass()] = true



        item:AddToCategory("Favorite")

        sql.Query(string.format("INSERT INTO grust_craftfavorites(item) VALUES('%s')", item:GetClass()))

    end



    function gRust.UnfavoriteItem(item)

        gRust.Favorites[item:GetClass()] = nil



        item:RemoveFromCategory("Favorite")

        sql.Query(string.format("DELETE FROM grust_craftfavorites WHERE item='%s'", item:GetClass()))

    end



    function gRust.IsFavorited(item)

        return gRust.Favorites[item:GetClass()]

    end



    hook.Add("InitPostEntity", "gRust.LoadFavorites", function()

        local favorites = sql.Query("SELECT item FROM grust_craftfavorites")

        if (favorites) then

            for _, v in ipairs(favorites) do

                if (!gRust.Items[v.item]) then continue end

                gRust.Items[v.item]:AddToCategory("Favorite")

                gRust.Favorites[v.item] = true

            end

        end

    end)

end



-- Функция для получения всех категорий автоматически
function gRust.GetCategories()
    local categories = {}
    local categoryMap = {}
    
    -- Проходим по всем предметам и собираем категории
    for itemClass, itemData in pairs(gRust.Items) do
        local category = itemData:GetCategory()
        if category and not categoryMap[category] then
            categoryMap[category] = true
            
            local items = gRust.GetItemsByCategory(category)
            
            table.insert(categories, {
                Name = category,
                //Icon = gRust.GetCategoryIcon(category),
                Items = items
            })
        end
    end
    
    -- Сортируем категории
    table.sort(categories, function(a, b)
        return a.Name < b.Name
    end)
    
    return categories
end

-- Функция для получения предметов по категории
function gRust.GetItemsByCategory(categoryName)
    local items = {}
    
    for itemClass, itemData in pairs(gRust.Items) do
        if itemData:GetCategory() == categoryName then
            table.insert(items, itemClass)
        end
    end
    
    return items
end

function gRust.GetItems()
    local items = {}
    
    for itemClass, _ in pairs(gRust.Items) do
        table.insert(items, itemClass)
    end
    
    return items
end



function gRust.GetItemRegister(itemClass)
    if not gRust.Items[itemClass] then return nil end
    
    local item = gRust.Items[itemClass]
    
    return {
        GetName = function() return item:GetName() end,
        GetIcon = function() 
            local iconPath = item:GetIcon()
            if iconPath then
                return Material(iconPath, "smooth")
            else
                return Material("icon16/box.png", "smooth") 
            end
        end,
        GetCategory = function() return item:GetCategory() end,
        IsInCategory = function(self, category)
            return item:GetCategory() == category
        end,
        GetClass = function() return itemClass end,
        GetStack = function() return item:GetStack() end,
        GetDescription = function() return item:GetDescription() end
    }
end

    function gRust.DrawPanelColored(x, y, w, h, color)
        surface.SetDrawColor(color)
        surface.DrawRect(x, y, w, h)
    end
