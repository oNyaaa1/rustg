gRust.Testing = true
gRust.InDev = true
--
-- Player Movement
--  
gRust.Config.WalkSpeed = 140
gRust.Config.RunSpeed = 240
gRust.Config.CrouchSpeed = 50
gRust.Config.JumpPower = 190
--
-- Chat
--
gRust.Config.CmdPrefix = "/"
--
-- Farming
--
gRust.Config.EntRespawnTime = 120
gRust.Config.WaterLevel = -62
--
-- Interact
--
gRust.Config.InteractRange = 12500
gRust.Config.MeleeRange = 3000
--
-- Building
--
gRust.Config.TCRadius = 450
gRust.Config.Scale = 63 -- Rust units to gmod units
--
-- Vending Machines
--
gRust.Config.MaxSellOrders = 6
--
-- Chat Messages
--
gRust.Config.ChatMessages = {
    {
        Text = "Want to contribute to the gRust.co project? Consider donating at store.gRust.co in exchange for in-game packages and skins!",
        Time = 315
    },
    {
        Text = "Be sure to join our Discord @ discord.gg/hrzUzMk5pw",
        Time = 425
    },
    {
        Text = "Use the /kits command to access kits",
        Time = 500
    },
}

--
-- Electrical
--
gRust.Config.MaxWires = 5
gRust.Config.MaxWireLength = 10
--
-- Modded
--
gRust.Config.Blueprints = true
gRust.Config.ProcessSpeed = 4 -- Multiplier for furnaces and recyclers
gRust.Stacks = {
    ItemStack = 1,
    ResourceStack = 1,
    ClothingStack = 1,
    ToolStack = 1,
    MedicalStack = 1,
    WeaponStack = 1,
    AttachmentStack = 1,
    AmmoStack = 1,
    ExplosivesStack = 1,
}

gRust.Gather = {
    TreeGather = 1,
    StoneGather = 1,
    MetalGather = 1,
    SulfurGather = 1,
    HQGather = 1,
    HempGather = 1,
}

