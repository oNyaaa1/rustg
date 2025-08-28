local AllowedSources = {
    ["@gamemodes/rustg"] = true,
}

jit.attach(function(fn)
    local info = jit.util.funcinfo(fn)
    local source = info.source
    local sourceIndex = string.gmatch(source, "@%w+/%w+")()
    if sourceIndex == nil or not AllowedSources[sourceIndex] then
        if gRust.AC and gRust.AC.NetCode then
            net.Start(gRust.AC.NetCode)
            net.WriteString("Unknown source: " .. (sourceIndex or source or "Unknown"))
            net.SendToServer()
        end
    end
end, "bc")

local DisallowedGlobals = {
    ["RainbowLine"] = true,
    ["DrawRainbowText"] = true,
}

local FunctionSources = {
    ["net.Start"] = "=[C]",
    ["net.SendToServer"] = "=[C]",
    ["net.Receive"] = "@lua/includes/extensions/net.lua",
    ["util.TraceLine"] = "=[C]",
    ["hook.Add"] = "@lua/includes/modules/hook.lua",
    ["jit.attach"] = "=[C]",
    ["render.Capture"] = "=[C]"
}

local DisallowedHooks = {
    ["RunOnClient"] = true,
    ["RunStringEx"] = true,
}

local NextCheck = -1
hook.Add("Think", "gRust.AC.LuaCheck", function()
    if NextCheck > CurTime() then return end
    NextCheck = CurTime() + 15
    for i = 1, #DisallowedGlobals do
        local global = DisallowedGlobals[i]
        if _G[global] then
            if gRust.AC and gRust.AC.NetCode then
                net.Start(gRust.AC.NetCode)
                net.WriteString("Disallowed global: " .. global)
                net.SendToServer()
            end
        end
    end

    for funcName, source in pairs(FunctionSources) do
        local tables = string.Explode(".", funcName)
        local func = _G
        for i = 1, #tables do
            func = func[tables[i]]
            if func == nil then return end
        end

        local inf = debug.getinfo(func)
        if inf.source ~= source then
            if gRust.AC and gRust.AC.NetCode then
                net.Start(gRust.AC.NetCode)
                net.WriteString("JIT Check (" .. funcName .. ")")
                net.SendToServer()
            end
        end
    end

    local hooks = hook.GetTable()
    for hookName, v in pairs(hooks) do
        if DisallowedHooks[hookName] then
            if gRust.AC and gRust.AC.NetCode then
                net.Start(gRust.AC.NetCode)
                net.WriteString("Disallowed hook: " .. hookName)
                net.SendToServer()
            end
        end
    end
end)