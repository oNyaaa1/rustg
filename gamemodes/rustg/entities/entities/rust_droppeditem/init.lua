AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.SpawnTime = CurTime()
    self.ModelSet = false

    if self.AutoRemove == nil or self.AutoRemove then
        timer.Simple(self.RemoveTime or 300, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end

    self:InitializePhysics()
end

function ENT:InitializePhysics()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMaterial("default")
    end
end

function ENT:SetupModel(itemClass)
    if not itemClass then return false end
    local itemData = gRust.Items[itemClass]
    if not itemData then return false end
    local model = itemData:GetModel()
    if not model or model == "" then return false end
    if not util.IsValidModel(model) then return false end
    self:SetModel(model)
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:SetModel(model)
            self:InitializePhysics()
        end
    end)
    self.ModelSet = true
    return true
end

function ENT:SetItem(item)
    if not item then return end
    self.Item = item
    local itemClass = item:GetItem()
    self:SetNWString("ItemClass", itemClass)
    self:SetNWInt("ItemQuantity", item:GetQuantity())
    self:SetNWInt("ItemWear", item:GetWear() or 1000)
    self:SetNWInt("ItemClip", item:GetClip() or 0)
    local success = self:SetupModel(itemClass)
    if not success then
        self:SetModel("models/environment/misc/loot_bag.mdl")
        self:InitializePhysics()
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then   return end
    if not self.Item then return end
    if activator:GiveItem(self.Item) then
        local itemData = gRust.Items[self.Item:GetItem()]
        if itemData and itemData:GetSound() then
            activator:EmitSound(gRust.RandomGroupedSound(string.format("pickup.%s", itemData:GetSound())))
        end
        hook.Call("gRust.ItemPickedUp", nil, activator, self.Item, self)
        self:Remove()
    else
        activator:ChatPrint("Inventory is full!")
    end
end

function ENT:OnTakeDamage(dmginfo)
    return
end

function ENT:Think()
    if self.Item and not self.ModelSet then
        self:SetupModel(self.Item:GetItem())
    end
    self:NextThink(CurTime() + 1)
    return true
end
