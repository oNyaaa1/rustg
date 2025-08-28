include("shared.lua")

function ENT:Initialize()
    -- Cache the model bounds for better performance
    self.ModelBounds = self:GetModelBounds()
end

function ENT:Draw()
    self:DrawModel()
    
    -- Optional: Add some ambient lighting effect or rust-like atmosphere
    -- This can be expanded later for visual enhancements
end

function ENT:Think()
    -- Add any client-side thinking if needed
    -- For example, particle effects, ambient sounds, etc.
end