local PLAYER = FindMetaTable("Player")
local CRAFT_CONFIG = {
    MAX_CRAFT_AMOUNT = 100,
    MAX_QUEUE_SIZE = 32,
    PROCESS_INTERVAL = 0.5,
    MAX_INDEX_BITS = 6
}

function PLAYER:HasBlueprint(itemClass)
    if not gRust.Items[itemClass] then return false end
    local blueprintTier = gRust.Items[itemClass]:GetBlueprint()
    if not blueprintTier then return true end
    return self:HasItem(itemClass .. ".BP", 1)
end

function PLAYER:IsLookingAtValidWorkbench(itemClass)
    local itemdata = gRust.Items[itemClass]
    if not itemdata then return false end
    local requiredTier = itemdata:GetTier() or 0
    if requiredTier == 0 then return true end
    local playerPos = self:GetPos()
    local playerAngle = self:GetAngles()
    local forwardVec = playerAngle:Forward()
    local nearbyEnts = ents.FindInSphere(playerPos, 200)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "rust_tier" .. requiredTier then
            local entPos = ent:GetPos()
            local dirToEnt = (entPos - playerPos):GetNormalized()
            local dot = forwardVec:Dot(dirToEnt)
            if dot > 0.3 then return true end
        end
    end
    return false
end

util.AddNetworkString("gRust.Craft")
util.AddNetworkString("gRust.Crafting")
util.AddNetworkString("gRust.CraftRemove")
util.AddNetworkString("gRust.CraftComplete")
util.AddNetworkString("gRust.CraftProgress")
net.Receive("gRust.Craft", function(len, ply)
    if not IsValid(ply) then return end
    local item = net.ReadString()
    local amount = net.ReadUInt(7)
    local skin = net.ReadString()
    if not item or item == "" then return end
    if amount <= 0 or amount > CRAFT_CONFIG.MAX_CRAFT_AMOUNT then return end
    local itemdata = gRust.Items[item]
    if not itemdata then return end
    if not ply:CanCraft(itemdata, amount) then return end
    if not ply:IsLookingAtValidWorkbench(item) then
        if ply.SendNotification then end
        return
    end

    if table.Count(ply:GetActiveCrafts()) >= CRAFT_CONFIG.MAX_QUEUE_SIZE then
        if ply.SendNotification then end
        return
    end

    ply:AddToCraftQueue(item, amount, skin)
end)

net.Receive("gRust.CraftRemove", function(len, ply)
    if not IsValid(ply) then return end
    local index = net.ReadUInt(CRAFT_CONFIG.MAX_INDEX_BITS)
    ply:CancelCraft(index)
end)

function PLAYER:InitCraftQueue()
    if not self.CraftQueue then
        self.CraftQueue = {}
        self.CraftQueueIndex = 0
        self.LastCraftProcess = 0
    end
end

function PLAYER:GetNextCraftIndex()
    self.CraftQueueIndex = (self.CraftQueueIndex or 0) + 1
    if self.CraftQueueIndex > (2 ^ CRAFT_CONFIG.MAX_INDEX_BITS - 1) then self.CraftQueueIndex = 1 end
    while self.CraftQueue[self.CraftQueueIndex] do
        self.CraftQueueIndex = self.CraftQueueIndex + 1
        if self.CraftQueueIndex > (2 ^ CRAFT_CONFIG.MAX_INDEX_BITS - 1) then self.CraftQueueIndex = 1 end
    end
    return self.CraftQueueIndex
end

function PLAYER:AddToCraftQueue(item, amount, skin)
    self:InitCraftQueue()
    local itemdata = gRust.Items[item]
    if not itemdata then return false end
    local craftRecipe = itemdata:GetCraft()
    if not craftRecipe or #craftRecipe == 0 then return false end
    for _, recipe in ipairs(craftRecipe) do
        if not self:HasItem(recipe.item, recipe.amount * amount) then
            if self.SendNotification then self:SendNotification("Insufficient Resources", NOTIFICATION_REMOVE, "resources", "") end
            return false
        end
    end

    for _, recipe in ipairs(craftRecipe) do
        self:RemoveItem(recipe.item, recipe.amount * amount)
        local reqItemData = gRust.Items[recipe.item]
        local reqItemName = reqItemData and reqItemData:GetName() or recipe.item
        local usedAmount = recipe.amount * amount
        local displayText = reqItemName
        local side = "-" .. usedAmount
        local icon = "materials/icons/close.png"
        if self.SendNotification then self:SendNotification(displayText, NOTIFICATION_REMOVE, icon, side) end
    end

    local index = self:GetNextCraftIndex()
    local currentTime = CurTime()
    local craftTime = itemdata:GetCraftTime() or 5
    self.CraftQueue[index] = {
        item = item,
        amount = amount,
        skin = skin or "",
        startTime = currentTime,
        craftTime = craftTime,
        endTime = currentTime + craftTime,
        completed = false,
        index = index,
        progress = 0
    }

    net.Start("gRust.Crafting")
    net.WriteString(item)
    net.WriteUInt(index, CRAFT_CONFIG.MAX_INDEX_BITS)
    net.WriteFloat(craftTime)
    net.Send(self)
    hook.Call("gRust.CraftStarted", nil, self, item, craftTime, amount, index)
    return true
