AddCSLuaFile()



ENT.Base = "rust_base"



ENT.Deploy = {}

ENT.Deploy.Model 	= "models/deployable/workbench_tier1.mdl"

ENT.Deploy.Sound	= "deploy/workbench_tier_1_deploy.wav"



ENT.DisplayIcon 	= gRust.GetIcon("gear")



ENT.MaxHealth		= 250

ENT.ShowHealth		= true



ENT.Pickup			= "tier1"



function ENT:Initialize()

	if (CLIENT) then return end



	self:SetModel(self.Deploy.Model)

	self:SetSolid(SOLID_VPHYSICS)



	self:SetHealth(self.MaxHealth)

	self:SetMaxHealth(self.MaxHealth)



	self:SetDamageable(true)

	

	self:SetMeleeDamage(0.1)

	self:SetBulletDamage(0.1)

	self:SetExplosiveDamage(0.5)



	self:SetInteractable(true)

	self:SetDisplayName("USE")

end



ENT.TechTree =

{

	{

		Item = "pickaxe",

		Direction = -1,

		Scrap = 125,

		Branch =

		{

			{

				Item = "shotgun.waterpipe",

				Scrap = 75,

				Branch =

				{

					{

						Item = "ammo.pistol",

						Scrap = 75,

						Branch =

						{

							{

								Item = "pistol.revolver",

								Scrap = 125,

								Branch =

								{

									{

										Item = "grenade.beancan",

										Scrap = 125,

										Branch =

										{

											{

												Item = "explosive.satchel",

												Scrap = 125,

											}

										}

									}

								}

							}

						}

					},

					{

						Item = "shotgun.double",

						Scrap = 125,

						Branch =

						{

							

						}

					},

					{

						Item = "knife.combat",

						Scrap = 125,

					}

				}

			}

		}

	},

	{

		Item 	= "hatchet",

		Direction = 2,

		Scrap = 125,

		Branch	=

		{

			{

				Item = "barricade.stone",

				Scrap = 75,

			}

		}

	},

	{

		Item 	= "electric.switch",

		Direction = 3,

		Scrap = 125,

		Branch	=

		{

			{

				Item = "electric.battery.rechargable.small",

				Scrap = 125,

				Branch =

				{

					{

						Item = "electric.solarpanel.large",

						Scrap = 125,

						Branch =

						{

							{

								Item = "ceilinglight",

								Scrap = 125,

								Branch =

								{

									{

										Item = "electric.doorcontroller",

										Scrap = 125,

									}

								}

							}

						}

					}

				}

			}

		}

	}

}



function ENT:Interact(pl)

	if (SERVER) then return end

	gRust.ToggleTechTree(self)

end