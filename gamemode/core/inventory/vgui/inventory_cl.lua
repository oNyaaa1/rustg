local round = math.Round
gRust.ScalingInfluence = ScrW()
gRust.Scaling = (ScrH() / 1440) * gRust.ScalingInfluence + (1 - gRust.ScalingInfluence) * ScrW() / 2560
gRust.SlotSize = round(120 * gRust.Scaling)
gRust.SlotPadding = round(8 * gRust.Scaling)
local PANEL = {}
AccessorFunc(PANEL, "Inventory", "Inventory")
local CONTAINER_PADDING = 12 * gRust.Scaling
function PANEL:Init()
    self:SetCols(6)
end

function PANEL:SetCols(n)
    self.Cols = n
    if self.Grid then self.Grid:InvalidateLayout(true) end
end

function PANEL:RemoveNameContainer()
    if IsValid(self.NameContainer) then self.NameContainer:Remove() end
end

function PANEL:SetInventory(inv)
    if not inv then return end
    if IsValid(self.Grid) then
        self.Grid:Remove()
        self.Grid = nil
    end

    if IsValid(self.NameContainer) then
        self.NameContainer:Remove()
        self.NameContainer = nil
    end

    local spacing = gRust.SlotPadding
    local padding = CONTAINER_PADDING
    local inventorySize = inv.InventorySlots
    local rows = math.ceil(inventorySize / self.Cols)
    self.Grid = self:Add("gRust.Inventory.SlotGrid")
    self.Grid:DockMargin(padding, padding, padding, 0)
    self.Grid:Dock(BOTTOM)
    self.Grid:SetCols(self.Cols)
    self.Grid:SetRows(rows)
    self.Grid:SetEntity(inv)
    self.Grid:SetMargin(spacing)
    local gridHeight = (gRust.SlotSize * rows) + (spacing * (rows - 1))
    self.Grid:SetTall(gridHeight)
    local NameContainer = self:Add("Panel")
    NameContainer:Dock(BOTTOM)
    NameContainer:SetTall(46 * gRust.Scaling)
    NameContainer.Paint = function(me, w, h)
        surface.SetMaterial(Material("materials/ui/background.png"))
        surface.SetDrawColor(126, 126, 126, 39)
        surface.DrawTexturedRect(0, 0, w, h)
        local inventoryName = "Inventory"
        if inv.GetName then
            inventoryName = inv:GetName() or inventoryName
        elseif inv.InventoryName then
            inventoryName = inv.InventoryName
        end

        draw.SimpleText(inventoryName, "gRust.32px", 16 * gRust.Scaling, h * 0.5, gRust.Colors.Text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.NameContainer = NameContainer
    local totalHeight = gridHeight + NameContainer:GetTall() + (padding * 2)
    self:SetTall(totalHeight)
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.Grid) and self.inventorySize then
        local inventorySize = self.inventorySize
        local rows = math.ceil(inventorySize / self.Cols)
        local spacing = gRust.SlotPadding
        local gridHeight = (gRust.SlotSize * rows) + (spacing * (rows - 1))
        self.Grid:SetTall(gridHeight)
        if IsValid(self.NameContainer) then
            local padding = CONTAINER_PADDING
            local totalHeight = gridHeight + self.NameContainer:GetTall() + (padding * 2)
            self:SetTall(totalHeight)
        end
    end
end

vgui.Register("gRust.Inventory", PANEL, "Panel")