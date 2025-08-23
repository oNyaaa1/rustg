AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Deploy.Model or "models/deployable/door_wood.mdl")
    
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(100)
        phys:EnableMotion(false)
    end

    self:SetOpened(false)
    self:SetBodygroup(2, 0)

    self.OriginalAngles = self:GetAngles()
    self.IsAnimating = false

    self.DoorCode = nil
    self.AuthorizedPlayers = {}
    
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    if self.IsAnimating then return end

    if self:GetBodygroup(2) == 1 and self.DoorCode then
        if not self.AuthorizedPlayers[activator:SteamID()] then
            return
        end
    end

    self:ToggleDoor()
end

function ENT:ToggleDoor()
    if self.IsAnimating then return end
    
    local isOpened = self:GetOpened()
    self:SetOpened(not isOpened)
    self.IsAnimating = true
    
    local targetAngle
    if not isOpened then
        targetAngle = self.OriginalAngles + Angle(0, 90, 0)
        self:EmitSound("doors/door_wood_open1.wav")
    else
        targetAngle = self.OriginalAngles
        self:EmitSound("doors/door_wood_close1.wav")
    end

    self:AnimateRotation(targetAngle, 1.0)
end

function ENT:AnimateRotation(targetAngle, duration)
    local startAngle = self:GetAngles()
    local startTime = CurTime()
    
    local function updateRotation()
        if not IsValid(self) then return end
        
        local progress = math.min((CurTime() - startTime) / duration, 1)
        
        local currentAngle = LerpAngle(progress, startAngle, targetAngle)
        self:SetAngles(currentAngle)
        
        if progress >= 1 then
            self.IsAnimating = false
            return
        end

        timer.Simple(0.01, updateRotation)
    end
    
    updateRotation()
end
