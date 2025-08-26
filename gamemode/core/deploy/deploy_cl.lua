
local DeployIndex
local DeployRotation = 0
local BaseRotation   = 180
local LastSocketID   = 0

function gRust.RequestDeploy(index)
    local Item = LocalPlayer().Inventory[index]
    if not Item then return end
    local Class      = gRust.Items[Item:GetItem()]:GetEntity()
    local DeployData = scripted_ents.Get(Class).Deploy
    DeployIndex      = index
    DeployRotation   = 0
    LastSocketID     = 0
    if not IsValid(gRust.DeployEntity) then
        gRust.DeployEntity = ClientsideModel(DeployData.Model)
        if DeployData.ModelScale then
            gRust.DeployEntity:SetModelScale(DeployData.ModelScale)
        end
    end
    gRust.DeployEntity.Data = DeployData
end

function gRust.ResetDeploy()
    if IsValid(gRust.DeployEntity) then gRust.DeployEntity:Remove() end
    DeployIndex    = nil
    DeployRotation = 0
    LastSocketID   = 0
end

local function UpdateDeploy()
    if not IsValid(gRust.DeployEntity) then return end
    local Data            = gRust.DeployEntity.Data
    local pos, ang        = LocalPlayer():GetDeployPosition(Data)
    LastSocketID          = LocalPlayer().DeploySocketID or 0
    if not Data.Socket then
        ang:RotateAroundAxis(ang:Up(), BaseRotation + DeployRotation)
    end
    gRust.DeployEntity:SetPos(pos)
    gRust.DeployEntity:SetAngles(ang)
    if LocalPlayer():CanDeploy(Data, gRust.DeployEntity) then
        gRust.DeployEntity:SetMaterial("models/darky_m/rust_building/build_ghost")
    else
        gRust.DeployEntity:SetMaterial("models/darky_m/rust_building/build_ghost_disallow")
    end
end
hook.Add("Think", "gRust.DeployUpdate", UpdateDeploy)

local lastR = false
hook.Add("Think", "gRust.DeployRotation", function()
    if not IsValid(gRust.DeployEntity) then return end
    if gRust.DeployEntity.Data.Socket then return end
    local r = input.IsKeyDown(KEY_R)
    if r and not lastR then
        DeployRotation = (DeployRotation + 90) % 360
    end
    lastR = r
end)

local function CheckPlace(pl, key)
    if not IsFirstTimePredicted() then return end
    if key ~= IN_ATTACK                   then return end
    if not IsValid(gRust.DeployEntity)    then return end
    if not DeployIndex                    then return end
    if not pl:CanDeploy(gRust.DeployEntity.Data, gRust.DeployEntity) then return end
    net.Start("gRust.Deploy")
        net.WriteUInt(DeployIndex, 3)
        net.WriteUInt(LastSocketID or 0, 8)
    net.SendToServer()
    if pl.Inventory[DeployIndex]:GetQuantity() <= 1 then
        gRust.ResetDeploy()
    end
end
hook.Add("KeyPress", "gRust.DeployKey", CheckPlace)
