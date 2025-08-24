include("shared.lua")
include("lang/cl_english.lua")

do
	RunConsoleCommand("cl_interp", 0)
end

timer.Create("UpdateSyncAll", 0.1, 0, function()
	//gRust.UpdateInventory()
end)