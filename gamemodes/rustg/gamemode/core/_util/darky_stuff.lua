if CLIENT then game.AddParticles("particles/blood_impact.pcf") end
game.AddParticles("particles/grust_particle.pcf")
game.AddParticles("particles/rust.pcf")
PrecacheParticleSystem("rust_fire")
PrecacheParticleSystem("rust_inc")
PrecacheParticleSystem("rust_fire_ent")
PrecacheParticleSystem("rust_fire_vm")
PrecacheParticleSystem("rust_explode")
PrecacheParticleSystem("rust_big_explosion")
PrecacheParticleSystem("rust_steam")
PrecacheParticleSystem("building_smoke")
local gunshots = file.Find("sound/weapons/rust_distant/*", "GAME")
local mp3s = file.Find("sound/weapons/rust_mp3/*.mp3", "GAME")
local wavs = file.Find("sound/weapons/rust/*.wav", "GAME")
for i = 1, #mp3s do
    local snd = string.sub(mp3s[i], 1, -5)
    sound.Add({
        name = "darky_rust." .. snd,
        channel = CHAN_STATIC,
        volume = 1.0,
        soundlevel = 180,
        sound = "weapons/rust_mp3/" .. snd .. ".mp3"
    })
end

for i = 1, #wavs do
    local snd = string.sub(wavs[i], 1, -5)
    sound.Add({
        name = "darky_rust." .. snd,
        channel = CHAN_STATIC,
        volume = 1.0,
        soundlevel = 180,
        sound = "weapons/rust/" .. snd .. ".wav"
    })
end

for i = 1, #gunshots do
    local snd = string.sub(gunshots[i], 1, -5)
    sound.Add({
        name = "darky_rust." .. snd,
        channel = CHAN_STATIC,
        volume = 10.0,
        soundlevel = 180,
        sound = "^weapons/rust_distant/" .. snd .. ".mp3"
    })
end

