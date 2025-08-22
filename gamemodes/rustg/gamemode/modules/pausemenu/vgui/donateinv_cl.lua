local INVENTORY_PANEL = {}

local data = nil
local timeupdate = 0

function INVENTORY_PANEL:Init()
    local player = LocalPlayer()

    local LeftPanel = self:Add("Panel")
    LeftPanel:Dock(LEFT)
    LeftPanel:SetWide(ScrH() * 0.3)
    LeftPanel.Paint = function(me, w, h)
        surface.SetDrawColor(70, 130, 180, 50)
        surface.DrawRect(0, 0, w, h)
    end

    local RootPanel = self:Add("Panel")
    RootPanel:Dock(FILL)
    RootPanel:DockPadding(ScrH() * 0.01, ScrH() * 0.01, ScrH() * 0.01, ScrH() * 0.01)
    RootPanel.Paint = function(me, w, h)
        surface.SetDrawColor(37, 36, 32, 150)
        surface.DrawRect(0, 0, w, h)
    end

    local refreshButton = LeftPanel:Add('DButton')
    refreshButton:Dock(BOTTOM)
    refreshButton:DockMargin(ScrH() * 0.025, 0, ScrH() * 0.025, ScrH() * 0.025)
    refreshButton:SetTall(ScrH() * 0.06)
    refreshButton:SetText("")
    refreshButton:SetFont("gRust.32px")
    refreshButton:SetTextColor(Color(255, 255, 255))

    refreshButton.Paint = function(me, w, h)
        local bgColor = me:IsHovered() and Color(70, 131, 180, 121) or Color(70, 130, 180, 50)
        surface.SetDrawColor(bgColor:Unpack())
        surface.DrawRect(0, 0, w, h)
        
        local iconSize = math.min(w, h) * 0.5
        local iconX = w * 0.08
        local iconY = (h - iconSize) / 2
        
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Material("materials/icons/vending.png", "smooth"))
        surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
        
        local textX = iconX + iconSize + w * 0.05
        draw.SimpleText("REFRESH INVENTORY", "gRust.32px", textX, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    local padding = math.max(20, ScrW() * 0.03)
    
    local scrollPanel = RootPanel:Add('DScrollPanel')
    scrollPanel:Dock(FILL)
    scrollPanel:DockPadding(padding, padding, padding, padding)

    local vbar = scrollPanel:GetVBar()
    vbar:SetWide(0)
    vbar:SetVisible(false)

    scrollPanel:SetMouseInputEnabled(true)

    function scrollPanel:OnMouseWheeled(delta)
        local target = self:GetCanvas():GetY() + delta * 50
        self:GetCanvas():MoveTo(0, math.Clamp(target, -(self:GetCanvas():GetTall() - self:GetTall()), 0), 0.1, 0, 0.5)
        return true
    end
    
    scrollPanel.Paint = function(me, w, h)
        local gradient = Material("vgui/gradient_down")
        surface.SetDrawColor(28, 106, 159, 120)
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h * 0.75)
    end
    
    local itemGrid = vgui.Create("DGrid", scrollPanel)
    itemGrid:SetPos(padding, padding + 60)

    local cols = 2
    local colWidth = 400
    local rowHeight = 490
    
    itemGrid:SetCols(cols)
    itemGrid:SetColWide(colWidth)
    itemGrid:SetRowHeight(rowHeight)

    function self:AddPreviewPanel()
        local previewContainer = self:Add("Panel")
        previewContainer:SetPos(0, 0)
        previewContainer:SetSize(ScrW(), ScrH())
        previewContainer:SetVisible(false)
        previewContainer:SetZPos(999)
        
        previewContainer.Paint = function(me, w, h)
            surface.SetDrawColor(22, 73, 112, 240)
            surface.DrawRect(0, 0, w, h)
        end
        
        local closeBtn = vgui.Create("DButton", previewContainer)
        closeBtn:SetSize(60, 60)
        closeBtn:SetPos(50, 50)
        closeBtn:SetText("")
        closeBtn:SetCursor('hand')
        
        closeBtn.Paint = function(me, w, h)
            local color = me:IsHovered() and Color(107, 106, 99, 169) or Color(78, 77, 70, 185)
            surface.SetDrawColor(color:Unpack())
            surface.DrawRect(0, 0, w, h)
            
            surface.SetDrawColor(232, 220, 211, 255)
            surface.SetMaterial(Material("materials/icons/close.png", "smooth mips"))
            surface.DrawTexturedRect((w-32)/2, (h-32)/2, 32, 32)
        end
        
        closeBtn.DoClick = function()
            previewContainer:SetVisible(false)
        end
        
        local leftPanel = vgui.Create("Panel", previewContainer)
        leftPanel:SetPos(120, 200)
        leftPanel:SetSize(430, 430)
        
        
        
        leftPanel.Paint = function(me, w, h)
            surface.SetDrawColor(78, 77, 70, 169)
            surface.DrawRect(0, 0, w, h)
            
            if me.icon then
                surface.SetDrawColor(232, 220, 211, 255)
                surface.SetMaterial(me.icon)
                surface.DrawTexturedRect(50, 50, w-100, h-120)
            end
        end
        

        local title = vgui.Create("DLabel", previewContainer)
        title:SetPos(580, 250)
        title:SetSize(500, 80)
        title:SetFont("gRust.48px")
        title:SetTextColor(Color(232, 220, 211))
        
        local statusLabel = vgui.Create("DLabel", previewContainer)
        statusLabel:SetPos(580, 340)
        statusLabel:SetSize(500, 40)
        statusLabel:SetFont("gRust.30px")
        statusLabel:SetTextColor(Color(16, 145, 238))

        local desc = vgui.Create("DLabel", previewContainer)
        desc:SetPos(580, 380)
        desc:SetSize(500, 30)
        desc:SetFont("gRust.30px")
        desc:SetTextColor(Color(232, 220, 211, 170))
        desc:SetText("DESCRIPTION")
        
        local descLabel = vgui.Create("DLabel", previewContainer)
        descLabel:SetPos(580, 420)
        descLabel:SetSize(500, 200)
        descLabel:SetFont("gRust.30px")
        descLabel:SetTextColor(Color(197, 104, 67))
        descLabel:SetWrap(true)
        descLabel:SetAutoStretchVertical(true)
        descLabel:SetContentAlignment(7)
        
        
        previewContainer.PerformLayout = function(me, w, h)
            me:SetSize(w, h)
            me:SetPos(0, 0)
        end
        
        self.previewContainer = previewContainer
        self.previewLeftPanel = leftPanel
        self.previewTitle = title
        self.previewStatus = statusLabel
        self.previewDesc = descLabel
    end

    function self:ShowItemPreview(itemData)
        if not IsValid(self.previewContainer) then return end
        
        self.previewContainer:SetVisible(true)
        self.previewContainer:SetSize(ScrW(), ScrH())
        self.previewContainer:InvalidateLayout()
        
        self.previewLeftPanel.icon = Material(itemData.icon or itemData.thumbnail, "smooth mips")
        self.previewTitle:SetText(string.upper(itemData.title or "UNKNOWN"))
        
        local statusText = ""
        local statusColor = Color(16, 145, 238)
        
        if itemData.expires then
            local timeLeft = itemData.expires - os.time()
            if timeLeft > 0 then
                local days = math.floor(timeLeft / 86400)
                local hours = math.floor((timeLeft % 86400) / 3600)
                local minutes = math.floor((timeLeft % 3600) / 60)
                
                if days > 0 then
                    statusText = "EXPIRES IN: " .. days .. " DAYS " .. hours .. " HOURS"
                elseif hours > 0 then
                    statusText = "EXPIRES IN: " .. hours .. " HOURS " .. minutes .. " MINUTES"
                else
                    statusText = "EXPIRES IN: " .. minutes .. " MINUTES"
                end
                statusColor = Color(255, 200, 100)
            else
                statusText = "EXPIRED"
                statusColor = Color(158, 149, 142)
            end
        else
            statusText = "PERMANENT ITEM"
            statusColor = Color(16, 145, 238)
        end
        
        self.previewStatus:SetText(statusText)
        self.previewStatus:SetTextColor(statusColor)
        
        self.previewDesc:SetText(itemData.description or "")
    end

    self:AddPreviewPanel()

    function self:SetPurchases(purchases)
        itemGrid:Clear()
        
        for _, purchase in ipairs(purchases) do
            if not purchase.itemid then continue end
            
            local item = vgui.Create("DButton", itemGrid)
            local bg = Material("materials/ui/background.png")

            local itemWidth = 340
            local itemHeight = 400
            
            item:SetSize(itemWidth, itemHeight)
            item:SetText("")
            item:SetCursor('hand')
            
            item.Paint = function(me, w, h)
                local isHovered = me:IsHovered()
                local bgColor = isHovered and Color(169, 236, 53) or Color(42, 42, 34, 255)

                surface.SetDrawColor(bgColor:Unpack())
                surface.DrawRect(0, 0, w, h)
                
                surface.SetDrawColor(42, 42, 34, 100)
                surface.SetMaterial(bg)
                surface.DrawTexturedRect(0, 0, w, h)

                surface.SetDrawColor(78, 77, 70, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
                if purchase.thumbnail and purchase.thumbnail ~= "" then
                    local mat = Material(purchase.thumbnail, "smooth mips")
                    if mat and not mat:IsError() then
                        surface.SetDrawColor(232, 220, 211, 255)
                        surface.SetMaterial(mat)
                        surface.DrawTexturedRect(10, 10, w-20, h-100)
                    else
                        -- Используем fallback если материал не найден
                        surface.SetDrawColor(100, 100, 100, 100)
                        surface.DrawRect(10, 10, w-20, h-100)
                        
                        surface.SetDrawColor(255, 255, 255, 180)
                        surface.SetMaterial(Material("icon16/box.png", "smooth"))
                        local iconSize = (w - 20) * 0.3
                        surface.DrawTexturedRect(w/2 - iconSize/2, 10 + (h-100)/2 - iconSize/2, iconSize, iconSize)
                    end
                elseif purchase.icon and purchase.icon ~= "" then
                    local mat = Material(purchase.icon, "smooth mips")
                    if mat and not mat:IsError() then
                        surface.SetDrawColor(232, 220, 211, 255)
                        surface.SetMaterial(mat)
                        surface.DrawTexturedRect(10, 10, w-20, h-100)
                    else
                        surface.SetDrawColor(100, 100, 100, 100)
                        surface.DrawRect(10, 10, w-20, h-100)
                        
                        surface.SetDrawColor(255, 255, 255, 180)
                        surface.SetMaterial(Material("icon16/box.png", "smooth"))
                        local iconSize = (w - 20) * 0.3
                        surface.DrawTexturedRect(w/2 - iconSize/2, 10 + (h-100)/2 - iconSize/2, iconSize, iconSize)
                    end
                else
                    surface.SetDrawColor(100, 100, 100, 100)
                    surface.DrawRect(10, 10, w-20, h-100)
                    
                    surface.SetDrawColor(255, 255, 255, 180)
                    surface.SetMaterial(Material("icon16/box.png", "smooth"))
                    local iconSize = (w - 20) * 0.3
                    surface.DrawTexturedRect(w/2 - iconSize/2, 10 + (h-100)/2 - iconSize/2, iconSize, iconSize)
                end
                

                draw.SimpleText(purchase.title or "UNKNOWN", "gRust.22px", 15, h - 72, Color(232, 220, 211), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                draw.SimpleText(purchase.subtitle or "Item", "gRust.16px", 15, h - 49, Color(158, 149, 142), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

                local btnY = h - 27
                local btnW = 115
                local btnH = 20
                local btnX = 15
                
                if purchase.expires then
                    local timeLeft = purchase.expires - os.time()
    
                    if timeLeft > 0 then
                        local timeText = ""
                        local timeColor = Color(255, 200, 100, 200)
                        
                        if timeLeft < 60 then
                            timeText = math.floor(timeLeft) .. "s"
                        else
                            local days = math.floor(timeLeft / 86400)
                            local hours = math.floor((timeLeft % 86400) / 3600)
                            local minutes = math.floor((timeLeft % 3600) / 60)
                            
                            if days > 0 then
                                timeText = days .. "d " .. hours .. "h"
                            elseif hours > 0 then
                                timeText = hours .. "h " .. minutes .. "m"
                            else
                                timeText = minutes .. "m"
                            end
                        end
                        
                        surface.SetDrawColor(timeColor:Unpack())
                        surface.DrawRect(btnX, btnY, btnW, btnH)
                        draw.SimpleText(timeText, "gRust.16px", btnX + btnW/2, btnY + btnH/2, Color(232, 220, 211), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    else
                        surface.SetDrawColor(78, 77, 70, 200)
                        surface.DrawRect(btnX, btnY, btnW, btnH)
                        draw.SimpleText("EXPIRED", "gRust.16px", btnX + btnW/2, btnY + btnH/2, Color(158, 149, 142), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                else
                    surface.SetDrawColor(16, 145, 238, 255)
                    surface.DrawRect(btnX, btnY, btnW, btnH)
                    draw.SimpleText("PERMANENT", "gRust.16px", btnX + btnW/2, btnY + btnH/2, Color(232, 220, 211), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            
            item.DoClick = function()
                self:ShowItemPreview(purchase)
            end
            itemGrid:AddItem(item)
        end
        
        itemGrid:InvalidateLayout(true)
        scrollPanel:InvalidateLayout(true)
    end

    function self:LoadInventoryData()
        local currentTime = CurTime()
        
        if data and (currentTime - timeupdate) < 300 then
            self:SetBusy(false)
            self:SetPurchases(data)
            return
        end
        
        self:SetBusy(false)
        net.Start('Store.RequestRefresh')
        net.SendToServer()
    end

    function self:PaintOver(w, h)
        if not self.isBusy then return end
        
        surface.SetDrawColor(128, 128, 128, 200)
        surface.DrawRect(0, 0, w, h)
        
        draw.SimpleText("Loading...", "gRust.64px", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function self:SetBusy(state)
        self.isBusy = state
        self:SetMouseInputEnabled(not state)
        refreshButton:SetEnabled(not state)
    end

    function self:PerformLayout()
        if IsValid(itemGrid) then
            local padding = math.max(20, ScrW() * 0.03)

            local cols = 2
            local colWidth = 400
            local rowHeight = 490
            
            itemGrid:SetCols(cols)
            itemGrid:SetColWide(colWidth)
            itemGrid:SetRowHeight(rowHeight)
            itemGrid:InvalidateLayout(true)
        end
        
        if IsValid(scrollPanel) then
            scrollPanel:InvalidateLayout(true)
        end
    end

    function refreshButton:DoClick()
        local parentPanel = self:GetParent():GetParent()
        parentPanel:SetBusy(true)
        
        data = nil
        timeupdate = 0
        
        net.Start('Store.RequestRefresh')
        net.SendToServer()
        
        timer.Simple(10, function()
            if IsValid(parentPanel) then
                parentPanel:SetBusy(false)
            end
        end)
    end

    self.itemGrid = itemGrid
    self.scrollPanel = scrollPanel

    timer.Simple(0.1, function()
        if IsValid(self) then
            self:LoadInventoryData()
        end
    end)
end

net.Receive("Store.PlayerDataLoaded", function()
    local purchases = net.ReadTable()
    
    data = purchases
    timeupdate = CurTime()

    for _, panel in pairs(vgui.GetWorldPanel():GetChildren()) do
        if panel.ClassName == "gRust.DonateInv" and IsValid(panel) then
            panel:SetBusy(false)
            panel:SetPurchases(purchases)
            break
        end
    end
end)

net.Receive("Store.PurchaseResponse", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    local newBalance = net.ReadInt(32)
    
    if success then
        data = nil
        timeupdate = 0
        
        timer.Simple(0.5, function()
            net.Start('Store.RequestRefresh')
            net.SendToServer()
        end)
    end
end)

vgui.Register("gRust.DonateInv", INVENTORY_PANEL, "Panel")

concommand.Add("store_reset_all", function(ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
    
    -- Подтверждение
    if args[1] ~= "confirm" then
        ply:ChatPrint("WARNING: This will delete ALL store and inventory data!")
        ply:ChatPrint("Use: store_reset_all confirm")
        return
    end
    
    -- Очищаем временные предметы
    sql.Query("DELETE FROM player_inventory")
    
    -- Очищаем покупки магазина
    PlayerData = {}
    
    ply:ChatPrint("ALL store and inventory data has been cleared!")
    
    -- Обновляем всех игроков
    for _, p in ipairs(player.GetAll()) do
        timer.Simple(0.5, function()
            if IsValid(p) then
                local inventory = LoadPlayerInventory(p)
                net.Start("Store.PlayerDataLoaded")
                net.WriteTable(inventory)
                net.Send(p)
            end
        end)
    end
end)
