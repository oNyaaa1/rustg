local PLAYER = FindMetaTable("Player")

function PLAYER:InitBlueprints()
    self.Blueprints = self.Blueprints or {}
end

function PLAYER:AddBlueprint(class)
    if (!gRust.Config.Blueprints) then return end
    
    self.Blueprints = self.Blueprints or {}
    self.Blueprints[class] = true

    net.Start("gRust.AddBlueprint")
    net.WriteString(class)
    net.Send(self)
end

function PLAYER:SyncBlueprints()
    self.Blueprints = self.Blueprints or {}
    
    net.Start("gRust.SyncBlueprints")
    
    local count = table.Count(self.Blueprints)
    net.WriteUInt(count, 16)
    
    for class, _ in pairs(self.Blueprints) do
        net.WriteString(class)
    end
    
    net.Send(self)
end

hook.Add("PlayerInitialSpawn", "gRust.InitBlueprints", function(ply)
    ply:InitBlueprints()
    timer.Simple(1, function()
        if (IsValid(ply)) then
            ply:SyncBlueprints()
        end
    end)
end)

util.AddNetworkString("gRust.SyncBlueprints")
util.AddNetworkString("gRust.AddBlueprint")
util.AddNetworkString("gRust.LearnBlueprint")

net.Receive("gRust.LearnBlueprint", function(len, ply)
    local ent = net.ReadEntity()
    local slot = net.ReadUInt(8)

    if (!IsValid(ent) or !IsValid(ply)) then return end
    if (ent:GetPos():Distance(ply:GetPos()) > 200) then return end

    local inv = ent.Inventory 

    if (!inv or !inv[slot]) then return end

    local item = inv[slot]
    local itemClass = item.Class
    local itemData = gRust.Items[itemClass]

    if (!itemData or !itemData:GetBlueprint()) then return end

    if (ply:HasBlueprint(itemClass)) then
        return
    end

    ply:AddBlueprint(itemClass)
    
    if item:GetQuantity() <= 1 then
        ent:RemoveSlot(slot)
    else
        item:RemoveQuantity(1)
        ent:SyncSlot(slot)
    end
end)
