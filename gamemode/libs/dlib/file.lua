local File = {}

function File.LoadDir(dir)
	local folder = dir .. "/"
	local Files, Folders = file.Find(folder .. "*", "LUA")

	for k, v in ipairs(Files) do
		if (string.EndsWith(v, "_sv.lua")) then
			IncludeSV(folder .. v)
		elseif (string.EndsWith(v, "_cl.lua")) then
			IncludeCL(folder .. v)
		else
			IncludeSH(folder .. v)
		end
	end

	for k, v in ipairs(Folders) do
		File.LoadDir(folder .. v)
	end
end

return File