AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

    util.PrecacheModel("models/vehicles/darky_m/rust/minicopter.mdl")
    util.PrecacheModel("models/nova/jeep_seat.mdl")

    local minicopterGibs = {
        "models/vehicles/darky_m/rust/minicopter_gib0.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib1.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib2.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib3.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib4.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib5.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib6.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib7.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib8.mdl",
        "models/vehicles/darky_m/rust/minicopter_gib9.mdl"
    }
    
    for _, model in pairs(minicopterGibs) do
        util.PrecacheModel(model)
    end

    util.PrecacheSound("vehicles/rust/minicopter/rotors-loop-close.wav")
    util.PrecacheSound("vehicles/rust/minicopter/engine-loop-close.wav")
    util.PrecacheSound("vehicles/rust/minicopter/engine-start-close.wav")
    util.PrecacheSound("vehicles/rust/minicopter/engine-stop-close.wav")
    util.PrecacheSound("vehicles/rust/minicopter/rotors-stop-close.wav")
    util.PrecacheSound("vehicles/rust/minicopter/metal_gib-3.wav")
    util.PrecacheSound("vehicles/rust/minicopter/rocket_explosion.wav")

    for i = 1, 4 do
        util.PrecacheSound("vehicles/rust/minicopter/minicopter-damaged-00" .. i .. ".wav")
    end
    
    util.PrecacheSound("vehicles/rust/minicopter/small-boat-close-fuel-container.wav")
    util.PrecacheSound("vehicles/rust/minicopter/small-boat-open-fuel-container.wav")
    util.PrecacheSound("buttons/lightswitch2.wav")

