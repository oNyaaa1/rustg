table.IndexByKey = function(tab, key)
    i = 0
    for k, v in pairs(tab) do
        i = i + 1
        if k == key then return i end
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
SWEP.DrawCrosshair = true
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.ShootSound = Sound("Metal.SawbladeStick")
SWEP.workDistance = 100
SWEP.PieMenu = {
    [1] = {
        Name = "Floor Frame",
        Icon = "materials/icons/build/floor_frame.png",
        Desc = "Floor frame for building structure",
        Foot = "50x Wood",
        Model = "models/building_re/twig_fframe.mdl",
        BuildingType = "floor"
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
        BuildingType = "wall"
    },
    [4] = {
        Name = "Window Frame",
        Icon = "materials/icons/build/wall_window.png",
        Desc = "Window frame for ventilation",
        Foot = "50x Wood",
        Model = "models/building_re/twig_wind.mdl",
        BuildingType = "wall"
    },
    [5] = {
        Name = "Wall Frame",
        Icon = "materials/icons/build/wall_frame.png",
        Desc = "Wall frame for structure",
        Foot = "50x Wood",
        Model = "models/building_re/twig_gframe.mdl",
        BuildingType = "wall"
    },
    [6] = {
        Name = "Half Wall",
        Icon = "materials/icons/build/wall_half.png",
        Desc = "Half wall for partial protection",
        Foot = "50x Wood",
        Model = "models/building_re/twig_hwall.mdl",
        BuildingType = "wall"
    },
    [7] = {
        Name = "Low Wall",
        Icon = "materials/icons/build/wall_low.png",
        Desc = "Low wall for barrier",
        Foot = "50x Wood",
        Model = "models/building_re/twig_twall.mdl",
        BuildingType = "wall"
    },
    [8] = {
        Name = "U Stairs",
        Icon = "materials/icons/build/stairs_u.png",
        Desc = "U-shaped stairs for vertical access",
        Foot = "50x Wood",
        Model = "models/building_re/twig_ust.mdl",
        BuildingType = "stair"
    },
    [9] = {
        Name = "L Stairs",
        Icon = "materials/icons/build/stairs_l.png",
        Desc = "L-shaped stairs for vertical access",
        Foot = "50x Wood",
        Model = "models/building_re/twig_lst.mdl",
        BuildingType = "stair"
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
        BuildingType = "foundation"
    },
    [13] = {
        Name = "Foundation Steps",
        Icon = "materials/icons/build/foundation_steps.png",
        Desc = "Foundation steps for access",
        Foot = "50x Wood",
        Model = "models/building_re/twig_steps.mdl",
        BuildingType = "floor"
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
        BuildingType = "floor"
    }
}

