local PLAYER = FindMetaTable("Player")
function PLAYER:GetDeployData()
	local tr = {}
	tr.start = self:EyePos()
	tr.endpos = tr.start + self:GetAimVector() * 125
	tr.filter = self
	return util.TraceLine(tr)
end

local AddAngle = Angle(0, 0, 0)
function PLAYER:GetDeployPosition(data)
	if data.GetPosition then return data.GetPosition(self) end
	local tr = self:GetDeployData()
	if data.Position then return data.Position(self, tr) end
	self.DeploySocket = false
	local CheckPos = self:EyePos() + self:GetAimVector() * 85
	local pos, ang
	if data.Socket then
		local ClosestDist
		local ClosestSocket
		local Structure
		for k, v in ipairs(ents.FindByClass("rust_structure")) do
			if v:GetPos():DistToSqr(self:GetPos()) > 25000 then continue end
			local Block = gRust.BuildingBlocks[v:GetOriginalModel()]
			if not Block then continue end
			for i, j in pairs(Block.Sockets) do
				if i ~= data.Socket then continue end
				for r, d in ipairs(j) do
					local Dist = v:LocalToWorld(d.pos):DistToSqr(CheckPos)
					if not ClosestDist or Dist < ClosestDist then
						ClosestDist = Dist
						ClosestSocket = d
						Structure = v
					end
				end
			end
		end

		if Structure then
			self.DeploySocket = true
			if CLIENT then AddAngle.y = data.Rotation or 0 end
			return Structure:LocalToWorld(ClosestSocket.pos), Structure:GetAngles() + ClosestSocket.ang + AddAngle, Structure
		else
			return tr.HitPos, self:GetAngles(), tr.Entity
		end
	else
		if data.Place and data.Place == "wall" then
			local Normal = tr.HitNormal:Angle()
			pos = tr.HitPos
			ang = Normal
		else
			local Normal = tr.HitNormal:Angle()
			pos = tr.HitPos
			ang = Angle(Normal.x, tr.HitWorld and Normal.y or 0, Normal.z)
			ang:RotateAroundAxis(ang:Right(), tr.Hit and -90 or 90)
			ang:RotateAroundAxis(ang:Up(), self:GetAngles().y)
			ang:RotateAroundAxis(ang:Up(), self:GetNW2Int("gRust.DeployRotation"))
			if data.Angle then
				ang:RotateAroundAxis(ang:Forward(), data.Angle.x)
				ang:RotateAroundAxis(ang:Right(), data.Angle.y)
				ang:RotateAroundAxis(ang:Up(), data.Angle.z)
			end
		end
	end
	return pos, ang, tr.Entity
end

function PLAYER:CanDeploy(data, ent)
	if not self:HasBuildPrivilege(self:GetPos(), gRust.Config.TCRadius ^ 2 * 4) then return false end
	if data.CanDeploy then return data.CanDeploy(self, ent) end
	if data and data.Socket then
		if IsValid(ent) and ent:GetNW2Bool("gRust.InUse", false) then return false end
		return self.DeploySocket
	end

	local DeployData = self:GetDeployData()
	return DeployData.Hit
end