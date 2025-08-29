ENT.Type = "anim"
ENT.Base = "rust_base"
gRust.BuildingBlocks = {
    ["models/building_re/twig_foundation.mdl"] = {
        Offset = Vector(64, 0, 0),
        Angle = Angle(0, 0, 0),
        Type = STRUCTURE_FOUNDATION,
        Rotate = 90,
        Sockets = {
            {
                pos = Vector(64.5, 0, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(0, 64.5, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(-64.5, 0, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(0, -64.5, 0),
                ang = Angle(0, 0, 0)
            }
        }
    },
    ["models/building_re/twig_foundation_trig.mdl"] = {
        Offset = Vector(64, 0, 0),
        Angle = Angle(0, 180, 0),
        Type = STRUCTURE_FOUNDATION,
        Rotate = 0,
        Index = 1,
        Sockets = {
            {
                pos = Vector(-55, 0, 0),
                ang = Angle(0, 180, 0)
            },
            {
                pos = Vector(0, -64.5 / 2, 0),
                ang = Angle(0, -30, 0)
            },
            {
                pos = Vector(0, 64.5 / 2, 0),
                ang = Angle(0, 30, 0)
            },
        }
    },
    ["models/building_re/twig_wall.mdl"] = {
        Offset = Vector(0, 0, 0),
        Angle = Angle(0, 90, 0),
        Type = STRUCTURE_WALL,
        Check = Vector(0, 0, 100),
        Rotate = 180,
        Sockets = {
            {
                pos = Vector(0, 0, 0),
                ang = Angle(),
                place = false
            },
            {
                pos = Vector(0, 0, 129),
                ang = Angle(0, 90, 0),
                relative = false
            },
        }
    },
    ["models/building_re/twig_wind.mdl"] = {
        Offset = Vector(0, 0, 0),
        Angle = Angle(0, 90, 0),
        Type = STRUCTURE_WALL,
        Check = Vector(0, 0, 100),
        Rotate = 180,
        Sockets = {
            {
                pos = Vector(0, 0, 0),
                ang = Angle(),
                place = false
            },
            {
                pos = Vector(0, 0, 129),
                ang = Angle(0, 90, 0)
            },
            ["window"] = {
                {
                    pos = Vector(0, 0, 0),
                    ang = Angle(0, 0, 0)
                }
            }
        }
    },
    ["models/building_re/twig_dframe.mdl"] = {
        Offset = Vector(0, 0, 0),
        Angle = Angle(0, 90, 0),
        Type = STRUCTURE_WALL,
        Check = Vector(0, 0, 120),
        Rotate = 180,
        Sockets = {
            {
                pos = Vector(0, 0, 0),
                ang = Angle(),
                place = false
            },
            {
                pos = Vector(0, 0, 129),
                ang = Angle(0, 90, 0),
                relative = false
            },
            ["door"] = {
                {
                    pos = Vector(-25.5, 0, 3.5),
                    ang = Angle(0, 0, 0)
                },
                {
                    pos = Vector(25.5, 0, 3.5),
                    ang = Angle(0, 180, 0)
                },
            },
            ["vending_machine"] = {
                {
                    pos = Vector(0, -1, 5),
                    ang = Angle(0, 90, 0)
                },
                {
                    pos = Vector(0, 1, 5),
                    ang = Angle(0, -90, 0)
                }
            }
        }
    },
    ["models/building_re/twig_gframe.mdl"] = {
        Offset = Vector(0, 0, 0),
        Angle = Angle(0, 90, 0),
        Type = STRUCTURE_WALL,
        Check = Vector(0, 0, 123),
        Rotate = 0,
        Sockets = {
            {
                pos = Vector(0, 0, 0),
                ang = Angle(),
                place = false
            },
            {
                pos = Vector(0, 0, 129),
                ang = Angle(0, 90, 0),
                relative = false
            },
            ["base"] = {
                {
                    pos = Vector(0, 0, 0),
                    ang = Angle(0, 0, 0)
                },
            },
            ["garage"] = {
                {
                    pos = Vector(0, -4, 129),
                    ang = Angle(0, 0, 0)
                },
            }
        }
    },
    ["models/building_re/twig_floor.mdl"] = {
        Offset = Vector(64, 0, 0),
        Angle = Angle(0, 0, 0),
        Relative = false,
        Type = STRUCTURE_FLOOR,
        Rotate = 90,
        Sockets = {
            {
                pos = Vector(64.5, 0, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(0, 64.5, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(-64.5, 0, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(0, -64.5, 0),
                ang = Angle(0, 0, 0)
            }
        }
    },
    ["models/building_re/twig_fframe.mdl"] = {
        Offset = Vector(64, 0, 0),
        Angle = Angle(0, 0, 0),
        Type = STRUCTURE_FLOOR,
        Rotate = 90,
        Sockets = {
            {
                pos = Vector(64.5, 0, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(0, 64.5, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(-64.5, 0, 0),
                ang = Angle(0, 0, 0)
            },
            {
                pos = Vector(0, -64.5, 0),
                ang = Angle(0, 0, 0)
            }
        }
    },
    ["models/building_re/twig_floor_trig.mdl"] = {
        Angle = Angle(0, 180, 0),
        Type = STRUCTURE_FLOOR,
        Rotate = 0,
        Sockets = {
            {
                pos = Vector(-55, 0, 0),
                ang = Angle(0, 180, 0)
            },
            {
                pos = Vector(0, -70 / 2, 0),
                ang = Angle(0, -30, 0)
            },
            {
                pos = Vector(0, 70 / 2, 0),
                ang = Angle(0, 30, 0)
            },
        }
    },
    ["models/building_re/twig_hwall.mdl"] = {
        Angle = Angle(),
        Type = STRUCTURE_WALL,
        Check = Vector(0, 0, 129 / 4),
        Rotate = 180,
        Sockets = {
            {
                pos = Vector(0, 0, 0),
                ang = Angle(0, -90, 0),
                place = false
            },
            {
                pos = Vector(0, 0, 129 / 2),
                ang = Angle(0, 90, 0),
                relative = false
            },
        }
    },
    ["models/building_re/twig_twall.mdl"] = {
        Angle = Angle(),
        Type = STRUCTURE_WALL,
        Check = Vector(0, 0, 129 / 6),
        Rotate = 180,
        Sockets = {
            {
                pos = Vector(0, 0, 0),
                ang = Angle(0, -90, 0),
                place = false
            },
            {
                pos = Vector(0, 0, 129 / 3),
                ang = Angle(0, 90, 0),
                relative = false
            },
        }
    },
    ["models/building_re/twig_steps.mdl"] = {
        Angle = Angle(),
        Type = STRUCTURE_FLOOR,
        Check = Vector(0, 0, 70),
        Rotate = 0,
        Sockets = {
            {
                pos = Vector(0, -62, -62),
                ang = Angle(0, 90, 0),
                place = false
            }
        }
    },
    ["models/building_re/twig_lst.mdl"] = {
        Angle = Angle(),
        Type = STRUCTURE_FLOOR,
        Check = Vector(0, 0, 60),
        Rotate = 0,
        Sockets = {
            {
                pos = Vector(0, 62, 0),
                ang = Angle(0, 90, 0),
                place = false
            }
        }
    },
    ["models/building_re/twig_ust.mdl"] = {
        Angle = Angle(),
        Type = STRUCTURE_FLOOR,
        Check = Vector(0, 0, 60),
        Rotate = 0,
        Sockets = {
            {
                pos = Vector(0, 62, 0),
                ang = Angle(0, 90, 0),
                place = false
            }
        }
    }
}

function ENT:GetOriginalModel()
    local mdl = string.sub(self:GetModel(), 19)
    mdl = string.sub(self:GetModel(), 1, 19) .. string.gsub(mdl, "/(.-)_", "twig_")
    return mdl
end