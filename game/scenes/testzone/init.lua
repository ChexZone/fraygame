local scene = GameScene.new{
    FrameLimit = 60,
    Update = function (self, dt)
        GameScene.Update(self, dt)
        self.Player = self:GetDescendant("Player")
        self.Camera.Position = self.Camera.Position:Lerp((self.Player:GetPoint(0.5,0.5)), 1000*dt)
        self.Camera.Zoom = 2 --+ (math.sin(Chexcore._clock)+1)/2
    end
}

-- Scenes have a list of Layers, which each hold their own Props
local bgTex = Texture.new("game/scenes/testzone2/skybox.png")
local wind1 = Texture.new("game/scenes/testzone2/wind1.png")
local wind2 = Texture.new("game/scenes/testzone2/wind2.png")
scene:AddLayer(Layer.new("Background", 320, 180)):AddProperties{ ZoomInfluence = 0, TranslationInfluence = 10,
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
scene:AddLayer(Layer.new("Buildings", 960/2, 540/2)):AddProperties{ ZoomInfluence = 0, TranslationInfluence = V{1,1},



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

local mainLayer = scene:GetLayer("Gameplay")



scene:AddLayer(Layer.new("GUI", 1920, 1080))

print(scene:GetChild("Buildings").TranslationInfluence)

mainLayer:GetParent():SwapChildOrder(mainLayer, mainLayer:GetParent():GetChild("Buildings"))

local crate2
-- test collidable
Chexcore:AddType("game.objects.wheel")

-- local wheel = Chexcore._types.Wheel.new():Nest(scene:GetLayer("Gameplay"))


mainLayer:Adopt(Prop.new{
    Name = "Semi5",
    Solid = true, Visible = true,
    Position = V{ 0, 0 },   -- V stands for Vector
    Size = V{ 20, 8 } * 2,
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
    Update = function (self, dt)
        self.Position = V{50 + math.sin(Chexcore._clock*2)*100, -80}
    end
})

mainLayer:Adopt(Prop.new{
    Name = "Semi6",
    Solid = true, Visible = true,
    Position = V{ 0, 0 },   -- V stands for Vector
    Size = V{ 20, 8 } * 2,
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
    Update = function (self, dt)
        self.Position = V{300, -50 - math.sin(Chexcore._clock*1-0.25)*100}
    end
})


local flying_platform = Prop.new{
    Name = "Semi6",
    Solid = true, Visible = true,
    Position = V{-25 , -50},
    OriginPos = V{-25, -50},
    Size = V{128, 32},
    Color = V{1,1,1},
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("chexcore/assets/images/test/flying_platform.png"),
    Update = function (self, dt)
        local goal = self:GetScene().Player.Floor == self and self.OriginPos + V{0, 10} or self.OriginPos
        self.Position = self.Position:Lerp(goal, dt * 10, 1)
        -- self.Rotation = self.Rotation + 0.025
        self.OriginPos = V{-25, 100} + V{math.cos(1+Chexcore._clock*2.5)*10, math.sin(Chexcore._clock)*100}
    end
}
flying_platform:Adopt(Prop.new{
    Name = "Fire",
    Solid = false, Visible = true,
    Position = V{-25,-50},
    Color = V{1,1,1,0.9},
    AnchorPoint = V{1, 0},
    GoalPoint = V{0.08, 0.75},
    Texture = Animation.new("chexcore/assets/images/test/fire_45.png", 1, 3):Properties{
        Duration = 0.5,
    },
    Update = function (self, dt)
        self.Position = self.Position:Lerp(self:GetParent():GetPoint(self.GoalPoint()), 25*dt, 1)

        self.DrawScale = self.DrawScale:Lerp(V{1,1}, 10*dt)


    end
})
flying_platform:GetChild("Fire"):Clone(true):Properties{
    GoalPoint = V{0.93, 0.75},
    Texture =Animation.new("chexcore/assets/images/test/fire_45.png", 1, 3):Properties{Duration = 0.5},
    AnchorPoint = V{1, 0},
    Size = V{-16, 16}
}

mainLayer:Adopt(flying_platform)

local tilemap = mainLayer:Adopt(Tilemap.new("chexcore/assets/images/test/tilemap.png", 32, 8, 8, {{
    11, 0, 0, 0, 0, 0, 0, 10,
    6, 11, 0, 0, 0, 0, 10, 7,
    4, 6, 1, 1, 1, 1, 7, 4,
    13, 13, 13, 13, 13, 13, 13, 13,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1,
}})):AddProperties{
    Position = V{64,0},
    AnchorPoint = V{0,0},
    Scale = 1,
    Active = true,
    Update = function (self, dt)
        -- self.Position.Y = self.Position.Y - 1
    end
}

local particles = mainLayer:Adopt(Particles.new{
    ParticleVelocity = V{1, 1},
    -- ParticleRotation = 1,
    AnchorPoint = V{0.5,0.5},
    ParticleAnchorPoint = V{0.5, 0.5},
    RelativePosition = true,
    -- ParticleAcceleration = V{0,20},
    LoopAnim = true,
    Visible = false,
    ParticleSizeVelocity = V{50,50},
    -- ParticleSizeAcceleration = V{-50, -50},
    ParticleRotVelocity = -2,
    -- ParticleRotAcceleration = 1,
    -- ParticleColorVelocity = V{1,1,1,-1},
    ParticleColor = V{1,1,1,1},
    Update = function (self,dt)
        self.Position = self:GetLayer():GetChild("Player") and self:GetLayer():GetChild("Player"):GetPoint(0.5,0.5)
        if math.random(1,20) == 1 then
            for i = 1,1 do
                self:Emit{SizeAcceleration = V{-50, -50}, Size = V{16, 16}, Position = V{0,0}}
            end
        end
        
    end
})

particles:Emit() particles:Emit()

particles:Destroy(2) particles:Destroy(1)

-- for i = 1, 5 do
--     particles:Emit{Position = V{10, 10}, Velocity = V{math.random(-50,50),math.random(-10,10), }, LifeTime = math.random(1,5)}
-- end
--particles:Emit() particles:Emit() 

-- particles:Emit{Position = V{10,10}, LifeTime = 5, Velocity = V{25,0}}
-- particles:Emit{Position = V{10,10}, LifeTime = 5, Velocity = V{-25,0}}
-- particles:Emit{Position = V{10,10}, LifeTime = 5, Velocity = V{0,25}}


print(particles._filledSlots, particles._vacantSlots)

tilemap:Clone(true):AddProperties{Position = V{199,0}}

local tilemap2 = mainLayer:Adopt(Tilemap.new("chexcore/assets/images/test/tilemap.png", 32, 50, 1, {{
    1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1

-- local tilemap2 = mainLayer:Adopt(Tilemap.new("chexcore/assets/images/test/tilemap.png", 32, 50, 1, {{
--     1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1


}})):AddProperties{
    Position = V{500,0},
    AnchorPoint = V{0,0},
    LockPlayerVelocity = true,
    Scale = 1,
    Active = true,
    Update = function (self, dt)
        self.Position.X = 500 + math.cos(Chexcore._preciseClock) * 50
        self.Position.Y = 0 + math.sin(Chexcore._preciseClock) * 25
    end
}

-- local tilemap3 = mainLayer:Adopt(Tilemap.new("chexcore/assets/images/test/tilemap.png", 32, 50, 1, {{
--     1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1

local tilemap3 = mainLayer:Adopt(Tilemap.new("chexcore/assets/images/test/tilemap.png", 32, 50, 1, {{
    1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1




}})):AddProperties{
    Position = V{1500,0},
    AnchorPoint = V{0,0},
    Scale = 1,
    Active = true,
    Update = function (self, dt)
        -- self.Position.Y = self.Position.Y - 1
    end
}

local tm4 = mainLayer:Adopt(Tilemap.new("chexcore/assets/images/test/player/another_tilemap.png", 16, 40, 40, {{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36,
1, 2, 2, 2, 2, 2, 2, 52, 54, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 22, 0, 36,
17, 81, 34, 34, 34, 34, 34, 102, 66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36,
33, 68, 0, 0, 0, 0, 0, 0, 0, 0, 49, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 66,
0, 36, 0, 20, 38, 38, 38, 38, 38, 38, 66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28,
20, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 11, 11, 12, 0, 0, 0, 0, 0, 0, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 28,
0, 53, 38, 38, 38, 38, 38, 38, 22, 0, 0, 0, 0, 0, 0, 0, 26, 27, 27, 28, 0, 0, 7, 9, 0, 0, 23, 24, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 28,
0, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 27, 27, 28, 0, 0, 23, 25, 0, 0, 39, 40, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 28,
20, 69, 38, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 27, 27, 28, 0, 0, 55, 57, 0, 0, 39, 40, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28,
0, 0, 0, 0, 0, 0, 0, 7, 8, 8, 8, 73, 2, 2, 2, 2, 2, 2, 3, 28, 0, 0, 0, 0, 0, 0, 55, 56, 57, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 28,
0, 0, 0, 0, 0, 5, 0, 23, 24, 24, 24, 89, 4, 18, 4, 18, 4, 18, 19, 28, 6, 0, 6, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 28,
0, 0, 0, 0, 0, 36, 0, 39, 40, 40, 40, 105, 4, 4, 4, 4, 4, 4, 19, 44, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 44,
0, 0, 5, 0, 0, 36, 0, 39, 40, 40, 40, 105, 4, 18, 4, 18, 4, 18, 19, 0, 6, 0, 6, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 36, 0, 0, 37, 0, 55, 56, 40, 40, 105, 4, 4, 4, 4, 4, 4, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 12,
0, 0, 36, 0, 0, 0, 0, 0, 0, 55, 40, 105, 4, 18, 4, 18, 4, 18, 19, 0, 6, 0, 6, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 28,
0, 0, 36, 0, 0, 0, 0, 0, 0, 0, 55, 121, 34, 34, 34, 34, 34, 82, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 28,
0, 0, 65, 38, 38, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 101, 102, 38, 38, 38, 38, 38, 38, 38, 38, 22, 0, 0, 20, 54, 38, 50, 0, 0, 0, 0, 0, 28,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1, 2, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 36, 0, 36, 0, 0, 0, 0, 10, 28,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 0, 0, 0, 0, 33, 34, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 65, 38, 66, 0, 0, 0, 0, 26, 28,
0, 0, 0, 0, 0, 1, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 28,
0, 0, 0, 0, 20, 71, 19, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28,
0, 0, 0, 0, 0, 17, 19, 23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 28,
0, 0, 0, 0, 0, 17, 19, 39, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 41, 0, 10, 11, 11, 11, 11, 11, 12, 0, 0, 0, 26, 28,
0, 0, 0, 0, 0, 17, 19, 55, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 57, 0, 26, 27, 27, 27, 27, 27, 28, 0, 0, 0, 26, 28,
0, 0, 0, 0, 20, 67, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 27, 27, 27, 27, 27, 27, 11, 11, 11, 27, 28,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 27, 28,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 28,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 26, 28,
10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 27, 28,
42, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 43, 44,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}})):Properties{
    Position = V{-750, -100},
    Scale = 1,
    LockPlayerVelocity = true,
    GoalColor = V{1,0,0},
    Update = function (self, dt)
        self.Position = V{-750, -100} + V{math.sin(Chexcore._clock/2)*200, math.cos(Chexcore._clock/2)*200}


    end
}

-- local tm5 = mainLayer:Adopt(Tilemap.import("game.scenes.testzone.tilemap", "chexcore/assets/images/test/player/another_tilemap.png", {
--     Position = V{0, -1200},
--     Scale = 1,
--     GoalColor = V{1,0,0},
--     AnchorPoint = V{0, 0},
--     LockPlayerVelocity = true,
--     Update = function (self, dt)
--         local cols = {
--             V{1,1,1,1},
--             V{0,1,1,1},
--             V{1,1,0,1},
--             V{1,0,0,1},
--             V{0,1,0,0.5},
--             V{1,0,1,0.5},
--             V{0,0,1,0.8},
--             V{0,0,0,1},
--             V{0.5,1,1,1},
--             V{1,1,1,0.2}
--         }

--         if math.random(1,math.floor(10000*dt)) < 10 then
--             self.GoalColor = cols[math.random(#cols)]
--         end


--         -- self.Color = self.Color:Lerp(self.GoalColor, 2*dt)
--         self.Position = V{math.sin(Chexcore._clock)*50, -1200}
--     end}))

-- print(tm5:GetChildren())

return scene