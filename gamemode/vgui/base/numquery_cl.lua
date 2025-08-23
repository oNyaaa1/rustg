local PANEL = {}

local Buttons =
{
	[1] = 	{Text = "7", Func = function(str) return str .. "7" end},
	[2] = 	{Text = "8", Func = function(str) return str .. "8" end},
	[3] = 	{Text = "9", Func = function(str) return str .. "9" end},
	[4] = 	{Text = "4", Func = function(str) return str .. "4" end},
	[5] = 	{Text = "5", Func = function(str) return str .. "5" end},
	[6] = 	{Text = "6", Func = function(str) return str .. "6" end},
	[7] = 	{Text = "1", Func = function(str) return str .. "1" end},
	[8] = 	{Text = "2", Func = function(str) return str .. "2" end},
	[9] = 	{Text = "3", Func = function(str) return str .. "3" end},
	[11] =	{Text = "0", Func = function(str) return str .. "0" end},
	[12] =	{Text = "C", Func = function(str, frame)
		if (string.len(str) <= 0) then
			frame:Remove()
		end

		return string.sub(str, 1, #str - 1)
	end},
}



function PANEL:Init()
	local scrw, scrh = ScrW(), ScrH()
	self.Input = ""

	local InputHeight = scrh * 0.06
	local Width = scrh * 0.2
	local Height = scrh * 0.2
	local Margin = scrh * 0.005
	local Container = self:Add("Panel")
	Container:SetWide(Width + Margin * 2)
	Container:SetTall(Height + Margin * 4 + Height / 3 + InputHeight)
	Container.PerformLayout = function(me, w, h)
		me:SetX(scrw * 0.5 - w * 0.5)
		me:SetY(scrh * 0.5 - h * 0.225)
	end

	local Input = Container:Add("Panel")
	Input:Dock(TOP)
	Input:SetTall(InputHeight)
	Input:DockMargin(0, 0, 0, Margin)
	Input.Paint = function(me, w, h)
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText(string.gsub(self.Input, "%w", " * "), "gRust.60px", w * 0.5, h * 0.5, Color(255, 255, 255), 1, 1)
	end

	local ButtonGrid = Container:Add("gRust.Grid")
	ButtonGrid:Dock(FILL)
	ButtonGrid:SetMargin(Margin)
	ButtonGrid:SetCols(3)
	ButtonGrid:SetRows(3)
	ButtonGrid:SetColWide(Width / 3)
	ButtonGrid:SetRowTall(Height / 3)
	ButtonGrid:NoClipping(true)

	for i = 1, 12 do
		local Panel = ButtonGrid:Add(i == 10 and "Panel" or "gRust.Button")
		if (i == 10) then continue end

		local ButtonData = Buttons[i]

		Panel:Dock(FILL)
		Panel:SetText(ButtonData.Text)
		Panel:SetTextColor(Color(0, 0, 0, 225))
		Panel:SetFont("gRust.60px")
		Panel.DoClick = function(me)
			local NewInput = ButtonData.Func(self.Input, self)

			if (NewInput) then
				LocalPlayer():EmitSound("keypad.beep")
				self.Input = NewInput
				if (string.len(self.Input) == 4) then
					if (self.Callback) then
						self.Callback(self.Input)
					end
					self:Remove()
				end
			end
		end
	end
end

function PANEL:PerformLayout()
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(26, 25, 22, 245)
	surface.DrawRect(0, 0, w, h)

	self:DrawBlur(4)

	draw.SimpleText(self.Input, "gRust.40px", 0, 0, Color(255, 255, 255), 0, 0)
end

vgui.Register("gRust.NumQuery", PANEL, "EditablePanel")

function gRust.NumQuery(cback)
	local Frame = vgui.Create("gRust.NumQuery")
	Frame:Dock(FILL)
	Frame:MakePopup()
	Frame.Callback = cback
end