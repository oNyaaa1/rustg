local Item
--
-- Wood
--
Item = gRust.ItemRegister("wood")
Item:SetName("Wood")
Item:SetDescription("Wood. Collected from trees and used in many crafting recipes. It's also needed to cook in camp-fires.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/wood.png")
Item:SetModel("models/items/wood.mdl")
Item:SetSound("wood")
gRust.RegisterItem(Item)
--
-- Stone
--
Item = gRust.ItemRegister("stone")
Item:SetName("Stone")
Item:SetDescription("Harvested from rocks using tools, basic building material.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/stone.png")
Item:SetModel("models/items/stone.mdl")
gRust.RegisterItem(Item)
--
-- Metal Ore
--
Item = gRust.ItemRegister("metal.ore")
Item:SetName("Metal Ore")
Item:SetDescription("Metal ore can be smelted into metal fragments through a furnace which is used to craft most of the tools, structures, items and weaponry throughout the game and is vital to have during most of the time being.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/metal_ore.png")
Item:SetModel("models/items/metal_ore.mdl")
gRust.RegisterItem(Item)
--
-- HQ Metal Ore
--
Item = gRust.ItemRegister("hq.metal.ore")
Item:SetName("High Quality Metal Ore")
Item:SetDescription("A rock containing High Quality Metal. Can be smelted in a furnace.")
Item:SetCategory("Resources")
Item:SetStack(250)
Item:SetIcon("materials/items/resources/hqmetal_ore.png")
gRust.RegisterItem(Item)
--
-- Sulfur Ore
--
Item = gRust.ItemRegister("sulfur.ore")
Item:SetName("Sulfur Ore")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/sulfur_ore.png")
Item:SetModel("models/items/sulfur_ore.mdl")
gRust.RegisterItem(Item)
--
-- Sulfur
--
Item = gRust.ItemRegister("sulfur")
Item:SetName("Sulfur")
Item:SetDescription("Sulfur ore is a resource found in Sulfur nodes. Smelting sulfur ore in any furnace will give sulfur, an ingredient in crafting gunpowder.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/sulfur.png")
Item:SetModel("models/items/sulphur.mdl")
gRust.RegisterItem(Item)
--
-- Metal Fragments
--
Item = gRust.ItemRegister("metal.fragments")
Item:SetName("Metal Fragments")
Item:SetDescription("Metal Fragments. Smelted from Metal Ore, used in lots of different crafting recipes.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/metal_fragments.png")
Item:SetModel("models/items/metalfragments.mdl")
gRust.RegisterItem(Item)
--
-- High Quality Metal
--
Item = gRust.ItemRegister("metal.refined")
Item:SetName("High Quality Metal")
Item:SetDescription("High Quality Metal is considered as a rare resource used for crafting metal items such as armor, doors, weapons and more. High Quality Metal is often used as the 'top-tier' when constructing or upgrading building blocks.")
Item:SetCategory("Resources")
Item:SetStack(250)
Item:SetIcon("materials/items/resources/hqmetal.png")
Item:SetModel("models/items/hqmetal.mdl")
Item:SetSound("metal")
gRust.RegisterItem(Item)
--
-- Charcoal
--
Item = gRust.ItemRegister("charcoal")
Item:SetName("Charcoal")
Item:SetDescription("Charcoal is the byproduct of wood when used for smelting in a campfire or furnace. It is used in conjunction with sulfur to craft gunpowder, a key ingredient for ammunition and explosives. Though it may be tempting to throw charcoal away, large quantities will be required in later stages of the game. Keep it if you can.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/charcoal.png")
Item:SetModel("models/items/charcoal.mdl")
Item:SetSound("charcoal")
gRust.RegisterItem(Item)
--
-- Cloth
--
Item = gRust.ItemRegister("cloth")
Item:SetName("Cloth")
Item:SetDescription("Cloth is a basic resource that has several means of being harvested. Most commonly it is farmed with hemp and hemp seeds, but can be gathered from animals and even cacti with the appropriate tools. It is used primarily for clothing, and the refining of low grade when combined with animal fat. To make cloth gathering a trivial task, the proper use of planters is recommended.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/cloth.png")
Item:SetModel("models/items/cloth.mdl")
Item:SetSound("cloth")
gRust.RegisterItem(Item)
--
-- Bone Fragments
--
Item = gRust.ItemRegister("bone.fragments")
Item:SetName("Bone Fragments")
Item:SetDescription("Bone Fragments are a resource obtained from harvesting animal corpses. They can be used in various crafting recipes, including the creation of bone tools and armor.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/bone_fragments.png")
Item:SetModel("models/items/bone_fragments.mdl")
Item:SetSound("seeds")
gRust.RegisterItem(Item)
--
-- Scrap
--
Item = gRust.ItemRegister("scrap")
Item:SetName("Scrap")
Item:SetDescription("Resource mainly used for researching items into blueprints at workbenches or going down the tech tree, which allows for targeting certain items you want to acquire. It's also a type of currency, used for trading various items at the Scientist Outpost and the Bandit Camp. As such, Scrap is very valuable and essential at any point in the game.")
Item:SetCategory("Resources")
Item:SetStack(2500)
Item:SetIcon("materials/items/resources/scrap.png")
Item:SetModel("models/items/scrappile.mdl")
Item:SetSound("metal")
gRust.RegisterItem(Item)
--
-- Gears
--
Item = gRust.ItemRegister("gears")
Item:SetName("Gears")
Item:SetDescription("Gears are used in the crafting of various desirable (building) supplies involved in base defense, such as traps, gates, and first and foremost armored & garage doors, which are significantly stronger than sheet metal doors. These are hard to come by in large quantities and are one of the more sought after items in the game.")
Item:SetCategory("Resources")
Item:SetStack(20)
Item:SetIcon("materials/items/resources/gears.png")
Item:SetModel("models/items/gears.mdl")
Item:SetSound("metal")
Item:SetCraft({

    {

        item = "metal.fragments",

        amount = 30

    },

    {

        item = "scrap",

        amount = 24

    }

})

