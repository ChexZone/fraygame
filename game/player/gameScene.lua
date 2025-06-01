local GameScene = {
    -- properties
    Name = "GameScene",

    GameplaySize = V{960, 540},

    Player = nil,   -- will search for this at runtime
    
    FrameLimit = 60,  -- maximum FPS
    PerformanceMode = false,    -- Performance (30fps) mode toggle
    _normalFPS = 60,            -- normal mode target FPS
    _performanceFPS = 30,       -- performance mode target FPS

    DeathHeight = 2000, -- if the player's height is greater than this, respawn it
    InRespawn = false,  -- whether the player is in a respawn sequence or not

    LightingQueue = {
        focalPoints = {},
        radii = {},
        sharpnesses = {},
        lightColors = {}
    }, -- over the course of the frame, LightSource objects will feed into this
    Brightness = 1, -- brightness of the overall scene (0=pitch black)
    ShadowColor = HSV{0,0,0},

    ShowStats = false,  -- show stats of the player

    OverlayLayer = nil,     -- set in constructor


    -- internal properties
    _super = "Scene",      -- Supertype
    _global = true
}

function GameScene.new(properties)
    local newGameScene = GameScene:SuperInstance()
    if properties then
        for prop, val in pairs(properties) do
            newGameScene[prop] = val
        end
    end

    newGameScene.LightingQueue = {
        focalPoints = {},
        radii = {},
        sharpnesses = {},
        lightColors = {}
    }

    local mainLayer = newGameScene:AddLayer(Layer.new("Gameplay", GameScene.GameplaySize.X, GameScene.GameplaySize.Y))
    -- mainLayer.Canvases[2] = Canvas.new(GameScene.GameplaySize()):Properties{Name="FINAL"}
    mainLayer.RenderCulling = true
    mainLayer.HelperCanvas = mainLayer.Canvases[2]
    -- mainLayer.FinalCanvas.Shader = Shader.new("game/assets/shaders/water.glsl")
    -- mainLayer.FinalCanvas.Shader:Send("screenSize", {960,540})
    -- mainLayer.FinalCanvas.Shader:Send("sourceCanvas", mainLayer.Canvases[1]._drawable)

    mainLayer.ShaderCache = {
        -- water = "game/assets/shaders/water.glsl",
        water = Shader.new("game/assets/shaders/water.glsl"),
        lighting = Shader.new("game/assets/shaders/scene-focus.glsl"):Send("blendRange", 5):Send("aspectRatio", {16,9})
    }



    -- mainLayer.ShaderQueue = {}

    mainLayer.OverlayShaders = {"water", "lighting"}





    -- mainLayer.GetShaderData = function(self, shaderName, valueName)
    --     -- nothing queued? bail out
    --     local queueForShader = self.ShaderQueue[shaderName]
    --     if not queueForShader or not queueForShader[valueName] then
    --         return nil
    --     end
    
    --     -- grab the cached data
    --     local cacheForShader = self.ShaderCache[shaderName]
    --     if not cacheForShader then
    --         return nil
    --     end
    
    --     local data = cacheForShader[valueName]
    --     if not data then
    --         return nil
    --     end
    
    --     -- safe to unpack now
    --     return table.unpack(data)
    -- end
    -- set up Gameplay layer draw cycle
    mainLayer.Draw = function (self, tx, ty)
        self.ShaderQueue = {}

        self.ShaderCache.lighting:Send("baseShadowColor", newGameScene.ShadowColor)
        self.ShaderCache.lighting:Send("darkenFactor", newGameScene.Brightness)
        self.ShaderCache.lighting:Send("lightCount", 0)
        self.ShaderCache.water:Send("waterCount", 0)
        self.ShaderCache.water:Send("waveOffset", V{tx, ty}/65)

        Layer.Draw(self, tx, ty)


        



        -- mainLayer.FinalCanvas.Shader:Send("frontWaveSpeed", -1.5)  -- move rightward normally
        -- mainLayer.FinalCanvas.Shader:Send("backWaveSpeed", -1.4)  -- move leftward normally
        -- mainLayer.FinalCanvas.Shader:Send("aspectRatio", {16,9})
        -- mainLayer.FinalCanvas.Shader:Send("waterSides", {1,1,0,1},{1,1,1,1})
        -- mainLayer.FinalCanvas.Shader:Send("waterRects", {0.595,0.3, 0.8,.55}, {0.3, 0.2, 0.6, 0.7})
        -- -- mainLayer.FinalCanvas.Shader:Send("renderSides", {1,1,1,1},{1,1,1,1})
        -- mainLayer.FinalCanvas.Shader:Send("waterCount",2)
        -- -- mainLayer.FinalCanvas.Shader:Send("waveInset",0.200)
        -- mainLayer.FinalCanvas.Shader:Send("clock",Chexcore._clock)
        -- self.FinalCanvas:CopyFrom(self.Canvases[1], mainLayer.FinalCanvas.Shader)
        
        
        
        -- mainLayer.BaseCanvas, mainLayer.Canvases[1] = mainLayer.Canvases[1], mainLayer.BaseCanvas
        
    end





    -- Euclidean algorithm to find GCD
