local scene = GameScene.new{
    FrameLimit = 60,
    Update = function (self, dt)
        GameScene.Update(self, dt)
        self.Player = self:GetDescendant("Player")
        -- self.Camera.Position = self.Camera.Position:Lerp((self.Player:GetPoint(0.5,0.5)), 1000*dt)
        -- self.Camera.Zoom = 1 --+ (math.sin(Chexcore._clock)+1)/2
    end,
    Brightness = .3,
    ShadowColor = HSV{0.5,0.8,0.2,1}
}
Chexcore:AddType("game.objects.wheel")
Chexcore:AddType("game.objects.cameraZone")

local bgLayer = scene:AddLayer(Layer.new("BG", 640, 360, true):Properties{TranslationInfluence = 0})
local mainLayer = scene:GetLayer("Gameplay")

scene:SwapChildOrder(bgLayer, mainLayer)


bgLayer:Adopt(Prop.new{
    Name = "GradientTest",
    Size = V{640, 76},
    Position = V{0, 32},
    Color = Vector.Hex("ffd500")
})
bgLayer:Adopt(Prop.new{
    Name = "GradientTest",
    Size = V{640, 76},
    Position = V{0, 32},
    Color = Vector.Hex("ffad1d"),
    AnchorPoint = V{0,1}
})
bgLayer:Adopt(Prop.new{
    Name = "GradientTest",
    Size = V{640, 300},
    Position = V{0, 32+76},
    Color = Vector.Hex("ffff69"),
    AnchorPoint = V{0,0}
})

for i = 1, 12 do
    bgLayer:Adopt(Prop.new{
        Name = "GradientTest",
        Size = V{64, 32},
        Texture =  Animation.new("game/scenes/pretty/sky-gradient.png", 1, 4),
        Position = V{64*i, 32} - V{80,0},
        Color = Vector.Hex("ffad1d")
    })
    bgLayer:Adopt(Prop.new{
        Name = "GradientTest",
        Size = V{64, -32},
        Texture =  Animation.new("game/scenes/pretty/sky-gradient.png", 1, 4),
        Position = V{64*i, 108} - V{80,0},
        Color = Vector.Hex("ffff69")
    })
end

bgLayer:Adopt(Prop.new{
    Name = "Sun",
    Texture = Texture.new("game/scenes/pretty/sun.png"),
    Size = V{78,78},
    Update = function (self, dt)
        if scene.Player then
            self.Position = V{-scene.Camera.Position.X/50 + (scene.Camera.Position.X/50 % 2) + 500, 64}
        end
    end
})

bgLayer:Adopt(Prop.new{
    Name = "Dune2",
    Texture = Texture.new("game/scenes/pretty/dunes_2.png"),
    Size = V{1024,128},
    Update = function (self, dt)
        if scene.Player then
            self.Position = V{-scene.Camera.Position.X/10 + (scene.Camera.Position.X/10 % 2), 64}
        end
    end
})

bgLayer:Adopt(Prop.new{
    Name = "Dune2",
    Texture = Texture.new("game/scenes/pretty/bg_lake.png"),
    Size = V{640,240},
    Update = function (self, dt)
        if scene.Player then
            self.Position = V{0, 140}
        end
    end
})

local lake2 = bgLayer:Adopt(Prop.new{
    Name = "Lake21",
    Texture = Texture.new("game/scenes/pretty/lake2.png"),
    Size = V{640,64},
    Update = function (self, dt)
        self.Position = V{-Chexcore._clock * 20, 3  + math.sin(Chexcore._clock)*5 + scene.Camera.Position.Y / 40}
        self.Position.X = (self.Position.X+640) % 1280 - 640
    end
})

bgLayer:Adopt(Prop.new{
    Name = "Lake22",
    Texture = Texture.new("game/scenes/pretty/lake2.png"),
    Size = V{640,64},
    Update = function (self, dt)
        self.Position = V{640-Chexcore._clock * 20, 3 + math.sin(Chexcore._clock)*5 + scene.Camera.Position.Y / 40}
        self.Position.X = (self.Position.X+640) % 1280 - 640
    end
})

bgLayer:Adopt(Prop.new{
    Name = "Lake2Top",
    Size = V{640, 240},
    AnchorPoint = V{0,1},
    Color = Vector.Hex("3e73ff"),
    Update = function (self, dt)
        self.Position.Y = lake2:GetEdge("top")
    end
})

bgLayer:Adopt(Prop.new{
    Name = "Lake11",
    Texture = Texture.new("game/scenes/pretty/lake1.png"),
    Size = V{640,64},
    Update = function (self, dt)
        self.Position = V{Chexcore._clock * 40, -5 + math.sin(Chexcore._clock+0.5)*5 - scene.Camera.Position.Y / 40}
        self.Position.X = (self.Position.X+640) % 1280 - 640
    end
})
bgLayer:Adopt(Prop.new{
    Name = "Lake12",
    Texture = Texture.new("game/scenes/pretty/lake1.png"),
    Size = V{640,64},
    Update = function (self, dt)
        self.Position = V{-640 + Chexcore._clock * 40, -5 + math.sin(Chexcore._clock+0.5)*5 - scene.Camera.Position.Y / 40}
        self.Position.X = (self.Position.X+640) % 1280 - 640
    end
})



local dune1 = bgLayer:Adopt(Prop.new{
    Name = "Dune1",
    Texture = Texture.new("game/scenes/pretty/dunes_1.png"),
    Size = V{1024,128},
    Update = function (self, dt)
        if scene.Player then
            self.Position = V{-scene.Camera.Position.X/5 + (scene.Camera.Position.X/5 % 1), 128 - scene.Camera.Position.Y/10}
        end
    end
})

local bg_extend = bgLayer:Adopt(Prop.new{
    Name = "BottomLake",
    Size = V{640,50},
    Color = Vector.Hex("ff8b00"),
    Update = function (self, dt)
        if scene.Player then
            self.Size.Y = 50 + scene.Camera.Position.Y / 50
            self.Position = V{0, dune1:GetEdge("bottom")}
        end
    end
})


bgLayer:Adopt(Prop.new{
    Name = "BottomLake",
    Texture = Texture.new("game/scenes/pretty/bg_bottom.png"),
    Size = V{640,180},
    Update = function (self, dt)
        if scene.Player then
            self.Position = V{0, bg_extend:GetEdge("bottom")}
        end
    end
})

local tilemap = Tilemap.import("game.scenes.pretty.level", "game/scenes/pretty/tiles.png", {Scale = 1 }):Nest(mainLayer):Properties{
    LockPlayerVelocity = true,
    -- Update = function (self,dt)
        
    --     -- self.Position = self.Position + V{1,0}
    --     -- self.LayerColors[3].H = (self.LayerColors[2].H + dt/2)%1 
    -- end,
    -- Position = V{0,-500}
}


return scene