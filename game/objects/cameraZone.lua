local CameraZone = {
    Name = "CameraZone",
    
    DampeningFactorX = 5,
    DampeningFactorY = 5,
    
    MaxDistancePerFrameX = 10,
    MaxDistancePerFrameY = 10,
    
    MinDistancePerFrameX = 1.5,
    MinDistancePerFrameY = 1.5,

    MaxDistanceFromFocusX = 0,
    MaxDistanceFromFocusY = 0,

    RealMaxDistanceFromFocusX = 250,
    RealMaxDistanceFromFocusY = 80,

    DampeningFactorReelingX = 10,
    DampeningFactorReelingY = 10,

    MinDistancePerFrameReelingX = 1.5,
    MinDistancePerFrameReelingY = 1.5,
    
    MaxDistancePerFrameReelingX = 15,
    MaxDistancePerFrameReelingY = 15,

    CameraSizeX = false,    -- can set custom camera dimensions!
    CameraSizeY = false,    -- can set custom camera dimensions!

    CameraOffsetX = false, -- can also set custom camera offsets
    CameraOffsetY = false, -- can also set custom camera offsets

    ZoomSpeed = 5,
    
    _super = "Prop", _global = true
}

function CameraZone.new()
    local cameraZone = Prop.new{
        Solid = true, Visible = true, Passthrough = true,
        Color = V{.8,.8,.8, 0},
        AnchorPoint = V{ 0,0 },
        Rotation = 0,
        DrawOverChildren = false,
        Texture = Texture.new("chexcore/assets/images/square.png"),
    }

    setmetatable(cameraZone, CameraZone)

    return cameraZone
end

function CameraZone:OnTouchEnter(other)
    if not other:IsA("Player") then return end
    local cam = self:GetLayer():GetParent().Camera
    cam.Overrides[#cam.Overrides+1] = self
    -- cam.Focus = self.Focus
    -- cam.FillWithFocus = self.Size:Magnitude() > 0
    -- self:GetLayer():GetParent().Camera.DampeningFactor = 10
end

function CameraZone:OnTouchLeave(other)
    -- self:GetLayer():GetParent().Camera.Focus = other
    local cam = self:GetLayer():GetParent().Camera

    for i = #cam.Overrides, 1, -1 do
        if cam.Overrides[i] == self then
            table.remove(cam.Overrides, i)
            break
        end
    end

    -- cam.FillWithFocus = false
    -- self:GetLayer():GetParent().Camera.DampeningFactor = 60
end

return CameraZone