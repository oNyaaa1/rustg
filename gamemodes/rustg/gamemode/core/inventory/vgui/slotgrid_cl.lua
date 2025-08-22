local PANEL = {}



AccessorFunc(PANEL, "Rows", "Rows", FORCE_NUMBER)

AccessorFunc(PANEL, "Cols", "Cols", FORCE_NUMBER)

AccessorFunc(PANEL, "Margin", "Margin", FORCE_NUMBER)



AccessorFunc(PANEL, "Entity", "Entity")

AccessorFunc(PANEL, "InventoryOffset", "InventoryOffset", FORCE_NUMBER)



function PANEL:Init()

	self.Slots = {}



	self.NeedLayout = true

end



function PANEL:GetInventory()

	return self:GetEntity().Inventory

end



function PANEL:SetSelection(n)

	self.Slots[self.Selected or 1]:SetSelected(false)

	self.Selected = n



	if (!n) then return end

	self.Slots[n]:SetSelected(true)

end



function PANEL:OnSelection(i)

end


function PANEL:UpdateSlot(slot)
    local Inventory = self:GetInventory()
    if (!Inventory) then return end
    
    local slotIndex = slot - (self:GetInventoryOffset() or 0)

    if (slotIndex < 1 or slotIndex > self:GetRows() * self:GetCols()) then return end

    if (!self.Slots[slotIndex]) then return end

    local item = Inventory[slot]

    self.Slots[slotIndex]:SetItem(item)
end


function PANEL:PerformLayout()
    if (!self.NeedLayout) then return end

    local Wide, Tall = self:GetWide(), self:GetTall()
    local Cols, Rows = self:GetCols(), self:GetRows()
    local Margin = self:GetMargin()

    for k, v in ipairs(self.Slots) do
        v:Remove()
        self.Slots[k] = nil
    end

    local RowHeight = (Tall - (Margin * (Rows - 1))) / Rows

    local i = 1
    for x = 1, Rows do
        local Row = self:Add("Panel")
        Row:SetTall(RowHeight)
        Row:Dock(TOP)

        if (x < Rows) then
            Row:DockMargin(0, 0, 0, Margin)
        end

        for y = 1, Cols do
            local Ent = self:GetEntity()
            local Slot = Row:Add("gRust.Inventory.Slot")
            Slot:SetWide(Wide / Cols - (self:GetMargin() * 0.5))
            Slot:Dock(LEFT)
            Slot:SetEntity(Ent)
            Slot:SetID(i + (self:GetInventoryOffset() or 0))

            Slot.OnQuickSwap = function(me)
                if (Ent == LocalPlayer()) then
                    local OtherContainer = gRust.Inventory.Container
                    if (OtherContainer) then
                        LocalPlayer():MoveSlot(Ent, OtherContainer, me:GetID(), OtherContainer:FindEmptySlot(), me.Item:GetQuantity())
                        return
                    end

                    if (!me.Item) then return end
                    local Slot = me:GetID() < 7 and Ent:FindEmptySlot(7, nil, me.Item) or Ent:FindEmptySlot(1, 6, me.Item)
                    if (!Slot) then return end

                    LocalPlayer():MoveSlot(Ent, Ent, me:GetID(), Slot, me.Item:GetQuantity())
                else
                    local Slot = LocalPlayer():FindEmptySlot(nil, nil, me.Item)
                    if (!Slot or !me.Item) then return end

                    LocalPlayer():MoveSlot(Ent, LocalPlayer(), me:GetID(), Slot, me.Item:GetQuantity())
                end
            end
            
            Slot.DoClick = function(me)
                if (IsValid(LocalPlayer().SelectedSlotPanel)) then
                    LocalPlayer().SelectedSlotPanel:SetSelected(false)
                end
                if ( gRust.Inventory.OnSelection) then
                    gRust.Inventory:OnSelection(me:GetEntity(), me:GetID())
                else
                    
                end
                me:SetSelected(true)
                LocalPlayer().SelectedSlotPanel = me
            end

            if (y < Cols) then
                Slot:DockMargin(0, 0, Margin, 0)
            end

            self.Slots[i] = Slot
            i = i + 1
        end
    end

    self:Update()
    self.NeedLayout = false
end





function PANEL:Update()

	local Inventory = self:GetInventory()

	if (!Inventory) then return end



	for i = 1, self:GetRows() * self:GetCols() do

		local Item = Inventory[i + (self:GetInventoryOffset() or 0)]

		if (!self.Slots[i]) then continue end



		self.Slots[i]:SetItem(Item)

	end

end



vgui.Register("gRust.Inventory.SlotGrid", PANEL, "Panel")