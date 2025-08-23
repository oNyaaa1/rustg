gRust.LastDeath = SysTime()

local Colors = gRust.Colors

local view = {}

hook.Add("CalcView", "gRust.FPDeath", function(pl, origin, ang, fov, znear, zfar)
    if (pl:Health() > 0) then return end

    local Ragdoll = pl:GetRagdollEntity()

    if (!IsValid(Ragdoll)) then return end

    local Head = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("eyes"))

    if (!Head.Pos) then return end

    view.origin = Head.Pos
    view.angles = Head.Ang

    return view
end)

local SleepingBagColors = {
    {
        Default = Color(104, 54, 39),
        Hovered = Color(116, 59, 42),
        Active = Color(136, 71, 51),
    },
    {
        Default = Color(58, 66, 42),
        Hovered = Color(71, 82, 49),
        Active = Color(76, 90, 50),
    },
    {
        Default = Color(48, 83, 110),
        Hovered = Color(52, 92, 122),
        Active = Color(51, 110, 155),
    }
}

local function ShowDeathScreen()
    gRust.CloseInventory()
    gRust.CloseCrafting()

    local Killer = net.ReadEntity()
    local bagCount = net.ReadUInt(8)
    local sleepingBags = {}

    for i = 1, bagCount do
        local bagIndex = net.ReadUInt(13)
        local bagPos = net.ReadVector()
        local canRespawn = net.ReadBool()
        local timeLeft = 0
        
        if not canRespawn then
            timeLeft = net.ReadFloat()
        end

        table.insert(sleepingBags, {
            index = bagIndex,
            pos = bagPos,
            canRespawn = canRespawn,
            timeLeft = timeLeft
        })
    end

    local pl = LocalPlayer()

    if (!IsValid(Killer)) then
        Killer = pl
    end

    local scrw, scrh = ScrW(), ScrH()

    local Frame = vgui.Create("Panel")
    Frame:Dock(FILL)
    Frame:SetAlpha(0)
    Frame:MakePopup()
    Frame:AlphaTo(255, 1, 1, function()
    end)

    local TopPanel = Frame:Add("DPanel")
    TopPanel:Dock(TOP)
    TopPanel:SetTall(scrh * 0.14)
    TopPanel.Paint = function(me, w, h)
        surface.SetDrawColor(Colors.Background)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("DEAD", "gRust.96px", w * 0.093, h * 0.5, Color(255, 255, 255, 200), 0, 1)
    end

    do
        local BoxCount = 0

        local function CreateBox(x, col, text1, text2)
            BoxCount = BoxCount + 1

            local Height = scrh * 0.045
            local YOffset = -scrh * 0.1
            local AnimTime = 0.75

            local Text = Frame:Add("DLabel")
            Text:SetX(x)
            Text:SetFont("gRust.24px")
            Text:SetText(text1)
            Text:SetWide(scrw * 0.1)
            Text:SetY(-scrh * 0.1)
            Text:SetTall(Height)
            Text.Start = SysTime() + 1.75 + (BoxCount * 0.5)
            Text.Think = function(me)
                local Lerped = Lerp((SysTime() - me.Start) / AnimTime, 0, 1)
                me:SetY(Anim.EaseOutBack(Lerped) * (math.abs(YOffset - (scrh * 0.02))) + YOffset)
            end

            local Panel = Frame:Add("gRust.Label")
            Panel:SetX(x)
            Panel:SetTextSize(34)   
            Panel:SetText(text2)
            Panel:SetY(scrh * 0.07 - (Height * 0.5))
            Panel:SetTall(Height)
            Panel:SetColor(col)
            Panel.Start = SysTime() + 1.75 + (BoxCount * 0.5)
            Panel.Think = function(me)
                local Lerped = Lerp((SysTime() - me.Start) / AnimTime, 0, 1)
                me:SetY(Anim.EaseOutBack(Lerped) * (math.abs(YOffset - (scrh * 0.075 - (Height * 0.5)))) + YOffset)
            end
        end

        CreateBox(scrw * 0.315, gRust.Colors.Secondary, "ALIVE FOR", string.FormattedTime(SysTime() - gRust.LastDeath, "%01im %01is"))
        CreateBox(scrw * 0.45, gRust.Colors.Primary, "KILLED BY", Killer == pl and "Suicide" or (Killer.Name and Killer:Name() or "Unknown"))
        CreateBox(scrw * 0.575, gRust.Colors.Primary, "WITH A", (Killer.GetActiveWeapon and IsValid(Killer:GetActiveWeapon())) and string.sub(Killer:GetActiveWeapon():GetClass(), 6) or "Nothing")
        CreateBox(scrw * 0.71, gRust.Colors.Surface, "AT A DISTANCE OF", string.format("%.1fm", math.Round(pl:GetPos():Distance(Killer:GetPos()) * 0.05, 1)))
    end

    local BottomPanel = Frame:Add("DPanel")
    BottomPanel:Dock(BOTTOM)
    BottomPanel:SetTall(scrh * 0.12)
    BottomPanel.Paint = function(me, w, h)
        surface.SetDrawColor(Colors.Background)
        surface.DrawRect(0, 0, w, h)
    end

    local VerticalPadding = ScrH() * 0.0235
    local HorizontalPadding = ScrW() * 0.052

    BottomPanel:DockPadding(HorizontalPadding, VerticalPadding, HorizontalPadding, VerticalPadding)

    local RespawnButton = BottomPanel:Add("gRust.Button")
    RespawnButton:Dock(RIGHT)
    RespawnButton:SetWide(scrw * 0.124)
    RespawnButton:SetText("RESPAWN >>")
    RespawnButton:SetFont("gRust.56px")
    RespawnButton:SetDefaultColor(Color(46, 53, 36))
    RespawnButton:SetHoveredColor(Color(65, 74, 40))
    RespawnButton:SetActiveColor(Color(81, 94, 51))
    RespawnButton:SetTextColor(Color(105, 122, 57, 255))
    RespawnButton.DoClick = function(me)
        net.Start("gRust.Respawn")
        net.SendToServer()
        Frame:Remove()
    end

    for i, bagData in ipairs(sleepingBags) do
        local Colors = SleepingBagColors[1 + ((i - 1) % 3)]
        local SleepingBag = BottomPanel:Add("gRust.Button")
        SleepingBag:Dock(LEFT)
        SleepingBag:SetWide(scrw * 0.11)
        SleepingBag:SetText("BAG " .. i)
        SleepingBag:SetFont("gRust.44px")
        SleepingBag:DockMargin(i == 1 and 0 or scrw * 0.01, 0, 0, 0)

        SleepingBag.Think = function()
            if bagData.canRespawn then
                SleepingBag:SetText("BAG " .. i)
                SleepingBag:SetWide(scrw * 0.11)
            else
                local timeLeft = math.max(0, bagData.timeLeft - (CurTime() - gRust.LastDeath))
                if timeLeft > 0 then
                    SleepingBag:SetText(string.format("BAG %i [%i]", i, math.ceil(timeLeft)))
                    SleepingBag:SetWide(scrw * 0.14)
                    bagData.canRespawn = false
                else
                    bagData.canRespawn = true
                    SleepingBag:SetText("BAG " .. i)
                    SleepingBag:SetWide(scrw * 0.11)
                end
            end
        end

        SleepingBag:SetDefaultColor(Colors.Default)
        SleepingBag:SetHoveredColor(Colors.Hovered)
        SleepingBag:SetActiveColor(Colors.Active)
        SleepingBag.DoClick = function()
            if not bagData.canRespawn then
                return
            end

            net.Start("gRust.BagRespawn")
            net.WriteUInt(bagData.index, 13)
            net.SendToServer()
            Frame:Remove()
        end
    end

    gRust.LastDeath = SysTime()
end

net.Receive("gRust.DeathScreen", ShowDeathScreen)
