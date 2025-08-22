include("shared.lua")

local Flare = Material("decals/flare_ore")
function ENT:Draw()
    self:DrawModel()
    
    local Weakspot = self:GetNW2Vector("Weakspot")
    if (Weakspot ~= vector_origin) then
        if (self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 50000) then return end

        cam.Start3D()
            render.SetMaterial(Flare)
            render.DrawSprite(Weakspot, 64, 64, color_white)
        cam.End3D()
    end
end

for i = 1, 4 do
    util.PrecacheModel("models/environment/ores/ore_node_stage" .. i .. ".mdl")
end