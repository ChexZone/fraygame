local scene = GameScene.new{
    FrameLimit = 60,
    Update = function (self, dt)
        GameScene.Update(self, dt)
        self.Player = self:GetDescendant("Player")
        -- self.Camera.Position = self.Camera.Position:Lerp((self.Player:GetPoint(0.5,0.5)), 1000*dt)
        -- self.Camera.Zoom = 1 --+ (math.sin(Chexcore._clock)+1)/2
    end
}
Chexcore:AddType("game.objects.wheel")
Chexcore:AddType("game.objects.cameraZone")

local bgLayer = Prop.new{Size = V{64, 36}, Color = HSV{0,0.5,0.5,01}, Texture = Texture.new("chexcore/assets/images/square.png"),Update = function(s,dt) s.Color.H = (s.Color.H + dt/5)%1 end}:Into(scene:AddLayer(Layer.new("BG", 64, 36, true):Properties{TranslationInfluence = 0}))
local mainLayer = scene:GetLayer("Gameplay")

scene:SwapChildOrder(bgLayer, mainLayer)

local tilemap = Tilemap.import("game.scenes.demo.tilemap2", "game/scenes/demo/tilemap.png", {Scale = 1 }):Nest(mainLayer):Properties{
    LockPlayerVelocity = true,
    Update = function (self,dt)
        
        -- self.Position = self.Position + V{1,0}
        -- self.LayerColors[3].H = (self.LayerColors[2].H + dt/2)%1 
        self.LayerColors[1].S = math.sin(Chexcore._clock)/2 + 0.5 
    end
}

return scene