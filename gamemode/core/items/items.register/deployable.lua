local Item
--
-- Recycler
--
Item = gRust.ItemRegister("recycler")
Item:SetName("Recycler")
Item:SetStack(10)
Item:SetEntity("rust_recycler")
Item:SetIcon("materials/items/deployable/recycler.png")
gRust.RegisterItem(Item)
--
-- Large Wood Box
--
Item = gRust.ItemRegister("box.wooden.large")
Item:SetName("Large Wood Box")
Item:SetDescription("A Large Wood Box is your most popular and conventional way to store your belongings. Each box has enough storage for 48x separate items/stacks of items. They can have both locks and code locks placed on them to keep unwanted players at bay for a brief period. If destroyed, they will destroy a portion of their contents as well. Boxes can be placed on shelves to save space.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_largewoodbox")
Item:SetIcon("materials/items/deployable/large_wood_box.png")
Item:SetCraft({
    {
        item = "wood",
        amount = 250,
    },
    {
        item = "metal.fragments",
        amount = 50,
    }
})

gRust.RegisterItem(Item)
--
-- Wood Box
--
Item = gRust.ItemRegister("box.wooden")
Item:SetName("Wood Box")
Item:SetDescription("A Wood Storage Box is a small box with the ability to store a maximum of 18 separate items or stacks of items inside of it. These can often times be used as a more space efficient way to store your items than the Large Wood Box, but can prove difficult to keep sorted as not all of your items are in one container. They can have both locks and codelocks placed on them to keep unwanted newmans at bay for a brief period. If destroyed, they will destroy a portion of their contents as well. Boxes can be placed on shelves to save space.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_woodbox")
Item:SetIcon("materials/items/deployable/wood_box.png")
Item:SetCraft({
    {
        item = "wood",
        amount = 100
    }
})

gRust.RegisterItem(Item)
--
-- Wooden Door
--
Item = gRust.ItemRegister("door.hinged.wood")
Item:SetName("Wooden Door")
Item:SetDescription("The Wooden Door is an early game building item that is made from wood and cheap to produce. Being the cheapest of all the doors, it is often used alongside a Lock to quickly secure a base. Its vulnerability to fire and weak explosive resistance makes the door a temporary solution to securing your base. Due to its flaws it should quickly be upgraded to a higher tier door such as Sheet Metal. The Wooden Door can take two kinds of locks the basic Lock and the Code Lock. To pick up the door, remove any locks, hold down the E (USE) key and select 'Pickup'. Note: There is currently a bug where a door sometimes can not be picked up until any type of Lock has been placed and removed.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_doorwood")
Item:SetIcon("materials/items/deployable/wooden_door.png")
Item:SetCraft({
    {
        item = "wood",
        amount = 300,
    }
})

gRust.RegisterItem(Item)
--
-- Sheet Metal Door
--
Item = gRust.ItemRegister("door.hinged.metal")
Item:SetName("Sheet Metal Door")
Item:SetDescription("The Sheet Metal Door is the most common door found on bases due to its resistances to melee weapons and fire but relatively cheap cost to craft. Regardless, it is still relatively weak to explosives compared to its expensive indirect upgrade, the 'Armoured Door'.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_doormetal")
Item:SetIcon("materials/items/deployable/metal_door.png")
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 150,
    }
})

gRust.RegisterItem(Item)
--
-- Armored Door
--
Item = gRust.ItemRegister("door.hinged.toptier")
Item:SetName("Armored Door")
Item:SetDescription("The Armored Door is the highest tier door and is the best option for base defense. If the door is put on a weaker door frame, the door frame will be targeted instead of the door itself. The door has a working hatch which allows you to see outside of the door and can be shot through in both directions.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_doorarmored")
Item:SetIcon("materials/items/deployable/armored_door.png")
Item:SetTier(3)
Item:SetBlueprint(500)
Item:SetCraft({
    {
        item = "metal.refined",
        amount = 20,
    },
    {
        item = "gears",
        amount = 5,
    }
})

