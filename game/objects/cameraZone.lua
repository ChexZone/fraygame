local CameraZone = {
    Name = "CameraZone",
    
    DampeningFactorX = 10,
    DampeningFactorY = 10,
    
    MaxDistancePerFrameX = false,--10,
    MaxDistancePerFrameY = false,--10,
    
    MinDistancePerFrameX = false,--1.5,
    MinDistancePerFrameY = false,--1.5,

    MaxDistanceFromFocusX = false,--0,
    MaxDistanceFromFocusY = false,--0,

    RealMaxDistanceFromFocusX = math.inf,
    RealMaxDistanceFromFocusY = math.inf,

    DampeningFactorReelingX = 10,
    DampeningFactorReelingY = 10,

    MinDistancePerFrameReelingX = false,--1.5,
    MinDistancePerFrameReelingY = false,--1.5,
    
    MaxDistancePerFrameReelingX = false,--15,
    MaxDistancePerFrameReelingY = false,--15,

    BorderSpeedX = false,--14,
    BorderSpeedY = false,--14,

    CameraSizeX = false,    -- can set custom camera dimensions!
    CameraSizeY = false,    -- can set custom camera dimensions!

    CameraOffsetX = false, -- can also set custom camera offsets
    CameraOffsetY = false, -- can also set custom camera offsets

    ZoomSpeed = 5,
    
    

    _super = "Prop", _global = true
}

function CameraZone.new()
    local cameraZone = Prop.new{
        Solid = true, Visible = false, Passthrough = true,
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