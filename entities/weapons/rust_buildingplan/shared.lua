table.IndexByKey = function(tab, key)
    local i = 0
    for k,v in pairs(tab) do
        i = i + 1
        if(k == key)then
            return i
        end
    end
    return nil
end

SWEP.PrintName = "Building Plan"
SWEP.Author = "Zohart"
SWEP.Instructions = "Left mouse to place, Right mouse for pie menu"
SWEP.Category = "GRust"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false  
SWEP.ViewModel = ""
SWEP.WorldModel = "models/darky_m/rust/w_buildingplan.mdl"
SWEP.ShootSound = Sound("Metal.SawbladeStick")
SWEP.workDistance = 300

SWEP.PieMenu = {
    [1] = {
        Name = "Floor Frame",
        Icon = "materials/icons/build/floor_frame.png",
        Desc = "Floor frame for building structure",
        Foot = "50x Wood",
        Model = "models/building_re/twig_fframe.mdl",
        BuildingType = "fframe"
    },
    [2] = {
        Name = "Wall",
        Icon = "materials/icons/build/wall.png",
        Desc = "Wall for protection",
        Foot = "50x Wood",
        Model = "models/building_re/twig_wall.mdl",
        BuildingType = "wall"
    },
    [3] = {
        Name = "Door Frame",
        Icon = "materials/icons/build/doorframe.png",
        Desc = "Door frame for entrance",
        Foot = "50x Wood",
        Model = "models/building_re/twig_dframe.mdl",
        BuildingType = "dframe"
    },
    [4] = {
        Name = "Window Frame",
        Icon = "materials/icons/build/wall_window.png",
        Desc = "Window frame for ventilation",
        Foot = "50x Wood",
        Model = "models/building_re/twig_wind.mdl",
        BuildingType = "wind"
    },
    [5] = {
        Name = "Wall Frame",
        Icon = "materials/icons/build/wall_frame.png",
        Desc = "Wall frame for structure",
        Foot = "50x Wood",
        Model = "models/building_re/twig_gframe.mdl",
        BuildingType = "gframe"
    },
    [6] = {
        Name = "Half Wall",
        Icon = "materials/icons/build/wall_half.png",
        Desc = "Half wall for partial protection",
        Foot = "50x Wood",
        Model = "models/building_re/twig_hwall.mdl",
        BuildingType = "hwall"
    },
    [7] = {
        Name = "Low Wall",
        Icon = "materials/icons/build/wall_low.png",
        Desc = "Low wall for barrier",
        Foot = "50x Wood",
        Model = "models/building_re/twig_twall.mdl",
        BuildingType = "twall"
    },
    [8] = {
        Name = "U Stairs",
        Icon = "materials/icons/build/stairs_u.png",
        Desc = "U-shaped stairs for vertical access",
        Foot = "50x Wood",
        Model = "models/building_re/twig_ust.mdl",
        BuildingType = "ust"
    },
    [9] = {
        Name = "L Stairs",
        Icon = "materials/icons/build/stairs_l.png",
        Desc = "L-shaped stairs for vertical access",
        Foot = "50x Wood",
        Model = "models/building_re/twig_lst.mdl",
        BuildingType = "lst"
    },
    [10] = {
        Name = "Roof",
        Icon = "materials/icons/build/roof.png",
        Desc = "Roof for weather protection",
        Foot = "50x Wood",
        Model = "models/building_re/twig_floor_trig.mdl",
        BuildingType = "roof"
    },
    [11] = {
        Name = "Foundation",
        Icon = "materials/icons/build/foundation.png",
        Desc = "Foundation for building base",
        Foot = "50x Wood",
        Model = "models/building_re/twig_foundation.mdl",
        BuildingType = "foundation"
    },
    [12] = {
        Name = "Triangle Foundation",
        Icon = "materials/icons/build/triangle_foundation.png",
        Desc = "Triangle foundation for corners",
        Foot = "50x Wood",
        Model = "models/building_re/twig_foundation_trig.mdl",
        BuildingType = "foundation_trig"
    },
    [13] = {
        Name = "Foundation Steps",
        Icon = "materials/icons/build/foundation_steps.png",
        Desc = "Foundation steps for access",
        Foot = "50x Wood",
        Model = "models/building_re/twig_steps.mdl",
        BuildingType = "steps"
    },
    [14] = {
        Name = "Floor",
        Icon = "materials/icons/build/floor.png",
        Desc = "Floor for building",
        Foot = "50x Wood",
        Model = "models/building_re/twig_floor.mdl",
        BuildingType = "floor"
    },
    [15] = {
        Name = "Floor Triangle",
        Icon = "materials/icons/build/floor_triangle.png",
        Desc = "Triangle floor for corners",
        Foot = "50x Wood",
        Model = "models/building_re/twig_floor_trig.mdl",
        BuildingType = "floor_trig"
    }
}

