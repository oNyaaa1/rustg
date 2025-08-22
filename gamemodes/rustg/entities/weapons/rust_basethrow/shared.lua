

SWEP.Base = "rust_base"



SWEP.ThrowDelay = 0.25

SWEP.ThrowForce = 2000

SWEP.FuseTime	= 3

SWEP.Stick		= false

SWEP.Damage     = 115



function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + 2)



	self:PlayAnimation("Throw")

	self.NextThrow = CurTime() + self.ThrowDelay

end

function SWEP:Think()
    if (self.NextThrow and CurTime() > self.NextThrow) then
        self.NextThrow = nil
        local pl = self:GetOwner()

        if (SERVER) then
            local ang = pl:GetAimVector():Angle()
            pl:RemoveItem(self:GetInventorySlot():GetItem(), 1, self.InventorySlot)

            local ent = ents.Create("rust_projectile2")
            ent:SetOwner(pl)

            local spawnPos = (pl:GetShootPos() + pl:EyeAngles():Forward() * 0.1)
            ent:SetPos(spawnPos)
            ent:SetAngles(ang)
            ent:Spawn()
            ent:SetModel(self.WorldModel)
            ent:Activate()

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocityInstantaneous(ang:Forward() * self.ThrowForce)
            end
            
            ent:SetFuse(CurTime() + self.FuseTime)
            ent:SetStick(self.Stick)

            ClearPlayerWeapon(pl)

            local CBack = self.FuseCallback
            local Damage = self.Damage

            ent.FuseCallback = function(ent)
                CBack(self, ent, Damage)
            end
        end
    end
end




function SWEP:FuseCallback(ent, damage)

	util.ScreenShake(ent:GetPos(), 5, 1, 2, 1000)

	util.BlastDamage(ent, ent:GetOwner(), ent:GetPos(), 256, damage)



	ent:EmitSound("darky_rust.beancan-grenade-explosion")

	ParticleEffect("rust_big_explosion", ent:GetPos(), ent:GetAngles())

end

