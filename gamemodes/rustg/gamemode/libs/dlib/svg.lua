local SVG = {}
SVG.__index = SVG

AccessorFunc(SVG, "Dirty", "Dirty", FORCE_BOOL)
AccessorFunc(SVG, "Vertices", "Vertices")

function SVG:Init(data)
    self.Data = data
    self:SetDirty(true)
end

function SVG:Recalculate()
    local Data = self.Data
    Data = string.match(Data, "<svg(.-)/svg>")
    Markup.MarkupToTable(Data)

    self:SetDirty(false)
end

function SVG:Draw()
    if (self.Dirty) then
        self:Recalculate()
    end

    self:SetDirty(false)
end

return function(dir)
    local meta = setmetatable({}, SVG)
    meta:Init(file.Read(dir, "DATA"))

    return meta
end