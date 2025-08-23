local PANEL = {}

function PANEL:Init()
    local Header = self:Add("Panel")
    Header:SetTall(80)
    Header:Dock(TOP)

    local Close = Header:Add("gRust.Button")
    Close:Dock(RIGHT)
    Close:SetWide(80)
    Close.DoClick = function(me)
        self:Remove()
    end
end

function PANEL:Paint(w, h)

end

vgui.Register("gRust.Frame", PANEL, "Panel")