local COMPLEX = {}

COMPLEX.__index = COMPLEX



function COMPLEX:__tostring()

	return string.format("(%.2f, %.2f)", self.re, self.im)

end



function COMPLEX:__add(rhs)

	if (type(rhs) == "numer") then

		return Complex(self.re + rhs, self.im)

	else

		return Complex(self.re + rhs.re, self.im + rhs.im)

	end

end



function COMPLEX:__sub(rhs)

	if (type(rhs) == "numer") then

		return Complex(self.re - rhs, self.im)

	else

		return Complex(self.re - rhs.re, self.im - rhs.im)

	end

end



function COMPLEX:__mul(rhs)

	if (type(rhs) == "numer") then

		return Complex(self.re * rhs, self.im * rhs)

	else

		local c1 = self.re * rhs.re

		local c2 = self.re * rhs.im

		local c3 = self.im * rhs.re

		local c4 = -(self.im * rhs.im)

		return Complex(c1 + c4, c2 + c3)

	end

end



function COMPLEX:__div(rhs)

	if (type(rhs) == "number") then

		return Complex(self.re / rhs, self.im / rhs)

	else

		local c1 = self * rhs


	end

end



function COMPLEX:Conjugate()

	return Complex(self.re, -self.im)

end



_G.Complex = function(re, im)

	local meta = setmetatable({}, COMPLEX)

	meta.re = re

	meta.im = im

	

	return meta

end



_G["j"] = Complex(0, 1)



--

-- Testing

--



local num1 = Complex(4, 1)

local num2 = Complex(-2, 1)



local Graph =

{

	num1,

	num2,

	num1 / num2,

}



--[[

local start = CurTime()

hook.Add("HUDPaint", "uhsdfsdf", function()

	local scrw, scrh = ScrW(), ScrH()

	surface.SetDrawColor(4, 4, 4)

	surface.DrawRect(0, 0, scrw, scrh)



	local Spacing = scrw / 50

	local xiter = math.ceil(scrw / Spacing)

	for x = 1, xiter do

		if (x == math.floor(xiter * 0.5)) then

			surface.SetDrawColor(255, 255, 255)

		else

			surface.SetDrawColor(125, 125, 125, 50)

		end



		surface.DrawLine(x * Spacing, 0, x * Spacing, scrh)

	end



	local yiter = math.ceil(scrh / Spacing)

	for y = 1, yiter do

		if (y == math.floor(yiter * 0.5)) then

			surface.SetDrawColor(255, 255, 255)

		else

			surface.SetDrawColor(125, 125, 125, 50)

		end



		surface.DrawLine(0, y * Spacing, scrw, y * Spacing)

	end



	local m = #Graph

	for k, v in ipairs(Graph) do

		surface.SetDrawColor((k / m) * 255, 255 - ((k / m) * 255), 0)

		surface.DrawLine(scrw * 0.5, scrh * 0.5, (scrw * 0.5) + (v.re * Spacing), (scrh * 0.5) - (v.im * Spacing))

	end

end)]]