local PANEL = {}

local Dragging = false
local DraggingPanel
local MouseCode

AccessorFunc(PANEL, "Selected", "Selected", FORCE_BOOL)
AccessorFunc(PANEL, "Preview", "Preview", FORCE_BOOL)
AccessorFunc(PANEL, "ID", "ID", FORCE_NUMBER)
AccessorFunc(PANEL, "Entity", "Entity")
AccessorFunc(PANEL, "DrawBackground", "DrawBackground", FORCE_BOOL)

gRust.ActiveInventorySlot = nil

gRust.ScalingInfluence = 0.0    
gRust.Scaling = (ScrH() / 1440) * gRust.ScalingInfluence + (1 - gRust.ScalingInfluence) * ScrW() / 2560

local BlueprintIcon = Material("items/misc/blueprint.png", "smooth")

local AnimTime = 0.3
local AnimIntensity = 0.1

local function Distance(x1, x2, y1, y2)
    return (x2 - x1)^2 + (y2 - y1)^2
end

local function IsMouseDown()
    return input.IsMouseDown(107) or
           input.IsMouseDown(108) or
           input.IsMouseDown(109)
end

function PANEL:Init()
    self:NoClipping(true)
    self:SetDrawBackground(true)
    self.BackgroundMaterial = Material("ui/background.png", "noclamp smooth")
    self.Text = self:Add("DLabel")
    self.Text:SetFont("gRust.30px")
    self.Text:SetText("")
    self.Text:SetWide(100)
    self.Text:SetContentAlignment(6)
    self.Text:SetTextColor(Color(255, 255, 255, 150))
    
    self.ClickScale = 1.0
    self.BounceOffset = 0
    
    self.Matrix = Matrix()
    self.AnimScale = 1
    self.HoveredTime = 0
    self.bHovered = false
    
    self.LastHoverState = false
end

function PANEL:PerformLayout()
    local Margin = self:GetTall() * 0.05
    self.Text:SetX(self:GetWide() - self.Text:GetWide() - Margin)
    self.Text:SetY(self:GetTall() - self.Text:GetTall() - Margin)
end

function PANEL:DrawDrag(x, y, w, h)
    if (!self.Item) then return end
    if (self.Preview) then return end
    surface.SetMaterial(Material(gRust.Items[self.Item:GetItem()]:GetIcon()))
    surface.SetDrawColor(255, 255, 255, 150)
    surface.DrawTexturedRect(x, y, w, h)
end

function PANEL:CanDrag()
    return self.Item ~= nil
end

function PANEL:OnDropped(Other, mcode)
    if (self.Preview) then return end
    if (!Other.Item) then return end
    local Amount = Other.Item:GetQuantity()
    if (mcode == 1) then
        Amount = 1
    elseif (mcode == 2) then
        if (LocalPlayer():KeyDown(IN_SPEED)) then
            Amount = Amount / 3
        else
            Amount = Amount * 0.5
        end
    end
    if (Other.Attachment) then
        net.Start("gRust.RemoveAttachment")
        net.WriteEntity(Other:GetEntity())
        net.WriteEntity(self:GetEntity())
        net.WriteUInt(Other.Weapon, 6)
        net.WriteUInt(Other.Attachment, 3)
        net.WriteUInt(self:GetID(), 6)
        net.SendToServer()
        return
    end
    LocalPlayer():EmitSound(gRust.RandomGroupedSound(string.format("drop.%s", gRust.Items[Other:GetItem():GetItem()]:GetSound())))
    LocalPlayer():MoveSlot(Other:GetEntity(), self:GetEntity(), Other:GetID(), self:GetID(), math.ceil(Amount))
end

function PANEL:OnRelease(other)
    if (!other) then return end
    if (!self.Item) then return end
    if (other.DropPanel) then
        net.Start("gRust.Drop")
        net.WriteEntity(self:GetEntity())
        net.WriteUInt(self:GetID(), 6)
        net.WriteUInt(self.Item:GetQuantity(), 20)
        net.SendToServer()
    end
end

function PANEL:SetItem(item)
    self.Item = item
    if (!item) then
        self.Text:SetText("")
        self.Icon = nil
        return
    end
    
    local ItemData = gRust.Items[item:GetItem()]
    self.Icon = Material(ItemData:GetIcon(), "smooth")
    if (item:GetQuantity() > 1) then
        self.Text:SetText(string.format("x%i", item:GetQuantity()))
    else
        self.Text:SetText("")
    end
