local F1Down = false

hook.Add("Think", "gRust.DevTools", function(pl, button)
    if (input.IsButtonDown(KEY_F1)) then
        if (!F1Down) then
            if (IsValid(gRust.DevTools)) then

                if (gRust.DevTools:IsVisible()) then
                    gRust.DevTools:SetVisible(false)
                    gRust.DevTools:SetMouseInputEnabled(false)
                    gRust.DevTools:SetKeyboardInputEnabled(false)
                else
                    gRust.DevTools:SetVisible(true)
                    gRust.DevTools:MakePopup()
                end
            else
                gRust.DevTools = vgui.Create("gRust.DevTools")
                gRust.DevTools:SetPos(0, 0)
                gRust.DevTools:SetSize(ScrW(), ScrH() * 0.88)
                gRust.DevTools:MakePopup()
                gRust.DevTools:DockMargin(8, 8, 8, 8)
                gRust.DevTools:AddTab("ITEMS", "gRust.DevTools.Items") 
                gRust.DevTools:AddTab("CONSOLE", "gRust.DevTools.Console")
            end
            F1Down = true
        end
    else
        F1Down = false
    end
end)
