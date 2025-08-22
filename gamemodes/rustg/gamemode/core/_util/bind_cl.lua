Binds = Binds or {}
KeyBinds = KeyBinds or {}
function gRust.AddBind(bind, callback)
	Binds[bind] = callback
end

function gRust.AddKeyBind(bind, callback)
	KeyBinds[bind] = callback
end

function GM:PlayerBindPress(pl, bind)
	if Binds[bind] then Binds[bind](pl) end
end

function GM:PlayerButtonDown(pl, key)
	if KeyBinds[key] then KeyBinds[key](pl, true) end
end

function GM:PlayerButtonUp(pl, key)
	if KeyBinds[key] then KeyBinds[key](pl, false) end
end