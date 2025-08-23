function Logger(msg)
    MsgC(Color(63, 163, 191), "[",  Color(31, 119, 163), "GRust", Color(63, 163, 191),"] ", Color(200,200,200), msg .. "\n")
end
function LoggerErr(msg)
    MsgC(Color(63, 163, 191), "[",  Color(31, 119, 163), "GRust", Color(63, 163, 191),"] ", Color(240, 0, 0), msg .. "\n")
end
function LoggerAdmin(msg)
    MsgC(Color(63, 163, 191), "[",  Color(31, 119, 163), "GRust", Color(63, 163, 191),"] ", Color(240, 0, 0), "[ADMIN]", Color(200,200,200), " " .. msg .. "\n")
end
Logger("-----------------------")
Logger("GRust Open Version 1.0")
Logger("-----------------------")
Logger("Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3553817120")
