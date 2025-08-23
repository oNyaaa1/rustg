local GeneratingMap = false
local OldCvars = {}
local function StartGenerate()
	RunConsoleCommand("cl_leveloverview", 29)
	OldCvars["net_graph"] = GetConVar("net_graph"):GetInt()
	RunConsoleCommand("net_graph", 0)
	RunConsoleCommand("grust_drawhud", 0)
	GeneratingMap = true
end

local function EndGenerate()
	RunConsoleCommand("cl_leveloverview", 0)
	RunConsoleCommand("net_graph", OldCvars["net_graph"])
	RunConsoleCommand("grust_drawhud", 1)
	GeneratingMap = false
end

concommand.Add("grust_generatemap", function(pl, cmd, args)
	if (!GetConVar("sv_cheats"):GetBool()) then
		pl:ChatPrint("sv_cheats must be enabled to generate the map")
		return
	end
	
	StartGenerate()
end)

hook.Add("CalcView", "gRust.GenerateMapView", function(pl, pos, ang, fov, near, far)
	if (!GeneratingMap) then return end

	local view = {}
	view.origin = Vector(0, 0, pl:GetPos().z + 5000)
	view.angles = ang

	return view
end)

hook.Add("PostRender", "gRust.GenerateMap", function()
	if (!GeneratingMap) then return end

	local data = render.Capture({
		format = "jpeg",
		x = 0,
		y = 0,
		w = ScrW(),
		h = ScrH()
	})

	file.Write("grust/map.jpeg", data)
	EndGenerate()
end)

hook.Add("HUDPaint", "gRust.GenerateMap", function()
	if (!GeneratingMap) then return end
	local scrw, scrh = ScrW(), ScrH()

	local Grids = 8
	gui.EnableScreenClicker(true)
	local StartX = (scrw - scrh) * 0.5

	surface.SetDrawColor(255, 255, 255, 100)
	for y = 1, Grids do
		local UseY = y * (scrh / Grids)
		surface.DrawLine(StartX, UseY, StartX + scrh, UseY)

		for x = 0, Grids - 1 do
			local UseY = (y - 1) * (scrh / Grids)
			draw.SimpleText(string.format("%s%i", string.char(65 + x), y), "gRust.32px", 4 + StartX + (x * (scrh / Grids)) , UseY, Color(255, 255, 255, 200), 0, 2)
		end
	end

	for x = 0, Grids do
		surface.DrawLine(StartX + (x * (scrh / Grids)), 0, StartX + (x * (scrh / Grids)), scrh)
	end
end)