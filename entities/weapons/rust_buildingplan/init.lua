AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("Player.PrimaryAttack")
util.AddNetworkString("BuildingPlan.ChangeBuilding")

-- Р¤СѓРЅРєС†РёСЏ РїСЂРѕРІРµСЂРєРё Рё РІС‹С‡РµС‚Р° СЂРµСЃСѓСЂСЃРѕРІ
local function CheckAndDeductResources(ply, buildingType)
    if(!buildingsTable[buildingType] or !buildingsTable[buildingType]["cost"]) then
        return false
    end

    local cost = buildingsTable[buildingType]["cost"]
    
    -- Р•СЃР»Рё СЃС‚РѕРёРјРѕСЃС‚СЊ - СЌС‚Рѕ С‚Р°Р±Р»РёС†Р° СЃ РЅРµСЃРєРѕР»СЊРєРёРјРё СЂРµСЃСѓСЂСЃР°РјРё
    if(type(cost[1]) == "table") then
        -- РЎРЅР°С‡Р°Р»Р° РїСЂРѕРІРµСЂСЏРµРј РЅР°Р»РёС‡РёРµ РІСЃРµС… СЂРµСЃСѓСЂСЃРѕРІ
        for _, resource in ipairs(cost) do
            if(!ply:HasItem(resource.item, resource.amount)) then
                ply:ChatPrint("РќРµРґРѕСЃС‚Р°С‚РѕС‡РЅРѕ СЂРµСЃСѓСЂСЃРѕРІ! РќСѓР¶РЅРѕ: " .. resource.amount .. "x " .. resource.item)
                return false
            end
        end
        
        -- Р•СЃР»Рё РІСЃРµ СЂРµСЃСѓСЂСЃС‹ РµСЃС‚СЊ, РѕС‚РЅРёРјР°РµРј РёС…
        for _, resource in ipairs(cost) do
            if(!ply:RemoveItem(resource.item, resource.amount)) then
                ply:ChatPrint("РћС€РёР±РєР° РїСЂРё СѓРґР°Р»РµРЅРёРё СЂРµСЃСѓСЂСЃРѕРІ!")
                return false
            end
        end
    else
        -- Р•СЃР»Рё СЃС‚РѕРёРјРѕСЃС‚СЊ - СЌС‚Рѕ РѕРґРёРЅ СЂРµСЃСѓСЂСЃ
        if(!ply:HasItem(cost.item, cost.amount)) then
            ply:ChatPrint("РќРµРґРѕСЃС‚Р°С‚РѕС‡РЅРѕ СЂРµСЃСѓСЂСЃРѕРІ! РќСѓР¶РЅРѕ: " .. cost.amount .. "x " .. cost.item)
            return false
        end
        
        if(!ply:RemoveItem(cost.item, cost.amount)) then
            ply:ChatPrint("РћС€РёР±РєР° РїСЂРё СѓРґР°Р»РµРЅРёРё СЂРµСЃСѓСЂСЃРѕРІ!")
            return false
        end
    end
    
    return true
end

net.Receive("Player.PrimaryAttack", function(len, ply)
    ply:GetActiveWeapon():SetNetworkedBool("attack", true)
end)

net.Receive("BuildingPlan.ChangeBuilding", function(len, ply)
    local swep = ply:GetActiveWeapon()
    if not IsValid(swep) then return end
    
    local buildingType = net.ReadString()
    if buildingsTable[buildingType] then
        swep:SetNetworkedString("selectedBuilding", buildingType)
        ply:EmitSound("ui.blip")
    end
end)

