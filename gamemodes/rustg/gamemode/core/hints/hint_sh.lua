local PLAYER = FindMetaTable("Player")

local HintCache = {}

function PLAYER:Hint(id, txt, max)
	max = max or 3

	if (SERVER) then
		net.Start("gRust.Hint")
		net.WriteString(id)
		net.WriteString(txt)
		net.WriteUInt(max, 6)
		net.Send(self)
	elseif (max ~= 0) then
		if (HintCache[id]) then return end

		local data = sql.Query(string.format("SELECT count FROM grust_hints WHERE id='%s'", id))
		if (!data or data == false) then
			sql.Query(string.format("INSERT INTO grust_hints(id, count) VALUES('%s', %i)", id, 1))
		else
			if (tonumber(data[1].count) >= max) then
				HintCache[id] = true
				return
			end
			sql.Query(string.format("UPDATE grust_hints SET count = count + 1 WHERE id='%s'", id))
		end
	end

	if (CLIENT) then
		gRust.Hint(txt)
	end
end

if (SERVER) then
	util.AddNetworkString("gRust.Hint")
else
	sql.Query([[CREATE TABLE IF NOT EXISTS grust_hints(
		id VARCHAR(20) NOT NULL,
		count INTEGER NOT NULL DEFAULT 0,
		PRIMARY KEY(id)
	)]])

	net.Receive("gRust.Hint", function(len, pl)
		LocalPlayer():Hint(net.ReadString(), net.ReadString(), net.ReadUInt(6))
	end)


	timer.Simple(120, function()
		LocalPlayer():Hint("show_map", "PRESS [G] TO OPEN YOUR MAP", 2)
	end)
end