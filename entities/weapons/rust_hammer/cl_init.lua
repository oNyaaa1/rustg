include("shared.lua")

-- Настройки вида
SWEP.VMPos = Vector(-2, -1, 0.5)
SWEP.VMAng = Vector(0, 0, 0)

-- Переменные для отслеживания
SWEP.currentEntity = nil
SWEP.LastStructure = nil
SWEP.PieOpen = false
SWEP.PickupStart = nil

-- Цвета
local DefaultColor = Color(255, 255, 255)
local HighlightColor = Color(0, 157, 255, 180)
local NoiseColor = Color(57, 182, 255)

-- Дистанция взаимодействия
local Dist = 150
local PickupTime = 0.5

local PieMenu = {
    {
        Name = "Upgrade to Metal",
        Desc = "Upgrades to Metal",
        Icon = "icons/level_metal.png",
        Foot = "200x Metal Fragments",
        Condition = function()
            return LocalPlayer():HasItem("metal.fragments", 200)
        end,
        Func = function(ent)
            net.Start("gRust.Upgrade")
            net.WriteEntity(ent)
            net.WriteUInt(2, 3)
            net.SendToServer()
        end
    },

    {
        Name = "Upgrade to HQ Metal",
        Desc = "Upgrades to Armored",
        Icon = "icons/level_top.png",
        Foot = "25x HQ Metal",
        Condition = function()
            return LocalPlayer():HasItem("metal.refined", 25)
        end,
        Func = function(ent)
            net.Start("gRust.Upgrade")
            net.WriteEntity(ent)
            net.WriteUInt(3, 3)
            net.SendToServer()
        end
    },

    {
        Name = "Demolish",
        Desc = "Demolish the structure",
        Icon = "icons/demolish.png",
        Foot = "Removes structure",
        Func = function(ent)
            net.Start("gRust.Demolish")
            net.WriteEntity(ent)
            net.SendToServer()
        end
    },
    
    {
        Name = "Rotate",
        Desc = "Rotate the structure in place",
        Icon = "icons/rotate.png",
        Func = function(ent)
            net.Start("gRust.Rotate")
            net.WriteEntity(ent)
            net.SendToServer()
        end
    },

    {
        Name = "Upgrade to Wood",
        Desc = "Upgrades to wood",
        Icon = "icons/level_wood.png",
        Foot = "200x Wood",
        Condition = function()
            return LocalPlayer():HasItem("wood", 200)
        end,
        Func = function(ent)
            net.Start("gRust.Upgrade")
            net.WriteEntity(ent)
            net.WriteUInt(0, 3)
            net.SendToServer()
        end
    },

    {
        Name = "Upgrade to Stone",
        Desc = "Upgrades to Stone",
        Icon = "icons/level_stone.png",
        Foot = "200x Stone",
        Condition = function()
            return LocalPlayer():HasItem("stone", 200)
        end,
        Func = function(ent)
            net.Start("gRust.Upgrade")
            net.WriteEntity(ent)
            net.WriteUInt(1, 3)
            net.SendToServer()
        end
    },
}


-- Основная функция Think (убрали обработку левой кнопки мыши)
function SWEP:Think()
    -- Проверка структуры для pie menu
    self:CheckStructure()
    
    -- Проверка pickup
    local pl = self:GetOwner()
    if(pl:KeyDown(IN_USE)) then
        if(self.PickupStart) then return end
        timer.Simple(0.2, function()
            if(pl:KeyDown(IN_USE) and !self.PickupStart) then
                self.PickupStart = CurTime()
            end
        end)
    else
        self.PickupStart = nil
    end
    
    -- Подсветка структур
    local trace = pl:GetEyeTrace()
    if(IsValid(trace.Entity) && isBuilding(trace.Entity)) then
        if(trace.HitPos:Distance(pl:GetPos()) <= Dist) then
            if(IsValid(self.currentEntity) && self.currentEntity ~= trace.Entity) then
                self.currentEntity:SetColor(DefaultColor)
            end
            
            if(IsValid(trace.Entity)) then
                if(trace.Entity ~= self.currentEntity) then
                    self.currentEntity = trace.Entity
                    LocalPlayer().ShowPieMenu = false
                    LocalPlayer().PieMenuStructure = nil
                end
            else
                if(IsValid(self.currentEntity)) then
                    self.currentEntity:SetColor(DefaultColor)
                    self.currentEntity = nil
                    LocalPlayer().ShowPieMenu = false
                    LocalPlayer().PieMenuStructure = nil
                end
            end
            
            if(IsValid(self.currentEntity)) then
                self.currentEntity:SetColor(HighlightColor)
            end
        else
            if(IsValid(self.currentEntity)) then
                self.currentEntity:SetColor(DefaultColor)
                self.currentEntity = nil
                LocalPlayer().ShowPieMenu = false
                LocalPlayer().PieMenuStructure = nil
            end
        end
    else
        if(IsValid(self.currentEntity)) then
            self.currentEntity:SetColor(DefaultColor)
            self.currentEntity = nil
            LocalPlayer().ShowPieMenu = false
            LocalPlayer().PieMenuStructure = nil
        end
    end
    
    -- Для singleplayer: добавляем обработку правой кнопки мыши в Think
    if(input.WasMousePressed(MOUSE_RIGHT)) then
        self:SecondaryAttack()
    end
