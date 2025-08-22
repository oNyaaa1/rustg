AddCSLuaFile()

ENT.Base = "rust_process"

ENT.Deploy = {}
ENT.Deploy.Model = "models/environment/misc/recycler.mdl"

ENT.ProcessTime = 1.0
ENT.StopOnEmpty = true
ENT.RecycleRate = 0.5

ENT.DisplayIcon = gRust.GetIcon("open")

function ENT:Initialize()
    if CLIENT then return end
    
    self:SetModel("models/environment/misc/recycler.mdl")
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetInteractable(true)
    self:CreateInventory(12)
    self:SetDisplayName("OPEN")
    
    self:SetNW2Bool("gRust.Enabled", false)
    self:SetNW2Bool("gRust.Processing", false)
    self:SetNW2Float("gRust.ProcessProgress", 0)
end

function ENT:GetProcessResult(itemClass)
    local itemData = gRust.Items[itemClass]
    if not itemData then return nil end
    
    local craft = itemData:GetCraft()
    if not craft then return nil end
    
    local results = {}
    
    for _, ingredient in ipairs(craft) do
        local amount = math.floor(ingredient.amount * self.RecycleRate)
        if amount > 0 then
            table.insert(results, {
                item = ingredient.item,
                amount = amount
            })
        end
    end
    
    return #results > 0 and results or nil
end

function ENT:CanProcess()
    for i = 7, 12 do
        local item = self.Inventory[i]
        if item then
            local results = self:GetProcessResult(item:GetItem())
            if results and #results > 0 then
                return true
            end
        end
    end
    
    return false
end

function ENT:Toggle()
    if CLIENT then
        net.Start("gRust.ProcessToggle")
        net.WriteEntity(self)
        net.SendToServer()
        return
    end
    
    local enabled = self:GetNW2Bool("gRust.Enabled", false)
    
    if !enabled then
        if self:CanProcess() then
            self:SetNW2Bool("gRust.Enabled", true)
            self:StartProcessing()
        else
            if IsValid(self.LastUser) and self.LastUser:IsPlayer() then
            end
            return false
        end
    else
        self:SetNW2Bool("gRust.Enabled", false)
        self:StopProcessing()
    end
    
    return true
end

function ENT:StartProcessing()
    if self:GetNW2Bool("gRust.Processing", false) then 
        return 
    end
    
    if !self:CanProcess() then 
        self:SetNW2Bool("gRust.Enabled", false)
        return 
    end
    
    self:SetNW2Bool("gRust.Processing", true)
    self:SetNW2Float("gRust.ProcessStart", CurTime())
    self:SetNW2Float("gRust.ProcessTime", self.ProcessTime)
    
    timer.Create("Recycler_" .. self:EntIndex(), self.ProcessTime, 1, function()
        if IsValid(self) then
            self:CompleteProcess()
        end
    end)
end

function ENT:StopProcessing()
    self:SetNW2Bool("gRust.Processing", false)
    self:SetNW2Float("gRust.ProcessProgress", 0)
    timer.Remove("Recycler_" .. self:EntIndex())
end

function ENT:CompleteProcess()
    for i = 7, 12 do
        local item = self.Inventory[i]
        if item then
            local results = self:GetProcessResult(item:GetItem())
            
            if results then
                local canAddAll = true
                for _, result in ipairs(results) do
                    local targetSlot = self:FindEmptySlot(1, 6, gRust.CreateItem(result.item, result.amount))
                    if not targetSlot then
                        canAddAll = false
                        break
                    end
                end
                
                if canAddAll then
                    item:RemoveQuantity(1)
                    if item:GetQuantity() <= 0 then
                        self:RemoveSlot(i)
                    else
                        self:SyncSlot(i)
                    end
                    
                    for _, result in ipairs(results) do
                        self:AddItem(result.item, result.amount, nil, 1, 6)
                    end
                    
                    break
                else
                    self:SetNW2Bool("gRust.Enabled", false)
                    self:StopProcessing()
                    return
                end
            end
        end
    end
    
    self:StopProcessing()
    
    if self:GetNW2Bool("gRust.Enabled", false) and self:CanProcess() then
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:StartProcessing()
            end
        end)
    else
        if self.StopOnEmpty then
            self:SetNW2Bool("gRust.Enabled", false)
        end
    end
