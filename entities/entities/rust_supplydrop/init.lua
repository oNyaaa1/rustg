AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("rust_storage")

function ENT:Initialize()
    if CLIENT then return end

    self.InventorySlots = 10
    self.SaveItems = false
    self.Interactable = true
    self.Damageable = false

    self:CreateInventory()

    self:SetModel("models/environment/crates/env_loot_supplydrop.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(true)
        phys:Wake()
    
        phys:SetMass(50) -- Еще меньше масса
        phys:SetMaterial("wood")
        phys:EnableDrag(true)
        phys:SetDragCoefficient(15) -- Еще больше сопротивление
        phys:SetAngleDragCoefficient(3000) -- Больше стабильности
        phys:SetInertia(Vector(1500, 1500, 1500))
    end
    
    self:SetUseType(SIMPLE_USE)

    self.IsFalling = true
    self.MaxFallSpeed = 40 -- Еще меньше максимальная скорость
    self.LandingSound = false

    -- Устанавливаем бодигруппу для закрытого ящика
    self:SetBodygroup(0, 0)

    timer.Simple(0.1, function()
        if IsValid(self) then
            self.SpawnPosition = self:GetPos()
            self.SpawnAngles = self:GetAngles()
            self:PopulateWithItems()
        end
    end)
end

function ENT:PopulateWithItems()
    local stoneItem = gRust.CreateItem("stone", 1000)
    if stoneItem then
        self:SetSlot(stoneItem, 1)
    end
end

function ENT:RemoveSlot(slot)
    BaseClass.RemoveSlot(self, slot)
    
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:CheckAndRespawnIfEmpty()
        end
    end)
end

function ENT:CheckAndRespawnIfEmpty()
    if not self.Inventory then
        self:Remove()
        return
    end
    
    local hasItems = false
    for i = 1, self.InventorySlots do
        if self.Inventory[i] then
            hasItems = true
            break
        end
    end
    
    if not hasItems then
        self:Remove()
    end
end

function ENT:Use(activator, caller)
    BaseClass.Use(self, activator, caller)
end

function ENT:Think()
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        local vel = phys:GetVelocity()

        -- Ограничиваем скорость падения
        if vel.z < -self.MaxFallSpeed then
            vel.z = -self.MaxFallSpeed
            phys:SetVelocity(vel)
        end

        -- Дополнительное торможение при падении
        if self.IsFalling and vel.z < -10 then -- Уменьшен порог
            -- Увеличена тормозящая сила
            local brakeForce = Vector(0, 0, math.abs(vel.z) * 4)
            phys:ApplyForceCenter(brakeForce)

            -- Более медленное покачивание
            local swayForce = Vector(
                math.sin(CurTime() * 0.2) * 2, -- Еще медленнее
                math.cos(CurTime() * 0.15) * 2,
                0
            )
            phys:ApplyForceCenter(swayForce)
        end

        if self.IsFalling then
            local tr = util.TraceLine({
                start = self:GetPos(),
                endpos = self:GetPos() + Vector(0, 0, -200), -- Увеличена дистанция
                filter = self
            })
            
            if tr.Hit and tr.HitNormal.z > 0.7 then
                -- Приземление при еще меньшей скорости
                if vel.z > -15 and not self.LandingSound then
                    self.IsFalling = false
                    self.LandingSound = true

                    self:SetBodygroup(0,0)
                    

                    timer.Simple(0.1, function()
                        if IsValid(self) and IsValid(phys) then
                            phys:SetDragCoefficient(0.1)
                            phys:SetAngleDragCoefficient(500)
                            phys:SetMass(15000) 
                        end
                    end)
                end
            end
        end
    end
    
    self:NextThink(CurTime() + 0.03) -- Еще более частая проверка
    return true
end
