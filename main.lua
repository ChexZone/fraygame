-- require("chexcore.code.libs.nest").init({console = "3ds", scale=1})
-- love._console = "3ds"
require "chexcore"
-- love.mouse.setVisible(false)
-- some of the constructors are still somewhat manual but they'll get cleaned up !

-- Scenes contain all the components of the game
function love.load()
    


    -- Load the Chexcore example Scene!
    
    Chexcore:AddType(require"game.player.player")
    Chexcore:AddType(require"game.objects.basketball")
    Chexcore:AddType(require"game.player.gameScene")
    Chexcore:AddType(require"game.player.gameCamera")
    local scene = require"game.scenes.debug.init"
    
    local player = Player.new():Nest(scene:GetLayer("Gameplay"))
    -- local player2 = Player.new():Nest(scene:GetLayer("Gameplay"))

    scene.Camera.Focus = player
    
    local spawn = scene:GetDescendant("PlayerSpawn")
    if spawn then
        player.Position = spawn.Position
        -- player2.Position = spawn.Position + V{50,0}
    end
    scene.Camera.Position = player.Position
    scene.FrameLimit = 5

    -- local scene = Scene.new{}
    

-- local scene = Scene.new()
-- local layer = scene:AddLayer(Layer.new("Game", 1600, 900))
-- layer:Adopt(Prop.new{
--     Name = "Cursor",
--     Texture = Texture.new("chexcore/assets/images/white-arrow.png"),
--     AnchorPoint = V{0.5 ,0.5}, -- so its position is "the center"

--     Update = function (self, dt)
--         local turnSpeed = (Input:IsDown("r") and 1 or 0) - (Input:IsDown("l") and 1 or 0)
--         local moveSpeed = 20 * ((Input:IsDown("n") and 1 or 0) - (Input:IsDown("s") and 1 or 0))
        
--         self.Rotation = self.Rotation + (turnSpeed*dt)
--         self.Position = self.Position + (Vector.FromAngle(self.Rotation)*moveSpeed*dt)
--     end
-- })


    -- local scene = Scene.new{}:With(Layer.new{Screen = "left"}:With(Text.new{AlignMode = "center", Size = V{500,20}, Text = "TOP", AnchorPoint = V{0.5,1}, Update = function(self) 
    --     self.Rotation = math.sin(Chexcore._preciseClock)/2 
    --     -- self.Size = V{500,20} * (1+math.sin(Chexcore._preciseClock/2)/2)
    --     self.FontSize = 40 +  (1+math.cos(Chexcore._preciseClock*3)*5)
    --     self.TextColor = HSV{Chexcore._preciseClock/5%1, 1, 1}
    -- end}))

    -- scene:GetLayer(1):Adopt(Gui.new{Size = V{100, 50}, OnHoverStart = function (self)
    --     self.DrawScale = V{0.8, 0.8}
    -- end, OnHoverEnd = function (self)
    --     self.DrawScale = V{1, 1}
    -- end})

    -- scene:Adopt(Layer.new{Screen = "bottom"}:With(Text.new{AlignMode = "center", Size = V{500,20}, Text = "BOTTOM", AnchorPoint = V{0.5,1}, Update = function(self) 
    --     self.Rotation = -math.sin(Chexcore._preciseClock)/2 
    --     -- self.Size = V{500,20} * (1+math.sin(Chexcore._preciseClock/2)/2)
    --     self.FontSize = 40 +  (1+math.cos(Chexcore._preciseClock*3)*5)
    --     self.TextColor = HSV{Chexcore._preciseClock/3%1, 1, 1}
    -- end}))

    -- scene:GetLayer("Gameplay"):SwapChildOrder(player, 1)

    -- print(tostring(player, true))

    -- local scene = require"chexcore.scenes.example.doodle" -- path to the .lua file of the scene

    -- A scene will only be processed by Chexcore while it is "mounted"
    Chexcore.MountScene(scene)


    -- print(player:ToString(true))
    -- You can unmount (or deactivate) a scene by using Chexcore.UnmountScene(scene)
end
