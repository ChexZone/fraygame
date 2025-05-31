local PlayerRagdoll = {
    Name = "PlayerRagdoll", _super = "Prop", _global = true
}

function PlayerRagdoll.new(dir)
    local ragdoll = Prop.new{
        Name = "PlayerRagdoll",
        Direction = dir or 1,
        MouseDropped = true,
        Canvas = Canvas.new(64, 64),
        HelperCanvas = Canvas.new(64, 64),
        FramesSinceActive = -1,
        FramesOnFloor = 0,
        Velocity = V{0,0},
        DrawInForeground = true,
        LandedOnBack = false,

        StunColor = V{1,0.4,0.4,1},
        IsStunned = true,

        RandomBackHeadAngle = math.rad(-90),
        Shader = Shader.new("game/assets/shaders/outline.glsl"):Send("step",{1/64,1/64}),
        StunShader = Shader.new("game/assets/shaders/custom-outline.glsl"):Send("step",{1/64,1/64}),
        Size = V{10,9},
        CollisionSize = V{10,8},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/assets/images/player/ragdoll/head.png"),
        Floor = nil,
        ZIndex = 5,
    
        Draw = function (self, tx, ty)
            local stunProgress = self.Player.StunTimer / self.Player.CurrentStunTotalLength
            print(stunProgress)
            self.StunColor = V{1,0.5*stunProgress ,0.5*stunProgress, stunProgress+0.5}
            self.StunShader:Send("outlineColor", V{self.StunColor[1],self.StunColor[2],self.StunColor[3],self.StunColor[4] or 1})

            self.Canvas:Activate()
            love.graphics.clear()
            -- love.graphics.circle("fill", 32, 32, 5)
            -- Prop.Draw(self, 32, 32)

        
            love.graphics.setColor(self.Color)
            

            for _, bodyPartName in ipairs{"RagdollBackLeg", "RagdollBackArm", "RagdollTorso", "RagdollFrontLeg", "RagdollFrontArm"} do
                local b = self:GetChild(bodyPartName)
                b.Texture:DrawToScreen(
                    b.Position[1] - self.Position[1] + 32,
                    b.Position[2] - self.Position[2] + 33,
                    b.Rotation,
                    b.Size[1],
                    b.Size[2],
                    b.AnchorPoint[1], b.AnchorPoint[2]
                )
            end




            -- HEAD
            self.Texture:DrawToScreen(
                32, 33,
                self.Rotation,
                self.Size[1],
                self.Size[2],
                self.AnchorPoint[1], self.AnchorPoint[2]
            )


            for _, bodyPartName in ipairs{"RagdollEye1", "RagdollEye2"} do
                local b = self:GetChild(bodyPartName)
                b.Texture:DrawToScreen(
                    b.Position[1] - self.Position[1] + 32,
                    b.Position[2] - self.Position[2] + 33,
                    b.Rotation,
                    b.Size[1],
                    b.Size[2],
                    b.AnchorPoint[1], b.AnchorPoint[2]
                )
            end


            self.Canvas:Deactivate()

            self.HelperCanvas:Activate()
            love.graphics.clear()
            love.graphics.setColor(1,1,1)

            self.Shader:Activate()

            local sx = 64 * (self.DrawScale[1]-1)
            local sy = 64 * (self.DrawScale[2]-1)


            self.Canvas:DrawToScreen(
                32, 32, 0,
                64*self.Direction + sx*self.Direction, 64 + sy,
                0.5,0.5
            )
            -- self.HelperCanvas:CopyFrom(self.Canvas)
            self.Shader:Deactivate()
            self.HelperCanvas:Deactivate()

            
            

            if self.IsStunned then
                self.Canvas:Activate()
                love.graphics.clear()
                self.StunShader:Activate()
                self.HelperCanvas:DrawToScreen(
                    32, 32, 0,
                    64, 64,
                    0.5,0.5
                )
                self.StunShader:Deactivate()
                self.Canvas:Deactivate()

                self.Canvas:DrawToScreen(
                    math.floor(self.Position[1] - tx),
                    math.floor(self.Position[2] - ty),
                    0, -- self.Rotation,
                    64,
                    64,
                    0.5,
                    0.5
                )
            else
                self.HelperCanvas:DrawToScreen(
                    math.floor(self.Position[1] - tx),
                    math.floor(self.Position[2] - ty),
                    0, -- self.Rotation,
                    64,
                    64,
                    0.5,
                    0.5
                )
            end

            
        end,

        Update = function (self, dt)
            if not self.IsActive then return end
            self.DrawScale = self.DrawScale:Lerp(V{1,1},8*dt)
            self.Color = self.Color:Lerp(V{1,1,1},2.5*dt)
            if not self.MouseDropped then
                local newMousePos = self:GetLayer():GetMousePosition()
    
                self:MoveTo(newMousePos)
                
                local vel = newMousePos - (self.MousePos or newMousePos)
    
                self.MousePos = newMousePos
    
                if Input:JustPressed("m_1") and not self.IgnoreFrame then
                    self.MouseDropped = true
                end
                self.IgnoreFrame = false
                self.GoalRotation = vel:Magnitude()>0.5 and V{vel.X, -vel.Y}:ToAngle() or 0
    
                self.Velocity = (self.Velocity or V{0,0}):Lerp(vel, dt*20)
                
            else

                if Input:JustPressed("m_1") and not self.NextOne then
                    self.NextOne = self:GetParent():Adopt(PlayerRagdoll.new(-self.Direction))
                    self.NextOne.IgnoreFrame = true
                end

                self.GoalRotation = self.Velocity:Magnitude()>0.5 and V{self.Velocity.X, -self.Velocity.Y}:ToAngle() or 0

                if not self.Floor then
                    self.FramesOnFloor = 0
                    self.Velocity = self.Velocity + V{0,0.1}
                else
                    self.FramesOnFloor = self.FramesOnFloor + 1
                    self.Velocity.Y = 0
                    self.Velocity.X = math.clamp(math.abs(self.Velocity.X) - 0.1, 0, math.huge) * sign(self.Velocity.X)
                    self.GoalRotation = self.LandedOnBack and self.RandomBackHeadAngle*self.Direction or math.rad(0)
                    self:ValidateFloor()
                end

                if self.Wall then
                    self:SetEdge(self.WallDirection, self.Wall:GetEdge(self.WallDirection=="left" and "right" or "left", self.WallTileNo, self.WallTileLayer))
                    self:ValidateWall()
                end

                local MAX_Y_DIST = 1
                local MAX_X_DIST = 1
                local subdivisions = 1
            
                if math.abs(self.Velocity.X) > MAX_X_DIST then
                    subdivisions = math.floor(1+math.abs(self.Velocity.X)/MAX_X_DIST)
                end
            
                if math.abs(self.Velocity.Y) > MAX_Y_DIST then
                    subdivisions = math.max(subdivisions, math.floor(1+math.abs(self.Velocity.Y)/MAX_Y_DIST))
                end

                local interval = subdivisions == 1 and self.Velocity or self.Velocity / subdivisions

                -- if moving vertically at least 1.5x faster than horizontally, prioritize X clipping, otherwise prioritize Y clipping
                for i = 1, subdivisions do
                    if math.abs(interval.Y) > 1.5*math.abs(interval.X) then
                        self.Position.X = self.Position.X + interval.X
                        self:Unclip("x")
                        self.Position.Y = self.Position.Y + interval.Y
                        self:Unclip("y")
                    else
                        self.Position.Y = self.Position.Y + interval.Y
                        self:Unclip("y")
                        self.Position.X = self.Position.X + interval.X
                        self:Unclip("x")
                    end
                end


                self.Velocity.Y = math.clamp(self.Velocity.Y, -10, 5)
                self.Velocity.X = math.clamp(self.Velocity.X, -7, 7)

                
            end
    
            self.Rotation = math.lerp(self.Rotation, self.GoalRotation*self.Direction, dt*10)

            if self.FramesSinceActive > -1 then
                self.FramesSinceActive = self.FramesSinceActive + 1
            end

            self.Player:UpdateTouchEvents(self)
        end,

        Unclip = function (self, axis)
            
            if self.FramesSinceActive == -1 then return end
            local clipped
            local collisionCandidates = self:GetLayer():GetCollisionCandidates(self)
            for solid, hDist, vDist, tileID, tileNo, tileLayer in self:CollisionPass(collisionCandidates, true) do
                local face = Prop.GetHitFace(hDist,vDist)
                local otherFace = face=="top" and "bottom" or face=="bottom" and "top" or face=="left" and "right" or face=="right" and "left"
                local surfaceInfo = solid:GetSurfaceInfo(tileID)
                local capFace = type(otherFace)=="string" and otherFace:sub(1,1):upper() .. otherFace:sub(2,#otherFace)

                -- damage handling
                if surfaceInfo[capFace] and surfaceInfo[capFace].DamageType and not self.Player.InTransition then
                    print(solid, face, tileID)
                    self.Player:SetEdge("top", self:GetEdge("top"))
                    self.Player:StartRagdoll(surfaceInfo[capFace], true)
                    if face == "bottom" then
                        self:MoveTo(self.Position.X, self.Position.Y-1)
                    end
                elseif not solid.Passthrough then -- regular collision
                    clipped = true
                    
                    if axis == "y" then
                        
                        if self.Velocity.Y <= 0 and not surfaceInfo.Bottom.Passthrough and face == "top" then
                            self.Velocity.Y = 0
                            self:SetEdge("top", solid:GetEdge("bottom", tileNo, tileLayer))
                        elseif (self.Velocity.Y >= 0) and not surfaceInfo.Top.Passthrough and face == "bottom" then
                            self.Velocity.Y = 0
                            self.Floor = solid
                            if self.Direction == -sign(self.Velocity.X) then
                                self.LandedOnBack = true
                                self.RandomBackHeadAngle = math.random(1,2)==1 and math.rad(-90) or math.rad(-90)
                            else
                                self.LandedOnBack = false
                            end
                            self:SetEdge("bottom", solid:GetEdge("top", tileNo, tileLayer))
                            self.GoalRotation = math.rad(270)
                        end
                    else -- x axis
                        if (self.Velocity.X >= 0 and face == "right" and not surfaceInfo.Left.Passthrough) and math.abs(hDist)>1 then
                            if math.abs(self.Velocity.X) > 2 then -- bounce
                                self.Velocity.X =  -self.Velocity.X/2
                                self.Wall = solid
                                self.WallTileNo = tileNo
                                self.WallTileLayer = tileLayer
                                self.WallDirection = "right"
                            else
                                self.Rotation = 0
                                self.Velocity.X =  0
                            end
                            

                            
                            self:SetEdge("right", solid:GetEdge("left", tileNo, tileLayer))
                        elseif (self.Velocity.X <= 0 and face == "left" and not surfaceInfo.Right.Passthrough) and math.abs(hDist)>1 then
                            if math.abs(self.Velocity.X) > 2 then -- bounce
                                self.Velocity.X =  -self.Velocity.X/2
                                self.Wall = solid
                                self.WallTileNo = tileNo
                                self.WallTileLayer = tileLayer
                                self.WallDirection = "left"
                            else
                                self.Rotation = 0
                                self.Velocity.X =  0
                            end
                            self:SetEdge("left", solid:GetEdge("right", tileNo, tileLayer))
                        end
                    end
                end
                
                self.Player:ProcessTouchInteraction(self, solid)
            end



            return clipped
        end,

        ValidateFloor = function (self)
            local hit = false
            self.Position.Y = self.Position.Y + 1
            for solid, hDist, vDist, tileID, tileNo, tileLayer in self:CollisionPass(self.Floor, true, false, true) do
                local surfaceInfo = solid:GetSurfaceInfo(tileID)
                local face = Prop.GetHitFace(hDist,vDist)
                if not surfaceInfo.Top.Passthrough and face == "bottom" then
                    hit = solid
                end

            end
            if not hit then
                self.Floor = nil
            end
            self.Position.Y = self.Position.Y - 1
        end,

        ValidateWall = function (self)
            local hit = false
            self.Position.X = self.Position.X + 1 * (self.WallDirection=="left" and -1 or 1)
            for solid, hDist, vDist, tileID, tileNo, tileLayer in self:CollisionPass(self.Wall, true, false, true) do
                local surfaceInfo = solid:GetSurfaceInfo(tileID)
                local face = Prop.GetHitFace(hDist,vDist)
                if (self.Velocity.X >= 0 and face == "right" and not surfaceInfo.Left.Passthrough) or (self.Velocity.X <= 0 and face == "left" and not surfaceInfo.Right.Passthrough) or ((face=="left" or face=="right")) then
                    hit = solid
                end
            end
            if not hit then
                self.Wall = nil
            end
            self.Position.X = self.Position.X - 1 * (self.WallDirection=="left" and -1 or 1)
        end
    }

    
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollEye1",
        Visible = false,
        Size = V{4,4},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/assets/images/player/ragdoll/dead_eye.png"),
        ZIndex = 6,
    
        Update = function (self, dt)
            self:MoveTo(self:GetParent():GetPoint(0.4,0.5))
            
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollEye2",
        Visible = false,
        Size = V{4,4},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/assets/images/player/ragdoll/dead_eye.png"),
        ZIndex = 6,
    
        Update = function (self, dt)
            self:MoveTo(self:GetParent():GetPoint(0.8,0.5))
            
        end,
    })
    
    ragdoll.Torso = ragdoll:Adopt(Prop.new{
        Name = "RagdollTorso",
        Size = V{10,10},
        AnchorPoint = V{0.5,0},
        Visible = false,
        Texture = Texture.new("game/assets/images/player/ragdoll/torso.png"),
        ZIndex = 3,
        GoalPoint = V{0.55,0.925},
    
        Update = function (self, dt)
            local p = self.Position:Clone()
            
            if self:GetParent().Floor then
                if self:GetParent().LandedOnBack then
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.35, 0.825}, dt*5)
                else
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.55, 0.925}, dt*5)
                end
            else
                self.GoalPoint = self.GoalPoint:Lerp(V{0.55, 0.925}, dt*5)
            end

            self:MoveTo(self:GetParent():GetPoint(self.GoalPoint.X,self.GoalPoint.Y))

            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle()*self:GetParent().Direction or self:GetParent().Rotation

            if self:GetParent().Floor then
                goalRot = self:GetParent().LandedOnBack and math.rad(-50) or math.rad(90)
            end
            
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*4, 0.1)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollFrontArm",
        Size = V{5,10},
        AnchorPoint = V{0.5,0.2},
        Texture = Texture.new("game/assets/images/player/ragdoll/front_arm.png"),
        ZIndex = 4,
        Visible = false,
        GoalPoint = V{0.2, 0.25},
        Update = function (self, dt)
            if self:GetParent().Floor then
                if self:GetParent().LandedOnBack then
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.3, 0.25}, dt*3)
                else
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.7, 0.25}, dt*3)
                end
            else
                self.GoalPoint = self.GoalPoint:Lerp(V{0.2, 0.25}, dt*3)
            end

            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(self.GoalPoint.X,self.GoalPoint.Y))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and -V{dist[1], -dist[2]}:ToAngle()*self:GetParent().Direction+torso.Rotation*1.5 or (self:GetParent().LandedOnBack and math.rad(0) or self:GetParent().Rotation)
            
            if self:GetParent().Floor then
                goalRot = self:GetParent().LandedOnBack and math.rad(-50) or math.rad(0)
            end
            
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*6, 0.1)
            -- self.Rotation = math.lerp(self.Rotation, torso.Rotation, dt*2, 0.05)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollBackArm",
        Size = V{5,8},
        Visible = false,
        AnchorPoint = V{0.5,0.2},
        Texture = Texture.new("game/assets/images/player/ragdoll/back_arm.png"),
        ZIndex = 2,
        GoalPoint = V{0.75, 0.25},

        Update = function (self, dt)
            -- local p = self.Position:Clone()
            -- local torso = self:GetParent().Torso
            -- self:MoveTo(torso:GetPoint(0.9,0.2))

            if self:GetParent().Floor then
                if self:GetParent().LandedOnBack then
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.9, 0.1}, dt*5)
                else
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.85, 0.25}, dt*5)
                end
            else
                self.GoalPoint = self.GoalPoint:Lerp(V{0.75, 0.25}, dt*5)
            end

            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(self.GoalPoint.X, self.GoalPoint.Y))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and -V{dist[1], -dist[2]}:ToAngle()*self:GetParent().Direction+torso.Rotation or self:GetParent().Rotation
            
            if self:GetParent().Floor then
                goalRot = self:GetParent().LandedOnBack and math.rad(-100) or goalRot
            end

            self.Rotation = math.lerp(self.Rotation, goalRot, dt*6, 0.1)
            -- self.Rotation = math.lerp(self.Rotation, torso.Rotation, dt*2, 0.05)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollFrontLeg",
        Size = V{6,8},
        Visible = false,
        AnchorPoint = V{0.5,0.2},
        GoalPoint = V{0.3,0.85},
        Texture = Texture.new("game/assets/images/player/ragdoll/front_leg.png"),
        ZIndex = 4,
    
        Update = function (self, dt)
            if self:GetParent().Floor then
                if self:GetParent().LandedOnBack then
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.45, 0.9}, dt*3)
                else
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.7, 0.85}, dt*3)
                end
                
            else
                self.GoalPoint = self.GoalPoint:Lerp(V{0.3, 0.85}, dt*3)
            end

            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(self.GoalPoint.X,self.GoalPoint.Y))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle()+torso.Rotation*1.5 or (0)
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*3, 0.1)
            -- self:MoveTo(torso:GetPoint(0.2,0.85))
            -- self.Rotation = math.lerp(self.Rotation, torso.Rotation, dt*3, 0.05)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollBackLeg",
        Size = V{6,8},
        Visible = false,
        AnchorPoint = V{0.5,0.2},
        GoalPoint = V{0.7,0.85},
        Texture = Texture.new("game/assets/images/player/ragdoll/back_leg.png"),
        ZIndex = 2,
    
        Update = function (self, dt)
            if self:GetParent().Floor then
                if self:GetParent().LandedOnBack then
                    self.GoalPoint = self.GoalPoint:Lerp(V{1.1, 0.75}, dt*3)
                else
                    self.GoalPoint = self.GoalPoint:Lerp(V{0.3, 0.85}, dt*3)
                end
                
            else
                self.GoalPoint = self.GoalPoint:Lerp(V{0.7, 0.85}, dt*3)
            end

            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(self.GoalPoint.X,self.GoalPoint.Y))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle()+torso.Rotation or self:GetParent().Rotation
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*3, 0.1)
        end,
    })

    return setmetatable(ragdoll, PlayerRagdoll)
end

return PlayerRagdoll