-- ============================================================================
-- РћРЎРќРћР’РќРђРЇ РўРђР‘Р›РР¦Рђ РЎРўР РћРРўР•Р›Р¬РќР«РҐ Р­Р›Р•РњР•РќРўРћР’ РЎ РќРћР’РћР™ РЎРўР РЈРљРўРЈР РћР™
-- ============================================================================
buildingsTable = {
    ["foundation"] = {
        ["model"] = "models/building_re/twig_foundation.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 64,
        ["cost"] = {
            item = "wood",
            amount = 50
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "map"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -129, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [2] = {
                    ["position"] = Vector(129, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [3] = {
                    ["position"] = Vector(-129, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 129, 0),
                    ["angle"] = Angle(0, 0, 0)
                }
            }
        }
    },
    ["foundation_triangle"] = {
        ["model"] = "models/building_re/twig_foundation_trig.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 55,
        ["cost"] = {
            item = "wood",
            amount = 35
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "map"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(-110, 0, 0),
                    ["angle"] = Angle(0, 180, 0)
                },
                [2] = {
                    ["position"] = Vector(0, -64.5, 0),
                    ["angle"] = Angle(0, -30, 0)
                },
                [3] = {
                    ["position"] = Vector(0, 64.5, 0),
                    ["angle"] = Angle(0, 30, 0)
                }
            }
        }
    },
    ["wall"] = {
        ["model"] = "models/building_re/twig_wall.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 15,
        ["cost"] = {
            item = "wood",
            amount = 25
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -64.5, 0),
                    ["angle"] = Angle(0, 90, 0)
                },
                [2] = {
                    ["position"] = Vector(64.5, 0, 0),
                    ["angle"] = Angle(0, 180, 0)
                },
                [3] = {
                    ["position"] = Vector(-64.5, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 64.5, 0),
                    ["angle"] = Angle(0, 270, 0)
                }
            }
        }
    },
    ["wall_window"] = {
        ["model"] = "models/building_re/twig_wind.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 15,
        ["cost"] = {
            item = "wood",
            amount = 25
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -64.5, 0),
                    ["angle"] = Angle(0, 90, 0)
                },
                [2] = {
                    ["position"] = Vector(64.5, 0, 0),
                    ["angle"] = Angle(0, 180, 0)
                },
                [3] = {
                    ["position"] = Vector(-64.5, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 64.5, 0),
                    ["angle"] = Angle(0, 270, 0)
                }
            }
        }
    },
    ["wall_door"] = {
        ["model"] = "models/building_re/twig_dframe.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 15,
        ["cost"] = {
            item = "wood",
            amount = 25
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -64.5, 0),
                    ["angle"] = Angle(0, 90, 0)
                },
                [2] = {
                    ["position"] = Vector(64.5, 0, 0),
                    ["angle"] = Angle(0, 180, 0)
                },
                [3] = {
                    ["position"] = Vector(-64.5, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 64.5, 0),
                    ["angle"] = Angle(0, 270, 0)
                }
            }
        }
    },
    ["wall_frame"] = {
        ["model"] = "models/building_re/twig_gframe.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 15,
        ["cost"] = {
            item = "wood",
            amount = 25
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -64.5, 0),
                    ["angle"] = Angle(0, 90, 0)
                },
                [2] = {
                    ["position"] = Vector(64.5, 0, 0),
                    ["angle"] = Angle(0, 180, 0)
                },
                [3] = {
                    ["position"] = Vector(-64.5, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 64.5, 0),
                    ["angle"] = Angle(0, 270, 0)
                }
            }
        }
    },
    ["wall_half"] = {
        ["model"] = "models/building_re/twig_hwall.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 15,
        ["cost"] = {
            item = "wood",
            amount = 15
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -64.5, 0),
                    ["angle"] = Angle(0, -90, 0)
                },
                [2] = {
                    ["position"] = Vector(64.5, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [3] = {
                    ["position"] = Vector(-64.5, 0, 0),
                    ["angle"] = Angle(0, 180, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 64.5, 0),
                    ["angle"] = Angle(0, 90, 0)
                }
            }
        }
    },
    ["wall_low"] = {
        ["model"] = "models/building_re/twig_twall.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 15,
        ["cost"] = {
            item = "wood",
            amount = 10
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -64.5, 0),
                    ["angle"] = Angle(0, -90, 0)
                },
                [2] = {
                    ["position"] = Vector(64.5, 0, 0),
                    ["angle"] = Angle(0, 0, 0)
                },
                [3] = {
                    ["position"] = Vector(-64.5, 0, 0),
                    ["angle"] = Angle(0, 180, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 64.5, 0),
                    ["angle"] = Angle(0, 90, 0)
                }
            }
        }
    },
    ["floor"] = {
        ["model"] = "models/building_re/twig_floor.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 64,
        ["cost"] = {
            item = "wood",
            amount = 30
        },
        ["parent"] = {
            ["buildings"] = {"wall", "foundation"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, 64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                },
                [2] = {
                    ["position"] = Vector(0, 64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                },
                [3] = {
                    ["position"] = Vector(0, -64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, -64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                }
            }
        }
    },
    ["floor_frame"] = {
        ["model"] = "models/building_re/twig_fframe.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 64,
        ["cost"] = {
            item = "wood",
            amount = 25
        },
        ["parent"] = {
            ["buildings"] = {"wall", "foundation"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, 64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                },
                [2] = {
                    ["position"] = Vector(0, 64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                },
                [3] = {
                    ["position"] = Vector(0, -64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, -64.5, 129),
                    ["angle"] = Angle(0, 0, 0)
                }
            }
        }
    },
    ["floor_triangle"] = {
        ["model"] = "models/building_re/twig_floor_trig.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 55,
        ["cost"] = {
            item = "wood",
            amount = 20
        },
        ["parent"] = {
            ["buildings"] = {"wall", "foundation"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(-110, 0, 129),
                    ["angle"] = Angle(0, 180, 0)
                },
                [2] = {
                    ["position"] = Vector(0, -70, 129),
                    ["angle"] = Angle(0, -30, 0)
                },
                [3] = {
                    ["position"] = Vector(0, 70, 129),
                    ["angle"] = Angle(0, 30, 0)
                }
            }
        }
    },
    ["steps"] = {
        ["model"] = "models/building_re/twig_steps.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 30,
        ["cost"] = {
            item = "wood",
            amount = 20
        },
        ["parent"] = {
            ["buildings"] = {"foundation"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, -124, -62),
                    ["angle"] = Angle(0, 90, 0)
                },
                [2] = {
                    ["position"] = Vector(124, 0, -62),
                    ["angle"] = Angle(0, 180, 0)
                },
                [3] = {
                    ["position"] = Vector(-124, 0, -62),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, 124, -62),
                    ["angle"] = Angle(0, 270, 0)
                }
            }
        }
    },
    ["stairs_l"] = {
        ["model"] = "models/building_re/twig_lst.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 30,
        ["cost"] = {
            item = "wood",
            amount = 35
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, 124, 60),
                    ["angle"] = Angle(0, 90, 0)
                },
                [2] = {
                    ["position"] = Vector(124, 0, 60),
                    ["angle"] = Angle(0, 180, 0)
                },
                [3] = {
                    ["position"] = Vector(-124, 0, 60),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, -124, 60),
                    ["angle"] = Angle(0, 270, 0)
                }
            }
        }
    },
    ["stairs_u"] = {
        ["model"] = "models/building_re/twig_ust.mdl",
        ["material"] = "models/zohart/buildings/twig",
        ["pos"] = Vector(0, 0, 0),
        ["colradius"] = 30,
        ["cost"] = {
            item = "wood",
            amount = 40
        },
        ["parent"] = {
            ["buildings"] = {"foundation", "floor"},
            ["positions"] = {
                [1] = {
                    ["position"] = Vector(0, 124, 60),
                    ["angle"] = Angle(0, 90, 0)
                },
                [2] = {
                    ["position"] = Vector(124, 0, 60),
                    ["angle"] = Angle(0, 180, 0)
                },
                [3] = {
                    ["position"] = Vector(-124, 0, 60),
                    ["angle"] = Angle(0, 0, 0)
                },
                [4] = {
                    ["position"] = Vector(0, -124, 60),
                    ["angle"] = Angle(0, 270, 0)
                }
            }
        }
    }
}



