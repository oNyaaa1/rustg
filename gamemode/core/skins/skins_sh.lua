local PLAYER = FindMetaTable("Player")
function PLAYER:HasSkin(skinid)
    return self.Skins[skinid] == true
end

function PLAYER:GetSkins()
    return self.Skins
end