end

-- Проверка структуры для pie menu
function SWEP:CheckStructure()
    local pl = self:GetOwner()
    pl:LagCompensation(true)
    local tr = pl:GetEyeTraceNoCursor()
    pl:LagCompensation(false)
    
    if(!IsValid(tr.Entity)) then return end
    
    if(tr.HitPos:DistToSqr(pl:EyePos()) > Dist * Dist or !isBuilding(tr.Entity)) then
        self:ClearStructureEffects()
        return
    end
    
    if(self.LastStructure ~= tr.Entity) then
        self:ClearStructureEffects()
    end
    
    tr.Entity:SetMaterial("models/building/build_noise.vmt")
    tr.Entity:SetColor(NoiseColor)
    self.LastStructure = tr.Entity
end

-- Очистка эффектов структуры
function SWEP:ClearStructureEffects()
    if(IsValid(self.LastStructure)) then
        self.LastStructure:SetMaterial()
        self.LastStructure:SetColor(DefaultColor)
        self.LastStructure = nil
    end
end

function SWEP:CheckPieMenu()
    local pl = self:GetOwner()
    self:CheckStructure()
    
    if(!pl:KeyDown(IN_ATTACK2) and self.PieOpen) then
        -- Добавляем небольшую задержку
        timer.Simple(0.1, function()
            if(!pl:KeyDown(IN_ATTACK2) and self.PieOpen) then
                if(gRust and gRust.ClosePieMenu) then
                    gRust.ClosePieMenu()
                end
                self.PieOpen = false
            end
        end)
    end
end


-- Вторичная атака (pie menu) - единственный способ взаимодействия
function SWEP:SecondaryAttack()
    if(!IsValid(self.LastStructure)) then return end
    
    self.UseStructure = self.LastStructure
    self.PieOpen = true
    
    if(gRust and gRust.OpenPieMenu) then
        gRust.OpenPieMenu(PieMenu, function(SelectionIndex)
            PieMenu[SelectionIndex].Func(self.UseStructure)
        end, self.UseStructure)
    else
        -- Альтернативное уведомление если gRust недоступен
        self:GetOwner():ChatPrint("gRust система недоступна! Pie menu не работает.")
    end
end

-- HUD для pickup
local Width = ScrH() * 0.275
local Height = ScrH() * 0.0125
local Y = ScrH() * 0.45

function SWEP:DrawHUD()
    self:CheckPieMenu()
    
    if(!self.PickupStart) then return end
    
    local ent = self:GetOwner():GetEyeTraceNoCursor().Entity
    if(!IsValid(ent) or !ent.Pickup) then return end
    
    local scrw, scrh = ScrW(), ScrH()
    local Progress = (CurTime() - self.PickupStart) / PickupTime
    local Alpha = math.min(math.Remap(Progress, 0, 0.25, 0, 1), 1)
    
    -- Рисование прогресс-бара
    surface.SetDrawColor(255, 255, 255, Alpha * 100)
    surface.DrawRect(scrw * 0.5 - Width * 0.5, scrh * 0.45 - Height * 0.5, Width, Height)
    
    draw.SimpleText("Pickup", "gRust.28px", scrw * 0.5 - Width * 0.415, Y - scrh * 0.025, Color(255, 255, 255, Alpha * 255), 0, 2)
    
    surface.SetDrawColor(255, 255, 255, Alpha * 255)
    surface.DrawRect(scrw * 0.5 - Width * 0.5, Y - Height * 0.5, (Width * Progress), Height)
    
    if(gRust and gRust.GetIcon) then
        surface.SetMaterial(gRust.GetIcon("give"))
        surface.SetDrawColor(ColorAlpha(gRust.Colors.Primary, Alpha * 255))
        surface.DrawTexturedRect(scrw * 0.5 - Width * 0.5, Y - scrh * 0.03, scrh * 0.025, scrh * 0.025)
    end
    
    if(Progress >= 1) then
        self.PickupStart = nil
        net.Start("gRust.Pickup")
        net.WriteEntity(ent)
        net.SendToServer()
    end
end

-- Очистка при смене оружия
function SWEP:Holster()
    self:ClearStructureEffects()
    if(IsValid(self.currentEntity)) then
        self.currentEntity:SetColor(DefaultColor)
        self.currentEntity = nil
    end
    return true
end

-- Очистка при удалении
function SWEP:OnRemove()
    self:ClearStructureEffects()
    if(IsValid(self.currentEntity)) then
        self.currentEntity:SetColor(DefaultColor)
        self.currentEntity = nil
    end
end
    