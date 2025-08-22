util.AddNetworkString("gRust.SetHunger")
util.AddNetworkString("gRust.SetThirst")
util.AddNetworkString("gRust.SyncMetabolism")

local PLAYER = FindMetaTable("Player")

function PLAYER:SetHunger(amount)
    amount = math.Clamp(amount or 0, 0, 511) 
    self.Hunger = amount
    
    net.Start("gRust.SetHunger")
    net.WriteUInt(amount, 9)
    net.Send(self)
end

function PLAYER:SetThirst(amount)
    amount = math.Clamp(amount or 0, 0, 255)
    self.Thirst = amount
    
    net.Start("gRust.SetThirst")
    net.WriteUInt(amount, 8)
    net.Send(self)
end

function PLAYER:SyncMetabolism()
    local hunger = self.Hunger or 0
    local thirst = self.Thirst or 0
    
    net.Start("gRust.SyncMetabolism")
    net.WriteUInt(hunger, 9)
    net.WriteUInt(thirst, 8)
    net.Send(self)
end


hook.Add("PlayerSpawn", "gRust.InitializeMetabolism", function(ply)
    ply.Hunger = 200
    ply.Thirst = 200
    
    local randomHealth = math.random(50, 60)
    ply:SetHealth(randomHealth)

    timer.Simple(0, function()
        if IsValid(ply) then
            ply:SyncMetabolism()
        end
    end)
end)

timer.Create("gRust.MetabolismTick", 30, 0, function()
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local currentHunger = ply:GetHunger()
            local currentThirst = ply:GetThirst()
            
            if currentHunger > 0 then
                ply:SetHunger(currentHunger - 1)
            end
            
            if currentThirst > 0 then
                ply:SetThirst(currentThirst - 1)
            end
            
            if currentHunger <= 0 or currentThirst <= 0 then
                ply:TakeDamage(5, ply, ply)
            end
        end
    end
end)

function PLAYER:AddHunger(amount)
    local currentHunger = self:GetHunger()
    self:SetHunger(currentHunger + (amount or 0))
end

function PLAYER:AddThirst(amount)
    local currentThirst = self:GetThirst()
    self:SetThirst(currentThirst + (amount or 0))
end
