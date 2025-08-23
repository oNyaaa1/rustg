hook.Add("PlayerButtonDown", "gRust.OpenMap", function(pl, key)
	if (key == KEY_G) then
		gui.EnableScreenClicker(true)
		
		gRust.MapMenu = vgui.Create("gRust.Map")
	end
end)

hook.Add("PlayerButtonUp", "gRust.CloseMap", function(pl, key)
	if (key == KEY_G) then
		if (!gRust.MapMenu || !gRust.MapMenu:IsValid()) then return end

		gui.EnableScreenClicker(false)
		gRust.MapMenu:Exit()
	end
end)