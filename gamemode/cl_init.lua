include("shared.lua")
include("lang/sv_english.lua")

do
	RunConsoleCommand("cl_interp", 0)
end

timer.Create("UpdateSyncAll", 0.1, 0, function()
	//gRust.UpdateInventory()
end)