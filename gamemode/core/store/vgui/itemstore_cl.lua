local STORE_PANEL = {}

function STORE_PANEL:Init()
    self.currentTab = "limited"
    self.storeItems = {}
    self.playerBalance = 0
    
    self:AddInterface()
    self:RequestStoreData()
end

function STORE_PANEL:AddInterface()
    self.Paint = function(me, w, h)
        surface.SetDrawColor(22, 22, 22, 255)
        surface.DrawRect(0, 0, w, h)
    end
    
    self:AddTopBar()
    self:AddContentArea()
    self:AddPreviewPanel()
end

function STORE_PANEL:AddTopBar()
    local topBar = self:Add("Panel")
    topBar:Dock(TOP)
    topBar:SetTall(66)
    topBar.Paint = function(me, w, h)
        surface.SetDrawColor(34, 34, 34, 255)
        surface.DrawRect(0, 0, w, h)
    end
    
    self:AddTopUpButton(topBar)
    self:AddBalanceDisplay(topBar)
    self:AddTab(topBar)
end

function STORE_PANEL:AddTopUpButton(parent)
    local topbtn = parent:Add("DButton")
    topbtn:Dock(RIGHT)
    topbtn:SetWide(66)
    topbtn:SetText("")
    topbtn:SetCursor('hand')
    
    topbtn.Paint = function(me, w, h)
        local color = me:IsHovered() and Color(115, 141, 69, 200) or Color(115, 141, 69, 120)
        surface.SetDrawColor(color:Unpack())
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(193, 241, 106, 255)
        surface.SetMaterial(Material("materials/icons/add.png", "smooth mips"))
        surface.DrawTexturedRect((w-32)/2, (h-32)/2, 32, 32)
    end
    
    topbtn.DoClick = function()
        gui.OpenURL("https://grust.co/donate")
    end
end

