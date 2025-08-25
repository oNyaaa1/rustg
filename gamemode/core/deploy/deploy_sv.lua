util.AddNetworkString("gRust.Deploy")
local function HandleDeploy(len, pl)
    if not IsValid(pl) then return end
    local index = net.ReadUInt(3)
    local Item = pl.Inventory[index]
    if not Item then return end
    local ItemData = gRust.Items[Item:GetItem()]
    if not ItemData then return end
    local Class = ItemData:GetEntity()
    local DeployData = scripted_ents.Get(Class).Deploy
    if not DeployData then return end
    -- Check if player can deploy at this position
    if not pl:CanDeploy(DeployData) then return end
    -- Get deployment position and angles
    local pos, ang, hitEnt = pl:GetDeployPosition(DeployData)
    if not pos then return end
    -- Additional validation checks
    if not pl:HasBuildPrivilege(pos, gRust.Config.TCRadius ^ 2 * 4) then return end
    -- Check for entity collision if not using sockets
    if not DeployData.Socket then
        -- Check surface normal to prevent ceiling placement
        local deployTrace = pl:GetDeployData()
        if deployTrace.Hit and deployTrace.HitNormal then
            -- Calculate angle between surface normal and up vector
            local surfaceAngle = math.deg(math.acos(deployTrace.HitNormal:Dot(Vector(0, 0, 1))))
            -- Prevent placement on surfaces that are too steep or upside down
            local maxAngle = DeployData.MaxSurfaceAngle or 45 -- Default 45 degrees
            if surfaceAngle > maxAngle then
                return -- Surface too steep or it's a ceiling
            end
        end

        local mins, maxs = DeployData.Mins or Vector(-16, -16, -16), DeployData.Maxs or Vector(16, 16, 16)
        local trace = util.TraceHull({
            start = pos,
            endpos = pos,
            mins = mins,
            maxs = maxs,
            filter = function(ent) return ent ~= pl and ent ~= hitEnt end
        })

        if trace.Hit and IsValid(trace.Entity) then return end
    end

    -- Create the entity
    local ent = ents.Create(Class)
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:SetAngles(ang)
    -- ИСПРАВЛЕНИЕ: НЕ используем SetOwner для сохранения коллизии
    -- ent:SetOwner(pl) -- Эта строка убрана!
    -- Используем только сетевые переменные для отслеживания владельца
    if ent.SetNW2Entity then ent:SetNW2Entity("gRust.Owner", pl) end
    if ent.SetNW2String then ent:SetNW2String("gRust.OwnerSteamID", pl:SteamID()) end
    -- Принудительно устанавливаем коллизию
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)
    ent:SetSolid(SOLID_VPHYSICS)
    -- Handle socket deployment
    if DeployData.Socket and IsValid(hitEnt) and hitEnt:GetClass() == "rust_structure" then
        ent:SetParent(hitEnt)
        if ent.SetNW2Bool then ent:SetNW2Bool("gRust.InUse", true) end
    end

    -- Custom spawn logic
    if DeployData.OnSpawn then DeployData.OnSpawn(ent, pl) end
    ent:Spawn()
    ent:Activate()
    -- ИСПРАВЛЕНИЕ: Настройка физики после спавна
    timer.Simple(0.1, function()
        if IsValid(ent) then
            -- Убеждаемся что коллизия работает правильно
            ent:SetCollisionGroup(COLLISION_GROUP_NONE)
            ent:SetSolid(SOLID_VPHYSICS)
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false) -- Делаем объект статичным
                phys:Wake()
            end
        end
    end)

    if Class == "rust_sleepingbag" then AddSleepingBagToPlayer(pl, ent) end
    -- Handle item consumption
    Item:SetQuantity(Item:GetQuantity() - 1)
    if Item:GetQuantity() <= 0 then
        pl.Inventory[index] = nil
        -- Clear hotbar if this was the selected item
        if pl.SelectedSlotIndex == index then
            pl.SelectedSlotIndex = nil
            pl.SelectedSlot = nil
            local activeWeapon = pl:GetActiveWeapon()
            if IsValid(activeWeapon) then pl:StripWeapon(activeWeapon:GetClass()) end
        end
    end

    if pl:SyncInventory() then pl:SyncInventory() end
    hook.Call("gRust.InventoryChanged", nil, pl, index, Item:GetQuantity() > 0 and Item or nil)
    -- Hook for custom deployment logic
    hook.Run("gRust.EntityDeployed", ent, pl, Item)
