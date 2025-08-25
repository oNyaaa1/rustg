AddCSLuaFile()
ENT.Base = "rust_base"
ENT.ShowHealth = true
local BarrelTypes = {
	{
		Health = 35,
		Color = Color(200, 165, 115),
		Bodygroup = 0
	},
	{
		Health = 50,
		Color = Color(80, 120, 205),
		Bodygroup = 0
	},
	{
		Health = 50,
		Color = Color(170, 62, 60),
		Bodygroup = 1
	}
}

function ENT:Initialize()
	if CLIENT then return end
	self:SetModel("models/environment/misc/barrel_v2.mdl")
	self:PhysicsInitStatic(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetDamageable(true)
	self:SetDamageSound(true)
	local Type = BarrelTypes[math.random(#BarrelTypes)]
	self:SetHealth(Type.Health)
	self:SetMaxHealth(Type.Health)
	self:SetColor(Type.Color)
	self:SetBodygroup(1, Type.Bodygroup)
	self:SetRespawnTime(120)
	self:PrecacheGibs()
	self:SetMeleeDamage(1.5)
	self:SetBulletDamage(2)
	self:SetExplosiveDamage(5)
end

local LootItems = {
	{
		Item = "scrap",
		Min = 2,
		Max = 2,
		Chance = 100
	},
	{
		Item = "fat.animal",
		Min = 5,
		Max = 20,
		Chance = 20
	},
	{
		Item = "metalblade",
		Min = 1,
		Max = 1,
		Chance = 16
	},
	{
		Item = "rope",
		Min = 1,
		Max = 2,
		Chance = 15
	},
	{
		Item = "sewingkit",
		Min = 3,
		Max = 4,
		Chance = 8
	},
	{
		Item = "propanetank",
		Min = 1,
		Max = 4,
		Chance = 8
	},
	{
		Item = "tarp",
		Min = 1,
		Max = 1,
		Chance = 8
	},
	{
		Item = "lowgradefuel",
		Min = 3,
		Max = 7,
		Chance = 4
	},
	{
		Item = "semibody",
		Min = 1,
		Max = 1,
		Chance = 1
	},
	{
		Item = "sheetmetal",
		Min = 1,
		Max = 1,
		Chance = 1
	},
	{
		Item = "metal_spring",
		Min = 1,
		Max = 1,
		Chance = 1
	},
	{
		Item = "roadsigns",
		Min = 3,
		Max = 4,
		Chance = 1
	},
	{
		Item = "gears",
		Min = 2,
		Max = 4,
		Chance = 1
	},
	{
		Item = "metalpipe",
		Min = 1,
		Max = 4,
		Chance = 1
	},
	{
		Item = "fuse",
		Min = 1,
		Max = 1,
		Chance = 1
	},
	{
		Item = "scard",
		Min = 1,
		Max = 1,
		Chance = 1
	},
}

local function GetRandomItem(tbl)
	for i = 1, #tbl do
		local v = tbl[i]
		if (math.random() * 100) > v.Chance then continue end
		local Item = gRust.CreateItem(v.Item)
		if not Item then return end
		Item:SetQuantity(math.random(v.Min, v.Max))
		table.remove(tbl, i)
		return Item
	end
end

function ENT:SpawnLoot()
	if CLIENT then return end
	tbl = table.Copy(LootItems)
	for i = 1, 5 do
		local v = LootItems[i]
		local Item = GetRandomItem(tbl)
		if not Item then continue end
		local Maxs = self:OBBMaxs()
		local ent = ents.Create("rust_droppeditem")
		ent:SetItem(Item)
		ent:SetPos(self:GetPos() + Vector(math.random(-Maxs.x, Maxs.x), math.random(-Maxs.y, Maxs.y), Maxs.z * math.random(0.25, 0.5)))
		ent:Spawn()
	end
end

local BarrelLoot
function ENT:OnDestroyed(dmg)
	if SERVER then self:GibBreakServer(dmg:GetDamageForce()) end
	self:SpawnLoot()
end

function ENT:Save()
	return false
end

function ENT:Load()
end