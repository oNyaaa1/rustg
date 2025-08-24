local Item
--
-- Assault Rifle
--
Item = gRust.ItemRegister("rifle.ak")
Item:SetName("Assault Rifle")
Item:SetDescription("The Assault Rifle is an accurate, powerful, and fully automatic rifle that fires 5.56 rifle rounds. It has a moderate rate of fire which allows for proficiency at close to medium range. Strong recoil makes it more difficult to fire in full-auto at long range, but experienced users may be able to control it more effectively. The Assault Rifle is generally used as an end-game multipurpose weapon, able to take fights at any range.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/assault_rifle.png")
Item:SetDescription("A slow, but powerful melee weapon. This is decent for PVPing but it's main use comes at farming components. The salvaged cleaver is one of the few melee weapons capable of destroying any barrel in a single hit. It is also fairly cheap, this makes it an ideal weapon to use when farming large amounts of barrels, especially if they are spread out.")
Item:SetWeapon("rust_ak47u")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(3)
Item:SetBlueprint(500)
Item:SetAttachments(4)
Item:SetModel("models/weapons/darky_m/rust/w_ak47u.mdl")
Item:SetCraft({
    {
        item = "wood",
        amount = 200
    },
    {
        item = "metal.refined",
        amount = 50
    },
    {
        item = "riflebody",
        amount = 1
    },
    {
        item = "metalspring",
        amount = 4
    }
})

gRust.RegisterItem(Item)
--
-- M249
--
Item = gRust.ItemRegister("lmg.m249")
Item:SetName("M249")
Item:SetDescription("The M249 Light Machine Gun can only be found in Helicopter Crates and Bradley Crates. It has a magazine capacity of 100 5.56 bullets, the largest in the game. It does more damage than the Assault Rifle and has a slightly faster rate of fire while being way easier to control recoil-wise, allowing for very accurate and deadly bursts in long-range when coupled with a Holographic sight or an 8x scope.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/m249.png")
Item:SetWeapon("rust_m249")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetAttachments(4)
Item:SetModel("models/weapons/darky_m/rust/w_m249.mdl")
gRust.RegisterItem(Item)
--
-- Bolt Action Rifle
--
Item = gRust.ItemRegister("rifle.bolt")
Item:SetName("Bolt Action Rifle")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/bolt_rifle.png")
Item:SetWeapon("rust_boltrifle")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(3)
Item:SetBlueprint(500)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "metal.refined",
        amount = 20
    },
    {
        item = "riflebody",
        amount = 1
    },
    {
        item = "metalpipe",
        amount = 3
    },
    {
        item = "metalspring",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- Bolt Action Rifle
--
Item = gRust.ItemRegister("rifle.l96")
Item:SetName("L96 Rifle")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/l96.png")
Item:SetWeapon("rust_l96")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetAttachments(4)
gRust.RegisterItem(Item)
--
-- Pump Shotgun
--
Item = gRust.ItemRegister("shotgun.pump")
Item:SetName("Pump Action Shotgun")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/pump_shotgun.png")
Item:SetWeapon("rust_pump")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetCraft({
    {
        item = "metal.refined",
        amount = 20
    },
    {
        item = "riflebody",
        amount = 1
    },
    {
        item = "metalpipe",
        amount = 3
    },
    {
        item = "metalspring",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- LR300
--
Item = gRust.ItemRegister("rifle.lr300")
Item:SetName("LR300")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/lr300.png")
Item:SetWeapon("rust_lr300")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetAttachments(4)
gRust.RegisterItem(Item)
--
-- M92
--
Item = gRust.ItemRegister("pistol.m92")
Item:SetName("M92 Pistol")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/m92.png")
Item:SetWeapon("rust_m92")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetAttachments(4)
gRust.RegisterItem(Item)
--
-- SPAS-12
--
Item = gRust.ItemRegister("shotgun.spas12")
Item:SetName("SPAS-12 Shotgun")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/spas12.png")
Item:SetWeapon("rust_spas12")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetAttachments(4)
gRust.RegisterItem(Item)
--
-- M249
--
Item = gRust.ItemRegister("lmg.m249")
Item:SetName("M249")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/m249.png")
Item:SetWeapon("rust_m249")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetAttachments(4)
gRust.RegisterItem(Item)
--
-- Custom SMG
--
Item = gRust.ItemRegister("smg.2")
Item:SetName("Custom SMG")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/custom_smg.png")
Item:SetWeapon("rust_customsmg")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "metal.refined",
        amount = 8
    },
    {
        item = "smgbody",
        amount = 1
    },
    {
        item = "metalspring",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- Thompson
--
Item = gRust.ItemRegister("smg.thompson")
Item:SetName("Thompson")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/thompson.png")
Item:SetWeapon("rust_thompson")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "metal.refined",
        amount = 10
    },
    {
        item = "wood",
        amount = 100
    },
    {
        item = "smgbody",
        amount = 1
    },
    {
        item = "metalspring",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- MP5A4
--
Item = gRust.ItemRegister("smg.mp5")
Item:SetName("MP5A4")
Item:SetDescription("The MP5A4 is a craftable, military-grade 30-round submachine gun. Dealing moderate to low damage with low recoil which makes it extremely effective at close range. However, the MP5A4 has one of the widest spreads in the game, limiting its use to short range. Although, like the LR300, this can be countered with a lasersight, making it viable for medium-range combat. The MP5 is currently the only craftable military-grade weapon.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/mp5.png")
Item:SetWeapon("rust_mp5")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "metal.refined",
        amount = 10
    },
    {
        item = "wood",
        amount = 100
    },
    {
        item = "smgbody",
        amount = 1
    },
    {
        item = "metalspring",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- Revolver
--
Item = gRust.ItemRegister("pistol.revolver")
Item:SetName("Revolver")
Item:SetDescription("The Revolver is cheap, prime for early game use. Although inaccurate, the Revolver's quick rate of fire allows it hold its own against players at most stages. Being a revolver, it has a low capacity of just 8 shots, but it's still an upgrade from its 1- and 2- shot alternatives. Taking a Revolver to a fight against opponents with metal armor is quite risky, as such opponents will take many more shots than normal to take out (even more so considering the small capacity). It is best advised to only use the Revolver against opponents with similar armaments or as a sidearm to another weapon.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/revolver.png")
Item:SetWeapon("rust_revolver")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(1)
Item:SetBlueprint(75)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "metalpipe",
        amount = 1
    },
    {
        item = "cloth",
        amount = 75
    },
    {
        item = "metal.fragments",
        amount = 125
    }
})

gRust.RegisterItem(Item)
--
-- Python
--
Item = gRust.ItemRegister("pistol.python")
Item:SetName("Python Revolver")
Item:SetDescription("The Python deals a great amount of damage per shot, but it has only 6 bullets in one magazine. It is pretty useful for shorter - medium distances. If combined with something like a Thompson, or even a Nailgun, the Python is pretty useful.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/python.png")
Item:SetWeapon("rust_python")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "metalpipe",
        amount = 1
    },
    {
        item = "cloth",
        amount = 25
    },
    {
        item = "metal.fragments",
        amount = 125
    }
})

