local gRust = gRust
local net = net

function net.WriteItem(item)
    net.WriteString(item:GetItem())
    net.WriteUInt(item:GetQuantity(), 20)
    net.WriteUInt(item:GetWear() or 0, 10)
    net.WriteUInt(item:GetClip() or 0, 7)

    local ID = gRust.Items[item:GetItem()]
    local count = ID:GetAttachments()

    if (count) then
        for i = 1, count do
            local mod = item.Mods[i]
            if (mod == nil) then
                net.WriteBit(0)
            else
                net.WriteBit(1)
                net.WriteItem(mod)
            end
        end
    end
end

function net.ReadItem()
    local name = net.ReadString()
    local Item = gRust.CreateItem(name)
    Item:SetQuantity(net.ReadUInt(20))
    Item:SetWear(net.ReadUInt(10))
    Item:SetClip(net.ReadUInt(7))

    local ID = gRust.Items[name]
    local count = ID:GetAttachments()

    if (count) then
        for i = 1, count do
            if (net.ReadBit() == 1) then
                Item.Mods[i] = net.ReadItem()
            end
        end
    end

    return Item
end

local ITEM = {
    Item = "wood",
    Quantity = 1,
    Wear = 1000,
    Clip = 0,
}

gRust.__ITEM = ITEM
ITEM.__index = ITEM

AccessorFunc(ITEM, "Item", "Item", FORCE_STRING)
AccessorFunc(ITEM, "Quantity", "Quantity", FORCE_NUMBER)
AccessorFunc(ITEM, "Wear", "Wear", FORCE_NUMBER)
AccessorFunc(ITEM, "Clip", "Clip", FORCE_NUMBER)
AccessorFunc(ITEM, "Skin", "Skin", FORCE_STRING)

function ITEM:SetQuantity(n)
    local ItemData = gRust.Items[self.Item]
    if ItemData then
        self.Quantity = math.max(0, math.min(n, ItemData:GetStack()))
    else
        self.Quantity = math.max(0, n)
    end
end

function ITEM:AddQuantity(n)
    if not n or n <= 0 then return false end
    local ItemData = gRust.Items[self.Item]
    if not ItemData then return false end

    local maxStack = ItemData:GetStack()
    local newQuantity = self.Quantity + n

    if newQuantity > maxStack then
        self.Quantity = maxStack
        return false, newQuantity - maxStack
    else
        self.Quantity = newQuantity
        return true, 0
    end
end

function ITEM:RemoveQuantity(n)
    if not n or n <= 0 then return false end
    local removedAmount = math.min(n, self.Quantity)
    self.Quantity = math.max(0, self.Quantity - n)
    return removedAmount
end

function ITEM:SetWear(n)
    self.Wear = math.max(n, 0)
end

function ITEM:CanStack(otheritem, amount)
    if type(otheritem) ~= "table" or not isfunction(otheritem.GetItem) or not isfunction(otheritem.GetQuantity) then
        return false
    end

    if self:GetItem() ~= otheritem:GetItem() then
        return false
    end

    local ItemData = gRust.Items[self:GetItem()]
    if ItemData and ItemData:GetDurability() then
        if self:GetWear() ~= otheritem:GetWear() then
            return false
        end
    end

    if self.Mods or otheritem.Mods then
        if not self:ModsEqual(otheritem) then
            return false
        end
    end

    if not ItemData then return false end

    local Total = (amount or self:GetQuantity()) + otheritem:GetQuantity()
    return Total <= ItemData:GetStack()
end

function ITEM:CanAddQuantity(amount)
    if not amount or amount <= 0 then return false end
    local ItemData = gRust.Items[self.Item]
    if not ItemData then return false end
    return (self.Quantity + amount) <= ItemData:GetStack()
end

function ITEM:GetMaxAddable()
    local ItemData = gRust.Items[self.Item]
    if not ItemData then return 0 end
    return ItemData:GetStack() - self.Quantity
end

function ITEM:ModsEqual(otheritem)
    if not self.Mods and not otheritem.Mods then return true end
    if not self.Mods or not otheritem.Mods then return false end

    local count1 = #self.Mods
    local count2 = #otheritem.Mods

    if count1 ~= count2 then return false end

    for i = 1, count1 do
        local mod1 = self.Mods[i]
        local mod2 = otheritem.Mods[i]

        if not mod1 and not mod2 then
            continue
        elseif not mod1 or not mod2 then
            return false
        elseif mod1:GetItem() ~= mod2:GetItem() then
            return false
        end
    end

    return true
