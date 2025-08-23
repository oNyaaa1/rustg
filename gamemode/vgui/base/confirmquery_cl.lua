local PANEL = {}

AccessorFunc(PANEL, "Name", "Name")
AccessorFunc(PANEL, "Callback", "Callback")

function PANEL:Init()
	local scrw, scrh = ScrW(), ScrH()

	local Container = self:Add("Panel")
	Container:SetWide(scrw * 0.250)
	Container:SetTall(scrh * 0.100)
	Container.PerformLayout = function(me, w, h)
		me:SetX(scrw * 0.5 - w * 0.5)
		me:SetY(scrh * 0.5 - h * 0.225)
	end

	local Buttons = Container:Add("Panel")
	Buttons:Dock(BOTTOM)
	Buttons:SetTall(scrh * 0.13)
	Buttons:DockPadding(1, 0, 1, 0)

	local Button1 = Buttons:Add("DButton")
	Button1:Dock(LEFT)
	Button1:SetWide(scrw * 0.12)
	Button1:SetText("")
	Button1.Paint = function(me, w, h)
		local bgColor = Color(115, 141, 69)
		if me:IsHovered() then
			bgColor = Color(134, 180, 55)
		end
		if me:IsDown() then
			bgColor = Color(105, 141, 42)
		end
		
		surface.SetDrawColor(bgColor:Unpack())
		surface.DrawRect(0, 0, w, h)
		
		draw.SimpleText("YES", "gRust.48px", w * 0.5, h * 0.6, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	Button1.DoClick = function(me)
		self:Remove()
		self:GetCallback()()
	end

	local Spacer = Buttons:Add("Panel")
	Spacer:Dock(LEFT)
	Spacer:SetWide(80)

	local Button2 = Buttons:Add("DButton")
	Button2:Dock(RIGHT)
	Button2:SetWide(scrw * 0.12)
	Button2:SetText("")
	Button2.Paint = function(me, w, h)
		local bgColor = Color(205, 65, 43)
		if me:IsHovered() then
			bgColor = Color(202, 74, 54)
		end
		if me:IsDown() then
			bgColor = Color(204, 84, 66)
		end
		
		surface.SetDrawColor(bgColor:Unpack())
		surface.DrawRect(0, 0, w, h)
		
		draw.SimpleText("NO", "gRust.48px", w * 0.5, h * 0.6, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	Button2.DoClick = function(me)
		self:Remove()
	end

	self.Button1 = Button1
	self.Button2 = Button2
end

function PANEL:PerformLayout()
	-- Текст рисуется в Paint функциях
end

function PANEL:Paint(w, h)

   surface.SetDrawColor(26, 25, 22, 245)
   surface.DrawRect(0, 0, w, h)

self:DrawBlur(4)
	draw.SimpleText(self:GetName(), "gRust.80px", w * 0.5, h * 0.390, Color(232, 220, 211, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("gRust.ConfirmQuery", PANEL, "EditablePanel")

function gRust.ConfirmQuery(name, callback)
	local Frame = vgui.Create("gRust.ConfirmQuery")
	Frame:MakePopup()
	Frame:Dock(FILL)
	Frame:SetName(name)
	Frame:SetCallback(callback)
end
