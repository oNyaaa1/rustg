
local function SyncTeam()

    gRust.Team      = {}

    gRust.TeamCache = {}



    local Count = net.ReadUInt(4)

    if (Count == 0) then return end



    for i = 1, Count do

        local SID = net.ReadUInt(32)

        local Name = net.ReadString()



        gRust.Team[i] = {SID = SID, Name = Name}

        gRust.TeamCache[SID] = true

    end

end

net.Receive("gRust.SyncTeam", SyncTeam)



function GM:DrawTeam()

    if (!gRust.Team or #gRust.Team == 0) then return end



    local DeadColor     = gRust.Colors.Primary

    local OnlineColor   = gRust.Colors.Secondary

    local OfflineColor  = gRust.Colors.Surface



    local scrh = ScrH()

    for i, v in ipairs(gRust.Team) do

        local pl = player.GetByAccountID(v.SID)

        draw.SimpleTextOutlined(string.format("• %s", v.Name), "gRust.38px", 20, scrh - (i * scrh * 0.024), IsValid(pl) and (pl:Alive() and OnlineColor or DeadColor) or OfflineColor, 0, 1, 2, Color(0, 0, 0))

    end

end



function gRust.CreateTeam()

    net.Start("gRust.CreateTeam")

    net.SendToServer()

end



function gRust.LeaveTeam()

    net.Start("gRust.LeaveTeam")

    net.SendToServer()

end