function SWEP:Think()
    if(buildingsTable[self:GetNetworkedString("selectedBuilding")] == nil)then
        self:SetNetworkedString("selectedBuilding", "foundation")
    end

    if(!self:GetNetworkedBool("attack"))then return else self:SetNetworkedBool("attack", false) end

    if(self:GetNetworkedString("isUsable"))then
        if(self:GetOwner():GetNetworkedInt("buildingState") == 1)then return end

        -- РџСЂРѕРІРµСЂСЏРµРј СЂРµСЃСѓСЂСЃС‹ РїРµСЂРµРґ РїРѕСЃС‚СЂРѕР№РєРѕР№
        local selectedBuilding = self:GetNetworkedString("selectedBuilding")
        if(!CheckAndDeductResources(self:GetOwner(), selectedBuilding)) then
            return
        end

        OnAnyAction(self)

        local trace = self:GetOwner():GetEyeTrace()
        local curEnt = trace.Entity

        -- Р›РѕРіРёРєР° РїРѕРёСЃРєР° СЂРѕРґРёС‚РµР»СЊСЃРєРѕР№ СЃСѓС‰РЅРѕСЃС‚Рё
        if(!IsValid(curEnt))then
            if(IsValid(self:GetOwner():GetGroundEntity()))then
                if(HasParent(self:GetNetworkedString("selectedBuilding"), self:GetOwner():GetGroundEntity():GetNetworkedString("buildingtype")))then
                    curEnt = self:GetOwner():GetGroundEntity()
                else
                    local entities = ents.FindInSphere(self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward()*self.workDistance, 50)
                    if(#entities > 0)then
                        for k,v in pairs(entities) do
                            if(v:GetClass() == "rust_building")then
                                if(v:GetNetworkedString("buildingtype") != nil)then
                                    curEnt = v
                                    break
                                end
                            end
                        end
                    end
                end
            else
                local entities = ents.FindInSphere(self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward()*self.workDistance, 50)
                if(#entities > 0)then
                    for k,v in pairs(entities) do
                        if(v:GetClass() == "rust_building")then
                            if(v:GetNetworkedString("buildingtype") != nil)then
                                curEnt = v
                                break
                            end
                        end
                    end
                end
            end
        end

        if(self:GetNetworkedString("selectedBuilding") != nil)then
            local vectornewpos = trace.HitPos + buildingsTable[self:GetNetworkedString("selectedBuilding")]["pos"]

            if(buildingsTable[self:GetNetworkedString("selectedBuilding")]["parent"] != nil)then
                if(IsValid(curEnt))then
                    if(curEnt:GetNetworkedString("buildingtype") == self:GetNetworkedString("selectedBuilding"))then
                        -- РСЃРїРѕР»СЊР·СѓРµРј РЅРѕРІСѓСЋ СЃС‚СЂСѓРєС‚СѓСЂСѓ РїРѕР·РёС†РёР№
                        local parentType = curEnt:GetNetworkedString("buildingtype")
                        local positionNumber = GetNumberOfPosition(self:GetOwner():GetAngles())
                        local buildingPos, buildingAngle = GetBuildingPosition(self:GetNetworkedString("selectedBuilding"), parentType, positionNumber)
                        
                        vectornewpos = trace.HitPos + buildingPos + buildingsTable[self:GetNetworkedString("selectedBuilding")]["pos"]
                    end
                end
            end

            if(self:GetOwner():GetPos():Distance(vectornewpos) > self.workDistance) then
                vectornewpos = self:GetOwner():EyePos() + self:GetOwner():EyeAngles():Forward()*self.workDistance
            end

            -- Р›РѕРіРёРєР° СЃРѕР·РґР°РЅРёСЏ РїРѕСЃС‚СЂРѕР№РєРё СЃ СѓР»СѓС‡С€РµРЅРЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
            if(buildingsTable[self:GetNetworkedString("selectedBuilding")]['parent'] != nil)then
                if(IsValid(curEnt) && self:GetOwner():GetPos():Distance(curEnt:GetPos()) < self.workDistance)then
                    if(HasParent(self:GetNetworkedString("selectedBuilding"), curEnt:GetNetworkedString("buildingtype")))then
                        -- РСЃРїРѕР»СЊР·СѓРµРј РЅРѕРІСѓСЋ СЃС‚СЂСѓРєС‚СѓСЂСѓ РїРѕР·РёС†РёР№
                        local parentType = curEnt:GetNetworkedString("buildingtype")
                        local positionNumber = GetNumberOfPosition(self:GetOwner():GetAngles())
                        local buildingPos, buildingAngle = GetBuildingPosition(self:GetNetworkedString("selectedBuilding"), parentType, positionNumber)
                        
                        local buildPos = curEnt:GetPos() + buildingPos

                        if(CheckPosition(self:GetNetworkedString("selectedBuilding"), curEnt, buildPos, buildingsTable[self:GetNetworkedString("selectedBuilding")]["colradius"]))then
                            local building = ents.Create("rust_building")
                            building:SetModel(buildingsTable[self:GetNetworkedString("selectedBuilding")]["model"])
                            building:SetPos(buildPos)
                            
                            if(buildingsTable[self:GetNetworkedString("selectedBuilding")]['material'] != nil)then
                                building:SetMaterial(buildingsTable[self:GetNetworkedString("selectedBuilding")]['material'])
                            end
                            
                            building:SetAngles(curEnt:GetAngles() + buildingAngle)
                            building:SetNetworkedString("buildingtype", self:GetNetworkedString("selectedBuilding"))
                            building:SetNetworkedString("buildtier", "twig")
                            building.player = self:GetOwner()
                            building:SetNetworkedString("parent", curEnt)
                            building:Spawn()
                            building:SetMaxHealth(100)
                            building:SetHealth(100)
                            
                            self:GetOwner():EmitSound("zohart/building/hammer-saw-"..math.random(1,3)..".wav")
                        end
                    end
                else
                    if(HasParent(self:GetNetworkedString("selectedBuilding"), 'map'))then
                        if(CheckPosition(self:GetNetworkedString("selectedBuilding"), curEnt, vectornewpos, buildingsTable[self:GetNetworkedString("selectedBuilding")]["colradius"]))then
                            local building = ents.Create("rust_building")
                            building:SetModel(buildingsTable[self:GetNetworkedString("selectedBuilding")]["model"])
                            
                            if(buildingsTable[self:GetNetworkedString("selectedBuilding")]['material'] != nil)then
                                building:SetMaterial(buildingsTable[self:GetNetworkedString("selectedBuilding")]['material'])
                            end
                            
                            building:SetPos(vectornewpos)
                            building:SetNetworkedString("buildingtype", self:GetNetworkedString("selectedBuilding"))
                            building:SetNetworkedString("buildtier", "twig")
                            building.player = self:GetOwner()
                            building:Spawn()
                            building:SetMaxHealth(100)
                            building:SetHealth(100)
                            
                            self:GetOwner():EmitSound("zohart/building/hammer-saw-"..math.random(1,3)..".wav")
                        end
                    end
                end
            else
                if(CheckPosition(self:GetNetworkedString("selectedBuilding"), curEnt, vectornewpos, buildingsTable[self:GetNetworkedString("selectedBuilding")]["colradius"]))then
                    local building = ents.Create("rust_building")
                    building:SetModel(buildingsTable[self:GetNetworkedString("selectedBuilding")]["model"])
                    
                    if(buildingsTable[self:GetNetworkedString("selectedBuilding")]['material'] != nil)then
                        building:SetMaterial(buildingsTable[self:GetNetworkedString("selectedBuilding")]['material'])
                    end
                    
                    building:SetPos(vectornewpos)
                    building:SetNetworkedString("buildingtype", self:GetNetworkedString("selectedBuilding"))
                    building:SetNetworkedString("buildtier", "twig")
                    building.player = self:GetOwner()
                    building:Spawn()
                    building:SetMaxHealth(100)
                    building:SetHealth(100)
                    
                    self:GetOwner():EmitSound("zohart/building/hammer-saw-"..math.random(1,3)..".wav")
                end
            end
        end
    end
end