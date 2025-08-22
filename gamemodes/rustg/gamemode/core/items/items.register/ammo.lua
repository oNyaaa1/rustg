local Item
--
-- Pistol Ammo
--
Item = gRust.ItemRegister("ammo.pistol")
Item:SetName("Pistol Ammo")
Item:SetDescription("Standard ammunition for pistols and submachine guns.")
Item:SetCategory("Ammo")
Item:SetStack(128)
Item:SetIcon("materials/items/ammo/pistol_ammo.png")
Item:SetTier(1)
Item:SetBlueprint(75)
Item:SetCraftTime(3)
Item:SetCraftAmount(4)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 10
    },
    {
        item = "gunpowder",
        amount = 5
    }
})

gRust.RegisterItem(Item)
--
-- Rifle Ammo
--
Item = gRust.ItemRegister("ammo.rifle")
Item:SetName("Rifle Ammo")
Item:SetDescription("Standard high powered ammunition, used by any rifle in the game currently. Offers superior damage, range, accuracy, damage drop off and air resistance from the Pistol Bullet.")
Item:SetCategory("Ammo")
Item:SetStack(128)
Item:SetIcon("materials/items/ammo/rifle_ammo.png")
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetCraftTime(3)
Item:SetCraftAmount(3)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 10
    },
    {
        item = "gunpowder",
        amount = 5
    }
})

gRust.RegisterItem(Item)
--
-- Shotgun Ammo
--
Item = gRust.ItemRegister("ammo.shotgun")
Item:SetName("Shotgun Ammo")
Item:SetDescription("The handmade shell is an early-game shotgun ammunition that fires a spread of 20 low-damage pellets. It's highly damaging in close quarters, but its lethality quickly drops off as range increases. In comparison to 12 gauge buckshot, the handmade shell has significantly more pellets, but less damage overall.")
Item:SetCategory("Ammo")
Item:SetStack(128)
Item:SetIcon("materials/items/ammo/shotgun_ammo.png")
Item:SetTier(2)
Item:SetBlueprint(75)
Item:SetCraftTime(3)
Item:SetCraftAmount(2)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 5
    },
    {
        item = "gunpowder",
        amount = 10
    }
})

gRust.RegisterItem(Item)
--
-- Arrow
--
Item = gRust.ItemRegister("arrow.wooden")
Item:SetName("Arrow")
Item:SetDescription("The Wooden Arrow is one of four ammo types for the crossbow and the bow. It has lower range and velocity than the High Velocity Arrow, but it does more damage compared to it.")
Item:SetCategory("Ammo")
Item:SetStack(64)
Item:SetIcon("materials/items/ammo/arrow.png")
Item:SetCraftTime(3)
Item:SetCraftAmount(2)
Item:SetCraft({
    {
        item = "wood",
        amount = 25
    },
    {
        item = "stone",
        amount = 10
    }
})

gRust.RegisterItem(Item)
--
-- Nailgun Nails
--
Item = gRust.ItemRegister("ammo.nailgun.nails")
Item:SetName("Nailgun Nails")
Item:SetDescription("Early game cheap and easy to acquire ammo for the Nailgun. Has a unique trajectory and velocity that is worse than regular arrows shot from a Hunting Bow, thus giving it a really small effective range. Work best up close and not beyond 10 meters.")
Item:SetCategory("Ammo")
Item:SetStack(64)
Item:SetIcon("materials/items/ammo/nailgun_nails.png")
Item:SetCraftTime(3)
Item:SetCraftAmount(5)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 8
    }
})

gRust.RegisterItem(Item)
--
-- Handmade Shells
--
Item = gRust.ItemRegister("ammo.handmade.shell")
Item:SetName("Handmade Shells")
Item:SetDescription("The handmade shell is an early-game shotgun ammunition that fires a spread of 20 low-damage pellets. It's highly damaging in close quarters, but its lethality quickly drops off as range increases. In comparison to 12 gauge buckshot, the handmade shell has significantly more pellets, but less damage overall.")
Item:SetCategory("Ammo")
Item:SetStack(64)
Item:SetIcon("materials/items/ammo/handmade_shell.png")
Item:SetCraftTime(3)
Item:SetCraftAmount(2)
Item:SetCraft({
    {
        item = "stone",
        amount = 5
    },
    {
        item = "gunpowder",
        amount = 5
    }
})

gRust.RegisterItem(Item)
--
-- Rocket
--
Item = gRust.ItemRegister("ammo.rocket.basic")
Item:SetName("Rocket")
Item:SetDescription("In Rust, rockets are the ammunition for rocket launchers, rockets will cause splash damage that can hit up to 4 walls at once. This type of ammunition is particularly effective against buildings. In terms of trajectory, rockets are launched forward with a considerable speed upon firing. However, the trajectory eventually falls off due to the in-game gravity effect. Rockets are currently one of the best tools for raiding and destroying buildings. Rockets are also deadly against players due to its high damage and range of splash damage.")
Item:SetCategory("Ammo")
Item:SetStack(64)
Item:SetIcon("materials/items/ammo/rocket.png")
Item:SetCraftTime(3)
Item:SetCraftAmount(2)
Item:SetBlueprint(125)
Item:SetTier(3)
Item:SetCraft({
    {
        item = "metal_pipe",
        amount = 2
    },
    {
        item = "gunpowder",
        amount = 150
    },
    {
        item = "explosives",
        amount = 10
    }
})

gRust.RegisterItem(Item)