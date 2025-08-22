include("shared.lua")
--[[
function ENT:Initialize()
end

local MaxSpinSpeed = 50
local ChangeRate = 20
function ENT:Think()
    self.Spin = self.Spin or 0
    if (self:GetRunning()) then
        self.Spin = self.Spin + FrameTime() * ChangeRate
    else
        self.Spin = self.Spin - FrameTime() * ChangeRate
    end
    self.Spin = math.Clamp(self.Spin, 0, MaxSpinSpeed)
    self.CurrentSpin = (self.CurrentSpin or 0) + self.Spin

    self:SetPoseParameter("spin", self.CurrentSpin % 360)

    self:NextThink(CurTime())
    return true
end

hook.Add("CalcView", "gRust.Minicopter", function(pl, pos, ang, fov)
    if (IsValid(pl:GetVehicle()) and IsValid(pl:GetVehicle():GetParent()) and pl:GetVehicle():GetParent():GetClass() == "rust_minicopter") then
        return {
            angles = pl:GetAngles(),
        }
    end
end)]]