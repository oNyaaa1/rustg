local SelectedSlot = 0

local function CheckSlots(desc)
    if (SelectedSlot == nil or SelectedSlot == 0) then
        gRust.ResetDeploy()
        net.Start("gRust.SelectWeapon")
        net.WriteUInt(0, 3)
        net.SendToServer()
        gRust.Hotbar:SetSelection(nil)
        return
    end

    local pl = LocalPlayer()
    if (SelectedSlot > 6) then
        SelectedSlot = 1
    elseif (SelectedSlot < 1) then
        SelectedSlot = 6
    end

    if (!pl.Inventory) then return end

    pl.SelectedSlotIndex = SelectedSlot
    pl.SelectedSlot = pl.Inventory[SelectedSlot]
    gRust.ResetDeploy()

    net.Start("gRust.SelectWeapon")
    net.WriteUInt(SelectedSlot, 3)
    net.SendToServer()

    local Item = pl.Inventory[SelectedSlot]
    if (!Item) then
        gRust.Hotbar:SetSelection(SelectedSlot)
        return
    end

    gRust.Hotbar:SetSelection(SelectedSlot)
    if (gRust.Items[Item:GetItem()]:GetEntity()) then
        gRust.RequestDeploy(SelectedSlot)
    end
end

hook.Add("PlayerBindPress", "gRust.SelectSlot", function(pl, bind, pressed, code)
    if (string.sub(bind, 1, 4) ~= "slot") then return end
    local slotNum = tonumber(string.sub(bind, 5))
    if SelectedSlot == 0 or SelectedSlot == nil then
        SelectedSlot = slotNum
    else
        if SelectedSlot == slotNum then
            SelectedSlot = 0
        else
            SelectedSlot = slotNum
        end 
    end
    CheckSlots()
end)

gRust.AddBind("invnext", function(pl)
    SelectedSlot = SelectedSlot or 0
    SelectedSlot = SelectedSlot + 1
    CheckSlots()
end)

gRust.AddBind("invprev", function(pl)
    SelectedSlot = SelectedSlot or 2
    SelectedSlot = SelectedSlot - 1
    CheckSlots(true)
end)
