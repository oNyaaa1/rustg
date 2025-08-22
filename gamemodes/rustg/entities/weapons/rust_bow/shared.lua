
local BaseClass = baseclass.Get("rust_base")

SWEP.Base   = "rust_base"



SWEP.WorldModel = "models/weapons/darky_m/rust/w_bow.mdl"

SWEP.ViewModel  = "models/weapons/darky_m/rust/c_bow.mdl"



function SWEP:PrimaryAttack()

    if (self.Charged and CurTime() > self.NextAttack) then

        self.Charged = false

        self.Fired = true



        local pl = self:GetOwner()

        if (!pl:HasItem("arrow", 1)) then return end



        self:PlayAnimation("PrimaryAttack")



        if (CLIENT) then return end



        local ang = pl:GetAimVector():Angle()

        

        local ent = ents.Create("rust_projectile")

        ent:SetOwner(pl)

        ent:SetPos(pl:GetShootPos())

        ent:SetAngles(ang + Angle(90, 0, 0))

        ent:Spawn()

        local phys = ent:GetPhysicsObject()

        phys:SetMass(0.75)

        phys:SetDamping(-15, 1)

        ent:SetModel("models/weapons/darky_m/rust/bone_arrow.mdl")

        ent:Activate()

        ent:Throw(ang:Forward(), 25000)



        pl:RemoveItem("arrow", 1)

        

        ent.PhysicsCollide = function(me, coldata, collider)

            if (me.Damaged) then return end

            me.Damaged = true

            

            local otherent = coldata.HitEntity

            

            ent:FireBullets({

                Attacker = pl,

                Damage = 35,

                Tracer = 0,

                Src = coldata.HitPos,

                Dir = coldata.HitNormal,

                Callback = function(attacker, tr, dmg)

                    dmg:SetDamageType(DMG_BULLET)

                end

            })

            

            me:Remove()

        end



        util.SpriteTrail(ent, 0, Color(255, 255, 255), false, 12, 0, 0.15, 1 / 12 * 0.5, "trails/laser")

    end

end



function SWEP:Think()

    local pl = self:GetOwner()



    if (pl:KeyDown(IN_ATTACK2)) then

        if (!pl:HasItem("arrow", 1)) then return end

        if (self.Charged) then return end

        if (self.Fired) then return end



        self:PlayAnimation("Deploy")

        self.Charged = true

        self.NextAttack = CurTime() + 1.35

    else

        self.Fired = false



        if (self.Charged and CurTime() > self.NextAttack) then

            self:SendWeaponAnim(ACT_VM_UNDEPLOY)

            self.Charged = false

        end

    end

end



function SWEP:Deploy()

    self:PlayAnimation("Deploy")

end

