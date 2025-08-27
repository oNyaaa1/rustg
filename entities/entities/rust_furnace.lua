AddCSLuaFile()
ENT.Base = "rust_process"
ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/furnace.mdl"
ENT.ProcessTime = 0.5
ENT.StopOnEmpty = true
ENT.Pickup = "furnace"
ENT.ShowHealth = true
ENT.ProcessTimes = {
    ["sulfur.ore"] = 2.0,
    ["metal.ore"] = 1.67,
    ["hq.metal.ore"] = 6.67,
}

ENT.WoodConsumption = {
    ["sulfur.ore"] = 1,
    ["metal.ore"] = 2,
    ["hq.metal.ore"] = 3,
}

ENT.CharcoalProduction = {
    ["sulfur.ore"] = 1,
    ["metal.ore"] = 2,
    ["hq.metal.ore"] = 3,
}

ENT.ProcessItems = {
    ["sulfur.ore"] = {
        item = "sulfur",
        amount = 1,
    },
    ["metal.ore"] = {
        item = "metal.fragments",
        amount = 1,
    },
    ["hq.metal.ore"] = {
        item = "metal.refined",
        amount = 1,
    }
}

ENT.DisplayIcon = gRust.GetIcon("open")
function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/deployable/furnace.mdl")
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetInteractable(true)
    self:CreateInventory(6)
    self:SetSaveItems(true)
    self:SetDamageable(true)
    self:SetHealth(500)
    self:SetMaxHealth(500)
    self:SetMeleeDamage(0.2)
    self:SetBulletDamage(0.05)
    self:SetExplosiveDamage(0.4)
    self:SetInteractable(true)
    self:SetDisplayName("OPEN")
    self.CurrentProcessingItems = {}
    self.ProcessWoodConsumed = false
    self:SetNW2Bool("gRust.Enabled", false)
    self:SetNW2Bool("gRust.Processing", false)
end

function ENT:Toggle()
    if CLIENT then
        net.Start("gRust.ProcessToggle")
        net.WriteEntity(self)
        net.SendToServer()
        return
    end

    local enabled = self:GetNW2Bool("gRust.Enabled", false)
    if not enabled then
        if self:CanProcess() then
            self:SetNW2Bool("gRust.Enabled", true)
            self:StartProcessing()
        else
            if IsValid(self.LastUser) and self.LastUser:IsPlayer() then end
            return false
        end
    else
        self:SetNW2Bool("gRust.Enabled", false)
        self:StopProcessing()
    end
    return true
end

function ENT:CanProcess()
    if not self.ProcessItems then return false end
    local itemsToProcess = {}
    local totalWoodNeeded = 0
    for i = 1, 6 do
        local item = self.Inventory[i]
        if item and self.ProcessItems[item:GetItem()] then
            table.insert(itemsToProcess, {
                slot = i,
                type = item:GetItem()
            })

            totalWoodNeeded = totalWoodNeeded + self:GetWoodConsumptionForItem(item:GetItem())
        end
    end

    if #itemsToProcess == 0 then return false end
    local woodCount = 0
    for i = 1, 6 do
        local item = self.Inventory[i]
        if item and item:GetItem() == "wood" then woodCount = woodCount + item:GetQuantity() end
    end
    return woodCount >= totalWoodNeeded and #itemsToProcess > 0
end

function ENT:StartProcessing()
    if not self:CanProcess() then return end
    self.CurrentProcessingItems = {}
    for i = 1, 6 do
        local item = self.Inventory[i]
        if item and self.ProcessItems[item:GetItem()] then
            table.insert(self.CurrentProcessingItems, {
                slot = i,
                type = item:GetItem()
            })
        end
    end

    if #self.CurrentProcessingItems > 0 then
        local maxTime = 0
        for _, itemData in pairs(self.CurrentProcessingItems) do
            local time = self:GetProcessTimeForItem(itemData.type)
            if time > maxTime then maxTime = time end
        end

        self.ProcessTime = maxTime
        self.ProcessWoodConsumed = false
    end

    self:SetNW2Bool("gRust.Processing", true)
    self:SetNW2Float("gRust.ProcessStart", CurTime())
    self:SetNW2Float("gRust.ProcessTime", self.ProcessTime)
    timer.Create("ProcessTimer_" .. self:EntIndex(), self.ProcessTime, 1, function() if IsValid(self) then self:CompleteProcess() end end)
end

