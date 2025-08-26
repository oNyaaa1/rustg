AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("rust_keylock_sound")

function ENT:Initialize()
    self:SetModel(self.Deploy.Model or "models/deployable/key_lock.mdl")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        //phys:EnableMotion(true) -- lock in place
    end

    self.Locked = true
    self.Authorized = {} -- table of SteamIDs authorized
end

-- Allow players to press USE on the lock
function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local sid = ply:SteamID()

    if self.Authorized[sid] then
        -- If already authorized, toggle lock state
        self.Locked = not self.Locked
        self:PlayLockSound(self.Locked and "doors/door_locked2.wav" or "doors/door_latch3.wav")
    else
        -- If not authorized, add them (like putting a key in the lock)
        self.Authorized[sid] = true
        self:PlayLockSound("buttons/button14.wav")
        ply:ChatPrint("You are now authorized to use this lock.")
    end
end

-- Helper to play sounds on client
function ENT:PlayLockSound(soundName)
    net.Start("rust_keylock_sound")
        net.WriteEntity(self)
        net.WriteString(soundName)
    net.Broadcast()
end
