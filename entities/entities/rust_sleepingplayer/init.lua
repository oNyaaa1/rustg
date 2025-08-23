AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("rust_storage")

function ENT:Initialize()
    if CLIENT then return end

    self.InventoryName = "SLEEPING PLAYER"

    self:SetModel("models/environment/misc/death_bag.mdl")
    
    self:SetSolid(SOLID_VPHYSICS)

    if self.Deploy then
        self:PhysicsInitStatic(SOLID_VPHYSICS)
    else
        self:PhysicsInit(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Sleep()
        end
    end


    self:CreateInventory(36)

    //self:SetSaveItems(true)

    self:SetInteractable(true)

    self:SetDamageable(false)

    
    self.OwnerSteamID = nil
    self.OwnerName = nil
    self.OwnerLastPos = nil
end

function ENT:SetOwner(player)
    if not IsValid(player) then return end

    
    self.OwnerSteamID = player:SteamID()
    self.OwnerName = player:Nick()
    self.InventoryName = string.upper(player:Nick() .. "'S LOOT")
    self.OwnerLastPos = player:GetPos()

    self:SetNWString("OwnerSteamID", self.OwnerSteamID)
    self:SetNWString("OwnerName", self.OwnerName)
    self:SetNWString("InventoryName", self.InventoryName)

end


function ENT:IsOwner(player)
    if not IsValid(player) then return false end
    return player:SteamID() == self.OwnerSteamID
end

function ENT:IsInventoryEmpty()
    if not self.Inventory then return true end

    for i = 1, self.InventorySlots do
        if self.Inventory[i] then
            return false
        end
    end
    return true
end

function ENT:CheckAndRemoveIfEmpty()
    if self:IsInventoryEmpty() then
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function ENT:RemoveSlot(slot)

    BaseClass.RemoveSlot(self, slot)

    timer.Simple(0.1, function()
        if IsValid(self) then
            self:CheckAndRemoveIfEmpty()
        end
    end)
end

function ENT:GetOwnerName()
    return self.OwnerName or "Unknown"
end

function ENT:GetOwnerSteamID()
    return self.OwnerSteamID
end

function ENT:GetOwnerLastPos()
    return self.OwnerLastPos
end

function ENT:TransferInventoryToPlayer(player)
    if not IsValid(player) or not self.Inventory then return end

    
    for i = 1, self.InventorySlots do
        local item = self.Inventory[i]
        if item then
            if player.GiveItem then
                player:GiveItem(item)
            end
        end
    end
    

    self.Inventory = {}
    self:Remove()
end

function ENT:CreateStashOnDestroy()
    return
end

function ENT:Use(activator, caller)
    if not self.Interactable then return end 
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if IsValid(gRust.Inventory) then return end
    local distance = self:GetPos():Distance(activator:GetPos())
    if distance > 200 then 
        gRust.CloseInventory()
        return 
    end

    activator:RequestInventory(self)
end