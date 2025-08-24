local SelectedSlot = 0
local lastSentSlot = 0

local function SendSelect(slot)
    if slot ~= lastSentSlot then
        net.Start("gRust.SelectWeapon")
        net.WriteUInt(slot, 3)
        net.SendToServer()
        lastSentSlot = slot
    end
end

local function CheckSlots()
    if not SelectedSlot or SelectedSlot == 0 then
        gRust.ResetDeploy()
        SendSelect(0)
        if IsValid(gRust.Hotbar) then gRust.Hotbar:SetSelection(nil) end
        return
    end

    if SelectedSlot > 6 then SelectedSlot = 1 end
    if SelectedSlot < 1 then SelectedSlot = 6 end

    local pl = LocalPlayer()
    if not pl.Inventory then return end

    pl.SelectedSlotIndex = SelectedSlot
    pl.SelectedSlot = pl.Inventory[SelectedSlot]

    gRust.ResetDeploy()
    SendSelect(SelectedSlot)

    if IsValid(gRust.Hotbar) then gRust.Hotbar:SetSelection(SelectedSlot) end

    local item = pl.Inventory[SelectedSlot]
    if item and gRust.Items[item:GetItem()]:GetEntity() then
        gRust.RequestDeploy(SelectedSlot)
    end
end

hook.Add("PlayerBindPress", "gRust.SelectSlot", function(_, bind)
    if string.sub(bind, 1, 4) ~= "slot" then return end
    local num = tonumber(string.sub(bind, 5))
    if not num then return end
    SelectedSlot = (SelectedSlot == num) and 0 or num
    CheckSlots()
end)

gRust.AddBind("invnext", function()
    SelectedSlot = (SelectedSlot or 0) + 1
    CheckSlots()
end)

gRust.AddBind("invprev", function()
    SelectedSlot = (SelectedSlot or 7) - 1
    CheckSlots()
end)