gRust.RegisterItem(Item)
--
-- Semi-Auto Pistol
--
Item = gRust.ItemRegister("pistol.semiauto")
Item:SetName("Semi-Automatic Pistol")
Item:SetDescription("The semi-automatic pistol (commonly referred to as the 'P250' or 'P2') is a fast firing, medium damage weapon that has a moderate bullet velocity and steep damage drop-off. It is an extremely popular weapon due to it's effectiveness at short-medium distances and it's low cost. It can be easily used as a primary weapon or as a compliment to pretty much any other gun.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/sap.png")
Item:SetWeapon("rust_sap")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "semi_auto_body",
        amount = 1
    },
    {
        item = "metal.refined",
        amount = 4
    },
    {
        item = "metalpipe",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- Semi-Automatic Rifle
--
Item = gRust.ItemRegister("rifle.semiauto")
Item:SetName("Semi-Automatic Rifle")
Item:SetDescription("The Semi-Automatic Rifle is a staple of low quality weapons due to its high cost-efficiency. With its medium-tier damage, comparatively low recoil and high accuracy, the Semi-Automatic Rifle is the jack of all trades, but master of none.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/sar.png")
Item:SetWeapon("rust_sar")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(2)
Item:SetBlueprint(125)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "semi_auto_body",
        amount = 1
    },
    {
        item = "metalspring",
        amount = 1
    },
    {
        item = "metal.fragments",
        amount = 450
    },
    {
        item = "metal.refined",
        amount = 4
    }
})

gRust.RegisterItem(Item)
--
-- Double Barrel Shotgun
--
Item = gRust.ItemRegister("shotgun.double")
Item:SetName("Double-Barrel Shotgun")
Item:SetCategory("Weapons")
Item:SetDescription("The Double Barrel Shotgun is a lower tier, close ranged weapon capable of one-hitting enemies within its effective range. It's best used in conjunction with other, longer range guns and against only one or two enemies at a time since it can only shoot two shells before requiring a lengthy reload.")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/dbarrel.png")
Item:SetWeapon("rust_dbarrel")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(1)
Item:SetBlueprint(125)
Item:SetAttachments(4)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 175,
    },
    {
        item = "metalpipe",
        amount = 2,
    }
})

gRust.RegisterItem(Item)
--
-- Combat Knife
--
Item = gRust.ItemRegister("knife.combat")
Item:SetName("Combat Knife")
Item:SetDescription("The best tool for harvesting animal corpses quickly and efficiently. It's also one of the best melee weapons in the game due its fast swing rate and high damage - it can also be swung while sprinting, without slowing down the user.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/combat_knife.png")
Item:SetWeapon("rust_combatknife")
Item:SetDurability(true)
Item:SetTier(1)
Item:SetBlueprint(125)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 25,
    },
    {
        item = "metal.refined",
        amount = 1
    }
})

