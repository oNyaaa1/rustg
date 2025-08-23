local function SyncSkins()
    local pl = LocalPlayer()

    pl.Skins = {}
    for i = 1, net.ReadUInt(16) do
        pl.Skins[net.ReadString()] = true
    end
end
net.Receive("gRust.SyncSkins", SyncSkins)