local function gcd(a, b)
    while b ~= 0 do
        a, b = b, a % b
    end
    return a
end


    -- mainLayer.Shader = Shader.new("game/assets/shaders/scene-focus.glsl")
    --     :Send("lightRects", unpack{{0.5,0.5, 0.85,.7}})
    --     :Send("radii", unpack{1,1})
    --     :Send("darkenFactor", 1)
    --     :Send("sharpnesses", unpack{0.4,1})
    --     :Send("aspectRatio", {16,9})
    --     :Send("blendRange", 5.0)
    --     :Send("baseShadowColor", newGameScene.ShadowColor or GameScene.ShadowColor)
    --     :Send("lightCount", 2)

    newGameScene.Camera = GameCamera.new():Set("Scene", newGameScene)

    newGameScene.OverlayLayer = newGameScene:Adopt(Layer.new("Overlay", 1280, 720, true))
    newGameScene.GuiLayer = newGameScene:Adopt(Layer.new("GUI", 640, 360, true))


    newGameScene.HealthBar = newGameScene.GuiLayer:Adopt(Prop.new{
        Name = "HealthBar",
        Health = 3,
        AnimationState = 0,     -- updates over time for Timer.Schedule overrides
        Size = V{100, 80},
        FramesAlive = 0,
        Texture = Texture.new("game/assets/images/gui/hud/healthbar_base.png"),
        ShakeIntensity = 0,
        OverhangPosition = V{0,0},
        GoalOverhangPosition = V{0,0},

        Update = function (self, dt)
            
            if self.ShakeIntensity == 0 or self.FramesAlive%2==0 then
                self.Position = V{-14 + math.random(-3,3) * self.ShakeIntensity*2, 0} + self.OverhangPosition
                self:GetChild("FacePlate").Position = self.Position + V{60,47}
                self:GetChild("Tube").Position = self.Position
            end

            self.OverhangPosition = self.OverhangPosition:Lerp(self.GoalOverhangPosition, 1/20)
            self.ShakeIntensity = math.lerp(self.ShakeIntensity, 0, 1/20, 0.1)

            self.FramesAlive = self.FramesAlive + 1
        end,
        
        Damage = function (self, amt)

            self.Health = self.Health - amt
            self.GoalOverhangPosition = V{24,0}
            if amt >= 0 then
                self.OverhangPosition = self.GoalOverhangPosition
                self.ShakeIntensity = 1
                self:GetChild("FacePlate").Size = V{40,60}
                self:GetChild("FacePlate").Rotation = math.random(1,2)==1 and -0.2 or 0.2
                if self.Health == 2 then
                    self:GetChild("FacePlate").Color = V{1,1,0}
                    self:GetChild("FacePlate").AnimationQueue = {{2, {48,  5, 40,  10, 41,  10, 42,  10, 43,  10, 42,  10, 43,  30, 48,  5, 25,  5, 26,  5, 27, 40, 27}, self:GetChild("FacePlate").NewExpression}}
                elseif self.Health == 1 then
                    self:GetChild("FacePlate").Color = V{1,0,0}
                    self:GetChild("FacePlate").AnimationQueue = {{2, {48+24,  5, 40+24,  10, 41+24,  10, 42+24,  10, 43+24,  10, 42+24,  10, 43+24,  30, 48+24,  5, 25+24,  5, 26+24,  5, 27+24, 5, 27+24}, self:GetChild("FacePlate").NewExpression}}
                elseif self.Health == 0 then
                    self:GetChild("FacePlate").AnimationQueue = { {2, {20}} }
                end
            else -- negative damage (healing)
                self:GetChild("FacePlate").Size = V{56,56}
                self:GetChild("FacePlate").Color = V{0,1,0}
                if self.Health == 3 then
                    self:GetChild("FacePlate").AnimationQueue = { {2, {24, 5, 21, 4, 22, 5, 23, 20, 21, 5, 24, 5, 24}, self:GetChild("FacePlate").NewExpression} }
                elseif self.Health == 2 then
                    self:GetChild("FacePlate").AnimationQueue = { {2, {24+24, 5, 21+24, 4, 22+24, 5, 23+24, 20, 21+24, 5, 24+24, 5, 24+24}, self:GetChild("FacePlate").NewExpression} }
                end
            end
            self:GetChild("FacePlate").BlinkTimer = 2

            local newAnimState = self.AnimationState + 1
            self.AnimationState = newAnimState

            Timer.Schedule(3, function ()
                if self.AnimationState == newAnimState then -- only round off the tween if another tween didn't start
                    self.GoalOverhangPosition = V{0,0}
                end
            end)
        end
    })

    newGameScene.HealthBar:Adopt(Prop.new{
        Name = "Tube",
        Size = V{100,80},
        AnchorPoint = V{1,0},
        Texture = Texture.new("game/assets/images/gui/hud/healthbar_tube.png")
    })

    newGameScene.HealthBar:Adopt(Prop.new{
        Name = "FacePlate",
        Size = V{52, 52},
        Position = V{34 + 26,21 + 26},
        GoalColor = V{1,1,1},
        GoalSize = V{52,52},
        AnchorPoint = V{0.5,0.5},
        
        BlinkTimer = 1,
        
        Last1HPFrameProfile = 1,

        AnimationQueue = {
            -- FORMAT: {currentFrame, [timeTilNextFrame, nextFrame, ...]}
            -- EXAMPLE:
            -- {1, {5, 10, 6, 11, 7}, nextAnimFunc}
            -- {1, {1, 30, 2, 3, 3, 3, 4}},
            -- {2, {31, 3, 32, 3, 33, 3, 34}}
        },

        Texture = Animation.new("game/assets/images/gui/hud/healthbar_faceplate_uncolored.png", 6, 12):Properties{
            IsPlaying = false
        },
        Update = function (self, dt)
            dt = 1/60

            

            self.Color = self.Color:Lerp(self.GoalColor, dt)
            self.Size = self.Size:Lerp(self.GoalSize, dt*2)
            self.Rotation = math.lerp(self.Rotation, 0, dt*2)

            self.BlinkTimer = self.BlinkTimer - dt

            if self.BlinkTimer <= 0 then
                if self:GetParent().Health == 3 then
                    self.Color = V{0.8,0.8,1}
                    self.BlinkTimer = 8
                elseif self:GetParent().Health == 2 then
                    self.Color = V{1,1,0.6}
                    self.BlinkTimer = 4
                elseif self:GetParent().Health == 1 then
                    self.Color = V{1,0.5,0.5}
                    self.Size = self.Size * 1.1
                    self.BlinkTimer = 2
                end
            end

            table.sort(self.AnimationQueue, function (a, b) -- sort AnimationQueue by priority
                return a[1] < b[1]
            end)

            for i = #self.AnimationQueue, 1, -1 do
                local animation = self.AnimationQueue[i]
                local frameQueue = animation[2]
            
                if i == #self.AnimationQueue then
                    self.Texture:SetFrame(frameQueue[1])
                end
            
                local delay = frameQueue[2]
                if delay then
                    frameQueue[2] = delay - 1
                    if frameQueue[2] == 0 then
                        table.remove(frameQueue, 1) -- remove frame
                        table.remove(frameQueue, 1) -- remove delay
                    end
                else
                    local callback = animation[3]
                    if callback then callback(self) end
                    table.remove(self.AnimationQueue, i)
                end
            end
        end,

        NewExpression = function (self)
            local newExpression

            if self:GetParent().Health == 3 then
                local m = math.random(1,5)
                newExpression =  m == 1 and {1, {1,  5, 2,  4, 3,  120 + math.random(-60,60), 1,  5, 24, 3, 24}, self.NewExpression}
                                    or m == 2 and {1, {4,  5, 5,  4, 6,  120 + math.random(-60,60), 4,  5, 24, 3, 24}, self.NewExpression}
                                    or m == 3 and {1, {7,  5, 8,  4, 9,  120 + math.random(-60,60), 7,  5, 24, 3, 24}, self.NewExpression}
                                    or m == 4 and {1, {10,  5, 11,  4, 12,  120 + math.random(-60,60), 10,  5, 24, 3, 24}, self.NewExpression}
                                    or m == 5 and {1, {13,  5, 14,  4, 15,  120 + math.random(-60,60), 13,  5, 24, 3, 24}, self.NewExpression}
            elseif self:GetParent().Health == 2 then
                local m = math.random(1,5)
                newExpression =  m == 1 and {1, {1+24,  5, 2+24,  4, 3+24,  120 + math.random(-60,60), 1+24,  5, 24+24, 3, 24+24}, self.NewExpression}
                                    or m == 2 and {1, {4+24,  5, 5+24,  4, 6+24,  120 + math.random(-60,60), 4+24,  5, 24+24, 3, 24+24}, self.NewExpression}
                                    or m == 3 and {1, {7+24,  5, 8+24,  4, 9+24,  120 + math.random(-60,60), 7+24,  5, 24+24, 3, 24+24}, self.NewExpression}
                                    or m == 4 and {1, {10+24,  5, 11+24,  4, 12+24,  120 + math.random(-60,60), 10+24,  5, 24+24, 3, 24+24}, self.NewExpression}
                                    or m == 5 and {1, {13+24,  5, 14+24,  4, 15+24,  120 + math.random(-60,60), 13+24,  5, 24+24, 3, 24+24}, self.NewExpression}

            elseif self:GetParent().Health == 1 then
                local m
                repeat m = math.random(1, 5) until m ~= self.Last1HPFrameProfile
                self.Last1HPFrameProfile = m

                local f1, f2, f3
                
                if m == 1 then f1, f2, f3 = 49, 50, 51
                elseif m == 2 then f1, f2, f3 = 52, 53, 54
                elseif m == 3 then f1, f2, f3 = 55, 56, 57
                elseif m == 4 then f1, f2, f3 = 58, 59, 60
                elseif m == 5 then f1, f2, f3 = 61, 62, 63 end

                newExpression = {1, {f1, 5, f2, 4, f3, 6, f2, 5, f3}, self.NewExpression}

                -- add extra length to the animation
                for i = 1, math.random(5, 25) do
                    newExpression[2][#newExpression[2]+1] = math.random(3,5)
                    newExpression[2][#newExpression[2]+1] = i%2==0 and f3 or f2
                end
            end


            self.AnimationQueue[#self.AnimationQueue+1] = newExpression
        end,

        ClearAnimationQueue = function (self)
            self.AnimationQueue = {}
        end
    })
    newGameScene.HealthBar:GetChild("FacePlate").Texture:SetFrame(3)
    newGameScene.HealthBar:GetChild("FacePlate"):NewExpression()
    -- local f f = function ()
    --     print("Repeats every 1 second")
    --     newGameScene.HealthBar:GetChild("FacePlate").Color = V{0,1,0}
    --     -- newGameScene.HealthBar:GetChild("FacePlate").Size = V{60,60}
    --     Timer.Schedule(2, f)
    -- end f()

    -- Timer.Schedule(7, function ()
    --     newGameScene.HealthBar:Damage(1)
    -- end)

    -- Timer.Schedule(14, function ()
    --     newGameScene.HealthBar:Damage(1)
    -- end)

    -- Timer.Schedule(21, function ()
    --     newGameScene.HealthBar:Damage(-1)
    -- end)

    -- Timer.Schedule(28, function ()
    --     newGameScene.HealthBar:Damage(-1)
    -- end)

    

    newGameScene.fallGuiTop = newGameScene.OverlayLayer:Adopt(Prop.new{
        Name = "FallGuiTop",
        Texture = Texture.new("chexcore/assets/images/test/fallGui.png"),
        Size = V{1280, 720},
        Position = V{1280/2, 720},
        AnchorPoint = V{0.5, 0},
        Visible = false,
    })

    newGameScene.fallGuiBottom = newGameScene.OverlayLayer:Adopt(Prop.new{
        Name = "FallGuiBottom",
        Texture = Texture.new("chexcore/assets/images/test/fallGui.png"),
        Size = V{1280, 720},
        Position = V{1280/2, 720*2},
        AnchorPoint = V{0.5, 1},
        Rotation = math.rad(180),
        Visible = false,
    })

    newGameScene.statsGui = newGameScene.OverlayLayer:Adopt(Gui.new{
        Name = "StatsGui",
        Size = V{350, 390},
        Position = V{0, 0},
        Texture = Texture.new("chexcore/assets/images/square.png"),
        Color = V{0, 0, 0, 0.8},
        Visible = false,

        active = false,
        originPos = nil,
        originMousePos = nil,
        timePressed = 0,
        drawChildren = true,
        goalRotation = 0,

        OnSelectStart = function (self)
            self.active = true
            self.originPos = self.Position
            self.originMousePos = self:GetLayer():GetMousePosition()
        end,
        OnHoverWhileSelected = function (self)
            self:OnSelectStart()
        end,
        OnSelectEnd = function (self)
            self.active = false
            if self.timePressed < 0.3 and (self.originPos - self.Position):Magnitude() < 20 then
                self.Position = self.originPos
                self.drawChildren = not self.drawChildren

            end
            self.timePressed = 0
        end,
        Update = function (self, dt)
            if self.active then
                self.timePressed = self.timePressed + dt
                local newPos = self.Position:Lerp(self.originPos + (self:GetLayer():GetMousePosition() - self.originMousePos), 50*dt)
                local xDiff = newPos.X - self.Position.X
                self.goalRotation = self.goalRotation + xDiff/500
                self.Position = newPos

                self:SetEdge("left", math.max(self:GetEdge("left"), 0))
                self:SetEdge("right", math.min(self:GetEdge("right"), 1280))
                self:SetEdge("top", math.max(self:GetEdge("top"), 0))
                self:SetEdge("bottom", math.min(self:GetEdge("bottom"), 720))
            end
        end
    })

    newGameScene.CameraBounds = Group.new("Gameplay"):With(Prop.new{
        Name = "Left",
        IgnoreCulling = true,
        AnchorPoint = V{0, 0.5},
        Color = V{0,0,0,1},
        DrawInForeground = true,
        ZIndex = 0.5,
    }):With(Prop.new{
        Name = "Right",
        IgnoreCulling = true,
        AnchorPoint = V{1, 0.5},
        Color = V{0,0,0,1},
        DrawInForeground = true,
        ZIndex = 0.5,
    }):With(Prop.new{
        Name = "Top",
        IgnoreCulling = true,
        AnchorPoint = V{0.5, 0},
        Color = V{0,0,0,1},
        DrawInForeground = true,
        ZIndex = 0.5,
    }):With(Prop.new{
        Name = "Bottom",
        IgnoreCulling = true,
        AnchorPoint = V{0.5, 1},
        Color = V{0,0,0,1},
        DrawInForeground = true,
        ZIndex = 0.5,
    }):Properties{
        Scene = newGameScene,
        PrepareToDraw = function (self)
            local PADDING = 500
            local dt = Chexcore._lastFrameTime
            local camera = self.Scene.Camera
            local camPos = camera.Position
            local camSize = self.Scene.GameplaySize / camera.Zoom
            local focusSize = camera:GetFocus().Size

            local horizBarSize, vertiBarSize = 0, 0
            local left, right, top, bottom = self:GetChild("Left"), self:GetChild("Right"), self:GetChild("Top"), self:GetChild("Bottom")

            local offsetX, offsetY = 0, 0
            local realFocus = camera:GetFocus()
            local override = camera.Overrides[#camera.Overrides]
            if realFocus ~= camera.Focus then -- camera is being overridden
                if override.BlackBorder then
                    horizBarSize = focusSize.X < camSize.X and (camSize.X - focusSize.X)/2 or 0
                    vertiBarSize = focusSize.Y < camSize.Y and (camSize.Y - focusSize.Y)/2 or 0
                    offsetX = override.CameraOffsetX or offsetX
                    offsetY = override.CameraOffsetY or offsetY
                    if not self.RecordedEdges then
                        self.LeftEdge = left:GetEdge("right")
                        self.RightEdge = right:GetEdge("left")
                        self.TopEdge = top:GetEdge("bottom")
                        self.BottomEdge = bottom:GetEdge("top")
                        self.RecordedEdges = true
                    end
                end
            else
                self.RecordedEdges = false
            end
            
            local borderSpeedX = (override and override.BorderSpeedX) or camera.BorderSpeed.X
            local borderSpeedY = (override and override.BorderSpeedY) or camera.BorderSpeed.Y

            local goalHorizSize = V{horizBarSize+1, camSize.Y*2}
            local goalVertiSize = V{camSize.X*2, vertiBarSize+1}

            local leftGoalSize = goalHorizSize - V{offsetX-1-PADDING, 0}
            local rightGoalSize = goalHorizSize + V{offsetX+PADDING, 0}
            local topGoalSize = goalVertiSize - V{0, offsetY-1-PADDING}
            local bottomGoalSize = goalVertiSize + V{0, offsetY+PADDING}

            

            left.Size = left.Size:Lerp(leftGoalSize, borderSpeedX*dt, 1)
            right.Size = right.Size:Lerp(rightGoalSize, borderSpeedX*dt, 1)
            top.Size = top.Size:Lerp(topGoalSize, borderSpeedY*dt, 1)
            bottom.Size = bottom.Size:Lerp(bottomGoalSize, borderSpeedY*dt, 1)


            left.Visible = left.Size.X - PADDING - 1 > 1
            right.Visible = right.Size.X - PADDING > 1
            top.Visible = top.Size.Y - PADDING - 1 > 1
            bottom.Visible = bottom.Size.Y - PADDING > 1

            -- if left.Size.X > leftGoalSize.X then
            --     left.Size.X = leftGoalSize.X
            -- end
            -- if right.Size.X > rightGoalSize.X then
            --     right.Size.X = rightGoalSize.X
            -- end
            -- if top.Size.Y > topGoalSize.Y then
            --     top.Size.Y = topGoalSize.Y
            -- end
            -- if bottom.Size.Y > bottomGoalSize.Y then
            --     print("AAH")
            --     bottom.Size.Y = bottomGoalSize.Y
            -- end

            local hBase = V{camSize.X/2+1 + PADDING, 0}
            local vBase = V{0, camSize.Y/2+1 + PADDING}
            -- local l,r,t,b = left:GetEdge("left"), left:GetEdge("right"), left:GetEdge("top"), left:GetEdge("bottom")
            left.Position = camPos - hBase
            right.Position = camPos + hBase
            top.Position = camPos - vBase
            bottom.Position = camPos + vBase


            -- mainLayer:SetPartitions(left)
            -- mainLayer:SetPartitions(right)
            -- mainLayer:SetPartitions(top)
            -- mainLayer:SetPartitions(bottom)

            -- if self.LeftEdge and left:GetEdge("right") > self.LeftEdge then
            --     left.Size.X = left.Size.X*2
            --     left:SetEdge("right", self.LeftEdge)
            -- end
            -- if vertiBarSize == 0 and self.BottomEdge and bottom:GetEdge("top") < self.BottomEdge then
            --     bottom:SetEdge("top", self.BottomEdge)
            -- end
            -- if vertiBarSize == 0 and self.TopEdge and top:GetEdge("bottom") > self.TopEdge then
            --     top:SetEdge("bottom", self.TopEdge)
            -- end
            -- if horizBarSize == 0 and self.LeftEdge and left:GetEdge("right") < self.LeftEdge and left.Size.X > 2 then
            --     left:SetEdge("right", self.LeftEdge)
            -- end
            -- if horizBarSize == 0 and self.RightEdge and right:GetEdge("left") > self.RightEdge and right.Size.X > 2 then
            --     right:SetEdge("left", self.RightEdge)
            -- end
        end
    }:Nest(mainLayer)

    

    newGameScene.OverlayLayer:GetChild("StatsGui"):Adopt(Text.new{
        AlignMode = "justify",
        TextColor = V{1, 1, 1},
        -- Font = Font.new(20--[["chexcore/assets/fonts/chexfont_bold.ttf"]]),
        Font = Font.new("chexcore/assets/fonts/futura.ttf", 20),
        Text = "STATS:",
        Visible = true,
        -- FontSize = 20,
        Size = V{330, 350},
        AnchorPoint = V{0.5, 0.5},
        Position = V{10, 10},
        Draw = function (self, tx, ty)
            if self:GetParent().Visible then
                self.Position = self:GetParent().Position + self:GetParent().Size/2
                Text.Draw(self, tx, ty)
            end
        end
    })

    return GameScene:Connect(newGameScene)
end

local Scene = Scene


function GameScene:Update(dt)

    self.FrameLimit = self.PerformanceMode and self._performanceFPS or self._normalFPS

    if not self.Player then
        self.Player = self:GetDescendant(Object.IsA, "Player")
    else
        -- print(self.Player.Position)
        

        if self.statsGui.Visible then
            local curFpsRatio = (1/self.Player:GetLayer():GetParent().FrameLimit)/Chexcore._lastFrameTime
            self.lastFpsRatio = math.lerp(self.lastFpsRatio or curFpsRatio, curFpsRatio, 0.05)

            self.lastPos = self.lastPos or V{0, 0}

            local pos_col_x = V{1 - math.abs(self.lastPos.X - self.Player.Position.X)/5, 1 - math.abs(self.lastPos.X - self.Player.Position.X)/13, 1}
            local pos_col_y = V{1 - math.abs(self.lastPos.Y - self.Player.Position.Y)/5, 1, 1}

            self.lastPos = self.Player.Position:Clone()


            self.statsGui:GetChild("Text").Text = {V{1,1,1,.8}," ~ STATS: ~ \n" , V{1,1,1}, 
                                        "Position: V{ ", pos_col_x, ("%0.2f"):format(self.Player.Position.X) .. ", ", pos_col_y, ("%0.2f"):format(self.Player.Position.Y), Constant.COLOR.WHITE, " }\n" ..
                                        "Speed: V{ ", V{1,1 - ((math.abs(self.Player.Velocity.X) - self.Player.RollPower) / self.Player.MaxSpeed.X),1 - (math.abs(self.Player.Velocity.X) / self.Player.MaxSpeed.X)}, ("%0.2f"):format(self.Player.Velocity.X) .. ", ", V{1 - math.abs(self.Player.Velocity.Y)/self.Player.MaxSpeed.Y, 1, 1 - math.abs(self.Player.Velocity.Y)/self.Player.MaxSpeed.Y}, ("%0.2f"):format(self.Player.Velocity.Y), Constant.COLOR.WHITE, " }\n" ..
                                        "Force: V{ ", self.Player.Acceleration.X == 0 and Constant.COLOR.WHITE:AddAxis(0.5) or Constant.COLOR.PINK, ("%0.2f"):format(self.Player.Acceleration.X) .. ", ", self.Player.Acceleration.Y == 0 and (Constant.COLOR.WHITE:AddAxis(0.5) or true) or Constant.COLOR.PURPLE + 0.5, ("%0.2f"):format(self.Player.Acceleration.Y), Constant.COLOR.WHITE, " }\n"  ..
                                        "Floor:               ", self.Player.Floor and Constant.COLOR.GREEN or Constant.COLOR.RED + 0.5, tostring(self.Player.Floor or "NONE"), Constant.COLOR.WHITE, 
                                        "\nFramesSincePounce: ", self.Player.FramesSincePounce == -1 and Constant.COLOR.ORANGE or Constant.COLOR.RED + 0.8, self.Player.FramesSincePounce,
                                        Constant.COLOR.WHITE, "\nFramesSinceJump: ", self.Player.FramesSinceJump == -1 and Constant.COLOR.ORANGE or Constant.COLOR.BLUE + 0.8, self.Player.FramesSinceJump,
                                        Constant.COLOR.WHITE, "\nFramesSinceDoubleJump: ", self.Player.FramesSinceDoubleJump == -1 and Constant.COLOR.ORANGE or Constant.COLOR.GREEN + 0.8, self.Player.FramesSinceDoubleJump,
                                        Constant.COLOR.WHITE, "\nFramesSinceCrouch: ", self.Player.CrouchTime == 0 and Constant.COLOR.ORANGE or Constant.COLOR.PURPLE + 0.5, self.Player.CrouchTime,
                                        Constant.COLOR.WHITE, "\nFramesSinceRoll: ", self.Player.FramesSinceRoll == -1 and Constant.COLOR.ORANGE or Constant.COLOR.ORANGE + 0.5, self.Player.FramesSinceRoll,
                                        Constant.COLOR.WHITE, "\nLastRollPower: ", V{1, 1 - (self.Player.LastRollPower - 0.5) / self.Player.RollPower, 1 - self.Player.LastRollPower / self.Player.RollPower}, self.Player.LastRollPower,
                                        Constant.COLOR.WHITE, "\nPerformance Mode:                 ", self.PerformanceMode and Constant.COLOR.GREEN or Constant.COLOR.RED, self.PerformanceMode and "ON" or "OFF",
                                        Constant.COLOR.WHITE, "\nFrameTime: ", Constant.COLOR.GREEN:Lerp(Constant.COLOR.RED, 1-curFpsRatio), ("%.2fms"):format(Chexcore._lastFrameTime*1000), V{1,1,1,0.5}, (" [%.2fms]"):format(Chexcore._cpuTime*1000), V{1 ,self.lastFpsRatio, self.lastFpsRatio}, ("\n            (%05.1f%% target FPS)"):format(self.lastFpsRatio*100),
                                        Constant.COLOR.WHITE, "\nLOVE Drawcalls:                     ", V{0.5, 0.5, 1}, Chexcore._graphicsStats.drawcalls,
                                    
                                        
                                    }
           
        end
        
        if not self.InRespawn and self.Player.Position.Y > self.DeathHeight and self.Player.LastSafePosition then
            self.InRespawn = true
            self.fallGuiBottom.Visible = true
            self.fallGuiTop.Visible = true

            Timer.Schedule(0.5, function ()
                if self.Player.IsInRagdoll then self.Player:EndRagdoll() end
                self.Player:Respawn(self.Player.LastSafePosition)
                self.Camera.Position = self.Player.LastSafePosition
            end)

            Timer.Schedule(1.2, function ()
                self.InRespawn = false
                self.fallGuiBottom.Visible = false
                self.fallGuiTop.Visible = false
                self.fallGuiTop.Position = V{1280/2, 720}
                self.fallGuiBottom.Position = V{1280/2, 720*2}
                self.fallGuiTop.Rotation = 0
                self.fallGuiBottom.Rotation = math.rad(180)
            end)
            

        end

        if self.InRespawn then
            -- self.fallGuiTop.Rotation = self.fallGuiTop.Rotation + 0.002
            -- self.fallGuiBottom.Rotation = self.fallGuiBottom.Rotation - 0.002
            self.fallGuiTop.Position.Y = self.fallGuiTop.Position.Y - 35 * 60 * dt
            self.fallGuiBottom.Position.Y = self.fallGuiBottom.Position.Y - 35 * 60 * dt

            -- self.fallGuiTop.Size.Y = self.fallGuiTop.Size.Y + 5
        end

        
        
    end

    -- make sure gui layer is on top
    
    local guiID = self.GuiLayer:GetChildID()
    while guiID ~= #self._children do
        self:SwapChildOrder(guiID, guiID+1)
        guiID = self.GuiLayer:GetChildID()
    end

    local overlayID = self.OverlayLayer:GetChildID()
    while overlayID ~= #self._children do
        self:SwapChildOrder(overlayID, overlayID+1)
        overlayID = self.OverlayLayer:GetChildID()
    end



    -- local ret = Scene.Update(self, dt)
    -- return ret

    -- manual reimplementation of Scene.Update instead
    for layer in self:EachChild() do
        layer:Update(dt)
    end

    if self.Camera.Update then
        self.Camera:Update(dt)
    end
end

function GameScene:Draw(tx, ty)
    
    self.CameraBounds:PrepareToDraw()

    -- flush lighting queue
    self:ApplyLighting()

    return Scene.Draw(self, tx, ty)
end

function GameScene:ApplyLighting()
    local queue = self.LightingQueue

    -- queue = {
    --     focalPoints = { {0.525, 0.55}, {0.475, 0.45} },
    --     radii = {1, 1},
    --     sharpnesses = {1,1},
    --     lightColors = {
    --         {1.0, 0.0, 1.0, 0.0},  -- red
    --         {1.0, 1.0, 0.0, 1.0},  -- red
    --     }
    -- }


    if #queue.sharpnesses == 0 then -- empty lighting queue
        
        -- self:GetLayer("Gameplay").Shader
        --     :Send("lightCount", 0)
        --     :Send("darkenFactor", self.Brightness or 0.4)
    else

        -- self:GetLayer("Gameplay").Shader
        --     :Send("lightRects", unpack(queue.focalPoints))
        --     :Send("lightChannels", unpack(queue.lightColors))
        --     :Send("radii", unpack(queue.radii))
        --     :Send("sharpnesses", unpack(queue.sharpnesses))
        --     :Send("baseShadowColor", self.ShadowColor or GameScene.ShadowColor)
        --     :Send("lightCount", #queue.sharpnesses)
        --     :Send("darkenFactor", self.Brightness or 0.4)

    end


    queue.lightColors = {}
    queue.focalPoints = {}
    queue.radii = {}
    queue.sharpnesses = {}
end

local radFactor = 1.075 / 8 / 16
function GameScene:EnqueueLight(lightSource, precomputed_tl, preomputed_br)
    -- lightSource.Radius = 0
    self.LightingQueue.sharpnesses[#self.LightingQueue.sharpnesses+1] = lightSource.Sharpness
    self.LightingQueue.radii[#self.LightingQueue.radii+1] = (lightSource.Radius*radFactor)
    self.LightingQueue.lightColors[#self.LightingQueue.lightColors+1] = lightSource.Color

    -- calculate focal point.. something like reverse Layer:GetMousePosition()?

    local x1, y1 = (lightSource:GetLayer():PositionOnMasterCanvas((precomputed_tl or lightSource:GetPoint(0,0))) / self.MasterCanvas:GetSize())()
    local x2, y2 = (lightSource:GetLayer():PositionOnMasterCanvas(preomputed_br or (lightSource:GetPoint(1,1))) / self.MasterCanvas:GetSize())()

    self.LightingQueue.focalPoints[#self.LightingQueue.focalPoints+1] = {x1, y1, x2, y2}


    



    
end





return GameScene