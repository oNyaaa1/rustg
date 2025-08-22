local Item



--

-- Rock

--



Item = gRust.ItemRegister("rock")

Item:SetName("Rock")

Item:SetDescription("A Rock. The most basic melee weapon and gathering tool.")

Item:SetCategory("Tools")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/rock.png")

Item:SetWeapon("rust_rock")

Item:SetCraft({

    {

        item = "stone",

        amount = 10

    }

})

gRust.RegisterItem(Item)



--

-- Stone hatchet

--



Item = gRust.ItemRegister("stonehatchet")

Item:SetName("Stone Hatchet")

Item:SetDescription("The Stone Hatchet is a primitive, early game tool used for collecting wood and flesh. It is available to craft, costing only wood and stones. Players starting out may find great use of the Stone Hatchet along with the Stone Pickaxe to aid in their farming endeavors. Although it is much less efficient than the Hatchet or Salvaged Axe, it is still used commonly due to its low barrier of entry- not costing any processed materials which require a furnace.")

Item:SetCategory("Tools")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/stone_hatchet.png")

Item:SetWeapon("rust_stonehatchet")

Item:SetCraft({

    {

        item = "wood",

        amount = 200,

    },

    {

        item = "stone",

        amount = 100

    }

})

gRust.RegisterItem(Item)



--

-- Stone pickaxe

--



Item = gRust.ItemRegister("stone.pickaxe")

Item:SetName("Stone Pickaxe")

Item:SetDescription("Primitive tool used for harvesting Stone, Metal ore and Sulfur ore. Can also be used to harvest animals due to its relatively high harvest rate, and contrary to popular belief, it is more efficient than the stone hatchet.")

Item:SetCategory("Tools")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/stone_pickaxe.png")

Item:SetWeapon("rust_stonepickaxe")

Item:SetCraft({

    {

        item = "wood",

        amount = 200,

    },

    {

        item = "stone",

        amount = 100

    }

})

gRust.RegisterItem(Item)



--

-- Building Plan

--



Item = gRust.ItemRegister("building.planner")

Item:SetName("Building Plan")

Item:SetDescription("The Building Plan is used to create weak twig structures at the cost of a nominal amount of wood. These twigs may be upgraded with a Hammer if the player has the resources to do so. Players may not build in zones in which there is a tool cupboard that they are not authorized on. Additionally, players may not build in certain areas of the map (such as near a radtown). Otherwise, players may build anywhere of their choosing.")

Item:SetCategory("Construction")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/building_plan.png")

Item:SetWeapon("rust_buildingplan")

Item:SetDurability(false)

Item:SetCraft({

    {

        item = "wood",

        amount = 20,

    },

})

gRust.RegisterItem(Item)



--

-- Hammer

--



Item = gRust.ItemRegister("hammer")

Item:SetName("Hammer")

Item:SetDescription("A tool used for rotating, repairing, and upgrading parts of structures. It can also be used to pick up certain deployable items.")

Item:SetCategory("Construction")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/hammer.png")

Item:SetWeapon("rust_hammer")

Item:SetDurability(false)

Item:SetModel("models/weapons/darky_m/rust/w_hammer.mdl")

Item:SetCraft({

    {

        item = "wood",

        amount = 200,

    },

})

gRust.RegisterItem(Item)



--

-- Hatchet

--



Item = gRust.ItemRegister("hatchet")

Item:SetName("Hatchet")

Item:SetDescription("An improved gathering rate is offset by a significantly longer gather speed, though it is nonetheless considered far superior to its stone counterpart. It is as efficient as the salvaged ice pick but just a bit slower.")

Item:SetCategory("Tools")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/hatchet.png")

Item:SetWeapon("rust_hatchet")

Item:SetBlueprint(125)

Item:SetTier(1)

Item:SetCraft({

    {

        item = "wood",

        amount = 200,

    },

    {

        item = "metal.fragments",

        amount = 100

    }

})

gRust.RegisterItem(Item)



--

-- Pickaxe

--



Item = gRust.ItemRegister("pickaxe")

Item:SetName("Pickaxe")

Item:SetDescription("This tool is a must-have for any gRust player. It is the most efficient tool when gathering wood and harvesting animals. Relatively cheap and durable, this tool should be what you aim for in the early stages of the game.")

Item:SetCategory("Tools")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/pickaxe.png")

Item:SetWeapon("rust_pickaxe")

Item:SetTier(1)

Item:SetBlueprint(125)

Item:SetCraft({

    {

        item = "wood",

        amount = 200,

    },

    {

        item = "metal.fragments",

        amount = 100

    }

})

gRust.RegisterItem(Item)



--

-- Jackhammer

--



Item = gRust.ItemRegister("jackhammer")

Item:SetName("Jackhammer")

Item:SetCategory("Tools")

Item:SetStack(1)

Item:SetIcon("materials/items/tools/jackhammer.png")

Item:SetWeapon("rust_jackhammer")

gRust.RegisterItem(Item)



--

-- Green Keycard

--



Item = gRust.ItemRegister("keycard_green")

Item:SetName("Green Keycard")

Item:SetDescription("The Green Keycard is a required object used to open doors with a glowing green keycard lock.")

Item:SetCategory("Tools")

Item:SetStack(1)

Item:SetIcon("materials/items/keycards/green_keycard.png")

Item:SetWeapon("rust_card")

gRust.RegisterItem(Item)

