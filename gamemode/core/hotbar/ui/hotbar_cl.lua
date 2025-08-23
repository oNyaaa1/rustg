local YOffset = ScrH() * 0.02175
function gRust.LoadHotbar(width, offset, margin)
    if IsValid(gRust.Hotbar) then gRust.Hotbar:Remove() end
    local Tall = width / 6
    local Grid = vgui.Create("gRust.Inventory.SlotGrid")
    Grid:SetCols(6)
    Grid:SetRows(1)
    Grid:SetWide(width + (margin * 0.5))
    Grid:SetTall(Tall - (ScrH() * 0.0025))
    Grid:SetMargin(margin)
    Grid:SetPos(offset, ScrH() - Tall - YOffset)
    Grid:SetEntity(LocalPlayer())
    Grid:SetZPos(1)
    gRust.Hotbar = Grid
end