-- ============================================================================
-- Р¤РЈРќРљР¦РР Р”Р›РЇ Р РђР‘РћРўР« РЎ РќРћР’РћР™ РЎРўР РЈРљРўРЈР РћР™ РџРћР—РР¦РР™
-- ============================================================================
-- Р¤СѓРЅРєС†РёСЏ РїРѕР»СѓС‡РµРЅРёСЏ РїРѕР·РёС†РёР№ РґР»СЏ РєРѕРЅРєСЂРµС‚РЅРѕРіРѕ СЂРѕРґРёС‚РµР»СЊСЃРєРѕРіРѕ С‚РёРїР°
function GetPositionsForParent(buildingType, parentType)
    if not buildingsTable[buildingType] then return nil end
    local buildingData = buildingsTable[buildingType]
    if not buildingData["parent"] or not buildingData["parent"]["positions"] then return nil end
    -- РџСЂРѕРІРµСЂСЏРµРј РЅРѕРІСѓСЋ СЃС‚СЂСѓРєС‚СѓСЂСѓ (СЃ РѕС‚РґРµР»СЊРЅС‹РјРё РїРѕР·РёС†РёСЏРјРё РґР»СЏ СЂРѕРґРёС‚РµР»РµР№)
    if type(buildingData["parent"]["positions"]) == "table" and buildingData["parent"]["positions"][parentType] then return buildingData["parent"]["positions"][parentType] end
    return nil
end

-- РћР±РЅРѕРІР»РµРЅРЅР°СЏ С„СѓРЅРєС†РёСЏ РїСЂРѕРІРµСЂРєРё СЂРѕРґРёС‚РµР»СЊСЃРєРёС… СЃРІСЏР·РµР№
function HasParent(buil, par)
    if buildingsTable[buil] ~= nil then
        if buildingsTable[buil]["parent"] ~= nil then
            for _, v in pairs(buildingsTable[buil]["parent"]["buildings"]) do
                if v == par then return true end
            end
        end
    end
    return false
end