function STORE_PANEL:AddBalanceDisplay(parent)
    local balance = parent:Add("Panel")
    balance:Dock(RIGHT)
    balance:SetWide(200)
    balance:DockMargin(0, 12, 12, 12)
    
    balance.Paint = function(me, w, h)
        surface.SetDrawColor(232, 220, 211, 255)
        surface.SetMaterial(Material("items/resources/scrapcoin.png", "smooth mips"))
        surface.DrawTexturedRect(w - h, 0, h, h)
        
        draw.SimpleText(string.Comma(self.playerBalance), "gRust.24px", w - h - 12, h/2, Color(232, 220, 211), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

function STORE_PANEL:AddTab(parent)
    local tabs = {
        {id = "limited", name = "LIMITED", icon = "materials/ui/zohart/icons/time.png"},
        {id = "bundles", name = "BUNDLES", icon = "materials/icons/construction.png"},
        {id = "general", name = "GENERAL", icon = "materials/icons/info.png"}
    }
    
    for i, tab in ipairs(tabs) do
        local tabBtn = parent:Add("DButton")
        tabBtn:Dock(LEFT)
        tabBtn:SetWide(180)
        tabBtn:DockMargin(0, 0, 3, 0)
        tabBtn:SetText("")
        tabBtn:SetCursor('hand')
        
        tabBtn.Paint = function(me, w, h)
            local isActive = self.currentTab == tab.id
            local isHovered = me:IsHovered()
            
            if isActive then
                surface.SetDrawColor(16, 145, 238, 255)
            elseif isHovered then
                surface.SetDrawColor(78, 77, 70, 255)
            else
                surface.SetDrawColor(78, 77, 70, 210)
            end
            surface.DrawRect(0, 0, w, h)
            
            local iconColor = isActive and Color(232, 220, 211, 190) or Color(232, 220, 211, 120)
            surface.SetDrawColor(iconColor:Unpack())
            surface.SetMaterial(Material(tab.icon, "smooth mips"))
            surface.DrawTexturedRect(w/2 - 50, h/2 - 11, 22, 22)
            
            local textColor = isActive and Color(232, 220, 211) or Color(232, 220, 211, 190)
            draw.SimpleText(tab.name, "gRust.20px", w/2 - 20, h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        
        tabBtn.DoClick = function()
            self.currentTab = tab.id
            self:RefreshContent()
        end
    end
end

function STORE_PANEL:AddContentArea()
    local scrollPanel = self:Add("DScrollPanel")
    scrollPanel:Dock(FILL)
    scrollPanel:DockPadding(40, 40, 40, 40)

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
    itemGrid:SetPos(40, 100)
    itemGrid:SetCols(3)
    itemGrid:SetColWide(400)
    itemGrid:SetRowHeight(490)
    
    self.itemGrid = itemGrid
    self.scrollPanel = scrollPanel
end

function STORE_PANEL:AddStoreItem(itemData)
    local item = vgui.Create("DButton", self.itemGrid)
    local bg = Material("materials/ui/background.png")
    
    item:SetSize(340, 400)
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

        if itemData.thumbnail then
            surface.SetDrawColor(232, 220, 211, 255)
            surface.SetMaterial(Material(itemData.thumbnail, "smooth mips"))
            surface.DrawTexturedRect(10, 10, w-20, h-100)
        elseif itemData.icon then
            surface.SetDrawColor(232, 220, 211, 255)
            surface.SetMaterial(Material(itemData.icon, "smooth mips"))
            surface.DrawTexturedRect(10, 10, w-20, h-100)
        end

        draw.SimpleText(itemData.title or "UNKNOWN", "gRust.22px", 15, h - 72, Color(232, 220, 211), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(itemData.subtitle or "Item", "gRust.16px", 15, h - 49, Color(158, 149, 142), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        
        local btnY = h - 27
        local btnW = 115
        local btnH = 20
        local btnX = 15
        
        if itemData.owned then
            surface.SetDrawColor(16, 145, 238, 255)
            surface.DrawRect(btnX, btnY, btnW, btnH)
            
            draw.SimpleText("PURCHASED", "gRust.16px", btnX + btnW/2, btnY + btnH/2, Color(232, 220, 211), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local canAfford = self.playerBalance >= itemData.price
            
            if canAfford then
                surface.SetDrawColor(115, 141, 69, 200)
                surface.DrawRect(btnX, btnY, btnW, btnH)
                
                local priceText = string.Comma(itemData.price or 0)
                draw.SimpleText(priceText, "gRust.16px", btnX + btnW/2, btnY + btnH/2, Color(232, 220, 211), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                surface.SetDrawColor(78, 77, 70, 200)
                surface.DrawRect(btnX, btnY, btnW, btnH)
                
                local priceText = string.Comma(itemData.price or 0)
                draw.SimpleText(priceText, "gRust.16px", btnX + btnW/2, btnY + btnH/2, Color(158, 149, 142), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
    
    item.DoClick = function()
        self:ShowItemPreview(itemData)
    end
    
    if not itemData.owned then
        local purchaseBtn = vgui.Create("DButton", item)
        purchaseBtn:SetPos(15, item:GetTall() - 27)
        purchaseBtn:SetSize(115, 20)
        purchaseBtn:SetText("")
        purchaseBtn:SetCursor('hand')
        purchaseBtn:SetZPos(10)
        
        purchaseBtn.Paint = function() end
        
        purchaseBtn.DoClick = function()
            local confirm = "Are you sure you want to buy '" .. (itemData.title or "UNKNOWN") .. "' for " .. string.Comma(itemData.price or 0) .. " SC?"
            
            gRust.ConfirmQuery(confirm, function()
                if not itemData.owned and self.playerBalance >= itemData.price then
                    self:PurchaseItem(itemData)
                end
            end)
        end
    end
    
    return item
end

function STORE_PANEL:AddPreviewPanel()
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
        local color = me:IsHovered() and Color(78, 77, 70, 255) or Color(78, 77, 70, 210)
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
    
    local type = vgui.Create("DLabel", previewContainer)
    type:SetPos(580, 310)
    type:SetSize(500, 40)
    type:SetFont("gRust.30px")
    type:SetTextColor(Color(16, 145, 238))
    
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
    
    
    local purchaseBtn = vgui.Create("DButton", previewContainer)
    purchaseBtn:SetSize(300, 60)
    purchaseBtn:SetText("")
    purchaseBtn:SetCursor('hand')
    
    purchaseBtn.Paint = function(me, w, h)
        local color = me:IsHovered() and Color(115, 141, 69, 255) or Color(115, 141, 69, 170)
        
        surface.SetDrawColor(color:Unpack())
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(232, 220, 211, 255)
        surface.SetMaterial(Material("icon16/cart.png"))
        surface.DrawTexturedRect(20, 20, 20, 20)
        
        local priceText = string.Comma(me.price or 0) .. ".00 GS"
        draw.SimpleText(priceText, "gRust.24px", w/2 + 20, h/2, Color(232, 220, 211), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local ownedBtn = vgui.Create("DButton", previewContainer)
    ownedBtn:SetSize(300, 60)
    ownedBtn:SetText("")
    ownedBtn:SetCursor('hand')
    ownedBtn:SetVisible(false)
    
    ownedBtn.Paint = function(me, w, h)
        surface.SetDrawColor(16, 145, 238, 255)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(232, 220, 211, 255)
        surface.SetMaterial(Material("icon16/tick.png"))
        surface.DrawTexturedRect(20, 20, 20, 20)
        
        draw.SimpleText("PURCHASED", "gRust.24px", w/2 + 20, h/2, Color(232, 220, 211), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    previewContainer.PerformLayout = function(me, w, h)
        me:SetSize(w, h)
        me:SetPos(0, 0)
        purchaseBtn:SetPos(w - 350, h - 110)
        ownedBtn:SetPos(w - 350, h - 110)
    end
    
    self.previewContainer = previewContainer
    self.previewLeftPanel = leftPanel
    self.previewTitle = title
    self.previewType = type
    self.previewDesc = descLabel
    self.purchaseBtn = purchaseBtn
    self.ownedBtn = ownedBtn
end

function STORE_PANEL:ShowItemPreview(itemData)
    if not IsValid(self.previewContainer) then return end
    
    self.previewContainer:SetVisible(true)
    self.previewContainer:SetSize(ScrW(), ScrH())
    self.previewContainer:InvalidateLayout()
    
    self.previewLeftPanel.icon = Material(itemData.icon or itemData.thumbnail, "smooth mips")
    self.previewTitle:SetText(string.upper(itemData.title or "UNKNOWN"))
    self.previewType:SetText(string.upper(itemData.subtitle or "ITEM SKIN"))
    self.previewDesc:SetText(itemData.description or "This is a skin for the item. You will be able to apply this skin at a repair bench or when you craft the item in game.")
    
    self.purchaseBtn.price = itemData.price
    self.purchaseBtn.DoClick = function()
        local confirm = "Are you sure you want to buy '" .. (itemData.title or "UNKNOWN") .. "' for " .. string.Comma(itemData.price or 0) .. " SC?" 
        gRust.ConfirmQuery(confirm, function()
            if not itemData.owned and self.playerBalance >= itemData.price then
                self:PurchaseItem(itemData)
                self.previewContainer:SetVisible(false)
            end
        end)
    end
    
    if itemData.owned then
        self.purchaseBtn:SetVisible(false)
        self.ownedBtn:SetVisible(true)
    else
        self.purchaseBtn:SetVisible(true)
        self.ownedBtn:SetVisible(false)
    end
end


function STORE_PANEL:RefreshContent()
    if not IsValid(self.itemGrid) then return end
    
    self.itemGrid:Clear()
    
    for _, itemData in ipairs(self.storeItems) do
        if itemData.category == self.currentTab then
            local itemPanel = self:AddStoreItem(itemData)
            self.itemGrid:AddItem(itemPanel)
        end
    end
    
    self.itemGrid:InvalidateLayout(true)
    if IsValid(self.scrollPanel) then
        self.scrollPanel:InvalidateLayout(true)
    end
end

function STORE_PANEL:RequestStoreData()
    net.Start("Store.RequestData")
    net.SendToServer()
end

function STORE_PANEL:PurchaseItem(itemData)
    
    if not itemData.owned and self.playerBalance >= itemData.price then
        net.Start("Store.BuyItem")
        net.WriteString(itemData.id)
        net.SendToServer()
        
        surface.PlaySound('zohart/purchase.wav')
    end
end

CURRENT_STORE_PANEL = nil

net.Receive("Store.UpdateData", function()
    local items = net.ReadTable()
    local balance = net.ReadInt(32)
    
    local storePanel = CURRENT_STORE_PANEL
    if not IsValid(storePanel) then
        for _, panel in pairs(vgui.GetWorldPanel():GetChildren()) do
            if panel.ClassName == "Item.Store" then
                storePanel = panel
                break
            end
        end
    end
    
    if IsValid(storePanel) then
        storePanel.storeItems = items
        storePanel.playerBalance = balance
        storePanel:RefreshContent()
    end
end)

net.Receive("Store.PurchaseResponse", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    local newBalance = net.ReadInt(32)
    
    local storePanel = CURRENT_STORE_PANEL
    if IsValid(storePanel) then
        storePanel.playerBalance = newBalance
        storePanel:RequestStoreData()
    end
end)

local INIT = STORE_PANEL.Init
function STORE_PANEL:Init()
    CURRENT_STORE_PANEL = self
    INIT(self)
end

vgui.Register("Item.Store", STORE_PANEL, "Panel")