gRust.RegisterItem(Item)
--
-- Road Signs
--
Item = gRust.ItemRegister("roadsigns")
Item:SetName("Road Signs")
Item:SetDescription("Road signs are a component used in the crafting of the mid-tier armors Road Sign Jacket, and Road Sign Kilt, along with crafting the salvaged cleaver. Also good as a source of scrap throughout the game.")
Item:SetCategory("Resources")
Item:SetStack(1000)
Item:SetIcon("materials/items/resources/road_signs.png")
Item:SetModel("models/items/roadsigns.mdl")
Item:SetSound("metal")
Item:SetCraft({

    {

        item = "scrap",

        amount = 5

    },

    {

        item = "metal.refined",

        amount = 2

    }


})

gRust.RegisterItem(Item)
--
-- Metal Pipe
--
Item = gRust.ItemRegister("metalpipe")
Item:SetName("Metal Pipe")
Item:SetDescription("Pipes are a relatively common component that are used for guns, salvaged tools, and rocket launchers and rockets. They can be somewhat abundant early game until you find the need to craft rockets, and then get consumed very quickly.")
Item:SetCategory("Resources")
Item:SetStack(1000)
Item:SetIcon("materials/items/resources/metal_pipe.png")
Item:SetModel("models/items/metalpipe.mdl")
Item:SetSound("metal")
Item:SetCraft({

    {

        item = "scrap",

        amount = 5

    },

    {

        item = "metal.refined",

        amount = 2

    }


})
gRust.RegisterItem(Item)
--
-- Metal Spring
--
Item = gRust.ItemRegister("metalspring")
Item:SetName("Metal Spring")
Item:SetDescription("An uncommon component used for the construction of almost every gun. It may be found with moderate frequency from crates, and uncommonly from barrels. Generally speaking, guns of higher tiers will require more Metal Springs, while low tier guns (Semi Auto Pistol, Rifle) require only one.")
Item:SetCategory("Resources")
Item:SetStack(1000)
Item:SetIcon("materials/items/resources/metal_spring.png")
Item:SetModel("models/items/spring.mdl")
Item:SetSound("metal")
Item:SetCraft({

    {

        item = "scrap",

        amount = 24

    },

    {

        item = "metal.refined",

        amount = 4

    }


})
gRust.RegisterItem(Item)
--
-- Sheet Metal
--
Item = gRust.ItemRegister("sheetmetal")
Item:SetName("Sheet Metal")
Item:SetDescription("An uncommon component that can be recycled into Metal Fragments and High Quality Metal, or used in the crafting of Heavy Plate armor pieces. It can be found in crates and barrels.")
Item:SetCategory("Resources")
Item:SetStack(1000)
Item:SetIcon("materials/items/resources/sheet_metal.png")
Item:SetModel("models/items/sheetmetal.mdl")
Item:SetSound("metal")
Item:SetCraft({

    {

        item = "scrap",

        amount = 20

    },

    {

        item = "metal.fragments",

        amount = 240

    },

    {

        item = "metal.refined",

        amount = 2

    }


})
gRust.RegisterItem(Item)
--
-- Semi Auto Body
--
Item = gRust.ItemRegister("semibody")
Item:SetName("Semi-Automatic Body")
Item:SetDescription("Semi Automatic Bodies are components used in the crafting of Semi-Auto Pistols and Semi-Auto Rifles. They can be found quite commonly and can be recycled for a good profit.")
Item:SetCategory("Resources")
Item:SetStack(10)
Item:SetIcon("materials/items/resources/semi_auto_body.png")
Item:SetModel("models/items/semibody.mdl")
Item:SetCraft({

    {

        item = "scrap",

        amount = 36

    },

    {

        item = "metal.fragments",

        amount = 180

    },

    {

        item = "metal.refined",

        amount = 4

    }


})
gRust.RegisterItem(Item)
--
-- Rifle Body
--
Item = gRust.ItemRegister("riflebody")
Item:SetName("Rifle Body")
Item:SetDescription("A rare component which is used for crafting late-game rifles. It can only be found in military and elite crates.")
Item:SetCategory("Resources")
Item:SetStack(10)
Item:SetIcon("materials/items/resources/rifle_body.png")
Item:SetModel("models/items/rifle_body.mdl")
Item:SetCraft({

    {

        item = "scrap",

        amount = 60

    },

    {

        item = "metal.refined",

        amount = 4

    }

})
gRust.RegisterItem(Item)
--
-- SMG Body
--
Item = gRust.ItemRegister("smgbody")
Item:SetName("SMG Body")
Item:SetDescription("A rare component which is used for crafting submachine guns. It can only be found in military and elite crates.")
Item:SetCategory("Resources")
Item:SetStack(10)
Item:SetIcon("materials/items/resources/smg_body.png")
Item:SetModel("models/items/smgbody.mdl")
Item:SetSound("metal")
Item:SetCraft({

    {

        item = "scrap",

        amount = 36

    },

    {

        item = "metal.refined",

        amount = 4

    }

})
gRust.RegisterItem(Item)
--
-- Tech Trash
--
Item = gRust.ItemRegister("techparts")
Item:SetName("Tech Trash")
Item:SetDescription("Tech Trash is an essential component in Timed Explosive Charges and weapon attachments. Tech Trash can be gained via military crates or the recycler.")
Item:SetCategory("Resources")
Item:SetStack(50)
Item:SetIcon("materials/items/resources/tech_trash.png")
Item:SetModel("models/items/techtrash.mdl")
Item:SetSound("metal")
Item:SetCraft({

    {

        item = "scrap",

        amount = 48

    },

    {

        item = "metal.refined",

        amount = 2

    }

})
gRust.RegisterItem(Item)
--
-- Sewing Kit
--
Item = gRust.ItemRegister("sewingkit")
Item:SetName("Sewing Kit")
Item:SetDescription("Sewing Kits are highly valued by mid to high tier players for their use in both roadsign and metal Armour.")
Item:SetCategory("Resources")
Item:SetStack(50)
Item:SetIcon("materials/items/resources/sewing_kit.png")
Item:SetModel("models/items/sewingkit.mdl")
Item:SetSound("cloth")
Item:SetCraft({

    {

        item = "rope",

        amount = 6

    },

    {

        item = "cloth",

        amount = 40

    }

})

