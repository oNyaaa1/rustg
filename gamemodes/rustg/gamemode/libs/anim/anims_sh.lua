--[[
Server Name: ★ [EU] gRust.co | Modded 10x | Wiped 2 hours ago | 2 Day Wipe
Server IP:   51.75.174.11:27044
File Path:   gamemodes/rust/gamemode/libs/anim/anims_sh.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

--
-- Anim functions
--

gRust.Anim = gRust.Anim or {}

local Punch = gRust.Anim.AnimationCurve(
    gRust.Anim.KeyFrame(0, 0),
    gRust.Anim.KeyFrame(0.112586, 0.9976035),
    gRust.Anim.KeyFrame(0.3120486, 0.01720615),
    gRust.Anim.KeyFrame(0.4316337, 0.17030682),
    gRust.Anim.KeyFrame(0.5524869, 0.03141804),
    gRust.Anim.KeyFrame(0.6549395, 0.002909959),
    gRust.Anim.KeyFrame(0.770987, 0.009817753),
    gRust.Anim.KeyFrame(0.8838775, 0.001939224),
    gRust.Anim.KeyFrame(1, 0)
)

function gRust.Anim.Punch(x)
    return Punch:Evaluate(x)
end

function gRust.Anim.InSineBounce(x, amp)
    amp = amp or 1.1
    return amp * math.sin(x * math.pi * (1 - (math.asin(1 / amp) / math.pi)))
end