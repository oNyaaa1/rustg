PLAYER = FindMetaTable("Player")

function PLAYER:MoveSlot(from, to, old, new, amount)
    if not new then return end
    net.Start("gRust.Inventory.Move")
    net.WriteEntity(from)
    net.WriteEntity(to)
    net.WriteUInt(old, 6)
    net.WriteUInt(new, 6)
    net.WriteUInt(amount, 20)
    net.SendToServer()
end

function PLAYER:RequestInventory(ent)
    net.Start("gRust.Inventory.Request")
    net.WriteEntity(ent)
    net.SendToServer()
end

function gRust.UpdateInventory()
    if not IsValid(LocalPlayer()) then return end
    if IsValid(gRust.Hotbar) then
        gRust.Hotbar:Update()
    end
    if IsValid(gRust.Inventory) and IsValid(gRust.Inventory.Slots) then
        gRust.Inventory.Slots:Update()
        gRust.Inventory.Attire:Update()
        if gRust.Inventory.Container then
            gRust.Inventory.UpdateContainer()
        end
    end
end

local function SyncSlot()
    local ent = net.ReadEntity()
    if (!IsValid(ent)) then return end
    local pos = net.ReadUInt(6)
    local item = net.ReadItem()
    if (!ent.Inventory) then return end
    ent.Inventory[pos] = item

    if ent == LocalPlayer() then
        if IsValid(gRust.Hotbar) and pos >= 1 and pos <= 6 then
            gRust.Hotbar:Update()
        end
        if IsValid(gRust.Inventory) and IsValid(gRust.Inventory.Slots) then
            gRust.Inventory.Slots:Update()
            if pos >= 31 and pos <= 36 then
                gRust.Inventory.Attire:Update()
            end
        end
    elseif gRust.Inventory.Container and gRust.Inventory.Container.Entity == ent then
        gRust.Inventory.UpdateContainer()
    end
end

function RemoveSlot()
    local ent = net.ReadEntity()
    local slot = net.ReadUInt(6)
    if not IsValid(ent) or not ent.Inventory then return end
    ent.Inventory[slot] = nil
    if ent == LocalPlayer() then
        gRust.UpdateInventory()
    elseif gRust.Inventory.Container and gRust.Inventory.Container.Entity == ent then
        gRust.Inventory.UpdateContainer()
    end
end

function SyncAll()
    local pl = LocalPlayer()
    pl.Inventory = {}
    for i = 1, net.ReadUInt(6) do
        pl.Inventory[net.ReadUInt(6)] = net.ReadItem()
    end
    pl.InventorySlots = net.ReadUInt(6)
    timer.Simple(0, function()
        gRust.UpdateInventory()
    end)
end

function CreateInventory()
    local pl = LocalPlayer()
    pl.Inventory = {}
    pl.InventorySlots = net.ReadUInt(6)
end

function SyncEntityContainer()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent.Inventory = {}
    local itemCount = net.ReadUInt(6)
    for i = 1, itemCount do
        local slot = net.ReadUInt(6)
        local item = net.ReadItem()
        if item then
            ent.Inventory[slot] = item
        end 
    end
    ent.InventorySlots = net.ReadUInt(6)
    timer.Simple(0, function()
        if IsValid(ent) then
            gRust.UpdateInventory()
        end
    end)
end

net.Receive("gRust.Inventory.SyncSlot", SyncSlot)
net.Receive("gRust.Inventory.Remove", RemoveSlot)
net.Receive("gRust.Inventory.SyncAll", SyncAll)
net.Receive("gRust.Inventory.Create", CreateInventory)
net.Receive("gRust.Inventory.Request", SyncEntityContainer)