gRust.RegisterItem(Item)
--
-- Key Lock
--
Item = gRust.ItemRegister("lock.key")
Item:SetName("Key Lock")
Item:SetDescription("Key locks are used to lock doors, hatches, storage boxes and tool cupboards. Once placed it should be locked by activating it and selecting \"Lock.\" For players other than the one who placed it to unlock it, they must have a key created by by the originating player. To remove a lock, unlock it and pick it up.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_keylock")
Item:SetIcon("materials/items/deployable/keylock.png")
Item:SetCraft({
    {
        item = "wood",
        amount = 75,
    }
})

gRust.RegisterItem(Item)
--
-- Keypad
--
Item = gRust.ItemRegister("lock.code")
Item:SetName("Code Lock")
Item:SetDescription("The code lock is used to lock doors, hatches, and storage crates. Players may set a new four-digit PIN if the lock is unlocked. Once locked, an LED on the keypad will change to red, indicating its status. Other players may attempt to gain access to a locked item by typing in a PIN in the keypad. If they are correct, a short beep will emit from the lock, and the player will subsequently have permanent access to the locked item (assuming the code isn't changed). If the player guesses incorrectly, a failure beep will play alongside an electric arc animation on the keypad, and the player will take increasing increments of damage until they wait long enough or die. Guest codes may be set on unlocked locks (make sure it's locked after setting the code!), which allows other players access to the locked item without the ability to unlock, remove, or change the code. Unlocked Code Locks may be removed or have a new password set by any player.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_keypad")
Item:SetIcon("materials/items/deployable/keypad.png")
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 100,
    }
})

gRust.RegisterItem(Item)
--
-- Furnace
--
Item = gRust.ItemRegister("furnace")
Item:SetName("Furnace")
Item:SetDescription("The furnace is the cheapest item for smelting metal and sulfur ore.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_furnace")
Item:SetIcon("materials/items/deployable/furnace.png")
Item:SetCraft({
    {
        item = "stone",
        amount = 200
    },
    {
        item = "wood",
        amount = 100
    },
    {
        item = "lowgradefuel",
        amount = 50
    }
})

gRust.RegisterItem(Item)
--
-- Tool Cupboard
--
Item = gRust.ItemRegister("cupboard.tool")
Item:SetName("Tool Cupboard")
Item:SetDescription("The Tool Cupboard is essential for any base because it prevents people who are not authorized from upgrading building blocks and placing and picking up deployables within a 25-meter radius (around 9 foundation blocks) from the cupboard. If you press 'E' on the cupboard you can authorize yourself so you are able to build in this area. If you hold 'E' on the cupboard you can clear the list of players authorized including yourself. Any player authorized from the cupboard will not be targeted by any flame turrets or shotgun traps within the cupboard's radius. Tool Cupboards can be locked with Key and Code Locks in order to disallow players from authorizing themselves without a passcode.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_toolcupboard")
Item:SetIcon("materials/items/deployable/tool_cupboard.png")
Item:SetCraft({
    {
        item = "wood",
        amount = 1000,
    }
})

gRust.RegisterItem(Item)
--
-- Sleeping Bag
--
Item = gRust.ItemRegister("sleepingbag")
Item:SetName("Sleeping Bag")
Item:SetDescription("A sleeping bag is a critical part of playing gRust. When placed, this item offers a respawn point directly on top of it. It can be named, given to a friend, or even be picked up by it's owner by using the interact key on it. After death, a menu will appear displaying your sleeping bags and beds by name and you can select whichever one you need. After being used, or being placed, there is a 5-minute cooldown period before being able to spawn on it. When possible, you should upgrade your base's respawn point to a bed, which has a drastically shorter cooldown timer.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_sleepingbag")
Item:SetIcon("materials/items/deployable/sleeping_bag.png")
Item:SetCraft({
    {
        item = "cloth",
        amount = 30,
    }
})

gRust.RegisterItem(Item)
--
-- Garage Door
--
Item = gRust.ItemRegister("wall.frame.garagedoor")
Item:SetName("Garage Door")
Item:SetDescription("The garage door is a form of lockable door which slides upward from the bottom when opened. It fits within a wall frame, like the double door, but opens much slower than any other type of door. It is, however, more durable than the sheet metal double door - making it an effective loot room door.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_garagedoor")
Item:SetIcon("materials/items/deployable/garage_door.png")
Item:SetTier(2)
Item:SetBlueprint(75)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 300
    },
    {
        item = "gears",
        amount = 2
    }
})