-- Функция для автоматической генерации сокетов
local function GenerateSockets(socketType, distance, height, count, startAngle, includeIds)
    local sockets = {}
    local angleStep = 360 / count
    local startId = includeIds and #includeIds + 1 or 1
    
    for i = 1, count do
        local angle = startAngle + (i - 1) * angleStep
        local radians = math.rad(angle)
        local x = math.sin(radians) * distance
        local y = -math.cos(radians) * distance
        
        table.insert(sockets, {
            type = socketType,
            pos = Vector(x, y, height or 0),
            ang = Angle(0, angle, 0),
            id = startId + i - 1
        })
    end
    
    return sockets
end

-- Функция для объединения сокетов
local function CombineSockets(...)
    local result = {}
    local currentId = 1
    
    for _, socketGroup in ipairs({...}) do
        for _, socket in ipairs(socketGroup) do
            socket.id = currentId
            table.insert(result, socket)
            currentId = currentId + 1
        end
    end
    
    return result
end

buildingsTable = {
    ["foundation"] = {
        ["model"] = "models/building_re/twig_foundation.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 64,
        ["cost"] = {item = "wood", amount = 50},
        ["sockets"] = CombineSockets(   
            GenerateSockets("foundation", 129, 0, 4, 0),     -- 4 foundation сокета
            GenerateSockets("wall", 64.5, 0, 4, 0),          -- 4 wall сокета
            GenerateSockets("steps", 94, -32, 4, 0)          -- 4 steps сокета
        ),
        ["socket"] = {"foundation", "map"}
    },
    
    ["foundation_trig"] = {
        ["model"] = "models/building_re/twig_foundation_trig.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 55,
        ["cost"] = {item = "wood", amount = 35},
        ["sockets"] = CombineSockets(
            GenerateSockets("foundation_trig",0,0,0), -- 3 foundation_trig сокета
            GenerateSockets("wall", 37.5, 0, 3, 180)           -- 3 wall сокета (другие позиции)
        ),
        ["socket"] = {"foundation", "map"}
    },
    
    ["wall"] = {
        ["model"] = "models/building_re/twig_wall.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 15,
        ["cost"] = {item = "wood", amount = 25},
        ["sockets"] = {
            {type = "floor", pos = Vector(0,-65,130), ang = Angle(0,0,0), id = 1}
        },
        ["socket"] = {"wall"}
    },
    
    ["wind"] = {
        ["model"] = "models/building_re/twig_wind.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 15,
        ["cost"] = {item = "wood", amount = 25},
        ["sockets"] = {
            {type = "floor", pos = Vector(0,65,130), ang = Angle(0,0,0), id = 1}
        },
        ["socket"] = {"wall"}
    },
    
    ["dframe"] = {
        ["model"] = "models/building_re/twig_dframe.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 15,
        ["cost"] = {item = "wood", amount = 25},
        ["sockets"] = {
            {type = "floor", pos = Vector(0,65,130), ang = Angle(0,0,0), id = 1},
            {type = "door", pos = Vector(-25,0,4), ang = Angle(0,0,0), id = 2}
        },
        ["socket"] = {"wall"}
    },
    
    
    ["gframe"] = {
        ["model"] = "models/building_re/twig_gframe.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 15,
        ["cost"] = {item = "wood", amount = 25},
        ["sockets"] = {
            {type = "floor", pos = Vector(0,65,130), ang = Angle(0,0,0), id = 1}
        },
        ["socket"] = {"wall"}
    },
    
    ["hwall"] = {
        ["model"] = "models/building_re/twig_hwall.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 15,
        ["cost"] = {item = "wood", amount = 15},
        ["sockets"] = {
            {type = "floor", pos = Vector(0,65,65), ang = Angle(0,0,0), id = 1}
        },
        ["socket"] = {"wall"}
    },
    
    ["twall"] = {
        ["model"] = "models/building_re/twig_twall.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 15,
        ["cost"] = {item = "wood", amount = 10},
        ["sockets"] = {},
        ["socket"] = {"wall"}
    },
    
    ["floor"] = {
        ["model"] = "models/building_re/twig_floor.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 64,
        ["cost"] = {item = "wood", amount = 30},
        ["sockets"] = CombineSockets(
            GenerateSockets("wall", 64.5, 0, 4, 0),      -- 4 wall сокета
            GenerateSockets("stairs", 94, 0, 4, 0)       -- 4 stairs сокета
        ),
        ["socket"] = {"floor"}
    },
    
    ["fframe"] = {
        ["model"] = "models/building_re/twig_fframe.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 64,
        ["cost"] = {item = "wood", amount = 25},
        ["sockets"] = CombineSockets(
            GenerateSockets("wall", 64.5, 0, 4, 0),      -- 4 wall сокета
            {{type = "floor", pos = Vector(0,0,96), ang = Angle(0,0,0), id = 0}}, -- 1 floor сокет
            GenerateSockets("stairs", 94, 0, 4, 0)       -- 4 stairs сокета
        ),
        ["socket"] = {"floor"}
    },
    
    ["floor_trig"] = {
        ["model"] = "models/building_re/twig_floor_trig.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 55,
        ["cost"] = {item = "wood", amount = 20},
        ["sockets"] = CombineSockets(
            GenerateSockets("wall", 37.5, 0, 3, 180),    -- 3 wall сокета
            {{type = "floor", pos = Vector(0,0,96), ang = Angle(0,0,0), id = 0}} -- 1 floor сокет
        ),
        ["socket"] = {"floor"}
    },
    
    ["steps"] = {
        ["model"] = "models/building_re/twig_steps.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 30,
        ["cost"] = {item = "wood", amount = 20},
        ["sockets"] = {},
        ["socket"] = {"steps"}
    },
    
    ["lst"] = {
        ["model"] = "models/building_re/twig_lst.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 30,
        ["cost"] = {item = "wood", amount = 35},
        ["sockets"] = {
            {type = "floor", pos = Vector(0,0,96), ang = Angle(0,0,0), id = 1}
        },
        ["socket"] = {"stairs"}
    },
    
    ["ust"] = {
        ["model"] = "models/building_re/twig_ust.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 30,
        ["cost"] = {item = "wood", amount = 40},
        ["sockets"] = {
            {type = "floor", pos = Vector(0,0,96), ang = Angle(0,0,0), id = 1}
        },
        ["socket"] = {"stairs"}
    },
    
    ["roof"] = {
        ["model"] = "models/building_re/twig_floor_trig.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0,0,0),
        ["colradius"] = 64,
        ["cost"] = {item = "wood", amount = 35},
        ["sockets"] = {},
        ["socket"] = {"floor"}
    }
}


