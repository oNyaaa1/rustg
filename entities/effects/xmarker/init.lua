EFFECT.Duration = 1
EFFECT.Size = 16

function EFFECT:Init(data)
    -- Position of the effect
    self.Pos = data:GetOrigin()
    self.LifeTime = CurTime() + self.Duration
end

function EFFECT:Think()
    -- Remove effect when lifetime is over
    return CurTime() < self.LifeTime
end

function EFFECT:Render()
    local alpha = math.Clamp((self.LifeTime - CurTime()) / self.Duration * 255, 0, 255)
    local size = self.Size

    local ang = Angle(90, 0, 0) -- flat on the ground

    cam.Start3D2D(self.Pos + Vector(0,0,2), ang, 0.5)
        draw.SimpleText("X", "Trebuchet24", 0, 0, Color(255,0,0,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