gRust.RegisterItem(Item)
--
-- Rope
--
Item = gRust.ItemRegister("rope")
Item:SetName("Rope")
Item:SetDescription("Rope is quite common component used in many items like wooden armor, satchel charges, ladders and shotgun traps. Because of that it remains relatively useful throughout the whole game. It can be often found in barrels alongside sewing kits which can be recycled for even more rope.")
Item:SetCategory("Resources")
Item:SetStack(50)
Item:SetIcon("materials/items/resources/rope.png")
Item:SetModel("models/items/rope.mdl")
Item:SetCraft({
    {
        item = "cloth",
        amount = 60
    }
})
gRust.RegisterItem(Item)
--
-- Tarp
--
Item = gRust.ItemRegister("tarp")
Item:SetName("Tarp")
Item:SetDescription("Tarps are used for the crafting of planter boxes, and water catchers. They can also be recycled for 50x cloth each. These are very common and can prove to be a good source of cloth.")
Item:SetCategory("Resources")
Item:SetStack(50)
Item:SetIcon("materials/items/resources/tarp.png")
Item:SetModel("models/items/tarp.mdl")
Item:SetCraft({
    {
        item = "cloth",
        amount = 120
    }
})
gRust.RegisterItem(Item)
--
-- Tarp
--
Item = gRust.ItemRegister("fat.animal")
Item:SetName("Animal Fat")
Item:SetDescription("Fat is a good package for biological energy, making it quite an effective fuel source. It can be taken from any animal, including humans.")
Item:SetCategory("Resources")
Item:SetStack(100)
Item:SetIcon("materials/items/resources/animal_fat.png")
--Item:SetModel("models/items/animal_fat.mdl")
gRust.RegisterItem(Item)
--
-- Low Grade Fuel
--
Item = gRust.ItemRegister("lowgradefuel")
Item:SetName("Low Grade Fuel")
Item:SetDescription("Low Grade Fuel is a resource made from Animal Fat and Cloth. It is required early game to make furnaces and mid game for Syringes. There are three ways to get this, hunting animals (or to a lesser effect, humans) and crafting it, refining crude oil at a monument or personal refinery, and finding it in oil barrels (or to a lesser effect in mine carts).")
Item:SetCategory("Resources")
Item:SetStack(500)
Item:SetIcon("materials/items/resources/low_grade_fuel.png")
Item:SetCraftTime(5)
Item:SetCraftAmount(4)
Item:SetCraft({
    {
        item = "fat.animal",
        amount = 3
    },
    {
        item = "cloth",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- Metal Blade
--
Item = gRust.ItemRegister("metalblade")
Item:SetName("Metal Blade")
Item:SetDescription("Metal blades are common components that can be found in barrels near roads or at monuments. They are used to craft some tools and melee weapons. If you don't have any use for the items you can craft with these it would be wise to recycle them for two scrap.")
Item:SetCategory("Resources")
Item:SetStack(50)
Item:SetIcon("materials/items/resources/metal_blade.png")
Item:SetModel("models/items/metalblade.mdl")
Item:SetCraft({

    {

        item = "scrap",

        amount = 4

    },

    {

        item = "metal.fragments",

        amount = 36

    }

})
gRust.RegisterItem(Item)
--
-- Propane Tank
--
Item = gRust.ItemRegister("propanetank")
Item:SetName("Propane Tank")
Item:SetDescription("")
Item:SetCategory("Resources")
Item:SetStack(5)
Item:SetIcon("materials/items/resources/propane_tank.png")
Item:SetModel("models/items/propanetank.mdl")
Item:SetCraft({

    {

        item = "scrap",

        amount = 2

    },

    {

        item = "metal.fragments",

        amount = 100

    }

})
gRust.RegisterItem(Item)
--
-- Electric Fuse
--
Item = gRust.ItemRegister("fuse")
Item:SetName("Electric Fuse")
Item:SetDescription("The Electric Fuse is a required item for monument puzzle rooms. It must be placed in the fuse box in order to power the keycard lock. Recycling the electric fuse also gives some quick scrap.")
Item:SetCategory("Resources")
Item:SetStack(10)
Item:SetIcon("materials/items/resources/fuse.png")
--Item:SetModel("models/items/propanetank.mdl")
Item:SetCraft({

    {

        item = "scrap",

        amount = 48

    }

})
gRust.RegisterItem(Item)
--
-- Gunpowder
--
Item = gRust.ItemRegister("gunpowder")
Item:SetName("Gunpowder")
Item:SetDescription("Gunpowder is a resource created by combining smelted sulfur and charcoal. It is used for multiple things from rockets, grenades, ammunition, and even land mines. As this is used almost exclusively for PvP purposes, this is a much sought after resource and should be protected and seized at every opportunity.")
Item:SetCategory("Resources")
Item:SetStack(1000)
Item:SetIcon("materials/items/resources/gunpowder.png")
Item:SetModel("models/items/gunpowder.mdl")
Item:SetCraftAmount(10)
Item:SetCraftTime(3)
Item:SetCraft({
    {
        item = "charcoal",
        amount = 30
    },
    {
        item = "sulfur",
        amount = 20
    }
})

gRust.RegisterItem(Item)
--
-- Explosives
--
Item = gRust.ItemRegister("explosives")
Item:SetName("Explosives")
Item:SetDescription("Explosives are used in more powerful raiding devices. They cannot be used on their own, only as an ingredient.")
Item:SetCategory("Explosives")
Item:SetStack(10)
Item:SetIcon("materials/items/resources/explosives.png")
Item:SetTier(3)
Item:SetModel("models/items/explosives.mdl")
Item:SetCraft({
    {
        item = "gunpowder",
        amount = 50
    },
    {
        item = "sulfur",
        amount = 10
    },
    {
        item = "metal.fragments",
        amount = 20
    }
})

gRust.RegisterItem(Item)