end

function ENT:FindEmptySlot(start, finish, item)
    if !self.Inventory then return nil end
    
    start = start or 1
    finish = finish or 12
    
    if item then
        for i = start, finish do
            local existingItem = self.Inventory[i]
            if existingItem and existingItem:GetItem() == item:GetItem() and existingItem:CanStack(item:GetQuantity()) then
                return i
            end
        end
    end
    
    for i = start, finish do
        if !self.Inventory[i] then
            return i
        end
    end
    
    return nil
end



local Container

function ENT:ConstructInventory(panel, data, rows)
    if IsValid(Container) then
        Container:Remove()
    end
    
    Container = panel:Add("Panel")
    Container:Dock(FILL)
    
    local LeftMargin = ScrW() * 0.02
    local RightMargin = ScrW() * 0.05
    
    local Controls = Container:Add("Panel")
    Controls:Dock(BOTTOM)
    Controls:SetTall(ScrH() * 0.13)
    Controls:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.15)
    Controls.Paint = PaintBackground
    local Title = Controls:Add("Panel")
    Title:Dock(TOP)
    Title:SetTall(ScrH() * 0.03)
    Title:DockMargin(0, 0, 0, ScrH() * 0.003)
    Title.Paint = function(me, w, h)
        surface.SetDrawColor(80, 76, 70, 100)
        surface.DrawRect(0, 0, w, h)
    end
    
    local ButtonPanel = Controls:Add("Panel")
    ButtonPanel:Dock(FILL)
    ButtonPanel.Paint = function(me, w, h)
        surface.SetDrawColor(80, 76, 70, 100)
        surface.DrawRect(0, 0, w, h)
    end
    
    local Margin = ScrH() * 0.01
    
    local ToggleButton = ButtonPanel:Add("gRust.Button")
    ToggleButton:Dock(LEFT)
    ToggleButton:SetText("Turn On")
    ToggleButton:DockMargin(Margin, Margin, Margin, Margin)
    ToggleButton:SetWide(ScrW() * 0.11)
    ToggleButton:SetDefaultColor(Color(39, 102, 65))
    ToggleButton:SetHoveredColor(Color(47, 136, 47))
    ToggleButton:SetActiveColor(Color(106, 177, 49))
    
    ToggleButton.Think = function(me)
        local On = self:GetNW2Bool("gRust.Enabled", false)
        if On then
            if !me.On then
                me.On = true
                me:SetText("Turn Off")
                ToggleButton:SetDefaultColor(Color(102, 59, 39))
                ToggleButton:SetHoveredColor(Color(136, 87, 47))
                ToggleButton:SetActiveColor(Color(177, 68, 49))
            end
        else
            if me.On then
                me.On = false
                me:SetText("Turn On")
                ToggleButton:SetDefaultColor(Color(39, 102, 65))
                ToggleButton:SetHoveredColor(Color(47, 136, 47))
                ToggleButton:SetActiveColor(Color(106, 177, 49))
            end
        end
    end
    
    ToggleButton.DoClick = function(me)
        self:Toggle()
    end
    
    local i = 1
    local function CreateRow(name)
        local Grid = Container:Add("gRust.Inventory.SlotGrid")
        Grid:Dock(BOTTOM)
        Grid:SetCols(6)
        Grid:SetRows(1)
        Grid:SetInventoryOffset((i - 1) * 6)
        Grid:SetEntity(self)
        Grid:SetMargin(data.margin)
        Grid:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.01)
        Grid:SetTall(((data.wide / 8) + data.margin))
        
        local Name = Container:Add("Panel")
        Name:Dock(BOTTOM)
        Name:SetTall(ScrH() * 0.03)
        Name:DockMargin(LeftMargin - ScrW() * 0.005, 0, RightMargin, ScrH() * 0.008)
        Name.Paint = function(me, w, h)
            surface.SetDrawColor(80, 76, 70, 100)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText(name, "gRust.38px", w * 0.01, h * 0.5, Color(255, 255, 255, 200), 0, 1)
        end
        
        i = i + 1
    end
    
    CreateRow("OUTPUT")
    CreateRow("INPUT")
    
    local distance = LocalPlayer():GetPos():Distance(self:GetPos())
    if (distance > 200) then
        gRust.CloseInventory()
        return
    end
end