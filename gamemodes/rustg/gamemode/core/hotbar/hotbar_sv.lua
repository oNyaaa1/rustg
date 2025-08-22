util.AddNetworkString("gRust.SelectWeapon")

function ClearPlayerWeapon(pl)
    if not IsValid(pl) then return end
    pl.SelectedSlotIndex = nil
    pl.SelectedSlot = nil
    for _, swep in ipairs(pl:GetWeapons()) do
        if swep.InventorySlot then
            pl:StripWeapon(swep:GetClass())
        end
    end
end

function SetPlayerWeapon(pl, slot)
    if not IsValid(pl) or not pl.Inventory then
        ClearPlayerWeapon(pl)
        return
    end

    if slot == 0 or not pl.Inventory[slot] then
        ClearPlayerWeapon(pl)
        pl:Give("rust_hands")
        pl:SelectWeapon("rust_hands")
        return
    end

    local item = pl.Inventory[slot]
    local ItemData = gRust.Items[item:GetItem()]
    if not ItemData or not ItemData.GetWeapon or not ItemData:GetWeapon() then
        ClearPlayerWeapon(pl)
        pl:Give("rust_hands")
        pl:SelectWeapon("rust_hands")
        return
    end

    if pl.SelectedSlotIndex == slot then return end

    pl.SelectedSlotIndex = slot
    pl.SelectedSlot = item

    for _, swep in ipairs(pl:GetWeapons()) do
        if swep.InventorySlot then
            pl:StripWeapon(swep:GetClass())
        end
    end

    local weaponClass = ItemData:GetWeapon()
    local swep = pl:Give(weaponClass)
    if IsValid(swep) then
        swep.InventorySlot = slot
        swep.InventoryItem = item
        pl:SelectWeapon(weaponClass)
    end
end

net.Receive("gRust.SelectWeapon", function(_, pl)
    local slot = net.ReadUInt(4)
    SetPlayerWeapon(pl, slot)
end)

hook.Add("gRust.ItemMoved", "gRust.CheckPlayerWeaponMoved", function(pl, from, to)
    if pl.SelectedSlotIndex == from or from == 0 or to == 0 or from == nil or to == nil then
        ClearPlayerWeapon(pl)
        SetPlayerWeapon(pl, pl.SelectedSlotIndex or 0)
    elseif pl.SelectedSlotIndex == to then
        ClearPlayerWeapon(pl)
        SetPlayerWeapon(pl, to)
    end
end)

hook.Add("gRust.ItemDropped", "gRust.CheckPlayerWeaponDropped", function(pl, item, ent, slot)
    if pl.SelectedSlotIndex == slot then
        ClearPlayerWeapon(pl)
        SetPlayerWeapon(pl, pl.SelectedSlotIndex or 0)
    end
end)

hook.Add("PlayerDeath", "gRust.ClearWeaponOnDeath", function(pl)
    ClearPlayerWeapon(pl)
    pl:Give("rust_hands")
    pl:SelectWeapon("rust_hands")
end)
