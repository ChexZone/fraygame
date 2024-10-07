local CameraZone = {
    Name = "CameraZone", _super = "Prop", _global = true
}

function CameraZone.new()
    local cameraZone = Prop.new{
        Solid = true, Visible = true, Passthrough = true,
        Color = V{.8,.8,.8, 0.25},
        AnchorPoint = V{ 0,0 },
        Rotation = 0,
        DrawOverChildren = false,
        Texture = Texture.new("chexcore/assets/images/square.png"),
    }

    setmetatable(cameraZone, CameraZone)

    return cameraZone
end

function CameraZone:OnTouchEnter(other)
    self:GetLayer():GetParent().Camera.Focus = self.Focus
    self:GetLayer():GetParent().Camera.DampeningFactor = 10
end

function CameraZone:OnTouchLeave(other)
    self:GetLayer():GetParent().Camera.Focus = other
    self:GetLayer():GetParent().Camera.DampeningFactor = 30
end

return CameraZone