function ENT:CompleteProcess()
    if not self.CurrentProcessingItems or #self.CurrentProcessingItems == 0 then
        self:StopProcessing()
        return
    end

    if not self.ProcessWoodConsumed then
        local totalWoodNeeded = 0
        for _, itemData in pairs(self.CurrentProcessingItems) do
            totalWoodNeeded = totalWoodNeeded + self:GetWoodConsumptionForItem(itemData.type)
        end

        local woodConsumed = 0
        for i = 1, 6 do
            local item = self.Inventory[i]
            if item and item:GetItem() == "wood" and item:GetQuantity() > 0 then
                local toConsume = math.min(item:GetQuantity(), totalWoodNeeded - woodConsumed)
                item:RemoveQuantity(toConsume)
                woodConsumed = woodConsumed + toConsume
                if item:GetQuantity() <= 0 then
                    self:RemoveSlot(i)
                else
                    self:SyncSlot(i)
                end

                if woodConsumed >= totalWoodNeeded then break end
            end
        end

        self.ProcessWoodConsumed = true
    end

    for _, itemData in pairs(self.CurrentProcessingItems) do
        local item = self.Inventory[itemData.slot]
        if item and item:GetItem() == itemData.type then
            local recipe = self.ProcessItems[item:GetItem()]
            local charcoalProduced = self:GetCharcoalProductionForItem(itemData.type)
            if recipe and recipe.item and recipe.amount then
                local canAddResult = self:FindEmptySlot(1, 6, gRust.CreateItem(recipe.item, recipe.amount)) ~= nil
                local canAddCharcoal = self:FindEmptySlot(1, 6, gRust.CreateItem("charcoal", charcoalProduced)) ~= nil
                if canAddResult and canAddCharcoal then
                    item:RemoveQuantity(1)
                    if item:GetQuantity() <= 0 then
                        self:RemoveSlot(itemData.slot)
                    else
                        self:SyncSlot(itemData.slot)
                    end

                    self:AddItem(recipe.item, recipe.amount, nil, 1, 6)
                    self:AddItem("charcoal", charcoalProduced, nil, 1, 6)
                end
            end
        end
    end

    self:StopProcessing()
    self.CurrentProcessingItems = {}
    if self:GetNW2Bool("gRust.Enabled", false) and self:CanProcess() then timer.Simple(0.1, function() if IsValid(self) then self:StartProcessing() end end) end
end

function ENT:StopProcessing()
    self:SetNW2Bool("gRust.Processing", false)
    timer.Remove("ProcessTimer_" .. self:EntIndex())
    self.ProcessWoodConsumed = false
end

function ENT:OnRemove()
    timer.Remove("ProcessTimer_" .. self:EntIndex())
    self:StopParticles()
end

function ENT:GetProcessTimeForItem(itemType)
    return self.ProcessTimes[itemType] or self.ProcessTime
end

function ENT:GetWoodConsumptionForItem(itemType)
    return self.WoodConsumption[itemType] or 1
end

function ENT:GetCharcoalProductionForItem(itemType)
    return self.CharcoalProduction[itemType] or 1
end

function ENT:Draw()
    self:DrawModel()
    local enabled = self:GetNW2Bool("gRust.Enabled")
    if enabled and not self.Fire then
        ParticleEffectAttach("rust_fire", PATTACH_POINT_FOLLOW, self, 1)
        self.Fire = true
    elseif not enabled and self.Fire then
        self:StopParticles()
        self.Fire = false
    end
end

local Container
function ENT:ConstructInventory(panel, data, rows)
    if IsValid(Container) then Container:Remove() end
    Container = panel:Add("Panel")
    Container:Dock(FILL)
    local LeftMargin = ScrW() * 0.02
    local RightMargin = ScrW() * 0.05
    local Controls = Container:Add("Panel")
    Controls:Dock(BOTTOM)
    Controls:SetTall(ScrH() * 0.13)
    Controls:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.15)
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
            if not me.On then
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

    ToggleButton.DoClick = function(me) self:Toggle() end
    local function CreateRow(name)
        local Grid = Container:Add("gRust.Inventory.SlotGrid")
        Grid:Dock(BOTTOM)
        Grid:SetCols(6)
        Grid:SetRows(1)
        Grid:SetInventoryOffset(0)
        Grid:SetEntity(self)
        Grid:SetMargin(data.margin)
        Grid:DockMargin(LeftMargin, 0, RightMargin, ScrH() * 0.01)
        Grid:SetTall((data.wide / 8) + data.margin)
        local Name = Container:Add("Panel")
        Name:Dock(BOTTOM)
        Name:SetTall(ScrH() * 0.03)
        Name:DockMargin(LeftMargin - ScrW() * 0.005, 0, RightMargin, ScrH() * 0.008)
        Name.Paint = function(me, w, h)
            surface.SetDrawColor(80, 76, 70, 100)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText(name, "gRust.38px", w * 0.01, h * 0.5, Color(255, 255, 255, 200), 0, 1)
        end
    end

    CreateRow("Furnace")
    local distance = LocalPlayer():GetPos():Distance(self:GetPos())
    if distance > 200 then
        gRust.CloseInventory()
        return
    end
end