gRust.RegisterItem(Item)
--
-- Research Table
--
Item = gRust.ItemRegister("research.table")
Item:SetName("Research Table")
Item:SetDescription("The research table is a craftable deployable item that is used for researching obtained items for a price. This can be done by pressing the 'E' key, inserting your item and the required scrap metal to acquire a blueprint for use at the appropriate tier of workbench. (note: blueprint is guaranteed unlike previous versions of rust).")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_researchtable")
Item:SetIcon("materials/items/deployable/research_table.png")
Item:SetTier(1)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 200
    },
    {
        item = "scrap",
        amount = 20
    }
})

gRust.RegisterItem(Item)
--
-- Repair Bench
--
Item = gRust.ItemRegister("box.repair.bench")
Item:SetName("Repair Bench")
Item:SetDescription("Repair benches offer a cost-effective way to repair once-broken items back to a usable state. Each repair costs half of the original cost of a new version of the item, and does not use components. Every time an item is repaired, it loses some of it's maximum durability. This is represented with a red portion on the durability bar of the item. The Repair Bench can currently change the skin of any item you have (granted it HAS varying skins) to any skin that you own in your steam inventory.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_repairbench")
Item:SetIcon("materials/items/deployable/repair_bench.png")
Item:SetTier(1)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 125
    }
})

gRust.RegisterItem(Item)
--
-- Workbench Level 1
--
Item = gRust.ItemRegister("workbench1")
Item:SetName("Workbench Level 1")
Item:SetDescription("The tier 1 Work Bench acts as a gateway towards crafting early game gear, including salvaged weapons and armor. You can find them at the Scientist Outpost and the Bandit Camp monuments.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_tier1")
Item:SetIcon("materials/items/deployable/tier1.png")
Item:SetCraft({
    {
        item = "wood",
        amount = 500,
    },
    {
        item = "metal.fragments",
        amount = 100
    },
    {
        item = "scrap",
        amount = 50
    }
})

gRust.RegisterItem(Item)
--
-- Workbench Level 2
--
Item = gRust.ItemRegister("workbench2")
Item:SetName("Workbench Level 2")
Item:SetDescription("The tier 2 Work bench allows you to craft mid-game weapons, armor, and building parts while in the vicinity of the work bench. Uses the same amount of space like the Tier One Workbench")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_tier2")
Item:SetIcon("materials/items/deployable/tier2.png")
Item:SetTier(1)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 500
    },
    {
        item = "metal.refined",
        amount = 20,
    },
    {
        item = "scrap",
        amount = 500
    }
})

gRust.RegisterItem(Item)
--
-- Workbench Level 3
--
Item = gRust.ItemRegister("workbench3")
Item:SetName("Workbench Level 3")
Item:SetDescription("The tier 3 Work Bench allows you to craft the highest tier of weapons, armor, and defenses.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_tier3")
Item:SetIcon("materials/items/deployable/tier3.png")
Item:SetTier(2)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 1000
    },
    {
        item = "metal.refined",
        amount = 100,
    },
    {
        item = "scrap",
        amount = 1250
    }
})

