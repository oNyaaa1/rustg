include("shared.lua")
ENT.ShowHealth = true
function ENT:Draw()
    self:DrawModel()
    local Block = gRust.BuildingBlocks[self:GetModel()]
    if not Block then return end
    for k, v in ipairs(Block.Sockets) do
        debugoverlay.Text(self:LocalToWorld(v.pos), string.format("SOCKET [%i]", k), 1)
    end
end