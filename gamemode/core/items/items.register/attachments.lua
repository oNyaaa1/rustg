local Item



--

-- Holo Sight

--



Item = gRust.ItemRegister("weapon.mod.holosight")

Item:SetName("Holosight")

Item:SetDescription("The Holosight is a craftable alternative to standard weapon iron sights. Its reticle is a bright red holographic bullseye which also glows in the dark, making it the best scope for night-time combat. Thanks to its slight magnification, it can provide a greater degree of accuracy to any ranged weapon without sacrificing recoil control or close-quarter capabilities. It's especially useful if barrel attachments obscure the weapon's original sights, such as the Silencer.")

Item:SetCategory("Attachments")

Item:SetStack(1)

Item:SetIcon("materials/items/attachments/holosight.png")

Item:SetTier(2)

Item:SetBlueprint(125)

Item:SetCraft({

    {

        item = "hq_metal",

        amount = 12

    },

    {

        item = "tech_trash",

        amount = 1

    }

})

Item.Attach = "scope"

gRust.RegisterItem(Item)



--

-- Silencer

--



Item = gRust.ItemRegister("weapon.mod.silencer")

Item:SetName("Silencer")

Item:SetDescription("The Silencer is a barrel attachment known to reduce gunfire sounds. It also removes the muzzle flash, giving you a good advantage during night without being spotted. It is quite useful against unaware enemies, and can allow you to get in extra hits before being spotted. Although the disadvantages can make short range battles go wrong. It is a good option for Bolt Action Rifles and L96s as the Silencer completely hides the bullet tracers, making the enemies confused where it came from, though it will reduce the velocity of the gun, meaning that you will need to aim a bit higher than usual to hit your opponent.")

Item:SetCategory("Attachments")

Item:SetStack(1)

Item:SetIcon("materials/items/attachments/silencer.png")

Item:SetTier(1)

Item:SetBlueprint(75)

Item:SetCraft({

    {

        item = "hq_metal",

        amount = 5

    }

})

Item.Attach = "muzzle"

gRust.RegisterItem(Item)



--

-- Muzzle Break

--



Item = gRust.ItemRegister("weapon.mod.muzzlebrake")

Item:SetName("Muzzle Break")

Item:SetDescription("The Muzzle Brake is a barrel attachment used to reduce recoil with the cost of weapon damage. It is very effective for recoils that is hard to control, like the Assault Rifle. However, the Muzzle Brake will drastically decrease the velocity of the bullets, giving you a disadvantage for long range battles. It is recommended with full-auto weapons or semi-auto weapons.")

Item:SetCategory("Attachments")

Item:SetStack(1)

Item:SetIcon("materials/items/attachments/muzzle_break.png")

Item:SetTier(2)

Item:SetBlueprint(125)

Item:SetCraft({

    {

        item = "hq_metal",

        amount = 8

    }

})

Item.Attach = "muzzle"

gRust.RegisterItem(Item)



--

-- 8x Scope

--



Item = gRust.ItemRegister("weapon.mod.8x.scope")

Item:SetName("8x Zoom Scope")

Item:SetDescription("The 8x Zoom Scope is a hand-crafted telescopic sight. Its reticle is simply a thin cross. Its magnification allows for greater precision over long ranges and extending most weapon's range, but is not ideal for close quarter engagements.")

Item:SetCategory("Attachments")

Item:SetStack(1)

Item:SetIcon("materials/items/attachments/8xscope.png")

Item:SetTier(3)

Item:SetBlueprint(125)

Item:SetCraft({

    {

        item = "hq_metal",

        amount = 8

    }

})

Item.Attach = "scope"

gRust.RegisterItem(Item)



--

-- 16x Scope

--



Item = gRust.ItemRegister("weapon.mod.16x.scope")

Item:SetName("16x Zoom Scope")

Item:SetDescription("The 16x Zoom Scope is a military-grade telescopic sight. Its reticle is a thin cross with bullet-drop guides. Its extreme magnification allows for precise fire over extreme distances, but its narrow field of view makes it impractical for any close quarter engagements or full-auto fire. As it's susceptible to shaking, consider using a Weapon Lasersight or Tactical Gloves in addition to this scope.")

Item:SetCategory("Attachments")

Item:SetStack(1)

Item:SetIcon("materials/items/attachments/16xscope.png")

Item.Attach = "scope"

gRust.RegisterItem(Item)