-- Sounds
sound.Add({
    name = "Player.Wade", -- removing ugly water sounds
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

sound.Add({
    name = "Player.Swim", -- same
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

sound.Add({
    name = "SolidMetal.ImpactHard", -- same
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

sound.Add({
    name = "SolidMetal.ImpactSoft", -- same
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

sound.Add({
    name = "Concrete.ImpactHard", -- same
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

sound.Add({
    name = "Concrete.ImpactSoft", -- same
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

sound.Add({
    name = "Wood.ImpactHard", -- same
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

sound.Add({
    name = "Wood.ImpactSoft", -- same
    channel = CHAN_BODY,
    volume = 1.0,
    level = 20,
    sound = "common/null.wav"
})

-- sound replacement but smarter
sound.Add({
    name = "HL2Player.BurnPain",
    channel = CHAN_VOICE,
    volume = 0.6,
    level = 75,
    sound = "rust/fire.mp3"
})

sound.Add({
    name = "Bullets.DefaultNearmiss",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 140,
    sound = {">rust/bullet-ricochet-1.mp3", ">rust/bullet-ricochet-2.mp3", ">rust/bullet-ricochet-3.mp3", ">rust/bullet-ricochet-4.mp3", ">rust/bullet-ricochet-5.mp3", ">rust/bullet-ricochet-6.mp3"}
})

sound.Add({
    name = "FX_RicochetSound.Ricochet",
    channel = CHAN_STATIC,
    volume = 0.5,
    level = 80,
    sound = {">rust/bullet-ricochet-1.mp3", ">rust/bullet-ricochet-2.mp3", ">rust/bullet-ricochet-3.mp3", ">rust/bullet-ricochet-4.mp3", ">rust/bullet-ricochet-5.mp3", ">rust/bullet-ricochet-6.mp3"}
})

sound.Add({
    name = "SolidMetal.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/metal_bullet_impact-1.mp3", "rust/metal_bullet_impact-2.mp3", "rust/metal_bullet_impact-3.mp3", "rust/metal_bullet_impact-4.mp3"}
})

sound.Add({
    name = "Dirt.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/dirt_bullet_impact-1.mp3", "rust/dirt_bullet_impact-2.mp3", "rust/dirt_bullet_impact-3.mp3"}
})

sound.Add({
    name = "Tile.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/concrete_impact_bullet1.mp3", "rust/concrete_impact_bullet2.mp3", "rust/concrete_impact_bullet3.mp3", "rust/concrete_impact_bullet4.mp3"}
})

sound.Add({
    name = "Concrete.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/concrete_impact_bullet1.mp3", "rust/concrete_impact_bullet2.mp3", "rust/concrete_impact_bullet3.mp3", "rust/concrete_impact_bullet4.mp3"}
})

sound.Add({
    name = "Glass.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/glass_bullet_impact-1.mp3", "rust/glass_bullet_impact-2.mp3", "rust/glass_bullet_impact-3.mp3"}
})

sound.Add({
    name = "Water.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/water_bullet_impact-1.mp3", "rust/water_bullet_impact-2.mp3", "rust/water_bullet_impact-3.mp3"}
})

sound.Add({
    name = "Flesh.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/flesh_bullet_impact-1.mp3", "rust/flesh_bullet_impact-2.mp3", "rust/flesh_bullet_impact-3.mp3", "rust/flesh_bullet_impact-4.mp3"}
})

sound.Add({
    name = "Carpet.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/cloth_bullet_impact1.mp3", "rust/cloth_bullet_impact2.mp3", "rust/cloth_bullet_impact3.mp3", "rust/cloth_bullet_impact4.mp3"}
})

sound.Add({
    name = "Sand.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/bullet-impact-sand-1.mp3", "rust/bullet-impact-sand-2.mp3", "rust/bullet-impact-sand-3.mp3", "rust/bullet-impact-sand-4.mp3"}
})

sound.Add({
    name = "Default.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/generic-bullet-impact-1.mp3", "rust/generic-bullet-impact-2.mp3", "rust/generic-bullet-impact-3.mp3", "rust/generic-bullet-impact-4.mp3"}
})

sound.Add({
    name = "Wood.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/wood_bullet_impact-1.mp3", "rust/wood_bullet_impact-2.mp3", "rust/wood_bullet_impact-3.mp3", "rust/wood_bullet_impact-4.mp3"}
})

sound.Add({
    name = "Wood_Box.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/wood_bullet_impact-1.mp3", "rust/wood_bullet_impact-2.mp3", "rust/wood_bullet_impact-3.mp3", "rust/wood_bullet_impact-4.mp3"}
})

sound.Add({
    name = "Wood_Solid.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/wood_bullet_impact-1.mp3", "rust/wood_bullet_impact-2.mp3", "rust/wood_bullet_impact-3.mp3", "rust/wood_bullet_impact-4.mp3"}
})

sound.Add({
    name = "Wood_Panel.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/wood_bullet_impact-1.mp3", "rust/wood_bullet_impact-2.mp3", "rust/wood_bullet_impact-3.mp3", "rust/wood_bullet_impact-4.mp3"}
})

sound.Add({
    name = "Wood_Plank.BulletImpact",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 75,
    sound = {"rust/wood_bullet_impact-1.mp3", "rust/wood_bullet_impact-2.mp3", "rust/wood_bullet_impact-3.mp3", "rust/wood_bullet_impact-4.mp3"}
})

sound.Add({
    name = "Bounce.Shell",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_NORM,
    sound = {"rust/m39-shell-drop-001.mp3", "rust/m39-shell-drop-002.mp3", "rust/m39-shell-drop-003.mp3"}
})

--
if CLIENT then return end
local shoes = "barefoot"
local path = "rust/footsteps/footstep-"
local sndtype = ".mp3"
local math = math
-- bind for EmitSound
local function PlayFS(ply, name, volume)
    ply:EmitSound(path .. name .. sndtype, SNDLVL_70dB, 100, volume * 2, CHAN_BODY)
end

