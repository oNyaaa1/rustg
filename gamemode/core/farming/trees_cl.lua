-- Create font once
surface.CreateFont("RustXFont", {
    font = "Trebuchet MS",
    size = 48,
    weight = 800,
    antialias = true
})

local function TreeEffects(len)
    local hitPos = net.ReadVector()
    local ent = net.ReadEntity()
    local effectdata = EffectData()
    effectdata:SetOrigin(hitPos)
    effectdata:SetEntity(ent)
    effectdata:SetSurfaceProp(9)
    effectdata:SetDamageType(2)
    util.Effect("GlassImpact", effectdata)
    local effectdataz = EffectData()
    effectdataz:SetOrigin(hitPos)
    effectdataz:SetEntity(ent)
    effectdataz:SetSurfaceProp(9)
    effectdataz:SetDamageType(2)
    util.Effect("xmarker", effectdataz)
end

net.Receive("gRust.TreeEffects", TreeEffects)