end

function PLAYER:ProcessCraftQueue()
    if not self.CraftQueue or table.IsEmpty(self.CraftQueue) then return end
    local currentTime = CurTime()
    local completedIndex = nil
    for index, craft in pairs(self.CraftQueue) do
        if not craft.completed then
            local progress = math.min((currentTime - craft.startTime) / craft.craftTime, 1)
            craft.progress = progress
            if currentTime >= craft.endTime then
                completedIndex = index
                break
            end
        end
    end

    if completedIndex then
        local craft = self.CraftQueue[completedIndex]
        local itemdata = gRust.Items[craft.item]
        if itemdata then
            local craftAmount = itemdata:GetCraftAmount() or 1
            local successCount = 0
            local totalGiven = 0
            for i = 1, craft.amount do
                local given = 0
                for j = 1, craftAmount do
                    if self:GiveItem(craft.item, 1, craft.skin ~= "" and craft.skin or nil) then
                        given = given + 1
                        totalGiven = totalGiven + 1
                    end
                end

                if given == craftAmount then successCount = successCount + 1 end
            end

            if successCount > 0 then
                hook.Call("gRust.CraftCompleted", nil, self, craft.item, totalGiven, completedIndex)
                net.Start("gRust.CraftComplete")
                net.WriteUInt(completedIndex, CRAFT_CONFIG.MAX_INDEX_BITS)
                net.WriteString(craft.item)
                net.WriteUInt(totalGiven, 7)
                net.Send(self)
            end

            local failedAmount = craft.amount - successCount
            if failedAmount > 0 then
                local craftRecipe = itemdata:GetCraft()
                for _, recipe in ipairs(craftRecipe) do
                    self:GiveItem(recipe.item, recipe.amount * failedAmount)
                end
            end
        end

        self.CraftQueue[completedIndex] = nil
    end
end

function PLAYER:GetActiveCrafts()
    self:InitCraftQueue()
    local active = {}
    local currentTime = CurTime()
    for index, craft in pairs(self.CraftQueue) do
        if craft and not craft.completed and currentTime < craft.endTime then
            craft.progress = math.min((currentTime - craft.startTime) / craft.craftTime, 1)
            table.insert(active, craft)
        end
    end

    table.sort(active, function(a, b) return a.startTime < b.startTime end)
    return active
end

function PLAYER:GetCraftProgress(index)
    if not self.CraftQueue or not self.CraftQueue[index] then return 0 end
    local craft = self.CraftQueue[index]
    if craft.completed then return 1 end
    local progress = math.min((CurTime() - craft.startTime) / craft.craftTime, 1)
    return progress
end

function PLAYER:CancelCraft(index)
    if not self.CraftQueue or not self.CraftQueue[index] then return false end
    local craft = self.CraftQueue[index]
    if craft.completed then return false end
    local itemdata = gRust.Items[craft.item]
    if not itemdata then return false end
    local progress = self:GetCraftProgress(index)
    local refundMultiplier = 1
    local craftRecipe = itemdata:GetCraft()
    for _, recipe in ipairs(craftRecipe) do
        local refundAmount = math.ceil(recipe.amount * craft.amount * refundMultiplier)
        if refundAmount > 0 then self:GiveItem(recipe.item, refundAmount) end
    end

    if self.RemoveCraftNotification then self:RemoveCraftNotification(index) end
    if self.SendNotification then end
    hook.Call("gRust.CraftRemoved", nil, self, craft.item, index)
    net.Start("gRust.CraftRemove")
    net.WriteUInt(index, CRAFT_CONFIG.MAX_INDEX_BITS)
    net.Send(self)
    self.CraftQueue[index] = nil
    return true
end

function PLAYER:ClearCraftQueue()
    if not self.CraftQueue then return end
    local count = 0
    for index, craft in pairs(self.CraftQueue) do
        if not craft.completed then
            self:CancelCraft(index)
            count = count + 1
        end
    end

    self.CraftQueue = {}
end

timer.Create("gRust.ProcessCrafts", CRAFT_CONFIG.PROCESS_INTERVAL, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:IsConnected() then ply:ProcessCraftQueue() end
    end
end)

hook.Add("PlayerInitialSpawn", "gRust.InitCraftQueue", function(ply) timer.Simple(1, function() if IsValid(ply) then ply:InitCraftQueue() end end) end)
hook.Add("PlayerDisconnected", "gRust.ClearCraftQueue", function(ply) if ply.CraftQueue then ply.CraftQueue = nil end end)
