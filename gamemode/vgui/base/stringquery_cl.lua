local PANEL = {}

AccessorFunc(PANEL, "Name", "Name")
AccessorFunc(PANEL, "Callback", "Callback")
AccessorFunc(PANEL, "Button1Text", "Button1Text")
AccessorFunc(PANEL, "Button2Text", "Button2Text")

function PANEL:Init()
	local scrw, scrh = ScrW(), ScrH()

	local Container = self:Add("Panel")
	Container:SetWide(scrw * 0.1625)
	Container:SetTall(scrh * 0.07)
	Container.PerformLayout = function(me, w, h)
		me:SetX(scrw * 0.5 - w * 0.5)
		me:SetY(scrh * 0.5 - h * 0.225)
	end

	local Input = Container:Add("DTextEntry")
	Input:Dock(TOP)
	Input:SetTall(scrh * 0.0325)

	local Buttons = Container:Add("Panel")
	Buttons:Dock(BOTTOM)
	Buttons:SetTall(scrh * 0.0325)

	local Button1 = Buttons:Add("gRust.Button")
	Button1:Dock(LEFT)
	Button1:SetWide(scrw * 0.08)
	Button1:SetDefaultColor(Color(205, 65, 43))
	Button1:SetHoveredColor(Color(202, 74, 54))
	Button1:SetActiveColor(Color(204, 84, 66))
	Button1.DoClick = function(me)
		self:Remove()
	end

	local Button2 = Buttons:Add("gRust.Button")
	Button2:Dock(RIGHT)
	Button2:SetWide(scrw * 0.08)
	Button2:SetDefaultColor(Color(115, 141, 69))
	Button2:SetHoveredColor(Color(105, 141, 42))
	Button2:SetActiveColor(Color(134, 180, 55))
	Button2.DoClick = function(me)
		self:Remove()
		self:GetCallback()(Input:GetValue())
	end

	self.Button1 = Button1
	self.Button2 = Button2
end

function PANEL:PerformLayout()
	self.Button1:SetText(self:GetButton1Text())
	self.Button2:SetText(self:GetButton2Text())
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(26, 25, 22, 245)
	surface.DrawRect(0, 0, w, h)

	self:DrawBlur(4)
	draw.SimpleText(self:GetName(), "gRust.62px", w * 0.5, h * 0.45, Color(255, 255, 255, 200), 1, 1)
end

vgui.Register("gRust.NumberQuery", PANEL, "EditablePanel")

function gRust.StringQuery(name, btn1, btn2, callback)
	local Frame = vgui.Create("gRust.NumberQuery")
	Frame:MakePopup()
	Frame:Dock(FILL)
	Frame:SetName(name)
	Frame:SetCallback(callback)
	Frame:SetButton1Text(btn1)
	Frame:SetButton2Text(btn2)
end