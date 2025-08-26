AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("Player.PrimaryAttack")
util.AddNetworkString("BuildingPlan.ChangeBuilding")

local function CheckAndDeductResources(ply, buildingType)
    if not buildingsTable[buildingType] or not buildingsTable[buildingType]["cost"] then return false end
    local cost = buildingsTable[buildingType]["cost"]

    if type(cost[1]) == "table" then
        for _, resource in ipairs(cost) do
            if not ply:HasItem(resource.item, resource.amount) then
                CONFIG:SendLanguage("dont_have", resource.amount .. "x " .. resource.item, ply)
                return false
            end
        end
        for _, resource in ipairs(cost) do
            if not ply:RemoveItem(resource.item, resource.amount) then
                CONFIG:SendLanguage("not_enough_resources", "", ply)
                return false
            end
        end
    else
        if not ply:HasItem(cost.item, cost.amount) then
            CONFIG:SendLanguage("not_enough_resources", cost.amount .. "x " .. cost.item, ply)
            return false
        end
        if not ply:RemoveItem(cost.item, cost.amount) then
            CONFIG:SendLanguage("error_removing", cost.amount .. "x " .. cost.item, ply)
            return false
        end
    end
    return true
end

net.Receive("Player.PrimaryAttack", function(len, ply) ply:GetActiveWeapon():SetNetworkedBool("attack", true) end)

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
    if buildingsTable[self:GetNetworkedString("selectedBuilding")] == nil then 
        self:SetNetworkedString("selectedBuilding", "foundation") 
    end

    if not self:GetNetworkedBool("attack") then
        return
    else
        self:SetNetworkedBool("attack", false)
    end

    if self:GetNetworkedString("isUsable") then
        if self:GetOwner():GetNetworkedInt("buildingState") == 1 then return end

        local selectedBuilding = self:GetNetworkedString("selectedBuilding")
        local trace = self:GetOwner():GetEyeTrace()
        
        local socket = FindNearestSocket(selectedBuilding, trace.HitPos, self.workDistance)
        
        if not socket then
            return
        end
        
        local finalPos = socket.pos
        local finalAng = socket.ang
        local distanceToPlayer = self:GetOwner():GetPos():Distance(finalPos)
        
        if distanceToPlayer > self.workDistance then
            return
        end
        
        if not CanPlaceAtSocket(selectedBuilding, socket) then
            return
        end
        
        if not CheckAndDeductResources(self:GetOwner(), selectedBuilding) then return end
        
        OnAnyAction(self)
        
        local building = ents.Create("rust_building")
        building:SetModel(buildingsTable[selectedBuilding]["model"])
        building:SetPos(finalPos)
        
        if buildingsTable[selectedBuilding]['material'] != nil then 
            building:SetMaterial(buildingsTable[selectedBuilding]['material']) 
        end
        
        building:SetAngles(finalAng)
        building:SetNetworkedString("buildingtype", selectedBuilding)
        building:SetNetworkedString("buildtier", "twig")
        building.player = self:GetOwner()
        
        if socket.entity and IsValid(socket.entity) then
            building:SetNetworkedString("parent", socket.entity)
        end
        
        building:Spawn()
        building:SetMaxHealth(100)
        building:SetHealth(100)
        self:GetOwner():EmitSound("zohart/building/hammer-saw-" .. math.random(1, 3) .. ".wav")
    end
end

function SWEP:SecondaryAttack()
    return false
end
