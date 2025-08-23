local surface = surface



local Wide = ScrW() * 1.55

local Tall = ScrH() * 0.04

local MaskW = ScrW() * 0.4

local CutW = ScrW() * 0.4



local PointW = ScrH() * 0.0075

local PointH = ScrH() * 0.01



local AlphaMask = BMASKS.CreateMask("compass_mask", "materials/misc/compass_mask.png")

local Compass = Material("materials/misc/compass_strip.png", "smooth")



function GM:DrawCompass()

	local scrw, scrh = ScrW(), ScrH()

	local pl = LocalPlayer()

	local Map = gRust.Map



	local Rot = pl:EyeAngles().y * (Wide / 360)

	

	BMASKS.BeginMask(AlphaMask)

	surface.SetDrawColor(255, 255, 255)

	surface.SetMaterial(Compass)

	surface.DrawTexturedRect(scrw * 0.5 - Wide * 0.5 + Rot, 0, Wide, Tall)



	surface.SetDrawColor(255, 255, 255)

	surface.SetMaterial(Compass)

	surface.DrawTexturedRect(scrw * 0.5 + Wide * 0.5 + Rot, 0, Wide, Tall)



	surface.SetDrawColor(255, 255, 255)

	surface.SetMaterial(Compass)

	surface.DrawTexturedRect(scrw * 0.5 - Wide * 1.5 + Rot, 0, Wide, Tall)



	if (Map and Map.MarkerX) then

		local MarkerVec = gRust.MapToVector(gRust.Map.MarkerX, gRust.Map.MarkerY)



		local MarkerX = Map.MarkerX 

		local MarkerY = Map.MarkerY

		local MarkerVec = gRust.MapToVector(MarkerX, MarkerY)

		local RelativePos = MarkerVec - pl:GetPos()

	

		local ang = math.deg(math.atan2(RelativePos.y, RelativePos.x))

	

		local Deg = -ang

		Deg = Deg + pl:EyeAngles().y

		Deg = Deg * (Wide / 360)

		surface.SetDrawColor(255, 255, 255)

		surface.SetMaterial(gRust.GetIcon("waypoint"))

		local WaypointSize = scrh * 0.025

		surface.DrawTexturedRect(Deg + scrw * 0.5 - WaypointSize * 0.5, scrh * 0.0025, WaypointSize, WaypointSize)

	end

	

	surface.SetDrawColor(0, 0, 0)

	surface.DrawRect(scrw * 0.5 - PointW * 0.5, 0, PointW, PointH)

	local Padding = 4

	surface.SetDrawColor(255, 255, 255)

	surface.DrawRect(scrw * 0.5 - PointW * 0.5 + Padding * 0.5, 0, PointW - Padding, PointH - Padding * 0.5)

	

	BMASKS.EndMask(AlphaMask, (scrw - MaskW) * 0.5, 0, MaskW, Tall, 255, 0, false, function()

		surface.DrawTexturedRect(0, 0, (scrw - CutW) * 0.5, Tall)

		surface.DrawTexturedRect(scrw - (scrw - CutW) * 0.5, 0, CutW, Tall)

	end)

end