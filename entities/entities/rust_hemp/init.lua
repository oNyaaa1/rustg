AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Deploy.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

	self:SetUseType(SIMPLE_USE)
	self:SetBodygroup(1, 3)
	
	self.CanPickup = true
	self.RespawnTime = 300
	self.MaxUses = 1
	self.CurrentUses = 0
end


function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if self.CurrentUses >= self.MaxUses then return end

    if activator:GiveItem("cloth", 10) then

        activator:EmitSound(gRust.RandomGroupedSound(string.format("pickup.%s","cloth")))
        
        self.CurrentUses = self.CurrentUses + 1

        if self.CurrentUses >= self.MaxUses then
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            
            timer.Simple(self.RespawnTime, function()
                if IsValid(self) then
                    self:SetNoDraw(false)
                    self:SetNotSolid(false)
                    self.CurrentUses = 0
                end
            end)
        end

    else
        activator:ChatPrint("")
    end
end

function ENT:OnRemove()
end