-- name converter for util.GetSurfacePropName to rust prefixs
local function MatName(mat)
    if mat == "grass" then return "-grass" end
    if mat == "dirt" then return "-dirt" end
    if mat == "snow" then return "-snow" end
    if mat == "gravel" then return "-gravel" end
    if mat == "rock" then return "-stones" end
    if mat == "carpet" then return "-cloth" end
    if mat == "mud" then return "-forest" end
    if mat == "chainlink" then return "-metal" end
    if string.find(mat, "wood") then return "-wood" end
    if string.find(mat, "metal") then return "-metal" end
    if string.find(mat, "sand") then return "-sand" end
    if string.find(mat, "ice") then return "-ice" end
    return "-concrete"
end

-- playing sound
local function StepSound(ply, mat, type, volume, cancelonwater)
    local WaterLevel = ply:WaterLevel()
    local MaterialName = MatName(mat)
    if type == "-jump-land-" then
        if WaterLevel == 1 then
            PlayFS(ply, "water-land-" .. math.random(1, 4), volume)
            if cancelonwater then return end
        elseif WaterLevel > 1 then
            return
        end

        PlayFS(ply, shoes .. MaterialName .. type .. "00" .. math.random(1, 4), volume)
    elseif type == "-jump-start-" then
        if WaterLevel >= 1 then
            PlayFS(ply, "water-med-" .. math.random(1, 4), volume)
            if cancelonwater then return end
        end

        PlayFS(ply, shoes .. MaterialName .. type .. "00" .. math.random(1, 4), volume)
    else
        if WaterLevel == 1 then
            PlayFS(ply, "water-light-" .. math.random(1, 4), volume)
            if cancelonwater then return end
        elseif WaterLevel > 1 then
            PlayFS(ply, "water-hard-" .. math.random(1, 8), volume)
            if cancelonwater then return end
        end

        PlayFS(ply, shoes .. MaterialName .. type .. "00" .. math.random(1, 8), volume)
    end
    return
end

-- doing traces from player legs to ground to check material
local function TraceGround(ply)
    local Trace = {
        start = ply:GetPos(),
        endpos = ply:GetPos() - Vector(0, 0, 30),
        filter = ply
    }

    local Result = util.TraceLine(Trace)
    return Result.SurfaceProps == 0 and "default" or util.GetSurfacePropName(Result.SurfaceProps)
end

-- for jump sounds
local function FinishMove(ply, move)
    if not IsFirstTimePredicted() then return end
    if not ply:Alive() then return end
    local OnGround = ply:OnGround() and ply:GetMoveType() == MOVETYPE_WALK
    if move:KeyDown(IN_JUMP) and not OnGround and not ply.RustFS_jumped then -- jumping sound
        ply.RustFS_landed = false
        ply.RustFS_jumped = true
        local TGMat = TraceGround(ply)
        StepSound(ply, TGMat, "-jump-start-", 1, true)
    elseif OnGround then
        ply.RustFS_jumped = false
    end

    if OnGround and not ply.RustFS_landed then -- landing sound
        ply.RustFS_landed = true
        local TGMat = TraceGround(ply)
        StepSound(ply, TGMat, "-jump-land-", 1, true)
    elseif not OnGround then
        ply.RustFS_landed = false
    end
end

-- footsteps
local function PlayerFootstep(ply, pos, foot, sound, volume, rf)
    if not ply:Alive() then return end
    local TGMat = TraceGround(ply)
    local Running = ply:GetVelocity():Length() > ply:GetWalkSpeed() + 15
    local OnGround = ply:OnGround() and ply:GetMoveType() == MOVETYPE_WALK
    local Crouching = ply:Crouching() and ply:GetMoveType() == MOVETYPE_WALK
    if ply.RustFS_landed and OnGround and not Crouching then
        if Running then
            StepSound(ply, TGMat, "-run-", volume, true)
        else
            StepSound(ply, TGMat, "-walk-", volume, true)
        end
    end
    return true
end

-- hooks
hook.Add("PlayerFootstep", "Rust.Footsteps", PlayerFootstep)
hook.Add("FinishMove", "Rust.Footsteps2", FinishMove)