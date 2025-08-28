local PLAYER = FindMetaTable("Player")
function PLAYER:GetDeployData()
    return util.TraceLine{
        start = self:EyePos(),
        endpos = self:EyePos() + self:GetAimVector() * 300,
        filter = self
    }
end

local AddAngle = Angle(0, 0, 0)
function PLAYER:GetDeployPosition(data)
    if data.GetPosition then return data.GetPosition(self) end
    local tr = self:GetDeployData()
    if data.Position then return data.Position(self, tr) end
    self.DeploySocket = false
    self.DeploySocketID = 0
    local checkPos = self:EyePos() + self:GetAimVector() * 85
    if data.Socket then
        local closestDist, closestSocket, structure
        for _, v in ipairs(ents.FindByClass("rust_structure")) do
            if v:GetPos():DistToSqr(self:GetPos()) > 25000 then continue end
            if v:GetNW2Bool("gRust.InUse", false) then continue end
            local block = gRust.BuildingBlocks[v:GetOriginalModel()]
            if not block then continue end
            for sockType, list in pairs(block.Sockets) do
                if sockType ~= data.Socket then continue end
                for _, d in ipairs(list) do
                    local dist = v:LocalToWorld(d.pos):DistToSqr(checkPos)
                    if not closestDist or dist < closestDist then
                        closestDist = dist
                        closestSocket = d
                        structure = v
                    end
                end
            end
        end

        if not structure then
            for _, v in ipairs(ents.FindByClass("rust_building")) do
                if v:GetPos():DistToSqr(self:GetPos()) > 25000 then continue end
                if v:GetNW2Bool("gRust.InUse", false) then continue end
                local bt = v:GetNWString("buildingtype")
                local cfg = buildingsTable[bt]
                if not cfg or not cfg.sockets then continue end
                for _, s in ipairs(cfg.sockets) do
                    if s.type ~= data.Socket then continue end
                    local worldPos = v:LocalToWorld(s.pos)
                    local dist = worldPos:DistToSqr(checkPos)
                    if not closestDist or dist < closestDist then
                        closestDist = dist
                        closestSocket = s
                        structure = v
                    end
                end
            end
        end

        if structure and closestSocket then
            self.DeploySocket = true
            self.DeploySocketID = closestSocket.id or 0
            return structure:LocalToWorld(closestSocket.pos), structure:GetAngles() + closestSocket.ang, structure
        end
        return tr.HitPos, self:GetAngles(), tr.Entity
    end

    local norm = tr.HitNormal:Angle()
    local pos = tr.HitPos
    local ang
    if data.Place == "wall" then
        ang = norm
    else
        ang = Angle(norm.x, tr.HitWorld and norm.y or 0, norm.z)
        ang:RotateAroundAxis(ang:Right(), tr.Hit and -90 or 90)
        ang:RotateAroundAxis(ang:Up(), self:GetAngles().y)
        ang:RotateAroundAxis(ang:Up(), self:GetNW2Int("gRust.DeployRotation"))
        if data.Angle then
            ang:RotateAroundAxis(ang:Forward(), data.Angle.x)
            ang:RotateAroundAxis(ang:Right(), data.Angle.y)
            ang:RotateAroundAxis(ang:Up(), data.Angle.z)
        end
    end
    return pos, ang, tr.Entity
end

function PLAYER:CanDeploy(data, ent)
    if not self:HasBuildPrivilege(self:GetPos(), gRust.Config.TCRadius ^ 2 * 4) then return false end
    if data.CanDeploy then return data.CanDeploy(self, ent) end
    if data.Socket then
        if IsValid(ent) and ent:GetNW2Bool("gRust.InUse", false) then return false end
        return self.DeploySocket
    end
    return self:GetDeployData().Hit
end