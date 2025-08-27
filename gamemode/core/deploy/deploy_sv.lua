util.AddNetworkString("gRust.Deploy")
local function HandleDeploy(_, pl)
    if not IsValid(pl) then return end
    local index = net.ReadUInt(3)
    local sockID = net.ReadUInt(8)
    local Item = pl.Inventory[index]
    if not Item then return end
    local ItemData = gRust.Items[Item:GetItem()]
    local Class = ItemData:GetEntity()
    local Deploy = scripted_ents.Get(Class).Deploy
    if not Deploy then return end
    local pos, ang, hitEnt = pl:GetDeployPosition(Deploy)
    if not pos then return end
    if Deploy.Socket == "lock" then
        local tr = pl:GetDeployData()
        if not IsValid(tr.Entity) or not string.find(tr.Entity:GetClass(), "door") then return end
        if tr.Entity:GetBodygroup(2) ~= 0 then return end
        if tr.Entity:GetNW2Bool("gRust.LockInUse", false) then return end
        hitEnt = tr.Entity
    elseif Deploy.Socket then
        if not pl.DeploySocket or sockID == 0 then return end
        if IsValid(hitEnt) and hitEnt:GetNW2Bool("gRust.InUse", false) then return end
        if Deploy.Socket == "lock" and IsValid(hitEnt) then
            if hitEnt.GetBodygroup and hitEnt:GetBodygroup(2) ~= 0 then return end
            if hitEnt:GetNW2Bool("gRust.LockInUse", false) then return end
        end
    else
        local trace = pl:GetDeployData()
        if trace.Hit then
            local angle = math.deg(math.acos(trace.HitNormal:Dot(Vector(0, 0, 1))))
            local max = Deploy.MaxSurfaceAngle or 45
            if angle > max then return end
        end
    end

    --if not Deploy.Socket then
    --  local mins, maxs = Deploy.Mins or Vector(-16, -16, -16), Deploy.Maxs or Vector(16, 16, 16)
    --   if util.TraceHull{start = pos, endpos = pos, mins = mins, maxs = maxs, filter = pl}.Hit then return end
    --end
    local ent = ents.Create(Class)
    if not IsValid(ent) then return end
    print(Class, ent)
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:SetNW2Entity("gRust.Owner", pl)
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)
    ent:SetSolid(SOLID_VPHYSICS)
    if Deploy.Socket and Deploy.Socket ~= "lock" and IsValid(hitEnt) then
        ent:SetParent(hitEnt)
        hitEnt:SetNW2Bool("gRust.InUse", true)
    end

    if Deploy.Socket == "lock" and IsValid(hitEnt) then hitEnt:SetNW2Bool("gRust.LockInUse", true) end
    if Deploy.OnSpawn then Deploy.OnSpawn(ent, pl) end
    ent:Spawn()
    ent:Activate()
    if Deploy.OnDeploy then
        local trace = pl:GetDeployData()
        Deploy.OnDeploy(pl, ent, trace)
    end

    timer.Simple(0, function()
        if not IsValid(ent) then return end
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Wake()
        end
    end)

    Item:SetQuantity(Item:GetQuantity() - 1)
    if Item:GetQuantity() <= 0 then pl.Inventory[index] = nil end
    if pl.SyncInventory then pl:SyncInventory() end
end

net.Receive("gRust.Deploy", HandleDeploy)