local scene = GameScene.new{
    FrameLimit = 60,
    DeathHeight = 3000,
    Update = function (self, dt)
        GameScene.Update(self, dt)
        -- self.Player = self:GetDescendant("Player")
        -- self.Camera.Position = self.Camera.Position:Lerp((self.Player:GetPoint(0.5,0.5)), 1000*dt)
        -- self.Camera.Zoom = 1 --+ (math.sin(Chexcore._clock)+1)/2
    end,
    Brightness = .25
}
Chexcore:AddType("game.objects.wheel")
Chexcore:AddType("game.objects.cameraZone")
Chexcore:AddType("game.objects.basketball")
Chexcore:AddType("game.objects.door")

local bgLayer = Prop.new{Size = V{640, 360},
    Update = function (self)
        self.Color = HSV{(scene.Camera.Position.Y/2000)%1,1,0.2}
    end
, Texture = Texture.new("chexcore/assets/images/square.png")}:Into(scene:AddLayer(Layer.new("BG", 640, 360, true):Properties{TranslationInfluence = 0}))
local mainLayer = scene:GetLayer("Gameplay")

for i = 1, 100 do
    mainLayer:Adopt(Prop.new{
        Texture = Texture.new{
            "chexcore/assets/images/test/star.png"
            , normalPath = "chexcore/assets/images/test/star_n.png"
            , specularPath = "chexcore/assets/images/test/star_s.png"
            -- , emissionPath = "chexcore/assets/images/test/star_light.png"
            -- , occlusionPath = "chexcore/assets/images/test/star_shadow.png"

        },    
        RotRate = math.random(-10,10)/100,
        AnchorPoint = V{0.5,0.5},
        Color = V{math.random(0,1),math.random(0,1),math.random(0,1),1},
        -- DrawOverShaders = true,
        Position = V{math.random(-250,250),math.random(-250,250)},
        Solid = math.random(2)==1 and true or false,

        Update = function (self, dt)
            -- self.Color.A = (math.sin(Chexcore._clock)+1)/2
            self.Rotation = self.Rotation - self.RotRate
        end
    })
end


local testOctagon = mainLayer:Adopt(Prop.new{
        Texture = Texture.new{
            "game/assets/images/meta/test_objects/octagon.png"
            , normalPath = "game/assets/images/meta/test_objects/octagon_n.png"
            , specularPath = "game/assets/images/meta/test_objects/octagon_s.png"
            -- , emissionPath = "chexcore/assets/images/test/star_light.png"
            -- , occlusionPath = "chexcore/assets/images/test/star_shadow.png"

        },  
        
        Size = V{64,64},
        AnchorPoint = V{0.5,0.5},
        Color = V{1,0,0},
        -- DrawOverShaders = true,
        Position = V{-100,-100},
        Solid = math.random(2)==1 and true or false,

        Update = function (self, dt)
            -- self.Color.A = (math.sin(Chexcore._clock)+1)/2
            self.Rotation = self.Rotation - 0.05
        end
    })

-- mainLayer:Adopt(Prop.new{
--     Texture = Texture.new(
--         "chexcore/assets/images/test/star_s.png"
--     ),
--     Position = V{0,-16},
--     -- DrawOverShaders = true,
-- })

scene:SwapChildOrder(bgLayer, mainLayer)

local tilemap = Tilemap.importFull("game.scenes.intro.laketown_tiles", "game.scenes.intro.laketown-tileset", {"game/assets/images/area/laketown/tileset.png", 
occlusionPath="game/assets/images/area/laketown/tileset_shadow.png",
emissionPath="game/assets/images/area/laketown/tileset_e.png",
-- normalPath="game/assets/images/area/laketown/tileset_n.png",
}, 
{Scale = 1 }):Nest(mainLayer):Properties{
    LockPlayerVelocity = false,
    -- TileSurfaceMapping = {
    --     [233] = "HalfTileLeft", [234] = "HalfTileRight",
    --     [265] = "HalfTileLeft", [266] = "HalfTileRight",
    --     [297] = "HalfTileLeft", [298] = "HalfTileRight",
    --     [329] = "HalfTileLeft", [330] = "HalfTileRight",

    --     [9] = "HalfTileLeft", [41] = "HalfTileLeft", [73] = "HalfTileLeft", [105] = "HalfTileLeft",

    --     [5] = "HalfTileTop",
    --     [225] = "HalfTileTop",
    --     [226] = "HalfTileTop",
    --     [227] = "HalfTileTop",
    --     [228] = "HalfTileTop",
    --     [231] = "HalfTileTop",
    --     [232] = "HalfTileTop",

    --     [393] = "HalfTileLeft",
    -- },
    Update = function (self,dt)
        
        -- self.Position = V{100*math.sin(Chexcore._clock), 0}
        -- self.LayerColors[3].H = (self.LayerColors[2].H + dt/2)%1 
        -- self.LayerColors[1].S = math.sin(Chexcore._clock)/2 + 0.5 
    end,


}

local layer = scene:AddLayer(Layer.new("Test", 640, 360)):Properties{
    TranslationInfluence = V{0,0}
}




layer:Adopt(Prop.new{
    -- Texture = Texture.new("game/scenes/debug/angular white bg.png"),
    Size = V{640,200},
    Color = V{1,1,1},
    AnchorPoint = V{0.5,0},
    Update = function (self, dt)
        self.Position.Y = -scene.Camera.Position.Y/7 + 270
        -- self.Rotation = math.sin(Chexcore._clock/4)/20
    end
})




scene:SwapChildOrder(#scene:GetChildren()-1,#scene:GetChildren())

local d1 = mainLayer:Adopt(Door.new():Properties{Position = V{348,2560}, Name="Door1"})
-- local d2 = mainLayer:Adopt(Door.new():Properties{Position = V{1852,2384}, Name="Door2"})
local d2 = mainLayer:Adopt(Door.new():Properties{Position = V{1451,1968}, Name="Door2"})

d1.Goal = d2; d2.Goal = d1

-- mainLayer:Adopt()

-- DISABLE PRINTING FOR NOW
-- local print = function() end

-- temp: holdable item

-- for i = 1,1 do
-- local holdable = scene:GetLayer("Gameplay"):Adopt(Basketball.new())
--     holdable.Collider = tilemap
-- end

return scene