end

net.Receive("gRust.Deploy", HandleDeploy)
-- ИСПРАВЛЕНИЕ: Обновленная функция проверки владельца
local PLAYER = FindMetaTable("Player")
function PLAYER:ServerCanDeploy(pos, data)
    -- Check build privilege
    if not self:HasBuildPrivilege(pos, gRust.Config.TCRadius ^ 2 * 4) then return false, "No build privilege" end
    -- Check foundation requirements
    if data.RequiresFoundation then
        local foundationFound = false
        for _, ent in ipairs(ents.FindInSphere(pos, 50)) do
            if ent:GetClass() == "rust_foundation" or ent:GetClass() == "rust_structure" then
                foundationFound = true
                break
            end
        end

        if not foundationFound then return false, "Requires foundation" end
    end

    -- Check height restrictions
    if data.MaxHeight then
        local trace = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0, 0, -data.MaxHeight),
            filter = self
        })

        if not trace.Hit then return false, "Too high from ground" end
    end

    -- Check water deployment
    if data.NoWater and util.PointContents(pos) == CONTENTS_WATER then return false, "Cannot deploy in water" end
    -- Check slope restrictions
    if data.MaxSlope then
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 10),
            endpos = pos - Vector(0, 0, 100),
            filter = self
        })

        if trace.Hit then
            local slope = math.deg(math.acos(trace.HitNormal:Dot(Vector(0, 0, 1))))
            if slope > data.MaxSlope then return false, "Slope too steep" end
        end
    end
    return true
end

-- ИСПРАВЛЕНИЕ: Обновленная функция для подбора объектов
hook.Add("PlayerUse", "gRust.DeployPickup", function(pl, ent)
    if not IsValid(ent) or not IsValid(pl) then return end
    -- ИСПРАВЛЕНИЕ: Проверяем владельца через сетевые переменные
    local owner = ent:GetNW2Entity("gRust.Owner")
    local ownerSteamID = ent:GetNW2String("gRust.OwnerSteamID", "")
    -- Проверяем владельца по SteamID если entity не найден
    if not IsValid(owner) and ownerSteamID ~= "" then
        if pl:SteamID() ~= ownerSteamID then return end
    elseif IsValid(owner) and owner ~= pl then
        return
    end

    local entTable = scripted_ents.Get(ent:GetClass())
    if not entTable or not entTable.Deploy then return end
    local deployData = entTable.Deploy
    if not deployData.CanPickup then return end
    -- Check if player is holding proper tool (hammer, etc.)
    local weapon = pl:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= "rust_hammer" then return end
    -- Add item back to inventory
    local itemClass = deployData.Item or ent:GetClass():gsub("rust_", "")
    if pl.AddItem then pl:AddItem(itemClass, 1) end
    -- Handle socket cleanup
    if deployData.Socket and ent:GetParent() then ent:SetNW2Bool("gRust.InUse", false) end
    -- Custom pickup logic
    if deployData.OnPickup then deployData.OnPickup(ent, pl) end
    ent:Remove()
    hook.Run("gRust.EntityPickedUp", ent, pl)
    return true
end)

-- ИСПРАВЛЕНИЕ: Добавляем функцию для получения владельца entity
local ENT = FindMetaTable("Entity")
function ENT:GetRustOwner()
    local owner = self:GetNW2Entity("gRust.Owner")
    if IsValid(owner) then return owner end
    -- Если entity не найден, ищем по SteamID
    local steamID = self:GetNW2String("gRust.OwnerSteamID", "")
    if steamID ~= "" then
        for _, ply in ipairs(player.GetAll()) do
            if ply:SteamID() == steamID then return ply end
        end
    end
    return nil
end