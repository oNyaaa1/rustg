local PLAYER = FindMetaTable("Player")
local TCRadius = gRust.Config.TCRadius
local TCRadiusSqr = gRust.Config.TCRadius ^ 2
function PLAYER:HasBuildPrivilege(pos, rad)
    if self:GetNW2Bool("gRust.BuildingBlocked", false) then return false end
    pos = pos or self:GetPos()
    rad = rad or TCRadiusSqr
    for k, v in ipairs(ents.FindByClass("rust_toolcupboard")) do
        if v:GetPos():DistToSqr(pos) > rad then continue end
        if SERVER and not v:IsAuthorized(self) then return false end
    end
    return true
end

function PLAYER:GetWorkbenchTier()
    if not self:HasBuildPrivilege() then return 0 end
    local WorkbenchTier = 0
    for k, v in ipairs(ents.FindInSphere(self:GetPos(), TCRadius)) do
        if string.sub(v:GetClass(), 1, 9) ~= "rust_tier" then continue end
        local Tier = tonumber(v:GetClass()[10])
        if Tier > WorkbenchTier then WorkbenchTier = Tier end
    end
    return WorkbenchTier
end