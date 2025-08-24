util.AddNetworkString("gRust.SelectWeapon")

local function StripInvWeapons(pl)
    for _, w in ipairs(pl:GetWeapons()) do
        if w.InventorySlot then pl:StripWeapon(w:GetClass()) end
    end
end

function GiveHands(pl)  
    pl:Give("rust_hands")
    pl:SelectWeapon("rust_hands")
end

function ClearPlayerWeapon(pl)
    StripInvWeapons(pl)
    GiveHands(pl)
    pl.SelectedSlotIndex = nil
    pl.SelectedSlot      = nil
end

local function EquipWeapon(pl, slot)
    if not IsValid(pl) or not pl.Inventory then
        ClearPlayerWeapon(pl)
        return
    end
    if slot == 0 or not pl.Inventory[slot] then
        ClearPlayerWeapon(pl)
        return
    end

    local item = pl.Inventory[slot]
    local cls  = gRust.Items[item:GetItem()]:GetWeapon()
    if not cls then
        ClearPlayerWeapon(pl)
        return
    end

    StripInvWeapons(pl)
    local swep = pl:Give(cls)
    if IsValid(swep) then
        swep.InventorySlot = slot
        swep.InventoryItem = item
        pl:SelectWeapon(cls)
    end
end

local function QueueEquip(pl, slot)
    pl.DesiredSlot = slot
    timer.Remove("gRustEquip" .. pl:UserID())
    timer.Create("gRustEquip" .. pl:UserID(), 0.07, 1, function()
        if IsValid(pl) then
            EquipWeapon(pl, pl.DesiredSlot or 0)
        end
    end)
end

net.Receive("gRust.SelectWeapon", function(_, pl)
    local slot = net.ReadUInt(3)
    if not IsValid(pl) then return end
    pl.SelectedSlotIndex = slot
    pl.SelectedSlot      = pl.Inventory and pl.Inventory[slot] or nil
    QueueEquip(pl, slot)
end)

hook.Add("gRust.ItemMoved", "gRust.CheckPlayerWeaponMoved", function(pl, fromEnt, toEnt, from, to)
    if not pl.SelectedSlotIndex then return end
    if (fromEnt == pl and from == pl.SelectedSlotIndex) or (toEnt == pl and to == pl.SelectedSlotIndex) then
        QueueEquip(pl, pl.SelectedSlotIndex or 0)
    end
end)

hook.Add("gRust.ItemDropped", "gRust.CheckPlayerWeaponDropped", function(pl, _, _, slot)
    if slot == pl.SelectedSlotIndex then
        QueueEquip(pl, pl.SelectedSlotIndex or 0)
    end
end)

hook.Add("PlayerDeath", "gRust.ClearWeaponOnDeath", function(pl)
    ClearPlayerWeapon(pl)
end)
