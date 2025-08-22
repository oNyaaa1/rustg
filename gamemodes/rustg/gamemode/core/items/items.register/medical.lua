local Item



--

-- Bandages

--



Item = gRust.ItemRegister("bandage")

Item:SetName("Bandages")

Item:SetDescription("Bandages are crafted medical supplies that stop bleeding and heal a small amount of health. It is common to chain-use bandages when the player has no access to other medical supplies, as hemp can be picked while running around the map and used for an easy health boost.")

Item:SetCategory("Medical")

Item:SetStack(3)

Item:SetIcon("materials/items/medical/bandages.png")

Item:SetWeapon("rust_bandages")

Item:SetCraftTime(3)

Item:SetCraft({

    {

        item = "cloth",

        amount = 5

    },

})

gRust.RegisterItem(Item)



--

-- Medical Syringe

--



Item = gRust.ItemRegister("syringe.medical")

Item:SetName("Medical Syringe")

Item:SetDescription("The Medical Syringe is the best medical supply used for combat situations. It instant heals you a portion of your health and slowly heals the rest. It also reduces your radiation poisoning which is very useful while navigating the red puzzle building with high levels of radiation. As of July 2021, the Medical Syringe can be used to revive people in Wounded state. It revives faster than holding E on the wounded player, however this gives you a disadvantage to look around and spot enemies as you will cancel the heal animation.")

Item:SetCategory("Medical")

Item:SetStack(3)


Item:SetIcon("materials/items/medical/syringe.png")

Item:SetWeapon("rust_medicalsyringe")

Item:SetBlueprint(75)

Item:SetCraft({

    {

        item = "cloth",

        amount = 15

    },

    {

        item = "metal.fragments",

        amount = 10

    },

    {

        item = "lowgradefuel",

        amount = 10

    }

})

gRust.RegisterItem(Item)