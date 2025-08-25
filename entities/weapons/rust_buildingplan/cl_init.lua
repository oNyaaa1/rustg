include("shared.lua")
local function ClientModel(swep, status, pos, rot)
    if not IsValid(swep.ghostEntity) then
        swep.ghostEntity = ClientsideModel(buildingsTable[swep:GetNetworkedString("selectedBuilding")]["model"])
        swep.ghostEntity:SetPos(pos)
        swep.ghostEntity:SetAngles(rot)
        swep.ghostEntity.RenderOverride = function(swep)
            render.SuppressEngineLighting(true)
            swep:DrawModel()
            render.SuppressEngineLighting(false)
        end

        swep.ghostEntity:SetRenderMode(RENDERMODE_TRANSALPHA)
        swep.ghostEntity:SetMaterial("models/debug/debugwhite")
        return
    elseif swep.ghostEntity:GetModel() ~= buildingsTable[swep:GetNetworkedString("selectedBuilding")]['model'] then
        swep.ghostEntity:SetModel(buildingsTable[swep:GetNetworkedString("selectedBuilding")]['model'])
    end

    swep.ghostEntity:SetPos(pos)
    swep.ghostEntity:SetAngles(rot)
    -- Р”РѕРїРѕР»РЅРёС‚РµР»СЊРЅР°СЏ РїСЂРѕРІРµСЂРєР° РґР»СЏ С„СѓРЅРґР°РјРµРЅС‚Р°
    local canPlace = status == 0
    if swep:GetNetworkedString("selectedBuilding") == "foundation" then canPlace = canPlace and CheckGroundSupport(pos, "foundation") end
    if canPlace then
        swep.ghostEntity:SetColor(Color(0, 157, 255, 220)) -- РЎРёРЅРёР№ - РјРѕР¶РЅРѕ СЃС‚СЂРѕРёС‚СЊ
    else
        swep.ghostEntity:SetColor(Color(255, 0, 0, 220)) -- РљСЂР°СЃРЅС‹Р№ - РЅРµР»СЊР·СЏ СЃС‚СЂРѕРёС‚СЊ
    end
end

-- Р¤СѓРЅРєС†РёСЏ РїРѕР»СѓС‡РµРЅРёСЏ РїРѕР·РёС†РёРё Рё СѓРіР»Р° РґР»СЏ РЅРѕРІРѕР№ СЃС‚СЂСѓРєС‚СѓСЂС‹ СЃ fallback
local function GetBuildingPositionAndAngle(buildingType, parentType, positionNumber)
    -- РџСЂРѕРІРµСЂСЏРµРј РЅР°Р»РёС‡РёРµ РіР»РѕР±Р°Р»СЊРЅРѕР№ С„СѓРЅРєС†РёРё
    if GetPositionsForParent then
        local positions = GetPositionsForParent(buildingType, parentType)
        if positions and positions[positionNumber] then return positions[positionNumber]["position"], positions[positionNumber]["angle"] end
    end

    -- Fallback: РїСЂСЏРјРѕРµ РѕР±СЂР°С‰РµРЅРёРµ Рє buildingsTable
    if buildingsTable[buildingType] and buildingsTable[buildingType]["parent"] and buildingsTable[buildingType]["parent"]["positions"] then
        local posData = buildingsTable[buildingType]["parent"]["positions"]
        -- РќРѕРІР°СЏ СЃС‚СЂСѓРєС‚СѓСЂР° (СЃ С‚РёРїР°РјРё СЂРѕРґРёС‚РµР»РµР№)
        if posData[parentType] and posData[parentType][positionNumber] then return posData[parentType][positionNumber]["position"], posData[parentType][positionNumber]["angle"] end
        -- РЎС‚Р°СЂР°СЏ СЃС‚СЂСѓРєС‚СѓСЂР° (РґР»СЏ СЃРѕРІРјРµСЃС‚РёРјРѕСЃС‚Рё)
        if posData[positionNumber] and posData[positionNumber]["position"] then return posData[positionNumber]["position"], posData[positionNumber]["angle"] end
    end
    return Vector(0, 0, 0), Angle(0, 0, 0)
end

function SWEP:PreviewChanged()
    if IsValid(self.ghostEntity) then self.ghostEntity:Remove() end
end

