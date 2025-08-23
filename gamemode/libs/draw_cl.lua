Draw = {}



function Draw.RotatedRect(x, y, w, h, rot)

	local Rect = {}



	rot = rot + 45

	rot = math.rad(rot)

	

	for i = 1, 4 do

		local Step = (i / 4) * math.pi * 2

	

		Rect[#Rect + 1] =

		{

			x = x + math.sin(Step + rot) * w,

			y = y + math.cos(Step + rot) * h

		}

	end



	surface.DrawPoly(Rect)

end



function Draw.StraightLine(x1, y1, x2, y2)

	if (x1 == x2 or y1 == y2) then

		surface.DrawLine(x1, y1, x2, y2)

	else

		surface.DrawLine(x1, y1, x1, y2)

		surface.DrawLine(x1, y2, x2, y2)

	end

end