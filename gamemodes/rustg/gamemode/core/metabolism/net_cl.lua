local function SetHunger()
    LocalPlayer().Hunger = net.ReadUInt(9)
end

local function SetThirst()
    LocalPlayer().Thirst = net.ReadUInt(8)
end

local function SyncMetabolism()
    local pl = LocalPlayer()
    pl.Hunger = net.ReadUInt(9)
    pl.Thirst = net.ReadUInt(8)
end

net.Receive("gRust.SetHunger", SetHunger)
net.Receive("gRust.SetThirst", SetThirst)
net.Receive("gRust.SyncMetabolism", SyncMetabolism)