AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("gRust.ProcessToggle")

DEFINE_BASECLASS("rust_storage")

function ENT:Initialize()
    if CLIENT then return end

    self.InventorySlots = 12
    self.SaveItems = false
    self.Interactable = true
    self.Damageable = false

    self.ProcessItems = self.ProcessItems or {}
    self.ProcessTime = self.ProcessTime or 5.0
    self.StopOnEmpty = self.StopOnEmpty or false
    self.AutoStart = self.AutoStart or false

    self:SetModel("models/props_c17/FurnitureWashingmachine001a.mdl")
    
    BaseClass.Initialize(self)

    self:SetNW2Bool("gRust.Enabled", false)
    self:SetNW2Bool("gRust.Processing", false)
    self:SetNW2Float("gRust.ProcessProgress", 0)

    self:SetDisplayName(self.DisplayName or "PROCESS")
    self:SetInteractable(true)
end

function ENT:ToggleProcessing()
    local enabled = self:GetNW2Bool("gRust.Enabled", false)
    self:SetNW2Bool("gRust.Enabled", !enabled)
    
    if !enabled and self:CanProcess() then
        self:StartProcessing()
    elseif enabled then
        self:StopProcessing()
    end
end

function ENT:CanProcess()
    if !self.ProcessItems then return false end

    local inputStart = (self.InventorySlots / 2) + 1
    for i = inputStart, self.InventorySlots do
        local item = self.Inventory[i]
        if item and self.ProcessItems[item:GetItem()] then
            return true
        end
    end
    
    return false
end

function ENT:StartProcessing()
    if self:GetNW2Bool("gRust.Processing", false) then return end
    
    self:SetNW2Bool("gRust.Processing", true)
    self:SetNW2Float("gRust.ProcessProgress", 0)
    
    self.ProcessTimer = CurTime() + (self.ProcessTime or 2.0)
    self.NextThink = CurTime() + 0.05
end

function ENT:StopProcessing()
    self:SetNW2Bool("gRust.Processing", false)
    self:SetNW2Float("gRust.ProcessProgress", 0)
    self.ProcessTimer = nil
end

function ENT:Think()
    if !self:GetNW2Bool("gRust.Enabled", false) then
        self.NextThink = CurTime() + 1
        return true
    end
    
    if self:GetNW2Bool("gRust.Processing", false) and self.ProcessTimer then
        local progress = math.Clamp(1 - ((self.ProcessTimer - CurTime()) / (self.ProcessTime or 2.0)), 0, 1)
        self:SetNW2Float("gRust.ProcessProgress", progress)
        
        if CurTime() >= self.ProcessTimer then
            self:CompleteProcess()
        else
            self.NextThink = CurTime() + 0.05
        end
    elseif self:CanProcess() then
        self:StartProcessing()
    elseif self.StopOnEmpty then
        self:SetNW2Bool("gRust.Enabled", false)
        self:StopProcessing()
    end
    
    self.NextThink = CurTime() + 0.1
    return true
end

function ENT:CompleteProcess()

    local inputStart = (self.InventorySlots / 2) + 1
    local outputEnd = self.InventorySlots / 2
    
    for i = inputStart, self.InventorySlots do
        local item = self.Inventory[i]
        if item and self.ProcessItems[item:GetItem()] then
            local recipe = self.ProcessItems[item:GetItem()]
            
            -- Check if we can add all output items
            local canAdd = true
            for _, output in pairs(recipe) do
                if !self:CanAddToOutput(output.item, output.amount) then
                    canAdd = false
                    break
                end
            end
            
            if canAdd then

                item:RemoveQuantity(1)
                if item:GetQuantity() <= 0 then
                    self:RemoveSlot(i)
                else
                    self:SyncSlot(i)
                end

                for _, output in pairs(recipe) do
                    self:AddToOutput(output.item, output.amount)
                end
                
                break
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
    end
end

function ENT:CanAddToOutput(itemName, amount)
    local outputEnd = self.InventorySlots / 2
    return self:FindEmptySlot(1, outputEnd, gRust.CreateItem(itemName, amount)) ~= nil
end

function ENT:AddToOutput(itemName, amount)
    local outputEnd = self.InventorySlots / 2
    self:AddItem(itemName, amount, nil, 1, outputEnd)
end

function ENT:Use(activator, caller)
    if not self.Interactable then return end
    
    if !IsValid(activator) or !activator:IsPlayer() then return end
    
    local distance = self:GetPos():Distance(activator:GetPos())
    if distance > 200 then 
        gRust.CloseInventory()
        return 
    end

    BaseClass.Use(self, activator, caller)
end

function ENT:Toggle()
    self:ToggleProcessing()
end



if SERVER then
    net.Receive("gRust.ProcessToggle", function(len, ply)
        local ent = net.ReadEntity()
        if IsValid(ent) and ent.Toggle then
            if ent:GetPos():Distance(ply:GetPos()) <= 200 then
                ent:Toggle()
            end
        end
    end)
end

