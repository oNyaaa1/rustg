local PANEL = {}

function PANEL:Init()
    gRust = gRust or {}
    gRust.DevTools = gRust.DevTools or {}
    gRust.DevTools.Console = gRust.DevTools.Console or {}
    gRust.DevTools.Console.History = gRust.DevTools.Console.History or {}
    
    if not gRust.DevTools.Console.Run then
        gRust.DevTools.Console.Run = function(self, command)
            if not command or command == "" then return end
            
            local trimmedCommand = string.Trim(command)
            if string.len(trimmedCommand) < 2 then
                return false
            end
            
            local args = string.Explode(" ", trimmedCommand)
            local cmd = string.lower(args[1] or "")
            
            if string.len(cmd) < 2 then
                return false
            end
            
            local serverCommands = {
                "sv_", "mp_", "bot_", "rcon_", "host_", "net_"
            }
            
            local isServerCommand = false
            for _, serverCmd in ipairs(serverCommands) do
                if string.StartWith(cmd, serverCmd) or cmd == serverCmd then
                    isServerCommand = true
                    break
                end
            end
            
            if isServerCommand then
               //print("[DevConsole] Server command blocked: " .. command)
                return false
            else
               //print("[DevConsole] Executing: " .. command)
                RunConsoleCommand(unpack(args))
                return true
            end
        end
    end

    local margin = 8
    
    local MainContainer = self:Add("Panel")
    MainContainer:Dock(FILL)
    MainContainer:DockMargin(margin, margin, margin, margin)
    
    local Input = MainContainer:Add("DTextEntry")
    Input:Dock(BOTTOM)
    Input:SetTall(40)
    Input:DockMargin(0, margin, 0, 0)
    Input:SetFont("gRust.32px")
    Input:SetTextColor(color_white)
    Input:SetCursor("hand")
    Input:SetDrawBorder(false)
    Input:SetDrawBackground(false)
    Input:SetMultiline(false)
    Input:SetVerticalScrollbarEnabled(false)
    
    local BottomContainer = MainContainer:Add("Panel")
    BottomContainer:Dock(BOTTOM)
    BottomContainer:SetTall(30)
    BottomContainer:DockMargin(0, margin, 0, 0)

    local Text = MainContainer:Add("RichText")
    Text:Dock(FILL)
    Text:SetFontInternal("gRust.32px")
    Text:SetVerticalScrollbarEnabled(true)
    
    local ButtonContainer = BottomContainer:Add("Panel")
    ButtonContainer:Dock(RIGHT)
    ButtonContainer:SetWide(140)
    
    local CopyButton = ButtonContainer:Add("DButton")
    CopyButton:Dock(RIGHT)
    CopyButton:DockMargin(5, 0, 0, 0)
    CopyButton:SetText("")
    CopyButton:SetCursor("hand")
    CopyButton.Alpha = 100
    
    local ClearButton = ButtonContainer:Add("DButton")
    ClearButton:Dock(RIGHT)
    ClearButton:DockMargin(5, 0, 0, 0)
    ClearButton:SetText("")
    ClearButton:SetCursor("hand")
    ClearButton.Alpha = 100
    
    CopyButton.Paint = function(me, w, h)
        if me:IsHovered() then
            me.Alpha = Lerp(FrameTime() * 15, me.Alpha, 255)
        else
            me.Alpha = Lerp(FrameTime() * 15, me.Alpha, 100)
        end
        
        draw.RoundedBox(0, 0, 0, w, h, Color(130, 201, 36, me.Alpha))
        draw.SimpleText("COPY", "gRust.18px", w * 0.5, h * 0.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    ClearButton.Paint = function(me, w, h)
        if me:IsHovered() then
            me.Alpha = Lerp(FrameTime() * 15, me.Alpha, 255)
        else
            me.Alpha = Lerp(FrameTime() * 15, me.Alpha, 100)
        end
        
        draw.RoundedBox(0, 0, 0, w, h, Color(130, 201, 36, me.Alpha))
        draw.SimpleText("CLEAR", "gRust.18px", w * 0.5, h * 0.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.OutputText = Text
    self.HistoryLoaded = false
    
    function self:AddConsoleText(text, color, skipHistory)
        if IsValid(Text) then
            color = color or Color(255, 255, 255, 255)
            Text:InsertColorChange(color.r, color.g, color.b, color.a)
            Text:AppendText(text .. "\n")
            
            if not skipHistory then
                table.insert(gRust.DevTools.Console.History, {text = text, color = color})
            end
        end
    end
    
    function self:LoadHistory()
        if IsValid(Text) and not self.HistoryLoaded then
            Text:SetText("")
            for i, entry in ipairs(gRust.DevTools.Console.History) do
                self:AddConsoleText(entry.text, entry.color, true)
            end
            self.HistoryLoaded = true
        end
    end
    
    local parentPanel = self
    
    CopyButton.DoClick = function()
        if #gRust.DevTools.Console.History > 0 then
            local clipboardText = ""
            for i, entry in ipairs(gRust.DevTools.Console.History) do
                clipboardText = clipboardText .. entry.text .. "\n"
            end
            
            SetClipboardText(clipboardText)
            
            CopyButton.Alpha = 255
            timer.Simple(0.2, function()
                if IsValid(CopyButton) then
                    CopyButton.Alpha = 100
                end
            end)
        else
        end
    end
    
    ClearButton.DoClick = function()
        if IsValid(Text) then
            Text:SetText("")
            gRust.DevTools.Console.History = {}
            
            parentPanel:AddConsoleText("gRust Developer Console", Color(130, 201, 36, 255))
        end
        
        ClearButton.Alpha = 255
        timer.Simple(0.2, function()
            if IsValid(ClearButton) then
                ClearButton.Alpha = 100
            end
        end)
    end
    
    Input.OnEnter = function(inputSelf)
        local text = inputSelf:GetValue()
        if text == "" then return end

        parentPanel:AddConsoleText("> " .. text, Color(130, 201, 36, 255))
        
        inputSelf:SetText("")
        inputSelf:RequestFocus()

        if gRust and gRust.DevTools and gRust.DevTools.Console and gRust.DevTools.Console.Run then
            local executed = gRust.DevTools.Console:Run(text)
            if executed == false then
            end
        else
        end
    end
    
    if #gRust.DevTools.Console.History == 0 then
        self:AddConsoleText("gRust Developer Console", Color(130, 201, 36, 255))
        self:AddConsoleText("Type commands below and press Enter to execute", Color(200, 200, 200, 255))
        
        if gRust and gRust.DevTools and gRust.DevTools.Console and gRust.DevTools.Console.Run then
        else
        end
    else
        self:LoadHistory()
    end
end

function PANEL:Paint(w, h)
end

vgui.Register("gRust.DevTools.Console", PANEL, "EditablePanel")
