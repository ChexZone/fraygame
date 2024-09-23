local scene = GameScene.new{
    FrameLimit = 60,

    Update = function (self, dt)
        Scene.Update(self, dt)
        self.Camera.Position = (self:GetDescendant("Player").Position - V{0, self:GetDescendant("Player").Size.Y/2})
        self.Camera.Zoom = 2 --+ (math.sin(Chexcore._clock)+1)/2
    end,

    DrawSize = V{320, 180}*2
}

-- Scenes have a list of Layers, which each hold their own Props
local bgTex = Texture.new("game/scenes/testzone2/skybox.png")
local wind1 = Texture.new("game/scenes/testzone2/wind1.png")
local wind2 = Texture.new("game/scenes/testzone2/wind2.png")
scene:AddLayer(Layer.new("Background", 320, 180)):AddProperties{ ZoomInfluence = 0, TranslationInfluence = 0.5,
Draw = function (self)
    self.Canvases[1]:Activate()
    love.graphics.setColor(1,1,1)
    bgTex:DrawToScreen(160,50 - scene.Camera.Position.Y/60,0,320,320,0.5,0.5)
    wind1:DrawToScreen(160 + (Chexcore._clock*5)%320,50 - scene.Camera.Position.Y/60,0,320,320,0.5,0.5)
    wind1:DrawToScreen(160 - 320 + (Chexcore._clock*5)%320,50 - scene.Camera.Position.Y/60,0,320,320,0.5,0.5)

    wind2:DrawToScreen(160 - (Chexcore._clock*6)%320,50 - scene.Camera.Position.Y/60,0,320,320,0.5,0.5)
    wind2:DrawToScreen(160 + 320 - (Chexcore._clock*6)%320,50 - scene.Camera.Position.Y/60,0,320,320,0.5,0.5)
    self.Canvases[1]:Deactivate()
end}

local buildingsTex = Texture.new("game/scenes/testzone2/CityBG.png")
scene:AddLayer(Layer.new("Buildings", 320, 180)):AddProperties{ ZoomInfluence = 0, TranslationInfluence = 0.5,
Draw = function (self)
    -- if true then return end
    self.Canvases[1]:Activate()
    love.graphics.clear()
    love.graphics.setColor(1,1,1)
    buildingsTex:DrawToScreen(160 - math.floor(scene.Camera.Position.X/15),130 - scene.Camera.Position.Y/15,0,320,320,0.5,0.5)
    buildingsTex:DrawToScreen(160 + 320 - math.floor(scene.Camera.Position.X/15),130 - scene.Camera.Position.Y/15,0,320,320,0.5,0.5)
    buildingsTex:DrawToScreen(160 - 320 - math.floor(scene.Camera.Position.X/15),130 - scene.Camera.Position.Y/15,0,320,320,0.5,0.5)
    self.Canvases[1]:Deactivate()
end}

local mainLayer = scene:AddLayer(Layer.new("Gameplay", 640, 360))

mainLayer:Adopt(Prop.new{
    Name = "Semi6",
    Solid = true, Visible = true,
    Position = V{ 0, 0 },   -- V stands for Vector
    Size = V{ 20, 8 } * 2,
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
    Update = function (self, dt)
        self.Position = V{300, -120 - math.sin(Chexcore._clock*1-0.25)*100}
    end
})

local tilemap = mainLayer:Adopt(Tilemap.new("game/scenes/testzone2/tiles.png", 32, 24, 2, {{
    12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 11, 11, 11, 11, 0 , 0 , 0 , 11,
    22, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 24
}})):AddProperties{
    Position = V{64,0},
    AnchorPoint = V{0,0},
    Scale = 1,
    Update = function (self, dt)
        -- self.Position.Y = self.Position.Y - 1
    end
}

return scene