local CIRCLE = {}
CIRCLE.__index = CIRCLE

local function AccFunc(name, recalc, force)
    CIRCLE[name] = 0
    CIRCLE["Get" .. name] = function(self)
        return self[name]
    end

    CIRCLE["Set" .. name] = function(self, v)
        self[name] = v

        if (recalc) then
            self.NeedRecalc = true
        end
    end
end

AccFunc("X", true, FORCE_NUMBER)
AccFunc("Y", true, FORCE_NUMBER)
AccFunc("Radius", true, FORCE_NUMBER)
AccFunc("InnerRadius", true, FORCE_NUMBER)
AccFunc("StartAngle", true, FORCE_NUMBER)
AccFunc("Vertices", false)

function CIRCLE:Recalculate()
    self.Vertices = {}

    local Quality = 64
    for i = 0, Quality do
        local x = i / Quality * math.pi * 2
        self.Vertices[#self.Vertices + 1] = {
            x = self.X + math.cos(x) * self.Radius,
            y = self.Y + math.sin(x) * self.Radius,
        }
    end

    if (self:GetInnerRadius() > 0) then
        self.InnerCircle = self.InnerCircle or self:Copy()
        self.InnerCircle:SetInnerRadius(0)
        self.InnerCircle:SetRadius(self:GetInnerRadius())
    end

    self.NeedRecalc = false
end

function CIRCLE:Copy()
    return table.Copy(self)
end

function CIRCLE:Draw()
    if (self.NeedRecalc) then
        self:Recalculate()
    end

    if (self:GetInnerRadius() > 0) then
        render.ClearStencil()

        render.SetStencilEnable(true)
            render.SetStencilTestMask(0xFF)
            render.SetStencilWriteMask(0xFF)
            render.SetStencilReferenceValue(0x01)

            render.SetStencilCompareFunction(STENCIL_NEVER)
            render.SetStencilFailOperation(STENCIL_REPLACE)
            render.SetStencilZFailOperation(STENCIL_REPLACE)

            self.InnerCircle:Draw()

            render.SetStencilCompareFunction(STENCIL_GREATER)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)
            
            surface.DrawPoly(self.Vertices)
        render.SetStencilEnable(false)
    else
        surface.DrawPoly(self.Vertices)
    end
end

return function(x, y, r)
    local meta = setmetatable({}, CIRCLE)
    meta:SetX(x)
    meta:SetY(y)
    meta:SetRadius(r)

    return meta
end