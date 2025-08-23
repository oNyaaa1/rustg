include("shared.lua")

ENT.InventorySlots = 12 
ENT.InventoryName = "CONTAINER"


local Container
local InventoryPanel

function ENT:ConstructInventory(panel, data, rows)

    if (IsValid(Container)) then
        Container:Remove()
        Container = nil
        InventoryPanel = nil
    end

    if (table.IsEmpty(data)) then   
        return
    end

    local Rows = rows or (self.InventorySlots / 6)

    Container = panel:Add("Panel")  
    Container:Dock(FILL)

    InventoryPanel = Container:Add("gRust.Inventory")
    InventoryPanel:Dock(BOTTOM)
    InventoryPanel:SetCols(6)
    InventoryPanel:SetInventory(self)
    
    local LeftMargin = ScrW() * 0.02
    local RightMargin = ScrW() * 0.04   
    InventoryPanel:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.165)


    Container.Think = function(me)
        if (!IsValid(self)) then 
            Container:Remove()
            Container = nil
            InventoryPanel = nil
            return
        end

        local distance = LocalPlayer():GetPos():Distance(self:GetPos())
        if (distance > 200) then
            gRust.CloseInventory()
            return
        end
    end

    local Loot = Container:Add("DLabel")
    Loot:Dock(BOTTOM)
    Loot:SetFont("gRust.58px")
    Loot:SetText("LOOT")
    Loot:SetColor(Color(255, 255, 255, 225))
    Loot:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.008)
    Loot:SetTall(ScrH() * 0.025)

end

function ENT:Interact()
    if IsValid(gRust.Inventory)  then return end
    gRust.OpenInventory(self)
end
