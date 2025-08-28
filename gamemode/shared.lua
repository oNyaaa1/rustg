GM.Name = "gRust | Rust in Garry's Mod"
GM.Author = ""
GM.Email = ""
GM.Website = ""
gRust = gRust or {
    Config = {},
}

-- Returns a random hit position on the surface of the tree facing the player
function GetRandomHitPos(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return ent:GetPos() end
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local trace = ply:GetEyeTrace()
    local localPos = trace.HitPos //+ Vector(math.Rand(mins.x, maxs.x), math.Rand(mins.y, maxs.y), math.Rand(mins.z, maxs.z))
    -- Convert local to world
    local worldPos = ent:LocalToWorld(localPos)
    -- Trace from player's eyes to the tree to clamp it to the surface
    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = worldPos,
        filter = ply
    })
    -- Return the hit position on the tree surface
    return tr.HitPos
end

CONFIG = CONFIG or {}
LANG = LANG or {}
local IncludeCL = CLIENT and include or AddCSLuaFile
local IncludeSV = SERVER and include or function() end
local IncludeSH = CLIENT and include or function(f)
    AddCSLuaFile(f)
    return include(f)
end

IncludeSH("config.lua")
gRust.IncludeSV = SERVER and include or function() end
gRust.IncludeCL = SERVER and AddCSLuaFile or include
gRust.IncludeSH = function(dir)
    if SERVER then
        AddCSLuaFile(dir)
        return include(dir)
    else
        return include(dir)
    end
end

local smart_include = function(f)
    if string.find(f, "_sv.lua") then
        return IncludeSV(f)
    elseif string.find(f, "_cl.lua") then
        return IncludeCL(f)
    else
        return IncludeSH(f)
    end
end

gRust.IncludeDir = function(dir)
    local fol = dir .. '/'
    local files, folders = file.Find(fol .. '*', "LUA")
    for _, f in ipairs(files) do
        smart_include(fol .. f)
    end

    for _, f in ipairs(folders) do
        gRust.IncludeDir(dir .. '/' .. f)
    end
end

gRust.IncludeDir("rustg/gamemode/libs")
gRust.IncludeDir("rustg/gamemode/vgui")
gRust.IncludeDir("rustg/gamemode/core")
hook.Run("gRust.LoadedCore")
gRust.IncludeDir("rustg/gamemode/modules")
hook.Run("gRust.Loaded")
function CONFIG:SendLanguage(lang, xs, ply)
    net.Start("gRust.SendLanguage")
    net.WriteString(lang)
    net.WriteString(xs)
    net.Send(ply)
end