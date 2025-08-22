hook.Add("gRust.LoadedCore", "gRust.LoadBlueprints", function()

	for k, v in pairs(gRust.Items) do

		if (!v:GetWeapon()) then continue end

		if (!v:GetClip()) then continue end

	

		v.Actions = v.Actions or {}

		v.Actions[#v.Actions + 1] = {
			Name = "Unload Ammo",

			Func = function(ent, slot)
				
				net.Start("gRust.UnloadAmmo")

				net.WriteEntity(ent)

				net.WriteUInt(slot, 6)

				net.SendToServer()
				
			end
		}
		

	end

end)