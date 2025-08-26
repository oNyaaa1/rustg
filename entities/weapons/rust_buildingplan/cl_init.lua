include("shared.lua")

local function ClientModel(swep, status, pos, rot)
    if not IsValid(swep.ghostEntity) then
        swep.ghostEntity = ClientsideModel(buildingsTable[swep:GetNetworkedString("selectedBuilding")]["model"])
        swep.ghostEntity.RenderOverride = function(ent)
            render.SuppressEngineLighting(true)
            ent:DrawModel()
            render.SuppressEngineLighting(false)
        end
        swep.ghostEntity:SetRenderMode(RENDERMODE_TRANSALPHA)
        swep.ghostEntity:SetMaterial("models/debug/debugwhite")
    elseif swep.ghostEntity:GetModel() ~= buildingsTable[swep:GetNetworkedString("selectedBuilding")]["model"] then
        swep.ghostEntity:SetModel(buildingsTable[swep:GetNetworkedString("selectedBuilding")]["model"])
    end

    swep.ghostEntity:SetPos(pos)
    swep.ghostEntity:SetAngles(rot)

    if status == 0 then
        swep.ghostEntity:SetColor(Color(0, 157, 255, 220))
    else
        swep.ghostEntity:SetColor(Color(255, 0, 0, 220))
    end
end

function SWEP:PreviewChanged()
    if IsValid(self.ghostEntity) then
        self.ghostEntity:Remove()
    end
end

function SWEP:Deploy()
    self.SelectedBlock = self.SelectedBlock or 1
    self.LastPieMenuClose = 0
    return true
end

function SWEP:Holster()
    if IsValid(self.ghostEntity) then self.ghostEntity:Remove() end
    if self.PieOpened then
        self.PieOpened = false
        if gRust and gRust.ClosePieMenu then gRust.ClosePieMenu() end
    end
    return true
end

function SWEP:UpdatePieMenu()
    if input.IsMouseDown(MOUSE_RIGHT) then
        if self.PieOpened then return true end
        self.PieOpened = true
        if gRust and gRust.OpenPieMenu then
            gRust.OpenPieMenu(self.PieMenu, function(i)
                self.SelectedBlock = i
                local selectedBuilding = self.PieMenu[i]
                if selectedBuilding and selectedBuilding.BuildingType then
                    self.LastPieMenuClose = CurTime()
                    net.Start("BuildingPlan.ChangeBuilding")
                    net.WriteString(selectedBuilding.BuildingType)
                    net.SendToServer()
                end
            end)
        end
        return true
    else
        if not self.PieOpened then return false end
        self.PieOpened = false
        self.LastPieMenuClose = CurTime()
        if gRust and gRust.ClosePieMenu then gRust.ClosePieMenu() end
    end
    return false
end

function SWEP:Think()
    self.LastPieMenuClose = self.LastPieMenuClose or 0
    self:UpdatePieMenu()

    local canPlace = (CurTime() - self.LastPieMenuClose) > 0.2
    local selectedBuilding = self:GetNetworkedString("selectedBuilding")

    if selectedBuilding then
        local ply  = self:GetOwner()
        local eyes = ply:EyePos()
        local aim  = ply:EyeAngles():Forward()
        
        local tr = util.TraceLine({
            start  = eyes,
            endpos = eyes + aim * 200,
            filter = function(ent) return ent ~= ply end
        })

        if ply:GetPos():Distance(tr.HitPos) > self.workDistance then
            if IsValid(self.ghostEntity) then self.ghostEntity:Remove() end
            return
        end

        local socket     = FindNearestSocket(selectedBuilding, tr.HitPos, 100)
        local canBuild   = false
        local finalPos   = nil
        local finalAng   = nil

        if socket then
            finalPos = socket.pos
            finalAng = socket.ang
            if ply:GetPos():Distance(finalPos) <= self.workDistance then
                canBuild = CanPlaceAtSocket(selectedBuilding, socket)
            end
        else
            finalPos = tr.HitPos
            finalAng = Angle(0, 0, 0)
            canBuild = false
        end

        self.CanActuallyBuild = canBuild
        ClientModel(self, canBuild and 0 or 1, finalPos, finalAng)
    end

    if input.WasMousePressed(MOUSE_LEFT) and canPlace and not self.PieOpened then
        if self.CanActuallyBuild then
            net.Start("Player.PrimaryAttack")
            net.WriteBool(false)
            net.SendToServer()
        end
    end
end

function SWEP:OnRemove()
    if IsValid(self.ghostEntity) then self.ghostEntity:Remove() end
    if self.PieOpened then
        self.PieOpened = false
        if gRust and gRust.ClosePieMenu then gRust.ClosePieMenu() end
    end
end

function SWEP:SecondaryAttack() return false end