function SWEP:Deploy()
    if not self.SelectedBlock then self.SelectedBlock = 1 end
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

-- РСЃРїСЂР°РІР»РµРЅРЅР°СЏ РёРЅС‚РµРіСЂР°С†РёСЏ pie menu СЃ Р·Р°С‰РёС‚РѕР№ РѕС‚ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРѕРіРѕ СЂР°Р·РјРµС‰РµРЅРёСЏ
function SWEP:UpdatePieMenu()
    if input.IsMouseDown(MOUSE_RIGHT) then
        if self.PieOpened then return end
        self.PieOpened = true
        if gRust and gRust.OpenPieMenu then
            gRust.OpenPieMenu(self.PieMenu, function(i)
                self.SelectedBlock = i
                local selectedBuilding = self.PieMenu[i]
                if selectedBuilding and selectedBuilding.BuildingType then
                    -- РЈСЃС‚Р°РЅР°РІР»РёРІР°РµРј РІСЂРµРјСЏ Р·Р°РєСЂС‹С‚РёСЏ РјРµРЅСЋ РґР»СЏ РїСЂРµРґРѕС‚РІСЂР°С‰РµРЅРёСЏ Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРѕРіРѕ СЂР°Р·РјРµС‰РµРЅРёСЏ
                    self.LastPieMenuClose = CurTime()
                    net.Start("BuildingPlan.ChangeBuilding")
                    net.WriteString(selectedBuilding.BuildingType)
                    net.SendToServer()
                end
            end)
        end
    else
        if not self.PieOpened then return end
        self.PieOpened = false
        -- Р—Р°РїРёСЃС‹РІР°РµРј РІСЂРµРјСЏ Р·Р°РєСЂС‹С‚РёСЏ РјРµРЅСЋ
        self.LastPieMenuClose = CurTime()
        if gRust and gRust.ClosePieMenu then gRust.ClosePieMenu() end
    end
end

