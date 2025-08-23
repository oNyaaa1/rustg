if (SERVER) then return end -- Clientside library

local PANEL = FindMetaTable("Panel")

local surface = surface
local Blur = Material("pp/blurscreen")

function PANEL:DrawBlur(amount)
    local x, y = self:LocalToScreen(0, 0)
    local scrw, scrh = ScrW(), ScrH()
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(Blur)

    for i = 1, 3 do
        Blur:SetFloat("$blur", (i / 3) * (amount or 3))
        Blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, scrw, scrh)
    end
end