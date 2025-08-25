gRust.Skins = gRust.Skins or {}
gRust.Skins.Registry = gRust.Skins.Registry or {}
function gRust:RegisterSkin(id, data)
	gRust.Skins[id] = data
	gRust.Skins.Registry[#gRust.Skins.Registry + 1] = id
end

gRust:RegisterSkin("nomercy", {
	name = "No Mercy AK Skin",
	ent = "assault_rifle",
	mat = "models/darky_m/rust_weapons/ak47u/skins/nomercy2",
	index = 2,
	worldindex = 0,
})

gRust:RegisterSkin("memeio", {
	name = "Memeio AK Skin",
	ent = "assault_rifle",
	mat = "models/darky_m/rust_weapons/ak47u/skins/memeio/memeio",
	index = 2,
	worldindex = 0,
})

gRust:RegisterSkin("danfmn", {
	name = "DanFMN AK Skin",
	ent = "assault_rifle",
	mat = "models/darky_m/rust_weapons/ak47u/skins/danfmn/danfmn",
	index = 2,
	worldindex = 0,
})

gRust:RegisterSkin("alien", {
	name = "Alien AK Skin",
	ent = "assault_rifle",
	mat = "models/darky_m/rust_weapons/ak47u/skins/alien/alien",
	index = 2,
	worldindex = 0,
})

gRust:RegisterSkin("metalrock", {
	name = "Metal Ore Rock Skin",
	ent = "rock",
	mat = "models/misc/ore/metal",
	index = 0,
	worldindex = 0,
})

gRust:RegisterSkin("fireaxe", {
	name = "Fire Axe Hatchet",
	ent = "hatchet",
	mat = "models/darky_m/rust_weapons/melee/skins/fireaxe/fireaxe",
	index = 0,
	worldindex = 0,
})

gRust:RegisterSkin("downbox", {
	name = "Down Large Wooden Box Skin",
	ent = "large_wood_box",
	mat = "models/zohart/deployables/large_wooden_box/skins/down/down_skin",
})

gRust:RegisterSkin("pink_rust", {
	name = "Pink gRust",
	ent = "custom_smg",
	mat = "models/darky_m/rust_weapons/smg/skins/pink_gRust/pink_gRust",
	index = 1,
	worldindex = 0,
})

gRust:RegisterSkin("pistol_fade", {
	name = "Fade",
	ent = "sap",
	mat = "models/darky_m/rust_weapons/sap/skins/fade/fade",
	index = 0,
	worldindex = 0,
})

gRust:RegisterSkin("rainbowdoor", {
	name = "Rainbow Door Skin",
	ent = "wooden_door",
	mat = "models/darky_m/rust/skins/door_wood/rainbow/rainbow",
})

gRust:RegisterSkin("magmadb", {
	name = "Magma",
	ent = "dbarrel",
	mat = "models/darky_m/rust_weapons/doublebarrel/skins/magma/magma",
	index = 0,
	worldindex = 1,
})

gRust:RegisterSkin("diamondpick", {
	name = "Diamond",
	ent = "pickaxe",
	mat = "models/darky_m/rust_weapons/melee/skins/diamondpick/diamond_pick",
	index = 0,
	worldindex = 0,
})

gRust:RegisterSkin("pixelfurnace", {
	name = "Pixel",
	ent = "furnace",
	mat = "models/darky_m/rust/skins/furnace/pixel/pixel",
})

gRust:RegisterSkin("amogusbag", {
	name = "Amogus",
	ent = "sleeping_bag",
	mat = "models/darky_m/rust/skins/sleepingbag/amogus/amogus",
})

gRust:RegisterSkin("ak_redsport", {
	name = "Redsport",
	ent = "assault_rifle",
	mat = "models/darky_m/rust_weapons/ak47u/skins/redsport/redsport_main",
	index = 2,
	worldindex = 0,
})

gRust:RegisterSkin("mp5_pinkfur", {
	name = "Pink Fur",
	ent = "mp5",
	mat = "models/darky_m/rust_weapons/mp5/skins/pinkfur/pinkfur",
	index = 0,
	worldindex = 0,
})

gRust:RegisterSkin("magmadoor", {
	name = "magma",
	ent = "wooden_door",
	mat = "models/darky_m/rust/skins/door_wood/magma/magma",
})

gRust:RegisterSkin("mp5_flashback", {
	name = "FlashBack",
	ent = "mp5",
	mat = "models/darky_m/rust_weapons/mp5/skins/flashback/body",
	index = 0,
	worldindex = 0,
})

gRust:RegisterSkin("hatchet_ultraviolet", {
	name = "Ultraviolet",
	ent = "hatchet",
	mat = "models/darky_m/rust_weapons/melee/skins/ultravioletaxe/v_axe",
	index = 0,
	worldindex = 0,
})

gRust:RegisterSkin("thompson_fade", {
	name = "Thompson",
	ent = "thompson",
	mat = "models/darky_m/rust_weapons/thompson/skins/fade/fade",
	index = 0,
	worldindex = 0,
})