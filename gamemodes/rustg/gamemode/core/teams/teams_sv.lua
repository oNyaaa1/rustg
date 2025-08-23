util.AddNetworkString("gRust.SyncTeam")
util.AddNetworkString("gRust.CreateTeam")
util.AddNetworkString("gRust.LeaveTeam")
util.AddNetworkString("gRust.InvitePlayer")

gRust.Teams = gRust.Teams or {}
gRust.TeamInvites = gRust.TeamInvites or {}
gRust.LastUseTime = gRust.LastUseTime or {}

local function SyncTeamToPlayer(ply)
    if (!IsValid(ply)) then return end
    
    local teamData = gRust.Teams[ply:AccountID()]
    if (!teamData) then
        net.Start("gRust.SyncTeam")
        net.WriteUInt(0, 4)
        net.Send(ply)
        return
    end
    
    net.Start("gRust.SyncTeam")
    net.WriteUInt(#teamData.members, 4)
    
    for _, memberSID in ipairs(teamData.members) do
        local memberPly = player.GetByAccountID(memberSID)
        local memberName = IsValid(memberPly) and memberPly:Nick()
        
        net.WriteUInt(memberSID, 32)
        net.WriteString(memberName or "")
    end
    
    net.Send(ply)
end

local function SyncTeamToMembers(teamData)
    if (!teamData or !teamData.members) then return end
    
    for _, memberSID in ipairs(teamData.members) do
        local memberPly = player.GetByAccountID(memberSID)
        if (IsValid(memberPly)) then
            SyncTeamToPlayer(memberPly)
        end
    end
end

function gRust.GetPlayerTeam(ply)
    if (!IsValid(ply)) then return nil end
    return gRust.Teams[ply:AccountID()]
end

function gRust.AreTeammates(ply1, ply2)
    if (!IsValid(ply1) or !IsValid(ply2)) then return false end
    if (ply1 == ply2) then return true end
    
    local team1 = gRust.GetPlayerTeam(ply1)
    local team2 = gRust.GetPlayerTeam(ply2)
    
    return team1 and team2 and team1 == team2
end

function gRust.InviteToTeam(inviter, target)
    if (!IsValid(inviter) or !IsValid(target)) then return end
    
    local inviterSID = inviter:AccountID()
    local targetSID = target:AccountID()
    local inviterTeam = gRust.Teams[inviterSID]
    
    if (!inviterTeam) then
        inviter:ChatPrint("You are not in a team! Create a team first.")
        return
    end
    
    if (inviterTeam.leader != inviterSID) then
        inviter:ChatPrint("Only the team leader can invite players!")
        return
    end
    
    if (gRust.Teams[targetSID]) then
        inviter:ChatPrint("Player " .. target:Nick() .. " is already in a team!")
        return
    end
    
    if (gRust.TeamInvites[targetSID]) then
        inviter:ChatPrint("Player " .. target:Nick() .. " already has an active invitation!")
        return
    end
    
    gRust.TeamInvites[targetSID] = {
        inviter = inviterSID,
        teamData = inviterTeam,
        time = CurTime()
    }
    
    inviter:ChatPrint("Invitation sent to player " .. target:Nick())
    target:ChatPrint("Player " .. inviter:Nick() .. " invites you to join their team!")
    target:ChatPrint("Type /accept to accept or /decline to decline")
    
    timer.Simple(60, function()
        if (gRust.TeamInvites[targetSID]) then
            gRust.TeamInvites[targetSID] = nil
            if (IsValid(target)) then
                target:ChatPrint("Team invitation has expired.")
            end
        end
    end)
end

function gRust.AcceptInvite(ply)
    if (!IsValid(ply)) then return end
    
    local playerSID = ply:AccountID()
    local invite = gRust.TeamInvites[playerSID]
    
    if (!invite) then
        ply:ChatPrint("You have no active team invitations!")
        return
    end
    
    local teamData = invite.teamData
    if (!teamData or !teamData.members or #teamData.members == 0) then
        gRust.TeamInvites[playerSID] = nil
        ply:ChatPrint("The team no longer exists!")
        return
    end
    
    table.insert(teamData.members, playerSID)
    gRust.Teams[playerSID] = teamData
    
    gRust.TeamInvites[playerSID] = nil
    
    SyncTeamToMembers(teamData)
    
    ply:ChatPrint("You joined the team!")
    
    local inviter = player.GetByAccountID(invite.inviter)
    if (IsValid(inviter)) then
        inviter:ChatPrint("Player " .. ply:Nick() .. " joined the team!")
    end
    
    for _, memberSID in ipairs(teamData.members) do
        if (memberSID != playerSID and memberSID != invite.inviter) then
            local member = player.GetByAccountID(memberSID)
            if (IsValid(member)) then
                member:ChatPrint("Player " .. ply:Nick() .. " joined the team!")
            end
        end
    end
end

function gRust.DeclineInvite(ply)
    if (!IsValid(ply)) then return end
    
    local playerSID = ply:AccountID()
    local invite = gRust.TeamInvites[playerSID]
    
    if (!invite) then
        ply:ChatPrint("You have no active team invitations!")
        return
    end
    
    local inviter = player.GetByAccountID(invite.inviter)
    
    gRust.TeamInvites[playerSID] = nil
    
    ply:ChatPrint("You declined the team invitation.")
    if (IsValid(inviter)) then
        inviter:ChatPrint("Player " .. ply:Nick() .. " declined the team invitation.")
    end
end

local function CreateTeam(len, ply)
    if (!IsValid(ply)) then return end
    
    local playerSID = ply:AccountID()
    
    if (gRust.Teams[playerSID]) then
        ply:ChatPrint("You are already in a team!")
        return
    end
    
    local teamData = {
        leader = playerSID,
        members = {playerSID},
        created = os.time()
    }
    
    gRust.Teams[playerSID] = teamData
    
    SyncTeamToPlayer(ply)
    
    ply:ChatPrint("Team successfully created! Press E on a player to invite them.")
end

local function LeaveTeam(len, ply)
    if (!IsValid(ply)) then return end
    
    local playerSID = ply:AccountID()
    local teamData = gRust.Teams[playerSID]
    
    if (!teamData) then
        ply:ChatPrint("You are not in a team!")
        return
    end
    
    for i, memberSID in ipairs(teamData.members) do
        if (memberSID == playerSID) then
            table.remove(teamData.members, i)
            break
        end
    end
    
    if (#teamData.members == 0) then
        gRust.Teams[playerSID] = nil
    else
        if (teamData.leader == playerSID) then
            teamData.leader = teamData.members[1]
            local newLeader = player.GetByAccountID(teamData.leader)
            if (IsValid(newLeader)) then
                newLeader:ChatPrint("You are now the new team leader!")
            end
        end
        
        for _, memberSID in ipairs(teamData.members) do
            gRust.Teams[memberSID] = teamData
        end
        
        SyncTeamToMembers(teamData)
    end
    
    gRust.Teams[playerSID] = nil
    
    SyncTeamToPlayer(ply)
    
    ply:ChatPrint("You left the team!")
end

net.Receive("gRust.CreateTeam", CreateTeam)
net.Receive("gRust.LeaveTeam", LeaveTeam)

hook.Add("PlayerUse", "gRust.InviteOnUse", function(ply, ent)
    if (!IsValid(ply) or !IsValid(ent) or !ent:IsPlayer()) then return end
    
    local currentTime = CurTime()
    local playerID = ply:SteamID()
    local targetID = ent:SteamID()
    local lastUseKey = playerID .. "_" .. targetID
    
    if (gRust.LastUseTime[lastUseKey] and currentTime - gRust.LastUseTime[lastUseKey] < 1) then
        return
    end
    
    gRust.LastUseTime[lastUseKey] = currentTime
    
    gRust.InviteToTeam(ply, ent)
end)

hook.Add("PlayerSay", "gRust.TeamChatCommands", function(ply, text, team)
    if (!IsValid(ply)) then return end
    
    local cmd = string.lower(text)
    
    if (cmd == "/accept") then
        gRust.AcceptInvite(ply)
        return ""
        
    elseif (cmd == "/decline") then
        gRust.DeclineInvite(ply)
        return ""
    end
end)

hook.Add("PlayerInitialSpawn", "gRust.SyncTeamOnSpawn", function(ply)
    timer.Simple(1, function()
        if (IsValid(ply)) then
            SyncTeamToPlayer(ply)
        end
    end)
end)

hook.Add("PlayerDisconnected", "gRust.CleanupTeamOnDisconnect", function(ply)
    if (!IsValid(ply)) then return end
    
    local playerSID = ply:AccountID()
    
    gRust.TeamInvites[playerSID] = nil
    
    local teamData = gRust.Teams[playerSID]
    if (teamData and #teamData.members > 1) then
        SyncTeamToMembers(teamData)
    end
end)
