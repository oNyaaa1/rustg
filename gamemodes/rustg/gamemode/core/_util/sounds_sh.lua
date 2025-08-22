function gRust.AddSound(name, dir, volume, chan)
    sound.Add({
        name = name,
        channel = chan or CHAN_STATIC,
        volume = volume,
        sound = dir,
    })
end

--
-- Sound groups
--

gRust.SoundGroups = {}
function gRust.AddSoundGroup(name, sounds)
    gRust.SoundGroups[name] = sounds
end

function gRust.RandomGroupedSound(name)
    return gRust.SoundGroups[name][math.random(1, #gRust.SoundGroups[name])]
end

--
-- UI Sounds
--

gRust.AddSound("ui.blip", "ui/blip.wav", 0.2)
gRust.AddSound("ui.piemenu.select", "ui/piemenu/piemenu_select.wav", 0.2)
gRust.AddSound("ui.piemenu.cancel", "ui/piemenu/piemenu_cancel.wav", 0.2)
gRust.AddSound("ui.piemenu.open", "ui/piemenu/piemenu_open.wav", 0.2)

--
-- Door Sounds
--

gRust.AddSound("door.wood.open", "doors/door_wood_open.wav", 1)
gRust.AddSound("door.wood.close", "doors/door_wood_close.wav", 1)
gRust.AddSound("door.wood.shut", "doors/door_wood_shut.wav", 1)

gRust.AddSound("door.metal.open", "doors/door_metal_open.wav", 1)
gRust.AddSound("door.metal.close", "doors/door_metal_close.wav", 1)
gRust.AddSound("door.metal.shut", "doors/door_metal_shut.wav", 1)

--
-- Keypad Sounds
--

gRust.AddSound("keypad.beep", "doors/keypad_beep.wav", 1)
gRust.AddSound("keypad.deploy", "doors/keypad_deploy.wav", 1)
gRust.AddSound("keypad.shock", "doors/keypad_shock.wav", 1)
gRust.AddSound("keypad.noauth", "doors/keypad_noauth.wav", 1)
gRust.AddSound("keypad.setcode", "doors/keypad_setcode.wav", 1)

--
-- Farming
--

gRust.AddSound("farming.hemp.pickup", "farming/hemp_pickup.wav", 1)
gRust.AddSound("tree.spray", "farming/tree_spray.wav")
gRust.AddSound("ore.flare.hit", "farming/flare_hit.wav", 0.5)
gRust.AddSound("ore.flare.finish", "farming/flare_finish.wav")

--
-- Hit Sounds
--

gRust.AddSound("hit.default", "combat/hitmarker.wav")
gRust.AddSound("hit.head", "combat/headshot.wav")

--
-- Tech Tree
--

gRust.AddSound("techtree.unlock", "ui/techtree/item_unlock.wav")

--
-- Vending Machine
--

gRust.AddSound("vending_machine.open", "inventory/vending_machine_open.wav")
gRust.AddSound("vending_machine.purchase", "farming/vending_machine_purchase.wav")

--
-- Items
--

local function AddItemSound(name)
    gRust.AddSoundGroup("pickup." .. name, {
        "ui/items/pickup_" .. name .. "_1.wav",
        "ui/items/pickup_" .. name .. "_2.wav",
        "ui/items/pickup_" .. name .. "_3.wav",
        "ui/items/pickup_" .. name .. "_4.wav"
    })
    
    gRust.AddSoundGroup("drop." .. name, {
        "ui/items/drop_" .. name .. "_1.wav",
        "ui/items/drop_" .. name .. "_2.wav",
        "ui/items/drop_" .. name .. "_3.wav",
        "ui/items/drop_" .. name .. "_4.wav"
    })
end

AddItemSound("stone")
AddItemSound("metal")
AddItemSound("cloth")
AddItemSound("wood")
AddItemSound("charcoal")
AddItemSound("paper")
AddItemSound("seeds")

--
-- Building / Upgrading
--

gRust.AddSoundGroup("build.place", {
    "building/hammer_saw_1.wav",
    "building/hammer_saw_2.wav",
    "building/hammer_saw_3.wav"
})

gRust.AddSoundGroup("build.stone", {
    "building/rust_stone_1.wav",
    "building/rust_stone_2.wav",
    "building/rust_stone_3.wav"
})

gRust.AddSoundGroup("build.metal", {
    "building/rust_metal_1.wav",
    "building/rust_metal_2.wav",
    "building/rust_metal_3.wav"
})

gRust.AddSoundGroup("build.metal", {
    "building/rust_metal_1.wav",
    "building/rust_metal_2.wav",
    "building/rust_metal_3.wav"
})

--
-- Doors
--

gRust.AddSoundGroup("door.wood.knock", {
    "doors/door_knock_wood_1.wav",
    "doors/door_knock_wood_2.wav"
})

gRust.AddSoundGroup("door.metal.knock", {
    "doors/door_knock_metal_1.wav",
    "doors/door_knock_metal_2.wav"
})

--
-- Farming
--

gRust.AddSoundGroup("tree.x.hit", {
    "farming/tree_x_hit1.wav",
    "farming/tree_x_hit2.wav",
    "farming/tree_x_hit3.wav",
    "farming/tree_x_hit4.wav"
})

gRust.AddSoundGroup("tree.crack.small", {
    "farming/tree_crack_small_1.wav",
    "farming/tree_crack_small_2.wav",
    "farming/tree_crack_small_3.wav"
})

gRust.AddSoundGroup("tree.crack.medium", {
    "farming/tree_crack_med_1.wav",
    "farming/tree_crack_med_2.wav",
    "farming/tree_crack_med_3.wav"
})