-- Р¤СѓРЅРєС†РёСЏ РїРѕР»СѓС‡РµРЅРёСЏ РїРѕР·РёС†РёР№ СЃ fallback Р»РѕРіРёРєРѕР№
function GetParentPositions(buildingType, parentType)
    local positions = GetPositionsForParent(buildingType, parentType)
    if positions then return positions end
    -- Fallback РЅР° РїРµСЂРІС‹Рµ РґРѕСЃС‚СѓРїРЅС‹Рµ РїРѕР·РёС†РёРё, РµСЃР»Рё СЃРїРµС†РёС„РёС‡РЅС‹Рµ РЅРµ РЅР°Р№РґРµРЅС‹
    if buildingsTable[buildingType] and buildingsTable[buildingType]["parent"] and buildingsTable[buildingType]["parent"]["positions"] then
        for _, positions in pairs(buildingsTable[buildingType]["parent"]["positions"]) do
            if type(positions) == "table" and positions[1] then return positions end
        end
    end
    return nil
end

-- Р¤СѓРЅРєС†РёСЏ РїРѕР»СѓС‡РµРЅРёСЏ РёРЅС„РѕСЂРјР°С†РёРё Рѕ СЃС‚СЂРѕРёС‚РµР»СЊРЅРѕРј СЌР»РµРјРµРЅС‚Рµ
function GetBuildingInfo(buildingType)
    if buildingsTable[buildingType] then return buildingsTable[buildingType] end
    return nil
end

-- Р¤СѓРЅРєС†РёСЏ РїРѕР»СѓС‡РµРЅРёСЏ РєРѕРЅРєСЂРµС‚РЅРѕР№ РїРѕР·РёС†РёРё
function GetBuildingPosition(buildingType, parentType, positionIndex)
    local positions = GetPositionsForParent(buildingType, parentType)
    if positions and positions[positionIndex] then return positions[positionIndex]["position"], positions[positionIndex]["angle"] end
    return Vector(0, 0, 0), Angle(0, 0, 0)
end

-- ============================================================================
-- РћРЎРўРђР›Р¬РќР«Р• Р¤РЈРќРљР¦РР Р‘Р•Р— РР—РњР•РќР•РќРР™
-- ============================================================================
function GetBuilding(buil)
    for k, v in pairs(buildingsTable) do
        if v == buil then return k end
    end
    return nil
end

function HasBuilding(buil)
    for k, v in pairs(buildingsTable) do
        if k == buil then return true end
    end
    return false
end

function OnAnyAction(swep)
    if SERVER then
        if not timer.Exists("buildingtoolusetimer" .. swep:GetCreationID()) then
            swep:SetNetworkedBool("isUsable", false)
            timer.Create("buildingtoolusetimer" .. swep:GetCreationID(), 0.2, 0, function()
                swep:SetNetworkedBool("isUsable", true)
                timer.Remove("buildingtoolusetimer" .. swep:GetCreationID())
            end)
        end
    end
end

function CheckPosition(selb, ent, pos, radius)
    if not CheckGroundSupport(pos, selb) then return false end
    local nearbyEnts = ents.FindInSphere(pos, radius)
    if #nearbyEnts > 0 then
        for k, v in pairs(nearbyEnts) do
            if IsValid(v) and v:GetClass() == "rust_building" then
                if v ~= ent then
                    local distance = pos:Distance(v:GetPos())
                    if distance < radius then return false end
                end
            end
        end
    end
    return true
end

function IsPositionOccupied(pos, buildingType, excludeEnt)
    local radius = buildingsTable[buildingType] and buildingsTable[buildingType]["colradius"] or 50
    local entities = ents.FindInSphere(pos, radius)
    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent:GetClass() == "rust_building" then if not excludeEnt or ent ~= excludeEnt then return true, ent end end
    end
    return false, nil
end

function CheckGroundSupport(pos, buildingType)
    if buildingType ~= "foundation" then return true end
    local traceDown = {
        start = pos,
        endpos = pos + Vector(0, 0, -120),
        filter = function(ent) return ent:GetClass() ~= "rust_building" end
    }

    local tr = util.TraceLine(traceDown)
    if tr.Hit then
        if IsValid(tr.Entity) then
            local entClass = tr.Entity:GetClass()
            if entClass == "worldspawn" or entClass == "func_detail" or entClass == "prop_physics" then return true end
            return false
        else
            return true
        end
    end
    return false
end

function GetNumberOfPosition(angle)
    if angle ~= nil then
        if angle.y < -45 and angle.y > -135 then
            return 1
        elseif angle.y > -45 and angle.y < 45 then
            return 2
        elseif angle.y < -135 or angle.y > 135 then
            return 3
        elseif angle.y > 45 and angle.y < 135 then
            return 4
        else
            return 0
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
end