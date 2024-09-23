local scene = GameScene.new{
    FrameLimit = 60,
    Update = function (self, dt)
        GameScene.Update(self, dt)
        self.Camera.Position = (self:GetDescendant("Player").Position - V{0, self:GetDescendant("Player").Size.Y/2})
        self.Camera.Zoom = 2 --+ (math.sin(Chexcore._clock)+1)/2
    end
}

local fxLayer = scene:AddLayer(Layer.new("starx", 1920, 1080):Properties{TranslationInfluence = 0, ZoomInfluence = 0})


fxLayer:Adopt(Prop.new{
    Name = "BG",
    Size = V{1920, 1080},
    Texture = Texture.new("chexcore/assets/images/test/space_real.jpg"),
    AnchorPoint = V{0.5, 0.5}
})

fxLayer:Adopt(Prop.new{
    Name = "Stars",
    Size = V{420*4, 420*4},
    Texture = Texture.new("chexcore/assets/images/test/stars.png"),
    AnchorPoint = V{0.5, 0.5},
    Position = V{-200,140},
    Update = function (self)
        self.Rotation = self:GetScene():GetLayer("Gameplay"):GetChild("Player").Position.X/1000
    end
})



local mainLayer = scene:AddLayer(Layer.new("Gameplay", 640, 360))



local testTilemap = Tilemap.new("chexcore/assets/images/test/test_zone.png", 32, 20, 10, {{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240}}):Nest(mainLayer):Properties{
    Visible = true,
    Scale = 1
}

print(scene._children)


return scene