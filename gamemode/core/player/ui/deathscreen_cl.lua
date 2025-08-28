gRust.LastDeath = SysTime()
local Colors = gRust.Colors
local view = {}
hook.Add("CalcView", "gRust.FPDeath", function(pl, origin, ang, fov, znear, zfar)
    if pl:Health() > 0 then return end
    local Ragdoll = pl:GetRagdollEntity()
    if not IsValid(Ragdoll) then return end
    local Head = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("eyes"))
    if not Head.Pos then return end
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
        local bagIndex  = net.ReadUInt(13)
        local bagPos    = net.ReadVector()
        local canRespawn = net.ReadBool()
        if not canRespawn then timeLeft = net.ReadFloat() end
        sleepingBags[#sleepingBags + 1] = {
            index = bagIndex,
            pos = bagPos,
            canRespawn = canRespawn,
            timeLeft = timeLeft
        }
    end

    local pl = LocalPlayer()
    if not IsValid(Killer) then Killer = pl end

    local scrw, scrh = ScrW(), ScrH()
    local Frame = vgui.Create("Panel")
    Frame:Dock(FILL)
    Frame:SetAlpha(0)
    Frame:MakePopup()
    Frame:AlphaTo(255, 1, 1)

    local TopPanel = Frame:Add("DPanel")
    TopPanel:Dock(TOP)
    TopPanel:SetTall(scrh * 0.14)
    TopPanel.Paint = function(me, w, h)
        surface.SetDrawColor(Colors.Background)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("DEAD", "gRust.96px", w * 0.093, h * 0.5, Color(107, 107, 107, 200), 0, 1)
    end

    local BoxCount = 0
    local function CreateBox(x, col, text1, text2, bgColor, bgAlpha, bgWidth, text1Offset, text1Font)
        BoxCount = BoxCount + 1
        local Height   = scrh * 0.045
        local YOffset  = -scrh * 0.1
        local AnimTime = 0.75
        text1Font = text1Font or "gRust.24px"

        if not bgWidth then
            surface.SetFont(text1Font)
            local w1 = select(1, surface.GetTextSize(text1))
            surface.SetFont("gRust.34px")
            local w2 = select(1, surface.GetTextSize(text2))
            bgWidth = math.max(w1, w2) + scrw * 0.0150
        end

        local Background = Frame:Add("DPanel")
        Background:SetX(x - scrw * 0.007)
        Background:SetWide(bgWidth)
        Background:SetY(-scrh * 0.105)
        Background:SetTall(scrh * 0.04)
        Background.Start = SysTime() + 1.75 + (BoxCount * 0.5)
        Background.Paint = function(_, w, h)
            draw.RoundedBox(0, 0, 0, w, h, bgColor or Color(0, 0, 0, bgAlpha or 100))
        end
        Background.Think = function(me)
            local t = (SysTime() - me.Start) / AnimTime
            me:SetY(Anim.EaseOutBack(Lerp(t, 0, 1)) * math.abs(YOffset - (scrh * 0.055)) + YOffset)
        end

        local Text = Frame:Add("DLabel")
        Text:SetX(x + (text1Offset or 0))
        Text:SetFont(text1Font)
        Text:SetText(text1)
        Text:SetWide(bgWidth)
        Text:SetContentAlignment(4)
        Text:SetTextInset(scrw * 0.002, 0)
        Text:SetY(-scrh * 0.1)
        Text:SetTall(Height)
        Text.Start = SysTime() + 1.75 + (BoxCount * 0.5)
        Text.Think = function(me)
            local t = (SysTime() - me.Start) / AnimTime
            me:SetY(Anim.EaseOutBack(Lerp(t, 0, 1)) * math.abs(YOffset - (scrh * 0.02)) + YOffset)
        end

        local Panel = Frame:Add("gRust.Label")
        Panel:SetX(x)
        Panel:SetTextSize(34)
        Panel:SetText(text2)
        Panel:SetWide(bgWidth)
        Panel:SetY(scrh * 0.07 - (Height * 0.5))
        Panel:SetTall(Height)
        Panel:SetColor(col)
        Panel:SetContentAlignment(4)
        Panel.Start = SysTime() + 1.75 + (BoxCount * 0.5)
        Panel.Think = function(me)
            local t = (SysTime() - me.Start) / AnimTime
            me:SetY(Anim.EaseOutBack(Lerp(t, 0, 1)) * math.abs(YOffset - (scrh * 0.075 - (Height * 0.5))) + YOffset)
        end
    end

    local function CreateAvatar(steamID, x, y, size)
        local player = player.GetBySteamID(steamID)
        if not IsValid(player) then return end
        local Avatar = Frame:Add("AvatarImage")
        Avatar:SetPlayer(player, size or 64)
        Avatar:SetX(x)
        Avatar:SetY(y)
        Avatar:SetSize(scrw * 0.0225, scrh * 0.04)
        Avatar.Start = SysTime() + 1.75 + 1
        Avatar.Think = function(me)
            local AnimTime = 0.75
            local Lerped = Lerp((SysTime() - me.Start) / AnimTime, 0, 1)
            local YOffset = -scrh * 0.1
            me:SetY(Anim.EaseOutBack(Lerped) * math.abs(YOffset - (scrh * 0.055)) + YOffset)
        end
        Avatar.Paint = function(me, w, h)
            draw.RoundedBox(0, -2, -2, w + 4, h + 4, Color(255, 255, 255, 200))
        end
    end

    CreateBox(
        scrw * 0.315,
        gRust.Colors.Secondary,
        "ALIVE FOR",
        string.FormattedTime(SysTime() - gRust.LastDeath, "%01im %01is"),
        Color(94, 116, 58),
        150,
        nil,
        -scrw * 0.007
    )

    CreateAvatar(Killer:SteamID(), scrw * 0.421, scrh * 0.055, 64)

    CreateBox(
        scrw * 0.45,
        gRust.Colors.Primary,
        "KILLED BY",
        Killer == pl and "Suicide" or (Killer.Name and Killer:Name() or "KillerName"),
        Color(175, 56, 37, 180),
        180,
        nil,
        -scrw * 0.029
    )

    CreateBox(
        scrw * 0.575,
        gRust.Colors.Primary,
        "WITH A",
        (Killer.GetActiveWeapon and IsValid(Killer:GetActiveWeapon())) and string.sub(Killer:GetActiveWeapon():GetClass(), 6) or "Nothing",
        Color(175, 56, 37, 180),
        160,
        nil,
        -scrw * 0.007
    )

    CreateBox(
        scrw * 0.71,
        gRust.Colors.Surface,
        "AT A DISTANCE OF",
        string.format("%.1fm", math.Round(pl:GetPos():Distance(Killer:GetPos()) * 0.05, 1)),
        Color(46, 46, 46),
        170,
        scrw * 0.05 ,
        -scrw * 0.007
    )

    gRust.MapMenu = vgui.Create("gRust.Map", Frame)
    gRust.MapMenu:Dock(TOP)
    gRust.MapMenu:DockMargin(0, 0, 0, 80)
    gRust.MapMenu:SetSize(scrw, scrh * 0.750)

    local BottomPanel = Frame:Add("DPanel")
    BottomPanel:Dock(BOTTOM)
    BottomPanel:SetTall(scrh * 0.12)
    BottomPanel.Paint = function(me, w, h)
        surface.SetDrawColor(Colors.Background)
        surface.DrawRect(0, 0, w, h)
    end

    local VerticalPadding = scrh * 0.0235
    local HorizontalPadding = scrw * 0.052
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
    RespawnButton.DoClick = function()
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
        SleepingBag:DockMargin(0, 0, 0, 5)
        SleepingBag:SetDefaultColor(Colors.Default)
        SleepingBag:SetHoveredColor(Colors.Hovered)
        SleepingBag:SetActiveColor(Colors.Active)
        SleepingBag.DoClick = function()
            if not bagData.canRespawn then return end
            net.Start("gRust.BagRespawn")
            net.WriteUInt(bagData.index, 13)
            net.SendToServer()
            Frame:Remove()
        end
        SleepingBag.Think = function()
            if bagData.canRespawn then
                SleepingBag:SetText("BAG " .. i)
                SleepingBag:SetWide(scrw * 0.11)
            else
                local timeLeft = math.max(0, bagData.timeLeft - (CurTime() - gRust.LastDeath))
                if timeLeft > 0 then
                    SleepingBag:SetText(string.format("BAG %i [%i]", i, math.ceil(timeLeft)))
                    SleepingBag:SetWide(scrw * 0.14)
                else
                    bagData.canRespawn = true
                    SleepingBag:SetText("BAG " .. i)
                    SleepingBag:SetWide(scrw * 0.11)
                end
            end
        end
    end

    gRust.LastDeath = SysTime()
end

net.Receive("gRust.DeathScreen", ShowDeathScreen)
