local Item
--
-- Beancan Grenade
--
Item = gRust.ItemRegister("grenade.beancan")
Item:SetName("Beancan Grenade")
Item:SetDescription("The Beancan Grenade is an early-game tool. They're used to craft Satchel Charges, but can be used by themselves in raiding. The Beancan Grenade has a random detonation period and can kill a player if it's within the range. The Beancan Grenade has a 15% chance to be a dud. However, Beancan Grenades have a 50% chance to explode when you attempt to pick them up again after a dud.")
Item:SetCategory("Explosives")
Item:SetStack(10)
Item:SetIcon("materials/items/throwable/beancan.png")
Item:SetWeapon("rust_beancan")
Item:SetDurability(false)
Item:SetClip(false)
Item:SetTier(1)
Item:SetBlueprint(75)
Item:SetCraft({
    {
        item = "gunpowder",
        amount = 60
    },
    {
        item = "metal.fragments",
        amount = 20
    }
})

gRust.RegisterItem(Item)
--
-- Supply Signal
--
Item = gRust.ItemRegister("supply.signal")
Item:SetName("Supply Signal")
Item:SetDescription("A purple smoke grenade that calls in an airdrop somewhere in a small radius around it. Can be found rarely in Military and Elite Crates.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/throwable/supply_signal.png")
Item:SetWeapon("rust_supplysignal")
Item:SetDurability(false)
Item:SetClip(false)
gRust.RegisterItem(Item)
--
-- Satchel Charge
--
Item = gRust.ItemRegister("explosive.satchel")
Item:SetName("Satchel Charge")
Item:SetDescription("The Satchel Charge is a midgame raiding tool that can be used to destroy player-made buildings for the purpose of entering and looting another player's base. The Satchel charge becomes armed when placed, has a random time until detonation, and has a small chance to malfunction, requiring the user to pick up and rearm the Charge. Note that sometimes the charge will re-ignite when the dud is picked up, going off with a very short fuse!")
Item:SetCategory("Explosives")
Item:SetStack(10)
Item:SetIcon("materials/items/throwable/satchel.png")
Item:SetWeapon("rust_satchel")
Item:SetDurability(false)
Item:SetClip(false)
Item:SetTier(1)
Item:SetBlueprint(125)
Item:SetCraft({
    {
        item = "grenade.beancan",
        amount = 4
    },
    {
        item = "rope",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- Timed Explosive CHarge
--
Item = gRust.ItemRegister("explosive.timed")
Item:SetName("Timed Explosive Charge")
Item:SetDescription("The Timed Explosive Charge, mostly knowns as C4, is an item often used when raiding other players. Once thrown, the charge will stick to walls, floors, doors and deployable items. Once attached to a target, the timed explosives will automatically detonate in a dependable and quick manner (in comparison to it's unreliable counterpart, the Satchel Charge). However, it does damage only to the structure it's attached to. If attached to a door, for example, it would destroy it without damaging the door frame or nearby walls. This item deals the most damage out of all explosive devices, and is the most ideal/useful for evicting your neighbors. It's important to protect this item from your enemies, as it can prove fatal once it's in the wrong hands.")
Item:SetCategory("Explosives")
Item:SetStack(1000)
Item:SetIcon("materials/items/throwable/c4.png")
Item:SetWeapon("rust_c4")
Item:SetDurability(false)
Item:SetClip(false)
Item:SetTier(3)
Item:SetBlueprint(500)
Item:SetCraft({
    {
        item = "explosives",
        amount = 20
    },
    {
        item = "cloth",
        amount = 5
    },
    {
        item = "techparts",
        amount = 2
    }
})

gRust.RegisterItem(Item)