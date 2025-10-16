-- require("chexcore.code.libs.nest").init({console = "3ds", scale=1})
-- love._console = "3ds"
require "chexcore"
-- love.mouse.setVisible(false)
-- some of the constructors are still somewhat manual but they'll get cleaned up !

-- Scenes contain all the components of the game
function love.load()
    

 

    
    print(Prop.new{Size=V{4,0}}:GetPoint(0,0))
    


    -- Load the Chexcore example Scene!
    
    Chexcore:AddType(require"game.player.player")
    Chexcore:AddType(require"game.player.ragdoll")
    Chexcore:AddType(require"game.objects.basketball")
    Chexcore:AddType(require"game.objects.npcs.candle")
    Chexcore:AddType(require"game.objects.water")
    Chexcore:AddType(require"game.objects.lightSource")
    Chexcore:AddType(require"game.objects.cube")
    Chexcore:AddType(require"game.objects.torch")
    Chexcore:AddType(require"game.player.gameScene")
    Chexcore:AddType(require"game.player.gameCamera")
    local scene = require"game.scenes.intro.init"

    -- local cube = Cube.new({":)","aA","D","D","]][[","F","G"},60):Nest(scene:GetLayer("Gameplay"))
    -- cube.Size = V{64,64}
    -- cube.GoalColor = V{1,1,1,1}
    -- cube.GoalScale = V{1,1}
    -- cube.Position = cube.Position
    -- cube.Shader = Shader.new("game/assets/shaders/4px-white-outline.glsl"):Send("step", V{1,1}/V{160,160})
    -- cube.Update = function (self,dt)
    --     self.Color = self.Color:Lerp(self.GoalColor, dt*5)
    --     self.DrawScale = self.DrawScale:Lerp(self.GoalScale, dt*5)
    --     if self.Scared then
    --         self.AnchorPoint = V{0.5 + math.random(-5,5)/100,0.5 + math.random(-5,5)/100}
    --     else
    --         self.AnchorPoint = V{0.5,0.5}
    --     end

    -- end
    
    -- cube:Adopt(LightSource.new():Properties{
    --     Name = "CubeLight",
    --     Position = cube:GetPoint(0.5,0.5),
    --     Sharpness = 1, Color = V{1,1,1,0.5}, Radius = 400,
    --     Update = function (self)
    --         self:MoveTo(cube.Position)
    --     end

    -- })
    -- function cube:OnTouchEnter(other)
    --     self.GoalColor = HSV{0.55, 0.3, .7}
    --     self.GoalScale = V{0.8,0.8}
    --     self.Scared = other
    -- end
    -- function cube:OnTouchLeave(other)
    --     self.GoalColor = V{1,1,1,1}
    --     self.GoalScale = V{1,1}
    --     self.Scared = false
    -- end
    -- cube.Solid = true
    -- cube.Passthrough = true
    -- cube.DrawInForeground = false
    -- cube.Name = "Track"
    -- _G.bigCube = cube
    -- for i = 1, 10 do
    --     local cube = Cube.new():Nest(scene:GetLayer("Gameplay"))
    --     cube.Size = V{32,32}
    --     cube.Shader = Shader.new("game/assets/shaders/4px-white-outline.glsl"):Send("step", V{1,1}/V{160,160})
    --     cube.Position = cube.Position + V{
    --         60 * math.cos(2*math.pi*i/10),
    --         60 * math.sin(2*math.pi*i/10)
    --     }
    --     cube.Color = HSV{i/10, 1, 1, 1}

    --     cube:Adopt(LightSource.new():Properties{
    --         Position = cube:GetPoint(0.5,0.5),
    --         Sharpness = 0, Color = cube.Color, Radius = 100,
    --         Update = function (self)
    --             self:MoveTo(cube.Position)
    --         end

    --     })

    -- end

    -- for i = 1, 10 do
    --     local cube = Cube.new():Nest(scene:GetLayer("Gameplay"))
    --     cube.Size = V{24,24}
    --     cube.Position = cube.Position + V{
    --         100 * math.cos(2*math.pi*i/20),
    --         100 * math.sin(2*math.pi*i/20)
    --     }
    -- end
    local player
    
    scene:GetLayer("Gameplay"):Adopt(PlayerRagdoll.new(1))

    -- Timer.Schedule(0.1, function ()
    --     Chexcore.testSound = StreamSound.new("loop_test.ogg")
    --     Chexcore.testSound:Play()
    --     -- Chexcore.testSound2:Play()
    -- end)


    --     Timer.Schedule(0.1, function ()
    --     Chexcore.testSound = StreamSound.new{
    --         start = {
    --             "p1.mp3"
    --         },
            
    --     }
    --     Chexcore.testSound:Play()
    -- end)


    player = Player.new():Nest(scene:GetLayer("Gameplay"))
    -- local player2 = Player.new():Nest(scene:GetLayer("Gameplay"))


    -- Timer.Schedule(1, function ()
    --     scene:GetLayer("Gameplay").Canvases[1]:RecordMatMap(30, "matmaptest")
    -- end)





    -- for i,v in pairs(love) do
    --     print(i)
    -- end

    -- player:Adopt(LightSource.new():Properties{
    --     Update = function (self, dt)
    --         self.Position = player:GetPoint(0.5,0.5)
    --     end,
    --     Radius = 0.4,
    --     Sharpness = .5,
    --     Color = V{1,1,0,1}
    -- })


    local testParticles = scene:GetLayer("Gameplay"):Adopt(Particles.new{
        Name = "Test",
        ParticleLifeTime = 10,
        ParticleAnchorPoint = V{0.5,0.5},
        ParticleColor = V{1,1,1,1},
        ParticleRotVelocity = 1,
        Visible = false,
        ParticleTexture = Texture.new("chexcore/assets/images/square.png"),
        -- Particle
    })

    local f f = function ()
        testParticles:Emit{CustomFunc = function (emitter, slot, dt)
            local lifetime = emitter:GetLifetime(slot)
            local radius = lifetime * 20
            local angle = lifetime * 2
            emitter:SetPosition(slot, V{math.cos(angle) * radius, math.sin(angle) * radius})
            

            -- emitter:SetColor(1, )

            local s = 10 * ((math.sin(Chexcore._clock*20)+1)/2 +1)
            emitter:SetSize(slot, V{s, s})
            -- Fade out over time
            -- emitter:SetColorA(slot, 1 - lifetime / 2)
        end}
        Timer.Schedule(0.1, f)
    end f()


    local testNormalProp = scene:GetLayer("Gameplay"):Adopt(Prop.new{
        Name = "TestNormieProp",
        Position = V{300,-120},
        Color = HSV{1,1,1},
        ZIndex = -1000
    })
    local testNormalProp2 = Prop.new{
        Name = "TestNormieProp",
        Position = V{300,-120},
        Color = HSV{0.5,1,1}
    }
    -- local testFancyProp = scene:GetLayer("Gameplay"):Adopt(RenderMask.new{
    --     Name = "TestFancyProp",
    --     Position = V{300,-120},
    --     RenderPipeline = {--testParticles,
    --         --testNormalProp2, testParticles, player, 
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{1,0,0,1}):Send("thickness", 4), player
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,1,0,1}):Send("thickness", 6),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,0,1,1}):Send("thickness", 8),
    --     --         Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{1,0,0,1}):Send("thickness", 4),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,1,0,1}):Send("thickness", 6),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,0,1,1}):Send("thickness", 8),
    --     --         Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{1,0,0,1}):Send("thickness", 4),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,1,0,1}):Send("thickness", 6),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,0,1,1}):Send("thickness", 8),
    --     --         Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{1,0,0,1}):Send("thickness", 4),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,1,0,1}):Send("thickness", 6),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,0,1,1}):Send("thickness", 8),
    --     --         Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{1,0,0,1}):Send("thickness", 4),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,1,0,1}):Send("thickness", 6),
    --     -- Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", V{0,0,1,1}):Send("thickness", 8),
    --     },

    --     Update = function (self, dt)
    --         self.Position.X = -120 + math.sin(Chexcore._clock)*100
    --     end
    -- })


    local testCandle = scene:GetLayer("Gameplay"):Adopt(Candle.new():Properties{
        Position = V{250, -20},
        Target = player
    })

    -- player.Visible = false
    scene.Camera.Focus = player
    player.Name="PLAYER1"
    local spawn = scene:GetDescendant("PlayerSpawn")
    if spawn then
        player.Position = spawn.Position
        -- player2.Position = spawn.Position + V{50,0}
    end
    -- scene.Camera.Position = player.Position
    scene.FrameLimit = 5

    -- local scene = Scene.new{}d
    



    local testWater = scene:GetLayer("Gameplay"):Adopt(Water.new())


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


    local testCheckpoint testCheckpoint = scene:GetLayer("Gameplay"):Adopt(Prop.new{
        Position = player.Position:Clone() + V{108,0},
        ZIndex = 0,
        LightSize = V{100, 50, 200}, -- X, Y, radius
        RealPos = player.Position:Clone() + V{96,8},

        ConfettiPopSound = Sound.new("game/assets/sounds/meta/checkpoint/confetti_pop.wav"):Set("Volume", 0.25),
        ConfettiCheerSound = Sound.new("game/assets/sounds/meta/checkpoint/confetti_cheer.wav"):Set("Volume", 0.1),
        IgnitionSound = Sound.new("game/assets/sounds/meta/checkpoint/ignition.wav"):Set("Volume", 0.25),

        Activated = false,

        LightProgress = -1, -- set to 0 to begin light animation
        Texture = Animation.new({"game/assets/images/meta/checkpoint.png",
            normalPath = "game/assets/images/meta/checkpoint_n.png",
            emissionPath = "game/assets/images/meta/checkpoint_l.png",
            specularPath = "game/assets/images/meta/checkpoint_s.png"
        },1,9):Properties{IsPlaying=false, Loop = true, Duration = 1}:AddCallback(3, function ()
            testCheckpoint:Activate()
        end),

        Activate = function (self)
            self:GetChild("ConfettiL"):BlastConfetti()
            self:GetChild("ConfettiI"):BlastConfetti()
            self:GetChild("ConfettiDot"):BlastConfetti()
            if not testCheckpoint.Activated then
                self.LightProgress = 0
                self.Activated = true
                self.ConfettiCheerSound:Play()
            end
            self.ConfettiPopSound:Play()
            testCheckpoint.ShaderEnabled = true
        end,

        Canvas = Canvas.new(100,100),
        HelperCanvas = Canvas.new(100,100),
        Size = V{32,80},
        AnchorPoint = V{0.5,0.85},
        Solid = true, Passthrough = true,
        RotVelocity = 0,
        Shader = Shader.new("game/assets/shaders/custom-outline.glsl"):Send("step",{1/100,1/100}):Send("outlineColor", {1,1,1,1}),
        ShaderEnabled = false,
        Draw = function (self, tx, ty)
            self.Canvas:Activate()
            love.graphics.clear()
            love.graphics.setColor(self.Color)
            


            self.Texture:DrawToScreen(
                self.Position[1] - self.Position[1] + 50,
                self.Position[2] - self.Position[2] + 70,
                self.Rotation,
                self.Size[1],
                self.Size[2],
                self.AnchorPoint[1], self.AnchorPoint[2]
            )

            self.Canvas:Deactivate()

            if self.ShaderEnabled then
                -- self.Shader:Activate()
                self.HelperCanvas:CopyFrom(self.Canvas, self.Shader)
                -- self.Shader:Deactivate()
    
                self.HelperCanvas:DrawToScreen(
                    math.floor(self.Position[1] - tx),
                    math.floor(self.Position[2] - ty) - 20,
                    0,
                    100,
                    100,
                    0.5,
                    0.5
                )
            else
                self.Canvas:DrawToScreen(
                    math.floor(self.Position[1] - tx),
                    math.floor(self.Position[2] - ty) - 20,
                    0,
                    100,
                    100,
                    0.5,
                    0.5
                )
            end

        end,

        Update = function (self,dt)
            self.Position = V{self.RealPos.X + math.sin(Chexcore._clock)*3 + self.Rotation*30, self.RealPos.Y + math.cos(Chexcore._clock+0.5)}
            self.Rotation = math.lerp(self.Rotation, 0, 0.05)
            -- self.Texture.PlaybackScaling = math.random(1,5)
            
            if self.LightProgress > -1 then
                local goalRadius = self.LightSize.Z + 5 - 10*(love.math.noise(Chexcore._clock*2))
                if self.LightProgress == 0 then
                    self:GetChild("PointLight").Visible = true
                    self:GetChild("PointLight").Radius = 0
                elseif self.LightProgress < 60 then
                    self:GetChild("PointLight").Radius = tween("outElastic", 0, goalRadius, self.LightProgress/60)
                    self:GetChild("PointLight").Size = V{tween("outElastic", 0, self.LightSize.X, self.LightProgress/60),tween("outElastic", 0, self.LightSize.Y, self.LightProgress/60)}
                else
                    self:GetChild("PointLight").Radius = goalRadius
                end
                self.LightProgress = self.LightProgress + 1
            else
                self:GetChild("PointLight").Visible = false
            end
        end,

        VirtualTouchEvent = function (self,other)
            if other.ActivateCheckpoint then other:ActivateCheckpoint(self) end

            if self.Activated and other.Health == 3 then
                return
            end
            other:Heal(3-other.Health)
            self.IgnitionSound:Play()

            if not self.Activated then
                self.Texture.IsPlaying = true
                self.Texture.Clock = 0
                self.Texture.LeftBound = 2
                self.Texture.RightBound = 5
                self.Texture.Duration = 0.55
                self.Texture.Loop = false
                
                Timer.Schedule(0.55, function ()
                    self.Texture.IsPlaying = true
                    self.Texture.Clock = 0
                    self.Texture.LeftBound = 6
                    self.Texture.RightBound = 9
                    self.Texture.Loop = true
                    self.Texture.Duration = 0.75
                end)
            else -- just confetti to heal the player
                self:Activate()
            end
            
            

        end,

        OnTouchStay = function (self, other)
            local vel = other.Velocity.X/50
            if math.abs(vel) > 0.035 then
                self.Rotation = math.lerp(self.Rotation, self.Rotation + vel, 0.1*math.abs(vel*30))
            end
        end
    }:With(Prop.new{
        Name = "CollisionBox",
        Update = function (self)
            self:MoveTo(self:GetParent().Position)
        end,

        OnTouchEnter = function (self,other)
            self:GetParent():VirtualTouchEvent(other)
        end,

        Size = V{20,60},
        AnchorPoint = V{0.5,0.825},
        Solid = true, Passthrough = true, Visible = false
    }):With(LightSource.new():Properties{
        Name = "PointLight",
        Radius = 250,
        Sharpness = 1,
        Color = V{1,1,0.5,1},
        AnchorPoint = V{0.5,0.5},
        Size = V{50,50},
        Visible = false,
        Update = function (self,dt)
            self:MoveTo(self:GetParent():GetPoint(0.5,0.325))
        end
    }):With(Particles.new{
        Name = "ConfettiL",
        Position = player.Position:Clone() + V{64,-30},
        ZIndex = -1,
        ParticleTexture = Texture.new("game/assets/images/meta/l_particle.png"),
        ParticleLifeTime = 1.325,
        IgnoreCulling = true,
        RelativePosition = false,
        ParticleSize = V{4,4},
        ParticleSizeVelocity = V{12,12},
        ParticleSizeAcceleration = V{-24,-24},
        -- ParticleAcceleration = V{-45,60},
        Size = V{0,0},
        
        ParticleColor =V{1,0,0,1},
        ParticleAnchorPoint = V{0.5,0.5},

        BlastConfetti = function (self)
            for i = 1, 3 do
                local col = i == 1 and V{1,0,0,1} or i == 2 and V{0,1,0,1} or V{0,0,1,1}
                local angle = self.Rotation - math.rad(35 + math.random(-20,20))
                self:Emit{
                    Color = col,
                    Position = self:GetParent():GetPoint(0.8,0.75),
                    Velocity = Vector.FromAngle(angle)*math.random(60,80),
                    RotVelocity = math.random(-5,5),
                    Rotation = math.random(-5,5),
                    Acceleration = V{-45,60}
                }

                angle = self.Rotation - math.rad(-180 - 35 + math.random(-20,20))
                self:Emit{
                    Color = col,
                    Position = self:GetParent():GetPoint(0.2,0.75),
                    Velocity = Vector.FromAngle(angle)*math.random(60,80),
                    RotVelocity = math.random(-5,5),
                    Rotation = math.random(-5,5),
                    Acceleration = V{45,60}
                }
            end
        end
    }):With(Particles.new{
        Name = "ConfettiI",
        Position = player.Position:Clone() - V{-64,64},
        ZIndex = -1,
        ParticleTexture = Texture.new("game/assets/images/meta/i_particle.png"),
        ParticleLifeTime = 2.5,
        IgnoreCulling = true,
        RelativePosition = false,
        ParticleSize = V{0,0},
        ParticleSizeVelocity = V{8,16}/2,
        ParticleSizeAcceleration = V{-7,-14}/2,
        -- ParticleAcceleration = V{-45,60},
        Size = V{0,0},
        ParticleColor =V{1,0,0,1},
        ParticleAnchorPoint = V{0.5,0.5},

        BlastConfetti = function (self)
            for i = 1, 5 do
                local col = (i%3) == 1 and V{1,0,0,1} or (i%3) == 2 and V{0,1,0,1} or V{0,0,1,1}
                local angle = self.Rotation - math.rad(35 + math.random(-20,20))
                local lifeMult = math.random(8,12)/10
                self:Emit{
                    SizeAcceleration = self.ParticleSizeAcceleration*lifeMult,
                    LifeTime = self.ParticleLifeTime/lifeMult,
                    SizeVelocity = self.ParticleSizeVelocity/lifeMult,
                    Color = col,
                    Position = self:GetParent():GetPoint(0.8,0.75),
                    Velocity = Vector.FromAngle(angle)*math.random(80,100),
                    RotVelocity = math.random(-5,5),
                    Rotation = math.random(-5,5),
                    Acceleration = V{-30,50}
                }

                angle = self.Rotation - math.rad(-180 - 35 + math.random(-20,20))
                self:Emit{
                    SizeAcceleration = self.ParticleSizeAcceleration*lifeMult,
                    LifeTime = self.ParticleLifeTime/lifeMult,
                    SizeVelocity = self.ParticleSizeVelocity/lifeMult,
                    Color = col,
                    Position = self:GetParent():GetPoint(0.2,0.75),
                    Velocity = Vector.FromAngle(angle)*math.random(80,100),
                    RotVelocity = math.random(-5,5),
                    Rotation = math.random(-5,5),
                    Acceleration = V{30,50}
                }
            end
        end
    }):With(Particles.new{
        Name = "ConfettiDot",
        Position = player.Position:Clone() - V{-64,64},
        ZIndex = -1,
        ParticleTexture = Texture.new("game/assets/images/meta/i_particle.png"),
        ParticleLifeTime = 4,
        IgnoreCulling = true,
        RelativePosition = false,
        ParticleSize = V{2,2},
        ParticleSizeVelocity = V{-0.4,-0.4},
        Size = V{0,0},
        ParticleColorVelocity = V{0,0,0,-00},
        ParticleAnchorPoint = V{0.5,0.5},

        BlastConfetti = function (self)
            for i = 1, 10 do
                local col = (i%3) == 1 and V{.65,0,0,1} or (i%2) == 2 and V{0,.65,0,1} or V{0,0,.65,1}
                local angle = self.Rotation - math.rad(35 + math.random(-20,20))
                local vel = Vector.FromAngle(angle)*math.random(80,100)
                self:Emit{ -- right
                    Color = col,
                    Position = self:GetParent():GetPoint(0.8,0.75),
                    Velocity = vel,
                    RotVelocity = math.random(-5,5),
                    Rotation = math.random(-5,5),
                    Acceleration = V{-35,40}
                }

                angle = self.Rotation - math.rad(-180 - 35 + math.random(-20,20))
                vel = Vector.FromAngle(angle)*math.random(80,100)
                self:Emit{ -- left
                    Color = col,
                    Position = self:GetParent():GetPoint(0.2,0.75),
                    Velocity = vel,
                    RotVelocity = math.random(-5,5),
                    Rotation = math.random(-5,5),
                    Acceleration = V{35,40}
                }
            end
        end
    }))

    testCheckpoint:Adopt(Prop.new{
        Name = "Platform",
        Position = testCheckpoint.Position,
        Size = V{32,4},
        AnchorPoint = V{0.5,0},
        Solid = true,
        Visible = false,

        PreventLedgeLunge = true,

        _surfaceInfo = {
            Bottom = {Passthrough = true},
            Right = {Passthrough = true},
            Left = {Passthrough = true}
        },


        Update = function (self, dt)
            self:MoveTo(self:GetParent():GetPoint(0.5,0.7625))
        end
    })

    testCheckpoint:Adopt(Prop.new{
        Name = "LifePreserver",
        Size = V{96,32},
        Texture = Animation.new("game/assets/images/meta/life_preserver.png", 7, 3):Properties{Duration=2, IsPlaying = false, Loop = false, LeftBound = 1, RightBound = 20},
        Position = testCheckpoint.Position + V{8+14,-3},
        GoalPos = testCheckpoint.Position + V{8+14,-3},
        AnchorPoint = V{0.5,0.5},
        Canvas = Canvas.new(96,32),
        HelperCanvas = Canvas.new(96,32),
        Shader = Shader.new("game/assets/shaders/outline.glsl"):Send("step",{1/96,1/32}),
        
        Draw = function(self, tx, ty)
            self.DrawScale = self.DrawScale:Lerp(V{1,1},0.05)
            self.Position = self.Position:Lerp(self.GoalPos,0.05)

            self.Canvas:Activate()
            love.graphics.clear()
            love.graphics.setColor(self.Color)
            
            local sx = self.Size[1] * (self.DrawScale[1]-1)
            local sy = self.Size[2] * (self.DrawScale[2]-1)
    

            self.Texture:DrawToScreen(
                self.Position[1] - self.Position[1] + 48,
                self.Position[2] - self.Position[2] + 16,
                self.Rotation,
                self.Size[1] + sx,
                self.Size[2] + sy,
                self.AnchorPoint[1], self.AnchorPoint[2]
            )

            self.Canvas:Deactivate()

            self.Shader:Activate()
            self.HelperCanvas:CopyFrom(self.Canvas)
            self.Shader:Deactivate()

            self.HelperCanvas:DrawToScreen(
                math.floor(self.Position[1] - tx),
                math.floor(self.Position[2] - ty),
                0,
                96,
                32,
                0.5,
                0.5
            )
        end
    }:With(Prop.new{
        Name = "Collider",
        Size = V{22,10},
        Visible = false,
        AnchorPoint = V{0.5,0},
        Solid = true, Passthrough = true,
        Position = testCheckpoint.Position,
        DB = 0,
        Update = function (self,dt)
            self.Position = self:GetParent().Position
            self.DB = self.DB - 1
        end,

        _surfaceInfo = {
            Top = {
                ForceJumpHeldFrames = 10,
                IsSpring = true,
                SpringPower = 5,
            }
        },

        OnTouchEnter = function (self, other)
            if self.DB <= 0 and not other.Floor then
                self:GetParent().DrawScale.Y = 0.5
                self:GetParent():MoveTo(self:GetParent().Position+V{0,6})
                self.DB = 5
                -- self:GetParent().Texture.IsPlaying = true
                -- self:GetParent().Texture.Clock = 0
            end
        end
    }))


    -- local f f = function ()
    --     testCheckpoint:GetChild("ConfettiL"):BlastConfetti()
    --     testCheckpoint:GetChild("ConfettiI"):BlastConfetti()
    --     Timer.Schedule(1, f)
    -- end
    -- f()

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