hook.Add("gRust.Loaded", "gRust.LoadKits", function()
    --[[gRust.RegisterKit("starter", {

        name = "Starter",

        order = 0,

        free = true,

        redemptions = 1,

        items = {

            {

                id = "wood",

                amount = 2500,

            },

            {

                id = "stone",

                amount = 2000,

            },

            {

                id = "metal.fragments",

                amount = 1000,

            },

            {

                id = "hq_metal",

                amount = 25,

            },

            {

                id = "tool_cupboard",

                amount = 1,

            },

            {

                id = "sleeping_bag",

                amount = 1,

            },

            {

                id = "large_wood_box",

                amount = 1,

            },

        }

    })]]
    gRust.RegisterKit("vip", {
        name = "VIP",
        order = 1,
        redemptions = 1,
        icon = "kits/vip.png",
        items = {
            {
                id = "wood",
                amount = 10000,
            },
            {
                id = "wood",
                amount = 5000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "stone",
                amount = 2500,
            },
            {
                id = "metal.fragments",
                amount = 5000,
            },
            {
                id = "hq_metal",
                amount = 75,
            },
            {
                id = "custom_smg",
                amount = 1,
            },
            {
                id = "pistol_ammo",
                amount = 128,
            },
            {
                id = "medical_syringe",
                amount = 5,
            },
            {
                id = "hatchet",
                amount = 1,
            },
            {
                id = "pickaxe",
                amount = 1,
            },
            {
                id = "hazmat_suit",
                amount = 1,
            },
            {
                id = "armored_door",
                amount = 1,
            },
            {
                id = "tier1",
                amount = 1,
            }
        }
    })

    gRust.RegisterKit("gold_vip", {
        name = "Gold VIP",
        redemptions = 1,
        order = 2,
        icon = "kits/gold_vip.png",
        items = {
            {
                id = "wood",
                amount = 10000,
            },
            {
                id = "wood",
                amount = 10000,
            },
            {
                id = "wood",
                amount = 5000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "stone",
                amount = 5000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "metal.fragments",
                amount = 10000,
            },
            {
                id = "metal.fragments",
                amount = 2500,
            },
            {
                id = "hq_metal",
                amount = 250,
            },
            {
                id = "thompson",
                amount = 1,
            },
            {
                id = "custom_smg",
                amount = 1,
            },
            {
                id = "mp5",
                amount = 1,
            },
            {
                id = "sar",
                amount = 1,
            },
            {
                id = "pistol_ammo",
                amount = 500,
            },
            {
                id = "ammo.rifle",
                amount = 100,
            },
            {
                id = "scientist_suit",
                amount = 1,
            },
            {
                id = "medical_syringe",
                amount = 10,
            },
            {
                id = "satchel_charge",
                amount = 4,
            },
            {
                id = "holosight",
                amount = 10,
            },
            {
                id = "tier2",
                amount = 1,
            },
        }
    })

    gRust.RegisterKit("platinum_vip", {
        name = "Platinum VIP",
        redemptions = 1,
        order = 3,
        icon = "kits/platinum_vip.png",
        items = {
            {
                id = "wood",
                amount = 10000,
            },
            {
                id = "wood",
                amount = 10000,
            },
            {
                id = "wood",
                amount = 10000,
            },
            {
                id = "wood",
                amount = 10000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "stone",
                amount = 10000,
            },
            {
                id = "metal.fragments",
                amount = 10000,
            },
            {
                id = "metal.fragments",
                amount = 10000,
            },
            {
                id = "metal.fragments",
                amount = 10000,
            },
            {
                id = "hq_metal",
                amount = 1000,
            },
            {
                id = "assault_rifle",
                amount = 1,
            },
            {
                id = "lr300",
                amount = 1,
            },
            {
                id = "bolt_rifle",
                amount = 1,
            },
            {
                id = "mp5",
                amount = 1,
            },
            {
                id = "ammo.rifle",
                amount = 500,
            },
            {
                id = "pistol_ammo",
                amount = 500,
            },
            {
                id = "scientist_suit",
                amount = 1,
            },
            {
                id = "medical_syringe",
                amount = 10,
            },
            {
                id = "medical_syringe",
                amount = 10,
            },
            {
                id = "8x_scope",
                amount = 1,
            },
            {
                id = "satchel_charge",
                amount = 10,
            },
            {
                id = "c4",
                amount = 2,
            }
        }
    })
    --[[gRust.RegisterKit("starter", {

        name = "Starter",

        order = 0,

        redemptions = 1,

        items = {

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 500,

            },

            {

                id = "metal.fragments",

                amount = 500,

            },

            {

                id = "hq_metal",

                amount = 20,

            },

            {

                id = "furnace",

                amount = 1,

            },

            {

                id = "large_wood_box",

                amount = 1,

            },

            {

                id = "revolver",

                amount = 1,

            },

            {

                id = "hunting_bow",

                amount = 1,

            },

            {

                id = "arrow",

                amount = 25,

            }

        }

    })



    gRust.RegisterKit("vip", {

        name = "VIP",

        order = 1,

        redemptions = 1,

        icon = "kits/vip.png",

        items = {

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 500,

            },

            {

                id = "metal.fragments",

                amount = 500,

            },

            {

                id = "hq_metal",

                amount = 20,

            },

            {

                id = "furnace",

                amount = 1,

            },

            {

                id = "large_wood_box",

                amount = 1,

            },

            {

                id = "revolver",

                amount = 1,

            },

            {

                id = "hunting_bow",

                amount = 1,

            },

            {

                id = "arrow",

                amount = 25,

            }

        }

    })



    gRust.RegisterKit("gold_vip", {

        name = "Gold VIP",

        redemptions = 1,

        order = 2,

        icon = "kits/gold_vip.png",

        items = {

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 500,

            },

            {

                id = "metal.fragments",

                amount = 1000,

            },

            {

                id = "metal.fragments",

                amount = 500,

            },

            {

                id = "hq_metal",

                amount = 75,

            },

            {

                id = "tier1",

                amount = 1,

            },

            {

                id = "large_wood_box",

                amount = 2,

            },

            {

                id = "scientist_suit",

                amount = 1,

            },

            {

                id = "sap",

                amount = 1,

            },

            {

                id = "dbarrel",

                amount = 1,

            },

            {

                id = "shotgun_ammo",

                amount = 6,

            },

            {

                id = "pistol_ammo",

                amount = 12,

            },

            {

                id = "crossbow",

                amount = 1,

            },

            {

                id = "arrow",

                amount = 25,

            },

            {

                id = "gunpowder",

                amount = 120,

            },

            {

                id = "doormetal",

                amount = 1,

            },

        }

    })



    gRust.RegisterKit("platinum_vip", {

        name = "Platinum VIP",

        redemptions = 1,

        order = 3,

        icon = "kits/platinum_vip.png",

        items = {

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "wood",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "stone",

                amount = 1000,

            },

            {

                id = "metal.fragments",

                amount = 1000,

            },

            {

                id = "metal.fragments",

                amount = 1000,

            },

            {

                id = "metal.fragments",

                amount = 1000,

            },

            {

                id = "hq_metal",

                amount = 150,

            },

            {

                id = "furnace",

                amount = 1,

            },

            {

                id = "large_wood_box",

                amount = 3,

            },

            {

                id = "pickaxe",

                amount = 1,

            },

            {

                id = "hatchet",

                amount = 1,

            },

            {

                id = "medical_syringe",

                amount = 1,

            },

            {

                id = "custom_smg",

                amount = 1,

            },

            {

                id = "thompson",

                amount = 1,

            },

            {

                id = "pistol_ammo",

                amount = 80,

            },

            {

                id = "satchel",

                amount = 1,

            }

        }

    })]]
end)