end

function PANEL:GetItem()
    return self.Item
end

function PANEL:OnDrag()
    if (self.Preview) then return end
    if (!self.Item) then return end
    
    LocalPlayer():EmitSound(gRust.RandomGroupedSound(string.format("drop.%s", gRust.Items[self.Item:GetItem()]:GetSound())))
end

function PANEL:DoClick()
    if (self.Preview) then return end
    
    if (IsValid(gRust.ActiveInventorySlot) && gRust.ActiveInventorySlot != self) then
        gRust.ActiveInventorySlot:SetSelected(false)
    end

    gRust.ActiveInventorySlot = self
    self:SetSelected(true)
    self.ClickStart = SysTime()
end

function PANEL:OnMousePressed(mouseCode)
    self.StartMouseX, self.StartMouseY = input.GetCursorPos()
    
    if (self.Preview) then return end
    
    if (mouseCode == MOUSE_LEFT) then
        self.ClickStartTime = SysTime()
        self.WasClicked = true
    end
end

function PANEL:OnMouseReleased(mouseCode)
    self.StartMouseX, self.StartMouseY = nil, nil
    
    if (DraggingPanel) then
        self:OnDropped(DraggingPanel, MouseCode)
    end
    
    if (self.Preview) then return end
    
    if (mouseCode == MOUSE_LEFT and self.WasClicked) then
        local clickDuration = SysTime() - (self.ClickStartTime or 0)
        
        if (!self.Dragging and clickDuration < 0.2) then
            self:DoClick()
        end
        
        self.WasClicked = false
        self.ClickStartTime = nil
    end
end

function PANEL:PaintOver(w, h)
    if (self.Dragging) then
        local mx, my = input.GetCursorPos()
        local lx, ly = self:LocalToScreen()
        mx = mx - lx
        my = my - ly
        self:DrawDrag(mx - (w * 0.5), my - (h * 0.5), w, h)
    end
end

function PANEL:UpdateAnimation()
    local x, y = self:LocalToScreen(0, 0)
    local w, h = self:GetWide(), self:GetTall()
    
    x = x + w * 0.5
    y = y + h * 0.5
    
    if (vgui.GetHoveredPanel() == self) then
        if (!self.bHovered) then
            self.bHovered = true
            self.HoveredTime = SysTime()

            if (!self.Preview) then
                LocalPlayer():EmitSound("ui.blip")
            end
        end
    else
        if (self.bHovered) then
            self.bHovered = false
        end
    end
    
    local t = Lerp((SysTime() - self.HoveredTime) / AnimTime, 0, 1)
    
    if (gRust.Anim and gRust.Anim.Punch) then
        self.AnimScale = (gRust.Anim.Punch(t) * AnimIntensity) + 1
    else
        local bounce = math.sin(t * math.pi)
        self.AnimScale = (bounce * AnimIntensity) + 1
    end
    
    self.Matrix:Identity()
    self.Matrix:Translate(Vector(x, y))
    self.Matrix:SetScale(Vector(self.AnimScale, self.AnimScale, 1))
    self.Matrix:Translate(Vector(-x, -y))
end

function PANEL:Think()
    if self.Preview then return end
    
    if (self.DraggingLast and !IsMouseDown()) then
        self:OnRelease(vgui.GetHoveredPanel())
    end
    
    self.DraggingLast = self.Dragging
    
    if ((self.Dragging or DraggingPanel) && !IsMouseDown()) then
        self.Dragging = false
        Dragging = false
        DraggingPanel = nil
        
        self.LastHoverState = false
        self.bHovered = false
    end
    
    if (self.StartMouseX) then
        local mx, my = input.GetCursorPos()
        
        if (!Dragging && self:CanDrag() && Distance(self.StartMouseX, mx, self.StartMouseY, my) > 5^2) then
            self.StartMouseX, self.StartMouseY = nil, nil
            Dragging = true
            DraggingPanel = self
            self.Dragging = true
            self:OnDrag()
            
            if (input.IsMouseDown(107)) then
                MouseCode = 0
            end
            if (input.IsMouseDown(108)) then
                MouseCode = 1
            end
            if (input.IsMouseDown(109)) then
                MouseCode = 2
            end
        end
    end
    
    self:UpdateAnimation()
    self:UpdateOtherAnimations()
    
    self.HadLastItem = self.Item ~= nil