function GetSocketsFromEntity(entity)
    if not IsValid(entity) then return {} end
    local buildingType = entity:GetNetworkedString("buildingtype")
    if not buildingsTable[buildingType] or not buildingsTable[buildingType].sockets then return {} end
    
    local sockets = {}
    local entPos = entity:GetPos()
    local entAng = entity:GetAngles()
    
    for i, socket in ipairs(buildingsTable[buildingType].sockets) do
        local worldPos = entPos + entAng:Forward() * socket.pos.x + entAng:Right() * socket.pos.y + entAng:Up() * socket.pos.z
        local worldAng = entAng + socket.ang
        
        table.insert(sockets, {
            type = socket.type,
            pos = worldPos,
            ang = worldAng,
            id = socket.id,
            entity = entity,
            occupied = IsSocketOccupied(worldPos, socket.type, entity)  -- Передаем родительскую постройку
        })
    end
    
    return sockets
end


function IsSocketOccupied(pos, socketType, parentEntity)
    local entities = ents.FindInSphere(pos, 15)
    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent:GetClass() == "rust_building" then
            if ent != parentEntity then
                local distance = pos:Distance(ent:GetPos())
                if distance < 20 then
                    return true
                end
            end
        end
    end
    return false
end


function FindNearestSocket(buildingType, pos, maxDistance)
    if not buildingsTable[buildingType] or not buildingsTable[buildingType].socket then
        return nil
    end

    local compatibleTypes = buildingsTable[buildingType].socket
    local nearestSocket = nil
    local nearestDistance = maxDistance or 300
    local mapSocket = nil

    local entities = ents.FindInSphere(pos, maxDistance or 300)
    for _, entity in ipairs(entities) do
        if IsValid(entity) and entity:GetClass() == "rust_building" then
            local sockets = GetSocketsFromEntity(entity)
            for _, socket in ipairs(sockets) do
                if table.HasValue(compatibleTypes, socket.type) and not socket.occupied then
                    local distance = pos:Distance(socket.pos)
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestSocket = socket
                    end
                end
            end
        end
    end

    if not nearestSocket and (buildingType == "foundation" or buildingType == "foundation_trig") and table.HasValue(compatibleTypes, "map") then
        local trace = {
            start = pos + Vector(0, 0, 50),
            endpos = pos + Vector(0, 0, -200),
            filter = function(ent) return ent:GetClass() != "rust_building" end
        }
        local tr = util.TraceLine(trace)
        if tr.Hit then
            nearestSocket = {
                type = "map",
                pos = pos,
                ang = Angle(0, 0, 0),
                entity = tr.Entity,
                id = 0,
                occupied = false
            }
        end
    end

    return nearestSocket
