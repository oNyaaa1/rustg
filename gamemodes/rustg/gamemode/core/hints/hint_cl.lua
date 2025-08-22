local HintFont = "gRust.38px"
local Padding = ScrH() * 0.007
local TextColor = Color(255, 255, 255, 200)

CreateClientConVar("grust_gamehints", "1", true, false)

function gRust.Hint(txt)
	if (!GetConVar("grust_gamehints"):GetBool()) then return end
	local scrw, scrh = ScrW(), ScrH()
	
	local Tall = scrh * 0.058
	surface.SetFont(HintFont)
	local w, h = surface.GetTextSize(txt)
	local Wide = Tall + w + Padding * 2

	local Panel = vgui.Create("DPanel")
	Panel:SetWide(Wide)
	Panel:SetTall(Tall)
	Panel:SetX(scrw * 0.5 - Wide * 0.5)
	Panel:SetY(scrh * 0.78)
	Panel:SetAlpha(0)
	Panel:AlphaTo(255, 0.5, 0)
	Panel:AlphaTo(0, 0.5, 5, function()
		Panel:Remove()
	end)
	Panel.Paint = function(me, w, h)
		surface.SetDrawColor(25, 80, 125)
		surface.DrawRect(0, 0, w, h)
	end

	local Icon = Panel:Add("Panel")
	Icon:Dock(LEFT)
	Icon:SetWide(Tall)
	Icon.Paint = function(me, w, h)
		surface.SetMaterial(gRust.GetIcon("info"))
		surface.SetDrawColor(TextColor)
		surface.DrawTexturedRect(Padding, Padding, w - Padding * 2, h - Padding * 2)
	end

	local Text = Panel:Add("DLabel")
	Text:Dock(FILL)
	Text:SetText(txt)
	Text:SetFont(HintFont)
	Text:SetColor(TextColor)
	Text:SetContentAlignment(5)
end