gRust.RegisterItem(Item)
--
-- Hemp Seed
--
Item = gRust.ItemRegister("seed.hemp")
Item:SetName("Hemp Seed")
Item:SetDescription("Hemp seeds can be found when picking wild Hemp. These seeds can be planted in the ground and grown to collect additional cloth.\n\n\nPlanting these seeds in a planter, and then watering them with large quantities of water yields significantly more cloth and faster growth.")
Item:SetCategory("Items")
Item:SetStack(50)
Item:SetEntity("rust_hemp")
Item:SetIcon("materials/items/deployable/hemp_seed.png")
gRust.RegisterItem(Item)
--[[


--

-- Concrete Barricade

--



Item = gRust.ItemRegister("barricade.concrete")

Item:SetName("Concrete Barricade")

Item:SetCategory("Items")

Item:SetStack(1)

Item:SetEntity("rust_concretebarricade")

Item:SetIcon("materials/items/deployable/concrete_barricade.png")

Item:SetTier(2)

Item:SetBlueprint(125)

Item:SetCraft({

    {

        item = "stone",

        amount = 200

    }

})

gRust.RegisterItem(Item)



--

-- Stone Barricade

--



Item = gRust.ItemRegister("barricade.stone")

Item:SetName("Stone Barricade")

Item:SetCategory("Items")

Item:SetStack(10)

Item:SetEntity("rust_stonebarricade")

Item:SetIcon("materials/items/deployable/stone_barricade.png")

Item:SetBlueprint(125)

Item:SetCraft({

    {

        item = "stone",

        amount = 100

    }

})

gRust.RegisterItem(Item)
]]
--
-- Metal Shop Front
--
Item = gRust.ItemRegister("wall.frame.shopfront.metal")
Item:SetName("Metal Shop Front")
Item:SetDescription("The metal shop front is quite useful for trading. The vendor can stand safely behind it without worrying about getting shot, as the glass is bulletproof. When the player on the inside and the player on the outside have put in items to make the desired trade, they both have to accept the deal for the items to be transferred.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_shopfront")
Item:SetIcon("materials/items/deployable/metal_shop_front.png")
Item:SetTier(1)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 250
    }
})

gRust.RegisterItem(Item)
--
-- Wooden Window Bars
--
Item = gRust.ItemRegister("wall.window.bars.wood")
Item:SetName("Wooden Window Bars")
Item:SetDescription("The Wooden Window Bars are the lowest-tier window bars, provide little cover and deny entrance through windows. They are weaker over its reinforced and metal counterparts. Due to its weakness to fire damage and low health higher tier window bars are recommended.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_woodbars")
Item:SetIcon("materials/items/deployable/wood_window_bars.png")
Item:SetTier(1)
Item:SetCraft({
    {
        item = "wood",
        amount = 200
    }
})

gRust.RegisterItem(Item)
--
-- Reinforced Glass Window
--
Item = gRust.ItemRegister("wall.window.glass.reinforced")
Item:SetName("Reinforced Glass Window")
Item:SetDescription("The Reinforced Glass Window is now the highest-tier glass window. It replaced the Strengthened glass Window's spot for the highest HP window, and you are now unable to shoot through it. This makes it vital for loot rooms and external TCs. Not very useful for information gathering, as the viewing area is quite small and obstructed by thick bars.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_reinforcedwindow")
Item:SetIcon("materials/items/deployable/reinforced_glass_window.png")
Item:SetTier(3)
Item:SetBlueprint(125)
Item:SetCraft({
    {
        item = "metal.refined",
        amount = 4
    }
})

gRust.RegisterItem(Item)
--
-- Table
--
Item = gRust.ItemRegister("table")
Item:SetName("Table")
Item:SetDescription("Every home needs a table. A decorative item which provides comfort when in close proximity.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_table")
Item:SetIcon("materials/items/deployable/table.png")
Item:SetBlueprint(75)
Item:SetCraft({
    {
        item = "wood",
        amount = 300
    }
})

gRust.RegisterItem(Item)
--
-- Shelves
--
Item = gRust.ItemRegister("shelves")
Item:SetName("Shelves")
Item:SetDescription("Shelves for item stacking")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_shelves")
Item:SetIcon("materials/items/deployable/shelves.png")
Item:SetBlueprint(75)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 400
    }
})

gRust.RegisterItem(Item)
--
-- Vending Machine
--
Item = gRust.ItemRegister("vending.machine")
Item:SetName("Vending Machine")
Item:SetDescription("The Vending Machine provides a safe way to make indirect trade with other players.")
Item:SetCategory("Items")
Item:SetStack(1)
Item:SetEntity("rust_vendingmachine")
Item:SetIcon("materials/items/deployable/vending_machine.png")
Item:SetCraft({
    {
        item = "gears",
        amount = 50,
    }
})

gRust.RegisterItem(Item)