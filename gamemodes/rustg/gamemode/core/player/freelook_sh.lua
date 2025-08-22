-- made by darsu <3
-- fixed by M1LKIS :)

local enabled = CreateConVar("altlook", 1, FCVAR_REPLICATED + FCVAR_ARCHIVE)

if SERVER then return end

local freelooking = false

concommand.Add("+freelook", function(ply, cmd, args) freelooking = true end)
concommand.Add("-freelook", function(ply, cmd, args) freelooking = false end)

local LookX, LookY = 0, 0
local InitialAng, CoolAng = Angle(), Angle()
local ZeroAngle = Angle()

local function isinsights(ply)
    local weapon = ply:GetActiveWeapon()
    return ply:KeyDown(IN_ATTACK2) or (weapon.GetInSights and weapon:GetInSights()) or (weapon.ArcCW and weapon:GetState() == ArcCW.STATE_SIGHTS) or (weapon.GetIronSights and weapon:GetIronSights())
end

local function holdingbind(ply)
    if !input.LookupBinding("freelook") then 
        return ply:KeyDown(IN_WALK)
    else
        return freelooking
    end
end

hook.Add("CalcView", "AltlookView", function(ply, origin, angles, fov)
    if !enabled:GetBool() then return end

    CoolAng = LerpAngle(0.15, CoolAng, Angle(LookY, -LookX, 0))

    if not holdingbind(ply) and CoolAng.p < 0.05 and CoolAng.p > -0.05 or isinsights(ply) and CoolAng.p < 0.05 and CoolAng.p > -0.05 or not system.HasFocus() or ply:ShouldDrawLocalPlayer() then 
        InitialAng = angles + CoolAng
        LookX, LookY = 0, 0 

        CoolAng = ZeroAngle

        return 
    end

    angles.p = angles.p + CoolAng.p
    angles.y = angles.y + CoolAng.y
end)

hook.Add("CalcViewModelView", "AltlookVM", function(wep, vm, oPos, oAng, pos, ang)
    if !enabled:GetBool() then return end

    local MWBased = wep.m_AimModeDeltaVelocity and -1.5 or 1

    ang.p = ang.p + CoolAng.p/2.5 * MWBased
    ang.y = ang.y + CoolAng.y/2.5 * MWBased

end)

hook.Add("InputMouseApply", "AltlookMouse", function(cmd, x, y, ang)
    if !enabled:GetBool() then return end

    local lp = LocalPlayer()
    if not holdingbind(lp) or isinsights(lp) or lp:ShouldDrawLocalPlayer() then LookX, LookY = 0, 0 return end
    
    InitialAng.z = 0
    cmd:SetViewAngles(InitialAng)

    local currentPitch = math.NormalizeAngle(InitialAng.p)

    local newLookX = LookX + x * 0.02
    local newLookY = LookY + y * 0.02

    local finalPitch = currentPitch + newLookY

    local maxPitch = 89
    local minPitch = -89
    
    if finalPitch > maxPitch then
        newLookY = maxPitch - currentPitch
    elseif finalPitch < minPitch then
        newLookY = minPitch - currentPitch
    end

    LookX = math.Clamp(newLookX, -100, 100)
    LookY = math.Clamp(newLookY, -65, 65)
    
    return true
end)
