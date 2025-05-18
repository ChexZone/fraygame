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
    Chexcore:AddType(require"game.objects.lightSource")
    Chexcore:AddType(require"game.objects.cube")
    Chexcore:AddType(require"game.player.gameScene")
    Chexcore:AddType(require"game.player.gameCamera")
    local scene = require"game.scenes.debug.init"

    local cube = Cube.new({":)","aA","D","D","]][[","F","G"},60):Nest(scene:GetLayer("Gameplay"))
    cube.Size = V{64,64}
    cube.GoalColor = V{1,1,1,1}
    cube.GoalScale = V{1,1}
    cube.Position = cube.Position
    cube.Shader = Shader.new("game/assets/shaders/4px-white-outline.glsl"):Send("step", V{1,1}/V{160,160})
    cube.Update = function (self,dt)
        self.Color = self.Color:Lerp(self.GoalColor, dt*5)
        self.DrawScale = self.DrawScale:Lerp(self.GoalScale, dt*5)
        if self.Scared then
            self.AnchorPoint = V{0.5 + math.random(-5,5)/100,0.5 + math.random(-5,5)/100}
        else
            self.AnchorPoint = V{0.5,0.5}
        end

    end
    
    cube:Adopt(LightSource.new():Properties{
        Name = "CubeLight",
        Position = cube:GetPoint(0.5,0.5),
        Sharpness = 1, Color = V{1,1,1,0.5}, Radius = 400,
        Update = function (self)
            self.Position = cube.Position
        end

    })
    function cube:OnTouchEnter(other)
        self.GoalColor = HSV{0.55, 0.3, .7}
        self.GoalScale = V{0.8,0.8}
        self.Scared = other
    end
    function cube:OnTouchLeave(other)
        self.GoalColor = V{1,1,1,1}
        self.GoalScale = V{1,1}
        self.Scared = false
    end
    cube.Solid = true
    cube.Passthrough = true
    cube.DrawInForeground = false
    cube.Name = "Track"
    _G.bigCube = cube
    for i = 1, 10 do
        local cube = Cube.new():Nest(scene:GetLayer("Gameplay"))
        cube.Size = V{32,32}
        cube.Shader = Shader.new("game/assets/shaders/4px-white-outline.glsl"):Send("step", V{1,1}/V{160,160})
        cube.Position = cube.Position + V{
            60 * math.cos(2*math.pi*i/10),
            60 * math.sin(2*math.pi*i/10)
        }
        cube.Color = HSV{i/10, 1, 1, 1}

        cube:Adopt(LightSource.new():Properties{
            Position = cube:GetPoint(0.5,0.5),
            Sharpness = 0, Color = cube.Color, Radius = 100,
            Update = function (self)
                self.Position = cube.Position
            end

        })

    end

    -- for i = 1, 10 do
    --     local cube = Cube.new():Nest(scene:GetLayer("Gameplay"))
    --     cube.Size = V{24,24}
    --     cube.Position = cube.Position + V{
    --         100 * math.cos(2*math.pi*i/20),
    --         100 * math.sin(2*math.pi*i/20)
    --     }
    -- end
    
    local player = Player.new():Nest(scene:GetLayer("Gameplay"))
    -- local player2 = Player.new():Nest(scene:GetLayer("Gameplay"))


    -- player:Adopt(LightSource.new():Properties{
    --     Name = "PlayerLight",
    --     -- AnchorPoint = V{0,0},
    --     Update = function (self, dt)
    --         self.Position = player:GetPoint(0.5,0.5)
    --         self.Radius = (math.sin(Chexcore._clock*2)+1)/2 * 128
    --         self.Sharpness = .5 --(math.cos(Chexcore._clock+math.pi/2)+1)/2
    --         self.Color = V{100,0,0,1}
    --         self.Size = V{
    --             512-(math.sin(Chexcore._clock*2)+1)/2*128,
    --             128-(math.sin(Chexcore._clock*2)+1)/2*128
    --         }
    --     end,
    --     Radius = 1.0,
    --     Sharpness = .5,
    --     Size = V{100,1}
    --     -- Color = V{0,0,0,1}
    -- })

    
    player:Adopt(LightSource.new():Properties{
        Name = "PlayerLight",
        -- AnchorPoint = V{0,0},

        Radius = 100,
        Sharpness = 1,
        Color = V{1,1,1,1},
        Update = function (self, dt)
            self.Position = player:GetPoint(0.5,0.5)
            -- collectgarbage("stop")
            collectgarbage("setpause", 150)
            collectgarbage("setstepmul", 100)
            print(collectgarbage("count"))
        end
        -- Color = V{0,0,0,1}
    })


    -- player:Adopt(LightSource.new():Properties{
    --     Update = function (self, dt)
    --         self.Position = player:GetPoint(0.5,0.5)
    --     end,
    --     Radius = 0.4,
    --     Sharpness = .5,
    --     Color = V{1,1,0,1}
    -- })

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

    -- scene:GetLayer("Gameplay"):Adopt(Prop.new{
    --     Name = "Parent",
    --     Update = function (self)
    --         self.Iterator = self.Iterator or scene:EachDescendant()
    --         for i = 1, 2 do
    --             local c = self.Iterator()
    --             if not c then
    --                 self.Iterator = scene:EachDescendant()
    --                 c = self.Iterator()
    --             end
    --             print(c)
    --         end
    --         print("------------------------------------")
    --     end
    -- }:With(Prop.new{Name="Child1"})
    -- :With(Prop.new{Name="Child2"})
    -- :With(Prop.new{Name="Child3"})
    -- )

    -- Timer.Schedule(.5, function ()
    --     print("-----------------------------------------------\n\n\n\n\n\n\n")


    --     -- local gc = Object.new{Name="Grandchild2-1"}
    --     -- local object = Object.new{Name="Parent"}
    --     --                 :With(Object.new{Name="Child1"}
    --     --                     :With(Object.new{Name="Grandchild1"})
    --     --                     :With(Object.new{Name="Grandchild2"}))

    --     local object = Object.new{Name="Parent"}
    --         :With(Object.new{Name="Child1"})
    --         :With(Object.new{Name="Child2"})
    --         :With(Object.new{Name="Child3"})

    --     -- for c in object:EachDescendant() do
    --     --     print(c.Name)
    --     -- end

    --     local descendantFunc = object:EachDescendant()

    --     print(descendantFunc())
    --     -- object:GetChild("Child1"):Emancipate()
    --     object:SwapChildOrder(1,3)
    --     print(descendantFunc())
    --     object:SwapChildOrder(2,1)

    --     print(descendantFunc())

    --     print(descendantFunc())


    -- end)

    -- print(player:ToString(true))
    -- You can unmount (or deactivate) a scene by using Chexcore.UnmountScene(scene)
end