function SWEP:Think()
    -- РРЅРёС†РёР°Р»РёР·РёСЂСѓРµРј РІСЂРµРјСЏ Р·Р°РєСЂС‹С‚РёСЏ pie menu РµСЃР»Рё РЅРµ СѓСЃС‚Р°РЅРѕРІР»РµРЅРѕ
    if not self.LastPieMenuClose then self.LastPieMenuClose = 0 end
    -- РћР±РЅРѕРІР»СЏРµРј pie menu
    self:UpdatePieMenu()
    -- Р‘Р»РѕРєРёСЂСѓРµРј СЂР°Р·РјРµС‰РµРЅРёРµ Р·РґР°РЅРёР№ СЃСЂР°Р·Сѓ РїРѕСЃР»Рµ Р·Р°РєСЂС‹С‚РёСЏ pie menu
    local timeSincePieMenuClose = CurTime() - self.LastPieMenuClose
    local canPlace = timeSincePieMenuClose > 0.2 -- Р—Р°РґРµСЂР¶РєР° 200РјСЃ РїРѕСЃР»Рµ Р·Р°РєСЂС‹С‚РёСЏ pie menu
    local trace = self:GetOwner():GetEyeTrace()
    local curEnt = trace.Entity
    if not IsValid(curEnt) then
        if IsValid(self:GetOwner():GetGroundEntity()) then
            if HasParent(self:GetNetworkedString("selectedBuilding"), self:GetOwner():GetGroundEntity():GetNetworkedString("buildingtype")) then
                curEnt = self:GetOwner():GetGroundEntity()
            else
                local entities = ents.FindInSphere(self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * self.workDistance, 50)
                if #entities > 0 then
                    for k, v in pairs(entities) do
                        if v:GetClass() == "rust_building" then
                            if v:GetNetworkedString("buildingtype") ~= nil then
                                curEnt = v
                                break
                            end
                        end
                    end
                end
            end
        else
            local entities = ents.FindInSphere(self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * self.workDistance, 50)
            if #entities > 0 then
                for k, v in pairs(entities) do
                    if v:GetClass() == "rust_building" then
                        if v:GetNetworkedString("buildingtype") ~= nil then
                            curEnt = v
                            break
                        end
                    end
                end
            end
        end
    end

    if self:GetNetworkedString("selectedBuilding") ~= nil then
        local selectedBuilding = self:GetNetworkedString("selectedBuilding")
        local vectornewpos = trace.HitPos + buildingsTable[selectedBuilding]["pos"]
        if buildingsTable[selectedBuilding]["parent"] ~= nil then
            if IsValid(curEnt) then
                if curEnt:GetNetworkedString("buildingtype") == selectedBuilding then
                    -- РџРѕР»СѓС‡Р°РµРј РїРѕР·РёС†РёСЋ СЃ РёСЃРїРѕР»СЊР·РѕРІР°РЅРёРµРј РЅРѕРІРѕР№ СЃС‚СЂСѓРєС‚СѓСЂС‹
                    local parentType = curEnt:GetNetworkedString("buildingtype")
                    local positionNumber = GetNumberOfPosition(self:GetOwner():GetAngles())
                    local buildingPos, buildingAngle = GetBuildingPositionAndAngle(selectedBuilding, parentType, positionNumber)
                    vectornewpos = trace.HitPos + buildingPos + buildingsTable[selectedBuilding]["pos"]
                end
            end
        end

        if self:GetOwner():GetPos():Distance(vectornewpos) > self.workDistance then vectornewpos = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward() * self.workDistance end
        if buildingsTable[selectedBuilding]['parent'] ~= nil then
            if IsValid(curEnt) and self:GetOwner():GetPos():Distance(curEnt:GetPos()) < self.workDistance then
                if HasParent(selectedBuilding, curEnt:GetNetworkedString("buildingtype")) then
                    -- РСЃРїРѕР»СЊР·СѓРµРј РЅРѕРІСѓСЋ СЃС‚СЂСѓРєС‚СѓСЂСѓ РґР»СЏ РїРѕР»СѓС‡РµРЅРёСЏ РїРѕР·РёС†РёРё Рё СѓРіР»Р°
                    local parentType = curEnt:GetNetworkedString("buildingtype")
                    local positionNumber = GetNumberOfPosition(self:GetOwner():GetAngles())
                    local buildingPos, buildingAngle = GetBuildingPositionAndAngle(selectedBuilding, parentType, positionNumber)
                    local finalPos = curEnt:GetPos() + buildingPos
                    local finalAngle = curEnt:GetAngles() + buildingAngle
                    if CheckPosition(selectedBuilding, curEnt, finalPos, buildingsTable[selectedBuilding]["colradius"]) then
                        ClientModel(self, 0, finalPos, finalAngle)
                    else
                        ClientModel(self, 1, finalPos, finalAngle)
                    end
                else
                    ClientModel(self, 1, vectornewpos, Angle(0, 0, 0))
                end
            else
                if CheckPosition(selectedBuilding, curEnt, vectornewpos, buildingsTable[selectedBuilding]["colradius"]) then
                    if HasParent(selectedBuilding, 'map') then
                        -- Р”Р»СЏ СЂР°Р·РјРµС‰РµРЅРёСЏ РЅР° РєР°СЂС‚Рµ РёСЃРїРѕР»СЊР·СѓРµРј РїРѕР·РёС†РёСЋ map РёР· РЅРѕРІРѕР№ СЃС‚СЂСѓРєС‚СѓСЂС‹
                        local mapPos, mapAngle = GetBuildingPositionAndAngle(selectedBuilding, "map", 1)
                        ClientModel(self, 0, vectornewpos, curEnt:GetAngles() + mapAngle)
                    else
                        ClientModel(self, 1, vectornewpos, Angle(0, 0, 0))
                    end
                else
                    ClientModel(self, 1, vectornewpos, Angle(0, 0, 0))
                end
            end
        else
            if CheckPosition(selectedBuilding, curEnt, vectornewpos, buildingsTable[selectedBuilding]["colradius"]) then
                ClientModel(self, 0, vectornewpos, Angle(0, 0, 0))
            else
                ClientModel(self, 1, vectornewpos, Angle(0, 0, 0))
            end
        end
    end

    if input.WasMousePressed(MOUSE_LEFT) and canPlace and not self.PieOpened then
        net.Start("Player.PrimaryAttack")
        net.WriteBool(false)
        net.SendToServer()
    end
end

function SWEP:OnRemove()
    if IsValid(self.ghostEntity) then self.ghostEntity:Remove() end
    if self.PieOpened then
        self.PieOpened = false
        if gRust and gRust.ClosePieMenu then gRust.ClosePieMenu() end
    end
end