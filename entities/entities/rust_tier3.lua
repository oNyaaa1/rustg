AddCSLuaFile()

ENT.Base = "rust_tier1"

ENT.Deploy = {}
ENT.Deploy.Model = "models/deployable/workbench_tier3.mdl"
ENT.Deploy.Sound	= "deploy/workbench_tier_3_deploy.wav"

ENT.MaxHealth		= 750

ENT.Pickup			= "tier3"

ENT.TechTree =
{
	{
		Item = "armored_door",
		Direction = 1,
        Scrap = 500,
		Branch =
		{
            {
                Item = "mp5",
                Scrap = 250,
                Branch =
                {
                    {
                        Item = "assault_rifle",
                        Scrap = 500,
                        Direction = 1,
                        Branch =
                        {
                            {
                                Item = "bolt_rifle",
                                Scrap = 500,
                                Direction = 1,
                                Branch =
                                {
                                    {
                                        Item = "8x_scope",
                                        Scrap = 500,
                                    },
                                }
                            },
                        }
                    },
                    {
                        Item = "explosives",
                        Scrap = 500,
                        Direction = 2,
                        Branch =
                        {
                            {
                                Item = "c4",
                                Scrap = 500
                            }
                        }
                    }
                }
            }
        }
	},
}