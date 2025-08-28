DEFINE_BASECLASS("rust_storage")
include("shared.lua")
ENT.InventorySlots = 24
ENT.InventoryName = "TOOL CUPBOARD"
function ENT:Draw()
    self:DrawModel()
    --render.SetColorMaterial()
    --render.DrawSphere(self:GetPos(), gRust.Config.TCRadius, 50, 50, Color(255, 0, 0, 20))
end

local color_grey = Color(225, 225, 225)
local color_white = Color(255, 255, 255)
local Container
local Grid
function ENT:ConstructInventory(panel, data, rows)
    local scrw, scrh = ScrW(), ScrH()
    if IsValid(Container) then
        Grid:Update()
        if table.IsEmpty(data) then Container:Remove() end
        return
    end

    local Rows = rows or (self.InventorySlots / 6)
    Container = panel:Add("Panel")
    Container:Dock(FILL)
    Grid = Container:Add("gRust.Inventory.SlotGrid")
    Grid:Dock(BOTTOM)
    Grid:SetCols(6)
    Grid:SetRows(Rows)
    Grid:SetEntity(self)
    Grid:SetMargin(data.margin)
    local LeftMargin = ScrW() * 0.02
    local RightMargin = ScrW() * 0.05
    Grid:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.165)
    Grid:SetTall(((data.wide / (Rows * 2)) + data.margin * Rows) * (Rows - 0.7))
    local Container = Container:Add("Panel")
    Container:Dock(BOTTOM)
    Container:SetTall(ScrH() * 0.3)
    Container:DockMargin(scrw * 0.02, 0, scrw * 0.0335, scrh * 0.005)
    local UpkeepCost = Container:Add("Panel")
    UpkeepCost:Dock(BOTTOM)
    UpkeepCost:SetTall(scrh * 0.175)
    UpkeepCost.Paint = function(me, w, h)
        surface.SetDrawColor(80, 76, 70, 175)
        surface.DrawRect(0, 0, w, h)
    end

    UpkeepTitle = UpkeepCost:Add("DLabel")
    UpkeepTitle:Dock(TOP)
    UpkeepTitle:SetTall(scrh * 0.04)
    UpkeepTitle:SetColor(Color(255, 135, 46))
    UpkeepTitle:SetText("Cost per 24 hours")
    UpkeepTitle:SetFont("gRust.34px")
    UpkeepTitle:SetContentAlignment(5)
    UpkeepResources = UpkeepCost:Add("Panel")
    UpkeepResources:Dock(FILL)
    UpkeepResources:SetTall(scrh * 0.035)
    ResourceContainer = UpkeepResources:Add("Panel")
    ResourceContainer:Dock(FILL)
    ResourceContainer:DockMargin(scrw * 0.075, scrh * 0.0075, scrw * 0.075, scrh * 0.0075)
    local Resources = {"wood", "stone", "metal.fragments", "hq_metal",}
    local NWInts = {"WoodUpkeep", "StoneUpkeep", "MetalUpkeep", "HQUpkeep"}
    for i = 1, 4 do
        local r = Resources[i]
        local Resource = ResourceContainer:Add("Panel")
        Resource:Dock(LEFT)
        local Wide = scrw * 0.187 - ((scrw * 0.075) * 2)
        Resource:SetWide(Wide)
        local ResourceIcon = Resource:Add("DImage")
        ResourceIcon:Dock(TOP)
        ResourceIcon:SetTall(Wide)
        ResourceIcon:SetImage(gRust.Items[r]:GetIcon())
        local ResourceAmount = Resource:Add("DLabel")
        ResourceAmount:Dock(FILL)
        ResourceAmount:SetFont("gRust.28px")
        ResourceAmount:SetContentAlignment(5)
        ResourceAmount:SetColor(color_grey)
        ResourceAmount.Think = function() ResourceAmount:SetText("x" .. self:GetNW2Int(NWInts[i])) end
    end

    UpkeepTime = UpkeepCost:Add("DLabel")
    UpkeepTime:Dock(BOTTOM)
    UpkeepTime:SetTall(scrh * 0.04)
    UpkeepTime:SetColor(Color(181, 221, 112))
    UpkeepTime:SetText("Protected for: " .. self:GetNW2String("gRust.ProtectedFor"))
    UpkeepTime:SetFont("gRust.34px")
    UpkeepTime:SetContentAlignment(5)
    local UpkeepInfo = Container:Add("Panel")
    UpkeepInfo:Dock(BOTTOM)
    UpkeepInfo:SetTall(scrh * 0.08)
    UpkeepInfo:DockMargin(0, scrh * 0.005, 0, scrh * 0.005)
    UpkeepInfo:DockPadding(scrh * 0.01, scrh * 0.01, scrh * 0.01, scrh * 0.01)
    UpkeepInfo.Paint = function(me, w, h)
        surface.SetDrawColor(80, 76, 70, 175)
        surface.DrawRect(0, 0, w, h)
    end

    local InfoIcon = UpkeepInfo:Add("DImage")
    InfoIcon:Dock(LEFT)
    InfoIcon:SetWide(scrh * 0.06)
    InfoIcon:SetImageColor(color_grey)
    InfoIcon:SetMaterial(gRust.GetIcon("info"))
    local InfoInfo = UpkeepInfo:Add("DLabel")
    InfoInfo:Dock(FILL)
    InfoInfo:DockMargin(scrw * 0.01, 0, 0, 0)
    InfoInfo:SetColor(color_grey)
    InfoInfo:SetWrap(true)
    InfoInfo:SetFont("gRust.24px")
    InfoInfo:SetContentAlignment(4)
    InfoInfo:SetText("Maintain the required amount of resources to prevent your base from decaying over time. Bases left unattended without enough upkeep resources will be destroyed")
    local Name = Container:Add("Panel")
    Name:Dock(BOTTOM)
    Name:SetTall(ScrH() * 0.03)
    Name:DockMargin(0, 0, 0, ScrH() * 0.001)
    Name.Paint = function(me, w, h)
        if not IsValid(self) then Container:Remove() end
        surface.SetDrawColor(80, 76, 70, 175)
        surface.DrawRect(0, 0, w, h)
        if not self.InventoryName then return end
        draw.SimpleText("UPKEEP MANAGEMENT", "gRust.38px", w * 0.01, h * 0.5, Color(255, 255, 255, 200), 0, 1)
    end
end