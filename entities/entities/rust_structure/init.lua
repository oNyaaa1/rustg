AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
    self:SetModel("models/building_re/twig_foundation.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Sleep()
    end

    self:SetMaxHealth(250)
    self:SetHealth(250)
    self:SetNetworkedString("buildtier", "twig")
    self:SetNetworkedString("buildingtype", self:GetBuildingType())
    self.AuthorizedPlayers = {}
    self.CreationTime = CurTime()
end

function ENT:GetBuildingType()
    local model = self:GetModel()
    if string.find(model, "foundation") then
        return "foundation"
    elseif string.find(model, "wall") or string.find(model, "frame") then
        return "wall"
    elseif string.find(model, "floor") or string.find(model, "stairs") or string.find(model, "steps") then
        return "floor"
    else
        return "foundation"
    end
end

function ENT:SetOwner(pl)
    BaseClass.SetOwner(self, pl)
    if IsValid(pl) then
        self:SetNW2String("OwnerName", pl:Nick())
        self:SetNW2String("OwnerSteamID", pl:SteamID())
        self:AuthorizePlayer(pl)
    end
end

function ENT:AuthorizePlayer(pl)
    if not IsValid(pl) then return end
    self.AuthorizedPlayers[pl:SteamID()] = true
end

function ENT:IsAuthorized(pl)
    if not IsValid(pl) then return false end
    return self.AuthorizedPlayers[pl:SteamID()] == true
end

function ENT:CanDecay()
    return CurTime() - self.CreationTime > 600
end

function ENT:Think()
    if self:CanDecay() and self:GetNetworkedString("buildtier") == "twig" then
        local damage = 1
        self:SetHealth(self:Health() - damage)
        if self:Health() <= 0 then
            self:Destroy()
            return
        end

        self:NextThink(CurTime() + 10)
        return true
    end
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    local attacker = dmginfo:GetAttacker()
    local tier = self:GetNetworkedString("buildtier")
    local multiplier = 1
    if tier == "twig" then
        multiplier = 1
    elseif tier == "wood" then
        multiplier = 0.5
    elseif tier == "stone" then
        multiplier = 0.25
    elseif tier == "metal" then
        multiplier = 0.1
    elseif tier == "armored" then
        multiplier = 0.05
    end

    damage = damage * multiplier
    self:SetHealth(math.max(0, self:Health() - damage))
    if self:Health() <= 0 then self:Destroy() end
end

function ENT:Destroy()
    self:DropResources()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(1)
    util.Effect("rust_building_destroy", effectdata)
    self:Remove()
end

function ENT:DropResources()
    local tier = self:GetNetworkedString("buildtier")
    local buildingType = self:GetNetworkedString("buildingtype")
    local dropTable = {
        twig = {
            wood = 25
        },
        wood = {
            wood = 75
        },
        stone = {
            stone = 150,
            wood = 25
        },
        metal = {
            ["metal.fragments"] = 100,
            stone = 50
        },
        armored = {
            ["metal.refined"] = 13,
            ["metal.fragments"] = 50
        }
    }

    local drops = dropTable[tier] or dropTable.twig
    for item, amount in pairs(drops) do
        local pos = self:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), 50)
        if SERVER and gRust and gRust.SpawnItem then gRust.SpawnItem(item, amount, pos) end
    end
end

function ENT:GetOriginalModel()
    return self:GetModel()
end

function ENT:UpdateMaterial()
    local tier = self:GetNetworkedString("buildtier")
    local materials = {
        twig = "models/darky_m/rust_building/twig",
        wood = "models/darky_m/rust_building/wood",
        stone = "models/darky_m/rust_building/stone",
        metal = "models/darky_m/rust_building/metal",
        armored = "models/darky_m/rust_building/armored"
    }

    local material = materials[tier] or materials.twig
    self:SetMaterial(material)
end

function ENT:GetHealth()
    return self:Health()
end

function ENT:GetMaxHealth()
    return self:GetMaxHealth()
end

function ENT:IsDecaying()
    return self:CanDecay() and self:GetNetworkedString("buildtier") == "twig"
end

util.AddNetworkString("gRust.StructureInfo")
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    net.Start("gRust.StructureInfo")
    net.WriteEntity(self)
    net.WriteString(self:GetNetworkedString("buildtier"))
    net.WriteString(self:GetNetworkedString("buildingtype"))
    net.WriteInt(self:Health(), 16)
    net.WriteInt(self:GetMaxHealth(), 16)
    net.WriteBool(self:IsDecaying())
    net.Send(activator)
end