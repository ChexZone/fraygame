local scene = GameScene.new{
    FrameLimit = 60,
    Update = function (self, dt)
        GameScene.Update(self, dt)
        self.Player = self:GetDescendant("Player")
        -- self.Camera.Position = self.Camera.Position:Lerp((self.Player:GetPoint(0.5,0.5)), 1000*dt)
        self.Camera.Zoom = 1 --+ (math.sin(Chexcore._clock)+1)/2
    end
}
Chexcore:AddType("game.objects.wheel")
Chexcore:AddType("game.objects.cameraZone")

local bg = Prop.new{Size = V{64, 36}, Color = V{0.5,0,1,0.2}, Texture = Texture.new("chexcore/assets/images/square.png")}:Nest(scene:AddLayer(Layer.new("BG", 64, 36, true):Properties{TranslationInfluence = 0}))
local mainLayer = scene:AddLayer(Layer.new("Gameplay", 640, 360))

local tilemap = Tilemap.import("game.scenes.demo.tilemap2", "game/scenes/demo/tilemap.png", {Scale = 1 }):Nest(mainLayer):Properties{
    Update = function (self,dt)
        -- self.Position = self.Position + V{1,0}
        self.LayerColors[2].H = (self.LayerColors[2].H + dt/2)%1 
        self.LayerColors[1].S = math.sin(Chexcore._clock)/2 + 0.5 
    end
}

return scene