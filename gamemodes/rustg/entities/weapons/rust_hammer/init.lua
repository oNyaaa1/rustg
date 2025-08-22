AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("gRust.Upgrade")
util.AddNetworkString("gRust.Demolish")
util.AddNetworkString("gRust.Rotate")
util.AddNetworkString("gRust.Pickup")

local UpgradeCosts = {
    ["foundation"] = {
        ["wood"] = {item = "wood", amount = 150},
        ["stone"] = {item = "stone", amount = 300}, 
        ["metal"] = {item = "metal.fragments", amount = 200},
        ["armored"] = {item = "metal.refined", amount = 25}
    },
    ["wall"] = {
        ["wood"] = {item = "wood", amount = 100},
        ["stone"] = {item = "stone", amount = 150},
        ["metal"] = {item = "metal.fragments", amount = 100},
        ["armored"] = {item = "metal.refined", amount = 15}
    },
    ["floor"] = {
        ["wood"] = {item = "wood", amount = 100},
        ["stone"] = {item = "stone", amount = 150},
        ["metal"] = {item = "metal.fragments", amount = 100},
        ["armored"] = {item = "metal.refined", amount = 15}
    }
}

-- Функция проверки валидности апгрейда (запрет отката назад)
local function IsValidUpgrade(currentTier, newTier)
    local tiers = {"twig", "wood", "stone", "metal", "armored"}
    local currentIndex = 0
    local newIndex = 0
    
    -- Находим индексы текущего и нового уровня
    for i, tier in ipairs(tiers) do
        if tier == currentTier then
            currentIndex = i
        end
        if tier == newTier then
            newIndex = i
        end
    end
    
    -- Проверяем, что новый уровень не ниже текущего
    return newIndex > currentIndex
end

net.Receive("gRust.Upgrade", function(len, ply)
    local ent = net.ReadEntity()
    local upgradeType = net.ReadUInt(3)
    
    if(!IsValid(ent) or !isBuilding(ent)) then return end
    if(ent:GetPos():Distance(ply:GetPos()) > 150) then return end
    
    local buildtiers = {"wood", "stone", "metal", "armored"}
    local newTier = buildtiers[upgradeType + 1]
    local buildType = ent:GetNetworkedString("buildingtype")
    local currentTier = ent:GetNetworkedString("buildtier")
    
    if(newTier and buildType) then
        -- Проверка запрета отката назад
        if(!IsValidUpgrade(currentTier, newTier)) then
            return
        end
        
        -- Проверка наличия стоимости в таблице
        if(!UpgradeCosts[buildType] or !UpgradeCosts[buildType][newTier]) then
            return
        end
        
        local cost = UpgradeCosts[buildType][newTier]

        -- Проверка наличия ресурсов
        if(!ply:HasItem(cost.item, cost.amount)) then
            return
        end

        -- Списание ресурсов
        if(!ply:RemoveItem(cost.item, cost.amount)) then
            return  
        end

        -- Выполнение апгрейда
        ent:SetNetworkedString("buildtier", newTier)
        
        if(newTier == "wood") then
            ent:SetModel("models/zohart/buildings/"..buildType.."_wood.mdl")
            ent:SetMaterial("models/zohart/buildings/wood_stone_metal")
            ent:SetMaxHealth(250)
            ent:SetHealth(250)
            ply:EmitSound("zohart/building/hammer-saw-"..math.random(1,3)..".wav")
        elseif(newTier == "stone") then
            ent:SetModel("models/zohart/buildings/"..buildType.."_stone.mdl")
            ent:SetMaterial("models/zohart/buildings/wood_stone_metal")
            ent:SetMaxHealth(500)
            ent:SetHealth(500)
            ply:EmitSound("zohart/building/stone-construction-"..math.random(1,3)..".wav")
        elseif(newTier == "metal") then
            ent:SetModel("models/zohart/buildings/"..buildType.."_metal.mdl")
            ent:SetMaterial("models/zohart/buildings/wood_stone_metal")
            ent:SetMaxHealth(1000)
            ent:SetHealth(1000)
            ply:EmitSound("zohart/building/metal-construction-"..math.random(1,3)..".wav")
        elseif(newTier == "armored") then
            ent:SetModel("models/zohart/buildings/"..buildType.."_armored.mdl")
            ent:SetMaterial("models/zohart/buildings/armored")
            ent:SetMaxHealth(2000)
            ent:SetHealth(2000)
            ply:EmitSound("zohart/building/metal-construction-"..math.random(1,3)..".wav")
        end 
    end
end)

net.Receive("gRust.Demolish", function(len, ply)
    local ent = net.ReadEntity()
    if(IsValid(ent) and isBuilding(ent) and ent:GetPos():Distance(ply:GetPos()) <= 150) then
        ent:Remove()
    end
end)

net.Receive("gRust.Rotate", function(len, ply)
    local ent = net.ReadEntity()
    if(IsValid(ent) and isBuilding(ent) and ent:GetPos():Distance(ply:GetPos()) <= 150) then
        local ang = ent:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 180)
        ent:SetAngles(ang)
    end
end)

net.Receive("gRust.Pickup", function(len, ply)
    local ent = net.ReadEntity()
    if(IsValid(ent) and ent.Pickup and ent:GetPos():Distance(ply:GetPos()) <= 150) then
        ent:Pickup(ply)
    end
end)
