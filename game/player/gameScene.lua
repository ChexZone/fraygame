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
    Brightness = .1, -- brightness of the overall scene (0=pitch black)

    ShowStats = false,  -- show stats of the player

    GuiLayer = nil,     -- set in constructor


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

    mainLayer.Shader2 = Shader.new("game/assets/shaders/scene-focus.glsl")
        :Send("lightRects", unpack{{0.5,0.5, 0.85,.7}})
        :Send("radii", unpack{1,1})
        :Send("darkenFactor", 1)
        :Send("sharpnesses", unpack{0.4,1})
        :Send("aspectRatio", {16,9})
        :Send("blendRange", 5.0)
        :Send("baseShadowColor", HSV{0,0,0})
        :Send("lightCount", 2)

    newGameScene.Camera = GameCamera.new():Set("Scene", newGameScene)

    newGameScene.GuiLayer = newGameScene:Adopt(Layer.new("GUI", 1280, 720, true))

    newGameScene.fallGuiTop = newGameScene.GuiLayer:Adopt(Prop.new{
        Name = "FallGuiTop",
        Texture = Texture.new("chexcore/assets/images/test/fallGui.png"),
        Size = V{1280, 720},
        Position = V{1280/2, 720},
        AnchorPoint = V{0.5, 0},
        Visible = false,
    })

    newGameScene.fallGuiBottom = newGameScene.GuiLayer:Adopt(Prop.new{
        Name = "FallGuiBottom",
        Texture = Texture.new("chexcore/assets/images/test/fallGui.png"),
        Size = V{1280, 720},
        Position = V{1280/2, 720*2},
        AnchorPoint = V{0.5, 1},
        Rotation = math.rad(180),
        Visible = false,
    })

    newGameScene.statsGui = newGameScene.GuiLayer:Adopt(Gui.new{
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
        AnchorPoint = V{0, 0.5},
        Color = V{0,0,0,1},
        DrawInForeground = true
    }):With(Prop.new{
        Name = "Right",
        AnchorPoint = V{1, 0.5},
        Color = V{0,0,0,1},
        DrawInForeground = true
    }):With(Prop.new{
        Name = "Top",
        AnchorPoint = V{0.5, 0},
        Color = V{0,0,0,1},
        DrawInForeground = true
    }):With(Prop.new{
        Name = "Bottom",
        AnchorPoint = V{0.5, 1},
        Color = V{0,0,0,1},
        DrawInForeground = true
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

    

    newGameScene.GuiLayer:GetChild("StatsGui"):Adopt(Text.new{
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
        
        self:GetLayer("Gameplay").Shader2
            :Send("lightCount", 0)
            :Send("darkenFactor", self.Brightness or 0.4)
    else

        self:GetLayer("Gameplay").Shader2
            :Send("lightRects", unpack(queue.focalPoints))
            :Send("lightChannels", unpack(queue.lightColors))
            :Send("radii", unpack(queue.radii))
            :Send("sharpnesses", unpack(queue.sharpnesses))
            :Send("lightCount", #queue.sharpnesses)
            :Send("darkenFactor", self.Brightness or 0.4)

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