end

function ITEM:Split(amount)
    if not amount or amount <= 0 or amount >= self.Quantity then return nil end

    local newItem = self:Copy()
    newItem:SetQuantity(amount)
    self:SetQuantity(self.Quantity - amount)

    return newItem
end

function ITEM:Merge(otheritem)
    if not self:CanStack(otheritem) then return false end

    local success, overflow = self:AddQuantity(otheritem:GetQuantity())

    if success then
        return true, 0
    else
        return false, overflow
    end
end

function ITEM:GetRepairCost()
    local Craft = gRust.Items[self:GetItem()]:GetCraft()
    if (!Craft) then return end

    local WearFrac = self:GetWear() / 1000
    local Repair = {}

    for k, v in ipairs(Craft) do
        local Amount = math.floor(v.amount * (1 - WearFrac))
        if (Amount <= 0) then continue end
        Repair[#Repair + 1] = {Class = v.item, Amount = Amount}
    end

    return Repair
end

function ITEM:AddMod(item)
    for i = 1, 4 do
        local v = self.Mods[i]
        if (!v) then continue end

        if (v:GetItem() == item:GetItem()) then
            return false
        end

        if (gRust.Items[v:GetItem()].Attach == gRust.Items[item:GetItem()].Attach) then
            return false
        end
    end

    if (!weapons.Get(gRust.Items[self:GetItem()]:GetWeapon()).AttachmentData[item:GetItem()]) then
        return false
    end

    local ItemData = gRust.Items[item:GetItem()]
    if (ItemData:GetCategory() ~= "Attachments") then return end

    self.Mods[#self.Mods + 1] = item
    return true
end

function ITEM:GetMods()
    local count = gRust.Items[self:GetItem()]:GetAttachments()
    if (!count or count < 1) then return end

    local mods = {}

    for i = 1, count do
        local v = self.Mods[i]
        if (!v) then continue end
        mods[#mods + 1] = v
    end

    return mods
end

function ITEM:Copy()
    local copy = table.Copy(self)
    if self.Mods then
        copy.Mods = {}
        for i, mod in pairs(self.Mods) do
            if mod then
                copy.Mods[i] = mod:Copy()
            end
        end
    end
    return setmetatable(copy, ITEM)
end

function ITEM:IsStackable()
    local ItemData = gRust.Items[self:GetItem()]
    if not ItemData then return false end
    return ItemData:GetStack() > 1
end
function gRust.CreateItem(class, quantity, wear)
    if (!gRust.Items[class]) then
        ErrorNoHalt("Attempted to create an unknown item class ", class, "\n")
        return
    end
    local meta = setmetatable({Item = class}, ITEM)
    if (gRust.Items[class]:GetAttachments()) then
        meta.Mods = {}
    end
    meta:SetQuantity(quantity or 1)
    meta:SetWear(wear or 1000) 
    return meta
end


gRust.Items = gRust.Items or {}

local ITEM_R = {
    Name = "wood",
    Stack = 1000,
    Category = "Resources",
    Durability = true,
    CraftTime = 10,
    CraftAmount = 1,
    Sound = "stone",
    Healing = 0,
    Calories = 0,
    Hydration = 0,
    Visible = true  -- Добавить эту строку
}

ITEM_R.__index = ITEM_R

AccessorFunc(ITEM_R, "Class", "Class", FORCE_STRING)
AccessorFunc(ITEM_R, "Name", "Name", FORCE_STRING)
AccessorFunc(ITEM_R, "Category", "Category", FORCE_STRING)
AccessorFunc(ITEM_R, "Stack", "Stack", FORCE_NUMBER)
AccessorFunc(ITEM_R, "Icon", "Icon", FORCE_STRING)
AccessorFunc(ITEM_R, "Sound", "Sound", FORCE_STRING)
AccessorFunc(ITEM_R, "Durability", "Durability", FORCE_BOOL)
AccessorFunc(ITEM_R, "Blueprint", "Blueprint")
AccessorFunc(ITEM_R, "Craft", "Craft")
AccessorFunc(ITEM_R, "CraftTime", "CraftTime", FORCE_NUMBER)
AccessorFunc(ITEM_R, "CraftAmount", "CraftAmount", FORCE_NUMBER)
AccessorFunc(ITEM_R, "Tier", "Tier", FORCE_NUMBER)
AccessorFunc(ITEM_R, "Entity", "Entity")
AccessorFunc(ITEM_R, "Weapon", "Weapon")
AccessorFunc(ITEM_R, "Clip", "Clip")
AccessorFunc(ITEM_R, "Attachments", "Attachments", FORCE_NUMBER)
AccessorFunc(ITEM_R, "Model", "Model", FORCE_STRING)
AccessorFunc(ITEM_R, "Purchasable", "Purchasable", FORCE_BOOL)
AccessorFunc(ITEM_R, "Healing", "Healing", FORCE_NUMBER)
AccessorFunc(ITEM_R, "Calories", "Calories", FORCE_NUMBER)
AccessorFunc(ITEM_R, "Hydration", "Hydration", FORCE_NUMBER)
AccessorFunc(ITEM_R, "Description", "Description", FORCE_STRING)
AccessorFunc(ITEM_R, "Visible", "Visible", FORCE_BOOL)   
AccessorFunc(ITEM_R, "Attire", "Attire", FORCE_STRING)

function ITEM_R:Copy()
    return table.Copy(self)
end

function ITEM_R:AddToCategory(cat)
    local len = gRust.CategoryItems[cat] and #gRust.CategoryItems[cat] or 0
    gRust.CategoryItems[cat][len + 1] = self
end

function ITEM_R:RemoveFromCategory(cat)
    for k, v in ipairs(gRust.CategoryItems[cat]) do
        if (v == self) then
            table.remove(gRust.CategoryItems[cat], k)
            return
        end
    end
end

function ITEM_R:GetDescription()
    return self.Description or "None"
end

function ITEM_R:SetDescription(desc)
    self.Description = desc
end

function ITEM_R:SetStack(stack)
    self.Stack = stack
end

function gRust.ItemRegister(class)
    local meta = setmetatable({}, ITEM_R)
    meta:SetClass(class)
    return meta
end

gRust.Stacks = gRust.Stacks or {
    ResourceStack = 1000,
    ClothingStack = 1,
    ToolStack = 1,
    MedicalStack = 5,
    WeaponStack = 1,
    AmmoStack = 128,
    ExplosivesStack = 10
}

local StackModifiers = {
    ["Resources"] = "ResourceStack",
    ["Clothing"] = "ClothingStack",
    ["Tools"] = "ToolStack",
    ["Medical"] = "MedicalStack",
    ["Weapons"] = "WeaponStack",
    ["Ammo"] = "AmmoStack",
    ["Explosives"] = "ExplosivesStack"
}

function gRust.RegisterItem(item)
    gRust.Items[item.Class] = item

    if (isnumber(item.Blueprint)) then
        local Blueprint = gRust.ItemRegister()
        Blueprint:SetClass(string.format("%s.Blueprint", item:GetClass()))
        Blueprint:SetName(string.format("%s Blueprint", item:GetName()))
        Blueprint:SetIcon(item:GetIcon())
        Blueprint:SetStack(1)
        Blueprint:SetBlueprint(true)
        Blueprint:SetCategory("Blueprints")
        gRust.RegisterItem(Blueprint)
    end

    if (StackModifiers[item.Category]) then
        item.Stack = item.Stack * gRust.Stacks[StackModifiers[item.Category]]
    end

    if (item.Model) then
        util.PrecacheModel(item.Model)
    end

    if (item:GetCategory() and item:GetCraft()) then
        item:AddToCategory(item.Category)
    end
end

hook.Add("gRust.LoadedCore", "LoadDrop", function()
    for k, v in pairs(gRust.Items) do
        v.Actions = v.Actions or {}
        v.Actions[#v.Actions + 1] = {
            Name = "Drop",
            Func = function(ent, slot)
                local amount = ent.Inventory and ent.Inventory[slot] and ent.Inventory[slot]:GetQuantity() or 1
                
                net.Start("gRust.Drop")
                net.WriteEntity(ent)
                net.WriteUInt(slot, 6)
                net.WriteUInt(amount, 20)
                net.SendToServer()
            end
        }
    end
end)
