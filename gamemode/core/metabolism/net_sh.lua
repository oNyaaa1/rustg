local PLAYER = FindMetaTable("Player")
function PLAYER:GetHunger()
    return self.Hunger or 0
end

function PLAYER:GetThirst()
    return self.Thirst or 0
end