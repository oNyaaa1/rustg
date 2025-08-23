AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.player = nil

ENT.therewasparent = false

function ENT:Initialize()
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_VPHYSICS )
    local physObj = self:GetPhysicsObject()
    if (IsValid(physObj)) then
        physObj:EnableMotion(false)
        physObj:Wake()
    end
    self:SetNetworkedString("buildtier", "twig")
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    if(self:GetNetworkedString("buildingtype") == nil || self.player == nil)then self:Remove() end
    self:SetNetworkedString("entity_building", self.build)
    if(self:GetNetworkedString("parent") != nil)then
        if(self:GetNetworkedString("buildingtype") == "foundation")then
            self:SetNetworkedString("parent", nil)
        else
    	    self.therewasparent = true
        end
    end

    local effectdata = EffectData()
	effectdata:SetOrigin( self:GetPos() + Vector(0,0,10) )
	util.Effect( "stunstickimpact", effectdata, true, true )
end

function ENT:Think()
    if(self:GetNetworkedString("buildingtype") == nil || self.player == nil)then self:Remove() end
    if(!IsValid(self:GetNetworkedString("parent")) && self.therewasparent)then self:Remove() end
    if(self:Health() <= 0)then 
        self:Remove() 
    end

    local tr = util.TraceLine( {
        start = self:GetPos(),
        endpos = self:GetPos() + Angle(self:GetAngles()+Angle(90,0,0)):Forward() * 10000,
        filter = function(ent) 
            if(ent != self)then 
                return false
            end
        end
    } )
end

function ENT:OnTakeDamage( dmginfo )
    if ( not self.m_bApplyingDamage ) then
        self.m_bApplyingDamage = true
        self:SetHealth(self:Health() - dmginfo:GetDamage())
        self:TakeDamageInfo( dmginfo )
        self.m_bApplyingDamage = false
    end
end