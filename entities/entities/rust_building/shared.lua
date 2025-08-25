ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Rust Building"
ENT.Author = "Zohart"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "GRust"
-- Система сокетов для строительных элементов
ENT.SOCKET_TYPES = {
    WALL = "wall_socket",
    FLOOR = "floor_socket",
    FOUNDATION = "foundation_socket",
    ATTACHMENT = "attachment_socket"
}

-- Позиции сокетов для каждого типа строения
ENT.BUILDING_SOCKETS = {
    ["foundation"] = {
        {
            type = "FOUNDATION",
            pos = Vector(0, -129, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "FOUNDATION",
            pos = Vector(129, 0, 0),
            ang = Angle(0, 0, 0),
            dir = "east"
        },
        {
            type = "FOUNDATION",
            pos = Vector(-129, 0, 0),
            ang = Angle(0, 0, 0),
            dir = "west"
        },
        {
            type = "FOUNDATION",
            pos = Vector(0, 129, 0),
            ang = Angle(0, 0, 0),
            dir = "south"
        },
        {
            type = "WALL",
            pos = Vector(0, -41, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(41, 0, 0),
            ang = Angle(0, 90, 0),
            dir = "east"
        },
        {
            type = "WALL",
            pos = Vector(-41, 0, 0),
            ang = Angle(0, -90, 0),
            dir = "west"
        },
        {
            type = "WALL",
            pos = Vector(0, 41, 0),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 30),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["foundation_triangle"] = {
        {
            type = "FOUNDATION",
            pos = Vector(0, -90, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "FOUNDATION",
            pos = Vector(90, 45, 0),
            ang = Angle(0, 120, 0),
            dir = "east"
        },
        {
            type = "FOUNDATION",
            pos = Vector(-90, 45, 0),
            ang = Angle(0, -120, 0),
            dir = "west"
        },
        {
            type = "WALL",
            pos = Vector(0, -40, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(40, 20, 0),
            ang = Angle(0, 120, 0),
            dir = "east"
        },
        {
            type = "WALL",
            pos = Vector(-40, 20, 0),
            ang = Angle(0, -120, 0),
            dir = "west"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 30),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["wall"] = {
        {
            type = "WALL",
            pos = Vector(0, -61, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(0, 61, 0),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        },
        {
            type = "ATTACHMENT",
            pos = Vector(0, 0, 61),
            ang = Angle(0, 0, 0),
            dir = "center"
        }
    },
    ["wall_door"] = {
        {
            type = "WALL",
            pos = Vector(0, -61, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(0, 61, 0),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["wall_window"] = {
        {
            type = "WALL",
            pos = Vector(0, -61, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(0, 61, 0),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["wall_frame"] = {
        {
            type = "WALL",
            pos = Vector(0, -61, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(0, 61, 0),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["wall_half"] = {
        {
            type = "WALL",
            pos = Vector(0, -61, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(0, 61, 0),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["wall_low"] = {
        {
            type = "WALL",
            pos = Vector(0, -61, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(0, 61, 0),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["floor"] = {
        {
            type = "FLOOR",
            pos = Vector(0, -129, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "FLOOR",
            pos = Vector(129, 0, 0),
            ang = Angle(0, 0, 0),
            dir = "east"
        },
        {
            type = "FLOOR",
            pos = Vector(-129, 0, 0),
            ang = Angle(0, 0, 0),
            dir = "west"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 129, 0),
            ang = Angle(0, 0, 0),
            dir = "south"
        },
        {
            type = "WALL",
            pos = Vector(0, -64.5, 61),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(64.5, 0, 61),
            ang = Angle(0, 90, 0),
            dir = "east"
        },
        {
            type = "WALL",
            pos = Vector(-64.5, 0, 61),
            ang = Angle(0, -90, 0),
            dir = "west"
        },
        {
            type = "WALL",
            pos = Vector(0, 64.5, 61),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["floor_frame"] = {
        {
            type = "FLOOR",
            pos = Vector(0, -129, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "FLOOR",
            pos = Vector(129, 0, 0),
            ang = Angle(0, 0, 0),
            dir = "east"
        },
        {
            type = "FLOOR",
            pos = Vector(-129, 0, 0),
            ang = Angle(0, 0, 0),
            dir = "west"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 129, 0),
            ang = Angle(0, 0, 0),
            dir = "south"
        },
        {
            type = "WALL",
            pos = Vector(0, -64.5, 61),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(64.5, 0, 61),
            ang = Angle(0, 90, 0),
            dir = "east"
        },
        {
            type = "WALL",
            pos = Vector(-64.5, 0, 61),
            ang = Angle(0, -90, 0),
            dir = "west"
        },
        {
            type = "WALL",
            pos = Vector(0, 64.5, 61),
            ang = Angle(0, 180, 0),
            dir = "south"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    },
    ["floor_triangle"] = {
        {
            type = "FLOOR",
            pos = Vector(0, -90, 0),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "FLOOR",
            pos = Vector(90, 45, 0),
            ang = Angle(0, 120, 0),
            dir = "east"
        },
        {
            type = "FLOOR",
            pos = Vector(-90, 45, 0),
            ang = Angle(0, -120, 0),
            dir = "west"
        },
        {
            type = "WALL",
            pos = Vector(0, -45, 61),
            ang = Angle(0, 0, 0),
            dir = "north"
        },
        {
            type = "WALL",
            pos = Vector(45, 22.5, 61),
            ang = Angle(0, 120, 0),
            dir = "east"
        },
        {
            type = "WALL",
            pos = Vector(-45, 22.5, 61),
            ang = Angle(0, -120, 0),
            dir = "west"
        },
        {
            type = "FLOOR",
            pos = Vector(0, 0, 122),
            ang = Angle(0, 0, 0),
            dir = "up"
        }
    }
}

-- Совместимость сокетов с типами строений
ENT.SOCKET_COMPATIBILITY = {
    [ENT.SOCKET_TYPES.WALL] = {"wall", "wall_door", "wall_window", "wall_frame", "wall_half", "wall_low"},
    [ENT.SOCKET_TYPES.FLOOR] = {"floor", "floor_frame", "floor_triangle"},
    [ENT.SOCKET_TYPES.FOUNDATION] = {"foundation", "foundation_triangle"},
    [ENT.SOCKET_TYPES.ATTACHMENT] = {"sign", "light", "workbench", "furnace"}
}

-- Функции для работы с сокетами
function ENT:IsSocketCompatible(socketType, buildingType)
    local compatibleTypes = self.SOCKET_COMPATIBILITY[socketType]
    if not compatibleTypes then return false end
    for _, compatibleType in ipairs(compatibleTypes) do
        if compatibleType == buildingType then return true end
    end
    return false
end

function ENT:GetCompatibleSockets(parentType, buildingType)
    local parentSockets = self.BUILDING_SOCKETS[parentType]
    if not parentSockets then return {} end
    local compatibleSockets = {}
    for _, socket in ipairs(parentSockets) do
        if self:IsSocketCompatible(socket.type, buildingType) then table.insert(compatibleSockets, socket) end
    end
    return compatibleSockets
end

function ENT:GetBuildingSockets(buildingType)
    return self.BUILDING_SOCKETS[buildingType] or {}
end

function ENT:GetSocketPosition(parentEnt, socketIndex)
    if not IsValid(parentEnt) then return nil, nil end
    local parentType = parentEnt:GetNetworkedString("buildingtype")
    local sockets = self:GetBuildingSockets(parentType)
    if sockets[socketIndex] then
        local socket = sockets[socketIndex]
        local worldPos = parentEnt:LocalToWorld(socket.pos)
        local worldAng = parentEnt:LocalToWorldAngles(socket.ang)
        return worldPos, worldAng
    end
    return nil, nil
end

function ENT:FindBestSocket(parentEnt, buildingType, playerAngles)
    if not IsValid(parentEnt) then return nil end
    local parentType = parentEnt:GetNetworkedString("buildingtype")
    local compatibleSockets = self:GetCompatibleSockets(parentType, buildingType)
    if #compatibleSockets == 0 then return nil end
    -- Простой выбор ближайшего сокета к направлению взгляда игрока
    local bestSocket = compatibleSockets[1]
    local bestIndex = 1
    -- Здесь можно добавить логику выбора лучшего сокета на основе playerAngles
    return bestSocket, bestIndex
end