gRust.RegisterItem(Item)
--
-- Nailgun
--
Item = gRust.ItemRegister("pistol.nailgun")
Item:SetName("Nailgun")
Item:SetDescription("A low powered low range early game weapon using nailgun nails as ammunition. The nailgun is easily accessible, very cheap and makes a good secondary weapon when in early game.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/nailgun.png")
Item:SetWeapon("rust_nailgun")
Item.AmmoType = "ammo.nailgun.nails"
Item:SetDurability(true)
Item:SetClip(true)
Item:SetCraft({
    {
        item = "metal.fragments",
        amount = 75
    },
    {
        item = "scrap",
        amount = 15
    }
})

gRust.RegisterItem(Item)
--
-- Waterpipe Shotgun
--
Item = gRust.ItemRegister("shotgun.waterpipe")
Item:SetName("Waterpipe Shotgun")
Item:SetDescription("The Waterpipe Shotgun is a low-tier gun that deals a decent amount of damage from close range. Can be loaded with the 12 Gauge Slug to deal less damage but shoot further. It is an early game weapon of choice for many and is often paired with a bow.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/waterpipe.png")
Item:SetWeapon("rust_waterpipe")
Item.AmmoType = "ammo.handmade.shell" or "ammo.shotgun"
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(1)
Item:SetBlueprint(75)
Item:SetCraft({
    {
        item = "wood",
        amount = 150
    },
    {
        item = "metal.fragments",
        amount = 75
    }
})

gRust.RegisterItem(Item)
--
-- Eoka Pistol
--
Item = gRust.ItemRegister("pistol.eoka")
Item:SetName("Eoka Pistol")
Item:SetDescription("A very cheap, very ineffective, and very unreliable pistol that fires shells.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/eoka.png")
Item:SetWeapon("rust_eoka")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetCraft({
    {
        item = "wood",
        amount = 75
    },
    {
        item = "metal.fragments",
        amount = 30
    }
})

gRust.RegisterItem(Item)
--
-- Hunting Bow
--
Item = gRust.ItemRegister("bow.hunting")
Item:SetName("Hunting Bow")
Item:SetDescription("An old school weapon for new school fun. Useful for short to medium range combat. Arrows shot have a chance to break when they hit, so be sure to carry more than one arrow. Can use either regular Arrows or High-Velocity Arrows which are able to go farther faster, but do less damage. Best used to hunt animals and other humans.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/bow.png")
Item:SetWeapon("rust_bow")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetCraft({
    {
        item = "wood",
        amount = 200
    },
    {
        item = "cloth",
        amount = 50
    }
})

gRust.RegisterItem(Item)
--
-- Crossbow
--
Item = gRust.ItemRegister("crossbow")
Item:SetName("Crossbow")
Item:SetDescription("The Crossbow is a low-tier weapon that can fire either a high-velocity or regular arrow a decent distance. It is capable of relatively high damage, and is a great option when paired with a Waterpipe Shotgun or Eoka Pistol or Nailgun.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/crossbow.png")
Item:SetWeapon("rust_crossbow")
Item:SetDurability(true)
Item:SetClip(true)
Item:SetTier(1)
Item:SetCraft({
    {
        item = "wood",
        amount = 200
    },
    {
        item = "metal.fragments",
        amount = 75
    },
    {
        item = "rope",
        amount = 2
    }
})

gRust.RegisterItem(Item)
--
-- Wooden Spear
--
Item = gRust.ItemRegister("spear.wooden")
Item:SetName("Wooden Spear")
Item:SetDescription("The Wooden Spear will inflict damage and cause the 'Bleeding' effect on the target. The Wooden Spear is throwable. After being thrown it will become stuck in the place it had hit (in the target). You can pick it up by pressing the 'Use' button (default 'E'). Can be upgraded to Stone Spear.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/wooden_spear.png")
Item:SetWeapon("rust_spear")
Item:SetDurability(true)
Item:SetCraft({
    {
        item = "wood",
        amount = 300
    }
})

gRust.RegisterItem(Item)
--
-- RPG
--
Item = gRust.ItemRegister("rocket.launcher")
Item:SetName("Rocket Launcher")
Item:SetDescription("The Rocket Launcher is a utility weapon which is primarily used for raiding and base defense. It fires a single rocket at a time and must be reloaded between uses. When loaded with regular Rockets, it can be utilized as an end-game raiding tool, capable of damaging multiple building parts at once. If loaded with Incendiary Rockets, the Rocket Launcher may be used as an area denial tool to spread fire to an area to prevent movement through it. Regular rockets or High Velocity Rockets may also be used as an efficient, but expensive, weapon to be used against players, as its high damage usually means an instant kill.")
Item:SetCategory("Weapons")
Item:SetStack(1)
Item:SetIcon("materials/items/weapons/rpg.png")
Item:SetWeapon("rust_rpg")
Item:SetDurability(true)
Item:SetClip(true)
gRust.RegisterItem(Item)