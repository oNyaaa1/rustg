util.AddNetworkString("gRust.UnloadAmmo")

net.Receive("gRust.UnloadAmmo", function(len, pl)
    local ent = net.ReadEntity()
    local slot = net.ReadUInt(6)
    if not IsValid(pl) or not IsValid(ent) then return end
    if ent ~= pl and ent:GetPos():Distance(pl:GetPos()) > 200 then return end
    if not ent.Inventory or not ent.Inventory[slot] then return end

    local item = ent.Inventory[slot]
    local itemData = gRust.Items[item:GetItem()]
    if not itemData then return end

    local ammoType = itemData.AmmoType
    local ammoCount = item:GetClip() or 0
    if ammoCount <= 0 or not ammoType then return end

    item:SetClip(0)
    ent:SyncSlot(slot)

    if pl.SelectedSlotIndex == slot and pl.SelectedSlot == item then
        local weaponClass = itemData:GetWeapon()
        local activeWeapon = pl:GetActiveWeapon()
        if IsValid(activeWeapon) and activeWeapon:GetClass() == weaponClass then
            activeWeapon:SetClip1(0)
        end
    end

    pl:GiveItem(ammoType, ammoCount)
end)
