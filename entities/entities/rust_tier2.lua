AddCSLuaFile()



ENT.Base = "rust_tier1"



ENT.Deploy = {}

ENT.Deploy.Model = "models/deployable/workbench_tier2.mdl"

ENT.Deploy.Sound	= "deploy/workbench_tier_2_deploy.wav"



ENT.MaxHealth		= 500



ENT.Pickup			= "tier2"



ENT.TechTree =

{

	{

		Item = "hazmatsuit",

		Direction = -1,

        Scrap = 125,

		Branch =

		{

            {

                Item = "syringe.medical",

                Scrap = 75,

                Branch =

                {

                    {

                        Item = "ammo.shotgun",

                        Scrap = 75,

                        Branch =

                        {

                            {

                                Item = "shotgun.pump",

                                Scrap = 125,

                                Branch =

                                {

                                    {

                                        Item = "pistol.semiauto",

                                        Scrap = 125,

                                        Branch =

                                        {

                                            {

                                                Item = "pistol.python",

                                                Scrap = 125,

                                                Branch =

                                                {

                                                    {

                                                        Item = "smg.2",

                                                        Scrap = 150,

                                                        Branch =

                                                        {

                                                            

                                                        }

                                                    },

                                                    {

                                                        Item = "smg.thompson",

                                                        Scrap = 150,

                                                        Direction = -2,

                                                        Branch =

                                                        {

                                                            {

                                                                Item = "ammo.rifle",

                                                                Scrap = 125,

                                                                Branch =

                                                                {

                                                                    {

                                                                        Item = "rifle.semiauto",

                                                                        Scrap = 150,

                                                                    }

                                                                }

                                                            }

                                                        },

                                                    },

                                                    {

                                                        Item = "wall.frame.garagedoor",

                                                        Scrap = 125,

                                                        Branch =

                                                        {

                                                            

                                                        }

                                                    }

                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                    },

                },

            }

        },

        {

            Item = "electric.hbhfsensor",

            Direction = 3,

            Scrap = 125,

            Branch =

            {

                {

                    Item = "smart.switch",

                    Scrap = 125,

                    Branch =

                    {

                        {

                            Item = "smart.alarm",

                            Scrap = 125,

                        }

                    }

                }

            }

        }

	},

}