end


function CanPlaceAtSocket(buildingType, socket)
    if not socket or not buildingsTable[buildingType] then
        return false
    end
    
    if socket.occupied then
        return false
    end
    
    local compatibleTypes = buildingsTable[buildingType].socket or {}
    if not table.HasValue(compatibleTypes, socket.type) then
        return false
    end
    
    if socket.type == "map" then
        if buildingType == "foundation" or buildingType == "foundation_trig" then
            return CheckGroundSupport(socket.pos, buildingType)
        else
            return false
        end
    end
    
    return CheckPosition(buildingType, socket.entity, socket.pos, buildingsTable[buildingType].colradius)
end

function GetBuildingInfo(buildingType)
    return buildingsTable[buildingType]
end

function CheckPosition(selb, ent, pos, radius)
    if not CheckGroundSupport(pos, selb) then
        return false
    end

    local nearbyEnts = ents.FindInSphere(pos, radius)
    if #nearbyEnts > 0 then
        for k, v in pairs(nearbyEnts) do
            if IsValid(v) and v:GetClass() == "rust_building" then
                if v != ent then
                    local distance = pos:Distance(v:GetPos())
                    if distance < radius then
                        return false
                    end
                end
            end
        end
    end
    return true
end

function CheckGroundSupport(pos, buildingType)
    if buildingType != "foundation" and buildingType != "foundation_trig" then
        return true
    end

    local traceDown = {
        start = pos,
        endpos = pos + Vector(0, 0, -120),
        filter = function(ent)
            return ent:GetClass() != "rust_building"
        end
    }

    local tr = util.TraceLine(traceDown)

    if tr.Hit then
        if IsValid(tr.Entity) then
            local entClass = tr.Entity:GetClass()
            if entClass == "worldspawn" or entClass == "func_detail" or entClass == "prop_physics" then
                return true
            end
            return false
        else
            return true
        end
    end
    return false
end

function OnAnyAction(swep)
    if(SERVER)then
        if(!timer.Exists("buildingtoolusetimer"..swep:GetCreationID()))then
            swep:SetNetworkedBool("isUsable", false)
            timer.Create("buildingtoolusetimer"..swep:GetCreationID(), 0.2, 0, function()
                swep:SetNetworkedBool("isUsable", true)
                timer.Remove("buildingtoolusetimer"..swep:GetCreationID())
            end)
        end
    end
end

function SWEP:Initialize()
    self:SetNetworkedBool("isUsable", true)
    self:SetNetworkedString("selectedBuilding", "foundation")
    self.SelectedBlock = 1
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Reload()
    return false
end
