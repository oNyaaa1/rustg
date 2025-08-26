local LastUse = 0
local Holding
hook.Add("KeyPress", "gRust.Interact", function(pl, key)
    if key ~= IN_USE then return end
    LastUse = CurTime()
    timer.Simple(0.1, function()
        if pl:KeyDown(IN_USE) then
            local tr = {}
            tr.start = pl:EyePos()
            tr.endpos = tr.start + pl:GetAimVector() * 72.5
            tr.mins = TraceMins
            tr.maxs = TraceMaxs
            tr.filter = pl
            pl:LagCompensation(true)
            tr = util.TraceHull(tr)
            pl:LagCompensation(false)
            local ent = tr.Entity
            if not ent.HoldInteract then return end
            ent:HoldInteract(pl)
            Holding = ent
        end
    end)
end)

local TraceMins, TraceMaxs = Vector(-4, -4, -4), Vector(4, 4, 4)
hook.Add("KeyRelease", "gRust.Interact", function(pl, key)
    if key ~= IN_USE then return end
    if Holding and Holding.ReleaseInteract then Holding:ReleaseInteract(pl) end
    local tr = {}
    tr.start = pl:EyePos()
    tr.endpos = tr.start + pl:GetAimVector() * 72.5
    tr.mins = TraceMins
    tr.maxs = TraceMaxs
    tr.filter = pl
    pl:LagCompensation(true)
    tr = util.TraceHull(tr)
    pl:LagCompensation(false)
    local ent = tr.Entity
    if LastUse + 0.25 < CurTime() or not IsValid(ent) then return end
    if ent.GetInteractable and ent:GetInteractable() then
        if (ent.NextInteract or 0) > CurTime() then return end
        ent:Interact(pl)
    end
end)