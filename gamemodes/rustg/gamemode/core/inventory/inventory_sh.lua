local ENTITY = FindMetaTable("Entity")

function ENTITY:ItemCount(item)
    if not self.Inventory then return 0 end
    local Count = 0
    for i = 1, self.InventorySlots do
        local v = self.Inventory[i]
        if item and (not v or v:GetItem() ~= item) then continue end
        Count = Count + (v and v:GetQuantity() or 0)
    end
    return Count
end

function ENTITY:OccupiedSlots()
    if not self.Inventory then return 0 end
    local Count = 0
    for i = 1, self.InventorySlots do
        if self.Inventory[i] then
            Count = Count + 1
        end
    end
    return Count
end

function ENTITY:HasItem(item, amount)
    if not self.Inventory then return false end
    amount = amount or 1
    return self:ItemCount(item) >= amount
end

function ENTITY:FindEmptySlot(from, to)
    if not self.Inventory then return end
    from = from or 1
    to = to or self.InventorySlots
    for i = from, to do
        if not self.Inventory[i] then return i end
    end
end
