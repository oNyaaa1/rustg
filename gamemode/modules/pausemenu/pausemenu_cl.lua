function gRust.OpenPauseMenu()
    if (IsValid(gRust.PauseMenu)) then return end
    gRust.PauseMenu = vgui.Create("gRust.PauseMenu")
    gRust.PauseMenu:Dock(FILL)
    gRust.PauseMenu:SetZPos(100)
    gui.EnableScreenClicker(true)

    gRust.DrawHUD = false
end

function gRust.ClosePauseMenu()
    if (!IsValid(gRust.PauseMenu)) then return end
    gRust.PauseMenu:Remove()
    gui.EnableScreenClicker(false)

    gRust.DrawHUD = true
end

hook.Add('PreRender', 'gRust.PauseMenu', function()
	if (input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible()) then
        gui.HideGameUI()

		if (IsValid(gRust.PauseMenu)) then
			gRust.ClosePauseMenu()
		else
			gRust.OpenPauseMenu()
		end
	end
end)