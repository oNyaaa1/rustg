AddCSLuaFile()
if SERVER then
    Logger("Loaded rust_recycler")
end

ENT.Base = "rust_process"
ENT.Deploy = {}
ENT.Deploy.Model = "models/environment/misc/recycler.mdl"
ENT.ProcessTime = 1.0
ENT.StopOnEmpty = true
ENT.RecycleRate = 0.5
ENT.DisplayIcon = gRust.GetIcon("open")
function ENT:Initialize()
    if CLIENT then return end
    self:SetUseType(SIMPLE_USE)
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

function ENT:OnTakeDamage()
    return false
end

function ENT:SyncSlot(i)
    -- Example: Network the slot's item data to clients
    local item = self.Inventory[i]
    if item then
        -- You might want to send item class, quantity, etc.
        self:SetNW2String("Slot_" .. i .. "_Class", item:GetItem())
        self:SetNW2Int("Slot_" .. i .. "_Quantity", item:GetQuantity())
    else
        self:SetNW2String("Slot_" .. i .. "_Class", "")
        self:SetNW2Int("Slot_" .. i .. "_Quantity", 0)
    end
end

function ENT:SyncAllSlots()
    if not self.Inventory then return end
    for i = 1, #self.Inventory do
        self:SyncSlot(i)
    end
end

function ENT:GetProcessResult(itemClass)
    local itemData = gRust.Items[itemClass]
    if not itemData then return nil end
    local craft = itemData:GetCraft()
    if type(craft) ~= "table" then return nil end
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

    self:SyncAllSlots()
    return #results > 0 and results or nil
end

function ENT:CanProcess()
    for i = 7, 12 do
        local item = self.Inventory[i]
        if item then
            local results = self:GetProcessResult(item:GetItem())
            if results and #results > 0 then return true end
        end
    end
    return true
end

function ENT:Toggle()
    local enabled = self:GetNW2Bool("gRust.Enabled", false)
    if enabled == false then
        if self:CanProcess() then
            self:SetNW2Bool("gRust.Enabled", true)
            self:StartProcessing()
        end
    else
        self:SetNW2Bool("gRust.Enabled", false)
        self:StopProcessing()
    end
    return true
end

function ENT:Use(activator, caller)
    if caller:IsPlayer() then self.LastUser = caller end
end

net.Receive("gRust.ProcessToggle", function(len, ply)
    local ent = net.ReadEntity()
    if IsValid(ent) and ent:GetClass() == "rust_recycler" and ent.LastUser == ply then ent:Toggle() end
end)

function ENT:StartProcessing()
    if self:GetNW2Bool("gRust.Processing", false) then return end
    if not self:CanProcess() then
        self:SetNW2Bool("gRust.Enabled", false)
        return
    end

    self:SetNW2Bool("gRust.Processing", true)
    self:SetNW2Float("gRust.ProcessStart", CurTime())
    self:SetNW2Float("gRust.ProcessTime", self.ProcessTime)
    timer.Create("Recycler_" .. self:EntIndex(), self.ProcessTime, 1, function() if IsValid(self) then self:CompleteProcess() end end)
end

function ENT:StopProcessing()
    self:SetNW2Bool("gRust.Processing", false)
    self:SetNW2Float("gRust.ProcessProgress", 0)
    timer.Remove("Recycler_" .. self:EntIndex())
end

function ENT:AddItem(itemClass, amount, data, startSlot, endSlot)
    startSlot = startSlot or 1
    endSlot = endSlot or 6
    for i = startSlot, endSlot do
        local slotItem = self.Inventory[i]
        if slotItem and slotItem:GetItem() == itemClass then
            slotItem:AddQuantity(amount)
            self:SyncAllSlots()
            return true
        end
    end

    for i = startSlot, endSlot do
        if not self.Inventory[i] then
            self.Inventory[i] = gRust.CreateItem(itemClass, amount, data)
            self:SyncAllSlots()
            return true
        end
    end
    return false -- No space
end

function ENT:CompleteProcess()
    for i = 7, 12 do -- input slots
        local item = self.Inventory[i]
        if item then
            local results = self:GetProcessResult(item:GetItem())
            if results then
                local canAddAll = true
                -- Check if all results can fit/stack
                for _, result in ipairs(results) do
                    local slot = self:FindEmptySlot(1, 6, gRust.CreateItem(result.item, result.amount))
                    if not slot then
                        canAddAll = false
                        break
                    end
                end

                if canAddAll then
                    -- Consume 1 input item
                    item:RemoveQuantity(1)
                    if item:GetQuantity() <= 0 then
                        self.Inventory[i] = nil
                        self:SyncSlot(i) -- <--- tell client the slot is empty now
                    else
                        self:SyncSlot(i) -- <--- tell client the new quantity
                    end

                    -- Add processed results (stack where possible)
                    for _, result in ipairs(results) do
                        self:AddItem(result.item, result.amount, nil, 1, 6)
                    end

                    break
                else
                    -- No room, stop
                    self:SetNW2Bool("gRust.Enabled", false)
                    self:StopProcessing()
                    return
                end
            end
        end
    end

    self:StopProcessing()
    if self:GetNW2Bool("gRust.Enabled", false) and self:CanProcess() then
        timer.Simple(0.1, function() if IsValid(self) then self:StartProcessing() end end)
    else
        if self.StopOnEmpty then self:SetNW2Bool("gRust.Enabled", false) end
    end
end

--[[
function ENT:CompleteProcess()
    for i = 6, 12 do
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
                    --item:RemoveQuantity(1)
                    if item:GetQuantity() <= 0 then
                        --self:RemoveSlot(i)
                    else
                        --self:SyncAllSlots()
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
        timer.Simple(0.1, function() if IsValid(self) then self:StartProcessing() end end)
    else
        if self.StopOnEmpty then self:SetNW2Bool("gRust.Enabled", false) end
    end
end]]
function ENT:FindEmptySlot(start, finish, item)
    if not self.Inventory then return nil end
    start = start or 1
    finish = finish or 12
    if item then
        for i = start, finish do
            local existingItem = self.Inventory[i]
            if existingItem and existingItem:GetItem() == item:GetItem() and existingItem:CanStack(item:GetQuantity()) then return i end
        end
    end

    for i = start, finish do
        if not self.Inventory[i] then return i end
    end
    return nil
end

local function PaintBackground(me, w, h)
    surface.SetDrawColor(50, 50, 50, 200)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawOutlinedRect(0, 0, w, h)
end

function ENT:Togglez()
    net.Start("gRust.ProcessToggle")
    net.WriteEntity(self)
    net.SendToServer()
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
    ToggleButton.DoClick = function(me) self:Togglez() end
    ToggleButton.Think = function(me)
        gRust.OpenInventory(self)
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

        i = i + 1
    end

    CreateRow("OUTPUT")
    CreateRow("INPUT")
    local distance = LocalPlayer():GetPos():Distance(self:GetPos())
    if distance > 200 then
        gRust.CloseInventory()
        return
    end
end