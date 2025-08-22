function util.AvatarURL(id64, cback)
    http.Fetch("https://steamcommunity.com/profiles/" .. id64 .. "?xml=1", function(body, size, headers, code)
        if (size == 0 or code < 200 or code > 299) then cback() return end
        
        local url, filetype = body:match("<avatarFull>.-(https?://%S+%f[%.]%.)(%w+).-</avatarFull>")
        if (!url or !filetype) then return end
        cback(url .. filetype)
    end, function() cback() end)
end

--[[---------------------------------------------------------
	Name: ModuleExists( name )
	Desc: Checks if a binary module is installed
-----------------------------------------------------------]]
function util.ModuleExists( name )
    
    local realm = CLIENT and "cl" or "sv"
    local arch = jit.arch == "x86" and "32" or "64"
    local ops = system.IsWindows() and "win" or ( system.IsOSX() and "osx" or "linux" )
    if ( ops == "osx" or (ops == "linux" and arch == "32") ) then
        arch = ""
    end
	
    local f = string.format( "lua/bin/gm%s_%s_%s%s.dll", realm, name, ops, arch )

    return file.Exists( f, "GAME" )
    
end

--[[---------------------------------------------------------
    Name: FuzzySearch( haystack, needle )
    Desc: Searches for the string using Approximate string matching
-----------------------------------------------------------]]
function util.FuzzySearch( haystack, needle )
    local nlen = string.len(needle)
    local hlen = string.len(haystack)
    
    if (nlen > hlen) then return false end
    if (nlen == hlen) then return needle == haystack end

    local j = 0
    for i = 1, nlen do
        local ch = string.sub(needle, i, i)
        local con = false
        while (j < hlen) do
            j = j + 1
            if (string.sub(haystack, j, j) == ch) then
                con = true
                goto nloop
            end
        end

        ::nloop::

        if (!con) then
            return false
        end
    end

    return true
end