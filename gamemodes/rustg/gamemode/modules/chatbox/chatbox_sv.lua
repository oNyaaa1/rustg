util.AddNetworkString("gRust.SendChat")

local rankColors = {
    superadmin = Color(255,  85,   0),
    admin      = Color(255, 170,   0),
    moderator  = Color( 85, 170, 255),
    vip        = Color(170, 255,  85)
}

local function GetRank(ply)
    return ply:GetUserGroup() or "user"
end

local function GetRankColor(rank)
    return rankColors[rank] or Color(255, 255, 255)
end

net.Receive("gRust.SendChat", function(len, ply)
    local msg      = net.ReadString()
    local teamchat = net.ReadBool()

    Logger(ply:Nick() .. " (" .. ply:SteamID() .. ") sent a chat message: " .. msg)

    if msg == "" or string.Trim(msg) == "" then return end
    if hook.Run("PlayerSay", ply, msg, teamchat, true) == false then return end

    local rank      = GetRank(ply)
    local rankColor = GetRankColor(rank)

    net.Start("gRust.SendChat")
        net.WritePlayer(ply)
        net.WriteString(msg)
        net.WriteBool(teamchat)

        if rank ~= "user" then
            net.WriteBool(true)
            net.WriteString(rank)
            net.WriteColor(rankColor)
        else
            net.WriteBool(false)
        end
    net.Broadcast()
end)