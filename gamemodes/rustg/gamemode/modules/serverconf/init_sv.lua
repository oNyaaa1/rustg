local BASE_SERVERCONF = {
    discord = "https://discord.gg/kyyuC48amc",
    website = "https://steamcommunity.com/sharedfiles/filedetails/?id=3553817120",
    steam = "https://steamcommunity.com/sharedfiles/filedetails/?id=3553817120"
}
local SERVERCONF_FILE = "grust/server.json"

local function LoadGRustServerCfg()
    if not file.Exists(SERVERCONF_FILE, "DATA") then
        local json = util.TableToJSON(BASE_SERVERCONF, true) 
        file.Write(SERVERCONF_FILE, json)
        Logger("[gRust] Created serverconf file with default template")
        return BASE_SERVERCONF
    end

    local json = file.Read(SERVERCONF_FILE, "DATA")
    if json then
        local config = util.JSONToTable(json)
        if config then
            Logger("Loaded serverconf file")
            return config
        end
    end

    LoggerErr("Failed to load serverconf file, using defaults")
    return BASE_SERVERCONF
end

local ServerConfig = LoadGRustServerCfg()

local function SendServerConfigToPlayer(ply)
    if not IsValid(ply) then return end
    
    net.Start("gRust.ServerConfig")
    net.WriteString(ServerConfig.discord or "")
    net.WriteString(ServerConfig.website or "")
    net.WriteString(ServerConfig.steam or "")
    net.Send(ply)
    
    Logger("Sent server config to player: " .. ply:Nick())
end

hook.Add("PlayerInitialSpawn", "gRust.SendServerConfig", function(ply)
    timer.Simple(5, function()
        if IsValid(ply) then
            SendServerConfigToPlayer(ply)
        end
    end)
end)