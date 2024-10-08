local CameraZone = {
    Name = "CameraZone", _super = "Prop", _global = true
}





-- {
--     id = 12,
--     name = "",
--     type = "Wheel",
--     shape = "rectangle",
--     x = 840.667,
--     y = 1356.67,
--     width = 128,
--     height = 128,
--     rotation = 0,
--     gid = 257,
--     visible = true,
--     properties = {}
--   },


-- objects = {
--     {
--       id = 16,
--       name = "TestZone",
--       type = "CameraZone",
--       shape = "rectangle",
--       x = 151.75,
--       y = -11.25,
--       width = 291.25,
--       height = 89.5,
--       rotation = 0,
--       visible = true,
--       properties = {
--         ["Focus"] = { id = 17 }
--       }
--     },












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
    self:GetLayer():GetParent().Camera.DampeningFactor = 60
end

return CameraZone