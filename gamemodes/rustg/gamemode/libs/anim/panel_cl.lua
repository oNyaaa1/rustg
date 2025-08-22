--[[
Server Name: ★ [EU] gRust.co | Modded 10x | Wiped 2 hours ago | 2 Day Wipe
Server IP:   51.75.174.11:27044
File Path:   gamemodes/rust/gamemode/libs/anim/panel_cl.lua
		 __        __              __             ____     _                ____                __             __         
   _____/ /_____  / /__  ____     / /_  __  __   / __/____(_)__  ____  ____/ / /_  __     _____/ /____  ____ _/ /__  _____
  / ___/ __/ __ \/ / _ \/ __ \   / __ \/ / / /  / /_/ ___/ / _ \/ __ \/ __  / / / / /    / ___/ __/ _ \/ __ `/ / _ \/ ___/
 (__  ) /_/ /_/ / /  __/ / / /  / /_/ / /_/ /  / __/ /  / /  __/ / / / /_/ / / /_/ /    (__  ) /_/  __/ /_/ / /  __/ /    
/____/\__/\____/_/\___/_/ /_/  /_.___/\__, /  /_/ /_/  /_/\___/_/ /_/\__,_/_/\__, /____/____/\__/\___/\__,_/_/\___/_/     
                                     /____/                                 /____/_____/                                  
--]]

--
-- Meta
--

local PANEL = FindMetaTable("Panel")

function PANEL:NewAnim(time, easefn, callback, animfn)
    local anim = {
        time = time,
        easefn = easefn,
        animfn = animfn,
        callback = callback,
        start = SysTime(),
    }

    if (self.AnimAnims) then
        self.AnimAnims[#self.AnimAnims + 1] = anim
    else
        self.AnimAnims = {}
        self.AnimAnims[1] = anim
        
        local oldThink = self.Think
        self.Think = function(self)
            if (oldThink) then
                oldThink(self)
            end

            for k, v in pairs(self.AnimAnims) do
                local t = (SysTime() - v.start) / v.time
                local eased = v.easefn and v.easefn(t) or t

                v.animfn(eased)

                if (t >= 1) then
                    self.AnimAnims[k] = nil
                    if (v.callback) then
                        v.callback()
                    end
                    v.animfn(1)
                end
            end
        end
    end

    --[[local oldThink = self.Think
    self.Think = function(self)
        if (oldThink) then
            oldThink(self)
        end

        local t = (SysTime() - anim.start) / anim.time
        t = anim.easefn and anim.easefn(t) or t

        anim.animfn(t)

        if (t >= 1) then
            self.Think = oldThink
            if (anim.callback) then
                anim.callback()
            end
        end
    end]]
end

-- AnimMoveTo
-- Moves the panel to a position over time

function PANEL:AnimMoveTo(x, y, time, callback, easefn)
    local oldX, oldY = self:GetPos()
    self:NewAnim(time, easefn, callback, function(t)
        self:SetPos(Lerp(t, oldX, x), Lerp(t, oldY, y))
    end)
end

-- AnimSizeTo
-- Resizes the panel to a size over time

function PANEL:AnimSizeTo(w, h, time, callback, easefn)
    local oldW, oldH = self:GetSize()
    self:NewAnim(time, easefn, callback, function(t)
        self:SetSize(Lerp(t, oldW, w), Lerp(t, oldH, h))
    end)
end

-- AnimAlphaTo
-- Fades the panel to an alpha over time

function PANEL:AnimAlphaTo(alpha, time, callback, easefn)
    local oldAlpha = self:GetAlpha()
    self:NewAnim(time, easefn, callback, function(t)
        self:SetAlpha(Lerp(t, oldAlpha, alpha))
    end)
end