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
	self.RespawnTime = 10 -- Changed from 300 to 10 seconds
	self.MaxUses = 1
	self.CurrentUses = 0
end


function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if self.CurrentUses >= self.MaxUses then return end

    if activator:GiveItem("cloth", 10) then
        activator:SendNotification("Cloth", NOTIFICATION_PICKUP, "materials/icons/pickup.png", "+" .. 10)
        activator:EmitSound(gRust.RandomGroupedSound(string.format("pickup.%s","cloth")))
        LoggerPlayer(activator, "picked up cloth.")
        self.CurrentUses = self.CurrentUses + 1

        if self.CurrentUses >= self.MaxUses then
            -- Store position and angles for respawn
            local pos = self:GetPos()
            local ang = self:GetAngles()
            local model = self:GetModel()
            
            -- Remove the entity completely
            self:Remove()

            -- Respawn after 300 seconds
            timer.Simple(300, function()
                local newHemp = ents.Create("rust_map_hemp")
                if IsValid(newHemp) then
                    newHemp:SetPos(pos)
                    newHemp:SetAngles(ang)
                    newHemp:Spawn()
                    newHemp:Activate()
                end
            end)
        end

    end
end

function ENT:OnRemove()
end
