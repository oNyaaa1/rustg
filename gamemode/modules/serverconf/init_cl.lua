-- Global server configuration
gRust = gRust or {}
gRust.ServerConfig = gRust.ServerConfig or {}

-- Receive server configuration from server
net.Receive("gRust.ServerConfig", function()
    gRust.ServerConfig.discord = net.ReadString()
    gRust.ServerConfig.website = net.ReadString()
    gRust.ServerConfig.steam = net.ReadString()
end)
