AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("gRust.PickupLock")
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
    --self.AuthorizedPlayers = {}
    self:SetUseType(SIMPLE_USE)
end

local function FindNearestTC(pos, radius)
    local nearest, best = nil, math.huge
    for _, v in ipairs(ents.FindInSphere(pos, radius or 300)) do
        if IsValid(v) and v:GetClass() == "rust_toolcupboard" then
            local d = pos:Distance(v:GetPos())
            if d < best then
                best = d
                nearest = v
                print(best, near)
            end
        end
    end
    return nearest
end

--[[function ENT:Use(activator, caller)
    if not IsValid(caller) and not caller:IsPlayer() then return end
    if self.IsAnimating then return end
    local tc = FindNearestTC(self:GetPos(), 300)
    if self:GetBodygroup(2) == 0 then self:ToggleDoor() end
    local hasAccess = false
    if tc then
        for k, v in pairs(tc.AuthorizedPlayers) do
            if v == caller:SteamID64() then hasAccess = true end
        end

        if hasAccess and self:GetBodygroup(2) > 0 then self:ToggleDoor() end
    end
end]]
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if self.IsAnimating then return end

    local tc = FindNearestTC(self:GetPos(), 300)

    -- Door unlocked, anyone can open
    if self:GetBodygroup(2) == 0 then
        self:ToggleDoor()
        return
    end

    -- Door locked, check TC authorization
    if tc then
        local hasAccess = tc:IsAuthorized(activator)
        if hasAccess then
            self:ToggleDoor()
        else
            activator:ChatPrint("You are not authorized on the nearby Tool Cupboard.")
        end
    else
        activator:ChatPrint("A Tool Cupboard is required nearby to unlock this door.")
    end
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