end

function PANEL:UpdateOtherAnimations()
    local dt = FrameTime()

    if self.ClickStart then
        local elapsed = SysTime() - self.ClickStart
        local duration = 0.12
        local progress = elapsed / duration
        
        if progress >= 1.0 then
            self.ClickStart = nil
            self.ClickScale = 1.0
        else
            local t = progress * 2
            if t <= 1 then
                self.ClickScale = 1.0 + t * 0.08
            else
                t = t - 1
                self.ClickScale = 1.08 - t * 0.08
            end
        end
    else
        if math.abs(self.ClickScale - 1.0) > 0.001 then
            self.ClickScale = Lerp(dt * 25, self.ClickScale, 1.0)
        else
            self.ClickScale = 1.0
        end
    end
end

function PANEL:Paint(w, h)
    if (!IsValid(LocalPlayer())) then return end
    
    if (!self.Preview) then
        cam.PushModelMatrix(self.Matrix)
    end
    
    local totalScale = self.ClickScale
    local scaledW = w * totalScale
    local scaledH = h * totalScale
    local offsetX = (w - scaledW) * 0.5
    local offsetY = (h - scaledH) * 0.5
    
    local backgroundMaterial = Material("ui/background.png", "noclamp smooth")
    local scale = 1 / 768
    local uScale = scaledW * scale
    local vScale = scaledH * scale
    
    surface.SetDrawColor(126, 126, 126, 39)
    surface.SetMaterial(backgroundMaterial)
    surface.DrawTexturedRectUV(offsetX, offsetY, scaledW, scaledH, 0, 0, uScale, vScale)
    
    if self:GetSelected() then
        surface.SetDrawColor(0, 127, 211, 150)
        surface.DrawRect(offsetX, offsetY, scaledW, scaledH)
    end
    
    if (!self.Item) then 
        if (!self.Preview) then
            cam.PopModelMatrix()
        end
        return 
    end
    
    local ID = gRust.Items[self.Item:GetItem()]
    
    if (ID:GetWeapon() && !self.Preview) then
        if (ID:GetDurability()) then
            surface.SetDrawColor(90, 206, 45, 20)
            surface.DrawRect(offsetX, offsetY, scaledW * 0.07, scaledH)
            
            local WearFrac = self.Item:GetWear() / 1000
            surface.SetDrawColor(137, 181, 55, 255)
            surface.DrawRect(offsetX, offsetY + scaledH - (scaledH * WearFrac), scaledW * 0.07, scaledH * WearFrac)
        end
        
        if (ID:GetClip()) then
            self.Text:SetText(self.Item:GetClip())
        end
    end
    
    if (!self.Icon) then 
        if (!self.Preview) then
            cam.PopModelMatrix()
        end
        return 
    end
    
    local iconSize = math.min(scaledW, scaledH) * 0.9
    local iconX = offsetX + (scaledW - iconSize) * 0.5
    local iconY = offsetY + (scaledH - iconSize) * 0.5
    
    if (ID:GetBlueprint() == true) then
        surface.SetDrawColor(200, 200, 200)
        surface.SetMaterial(BlueprintIcon)
        surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
    end
    
    surface.SetDrawColor(200, 200, 200)
    surface.SetMaterial(self.Icon)
    surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
    
    local mods = self:GetItem():GetMods()
    if (mods and !self.Preview) then
        local Padding = math.floor(scaledH * 0.0)
        local Spacing = math.floor(scaledH * 0.025)
        local Margin = scaledH * 0.05
        local ModSize = math.floor(scaledH * 0.09)
        
        for i = 1, 3 do
            local modAlpha = mods[i] and 255 or 50
            surface.SetDrawColor(255, 255, 255, modAlpha)
            surface.DrawRect(
                offsetX + Margin + Padding, 
                offsetY + Padding * 2 + ((i - 1) * (ModSize + Spacing)), 
                ModSize, 
                ModSize
            )
        end
    end
    
    if (!self.Preview) then
        cam.PopModelMatrix()
    end
end

function PANEL:SetSelected(selected)
    self.Selected = selected
end

function PANEL:GetSelected()
    return self.Selected
end

vgui.Register("gRust.Inventory.Slot", PANEL, "Panel")
