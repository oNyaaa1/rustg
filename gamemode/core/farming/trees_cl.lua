-- Create font once
surface.CreateFont("RustXFont", {
    font = "Trebuchet MS",
    size = 48,
    weight = 800,
    antialias = true
})

local hitPos = nil
local Angles = nil
local function TreeEffects(len)
    hitPos = net.ReadVector()
    Angles = net.ReadAngle()
    local ent = net.ReadEntity()
    local effectdata = EffectData()
    effectdata:SetOrigin(hitPos)
    effectdata:SetEntity(ent)
    effectdata:SetSurfaceProp(9)
    effectdata:SetDamageType(2)
    effectdata:SetEntity(ent)
    util.Effect("GlassImpact", effectdata)
end

net.Receive("gRust.TreeEffects", TreeEffects)
hook.Add("PostDrawOpaqueRenderables", "DrawTreeXMarker", function()
    if not hitPos then return end
    cam.Start3D2D(hitPos, Angles - Angle(90, 0, 0), 0.25)
    surface.SetDrawColor(255, 0, 0, 255)
    surface.DrawLine(-10, -10, 10, 10)
    surface.DrawLine(-10, 10, 10, -10)
    cam.End3D2D()
end)