local Basketball = {
    Name = "Basketball",
    
    _super = "Prop", _global = true
}

function Basketball.new()
    local newBall = Prop.new{
        Name = "Holdable",
        LinesTexture = Texture.new("game/assets/images/basketball-lines.png"),
        BaseTexture = Texture.new("game/assets/images/basketball-base.png"),
        HeldTexture = Texture.new("game/assets/images/basketball-held.png"),
        DrawOverChildren = true,
        DrawInForeground = true,

        Size = V{14, 14},
        CollisionSize = V{24,24},
        -- Color = V{1, 0, 0},
        InternalDrawScale = V{1,1},
        InternalRotation = 0,
        AnchorPoint = V{0.5,0.5},
        Position = V{2780, 1100},
        Solid = true, Passthrough = true,
    
    
        -- will be properties of holdables
        IsHoldable = true,
        Owner = nil, -- will be a Player object
    
        COYOTE_FRAMES_AFTER_DROP = 6,
        COYOTE_FRAMES_AFTER_GROUNDED_THROW = 12,
        COYOTE_FRAMES_AFTER_AIRBORN_THROW = 18,
        COYOTE_FRAMES_AFTER_VERTICAL_BOUNCE = 5,
        MIDAIR_THROW_HEIGHT = -1,
        GROUNDED_THROW_HEIGHT = -1,
        X_BOUNCE_DELAY = 4,
        Y_BOUNCE_DELAY = 4,
        DebounceX = 0,
        DebounceY = 0,
        CoyoteFrames = 0,
        Velocity = V{0, 0},
        Gravity = 0.15,
        MinThrowSpeed = 3.5,
        TerminalVelocity = V{5, 3.5},
        PickupDebounce = 0,
        FRAMES_BETWEEN_DROP_AND_REGRAB = 10,
        X_DECELERATION_GROUND = 0.035,
        X_DECELERATION_AIR = 0.01,
        Y_BOUNCE_HEIGHT_LOSS = 1.5,
        Y_MIN_BOUNCE_HEIGHT = 0.75,
        ExtendsHitbox = true,
        CanBeOverhang = false,
        SquashWithPlayer = true,
        VerticalOffset = -12,
        RotVelocity = 0,
        LastDrawnPos = V{0,0},
        Collider = tilemap,
        Floor = nil,
    
        SFX = {
            Bounce = Sound.new("game/assets/sounds/basketball_1.wav", "static"):Set("Volume", 0.1)
        },
    
        Draw = function (self, tx, ty)
            if (not self.Owner) or self.Owner.FramesSinceHoldingItem < 2 then
                local drawPos = self.Position
                if self.Owner and self.Owner.FramesSinceHoldingItem == 1 then
                    drawPos = self.LastDrawnPos
                end
                -- -- self:GetChild("DrawBase").Position = self.Position
                self.Texture:Activate()
                love.graphics.clear()
                love.graphics.setColor(1,1,1,1)
                local sx = self.Size[1] * (self.InternalDrawScale[1]-1)
                local sy = self.Size[2] * (self.InternalDrawScale[2]-1)

                self.BaseTexture:DrawToScreen(
                    self.Size[1]/2+1, self.Size[2]/2+1,
                    0,
                    self.Size[1] + sx,
                    self.Size[2] + sy,
                    0.5, 0.5
                )

                self.LinesTexture:DrawToScreen(
                    self.Size[1]/2+1, self.Size[2]/2+1,
                    self.InternalRotation,
                    self.Size[1] + sx,
                    self.Size[2] + sy,
                    0.5, 0.5
                )
                self.Texture:Deactivate()
                -- self.Texture:Deactivate()
                if self.Shader then self.Shader:Activate() end

                self.Texture:DrawToScreen(
                    math.floor(drawPos[1] - tx+0.5),
                    math.floor(drawPos[2] - ty),
                    0,
                    self.Texture:GetWidth(),
                    self.Texture:GetHeight(),
                    self.AnchorPoint[1],
                    self.AnchorPoint[2]
                )
                
                -- Prop.Draw(self, tx+0.5, ty-1, isForeground)
                if self.Shader then self.Shader:Deactivate() end                
            end
            self.LastDrawnPos = self.Position
        end,
    
        _dtThreshold = 1/50,
        Update = function(self, dt)
    
            local frameInterval = dt > self._dtThreshold and 2 or 1
    
            if not self.Owner then
                
                if self.PickupDebounce > 0 then
                    self.PickupDebounce = math.max(self.PickupDebounce - frameInterval, 0)
                end
    
                if self.DebounceX > 0 then
                    self.DebounceX = math.max(self.DebounceX - frameInterval, 0)
                end
                if self.DebounceY > 0 then
                    self.DebounceY = math.max(self.DebounceY - frameInterval, 0)
                end
    
                -- physics
    
                local MAX_Y_DIST = 1
                local MAX_X_DIST = 1
                local subdivisions = 1
                local posDelta = self.Velocity:Clone()*60*dt
    
                if math.abs(posDelta.X) > MAX_X_DIST then
                    subdivisions = math.floor(1+math.abs(posDelta.X)/MAX_X_DIST)
                end
            
                if math.abs(posDelta.Y) > MAX_Y_DIST then
                    subdivisions = math.max(subdivisions, math.floor(1+math.abs(posDelta.Y)/MAX_Y_DIST))
                end
                
                local interval = subdivisions == 1 and posDelta or posDelta / subdivisions
    
                
    
                for i = 1, subdivisions do
                    self.Position = self.Position + interval
                    self:RunCollision(false, dt)
                end
    
                
    
                if self.CoyoteFrames == 0 then
                    if not self.Floor then
                        self.Velocity.Y = self.Velocity.Y + self.Gravity*60*dt
                    end
                else
                    self.CoyoteFrames = math.max(self.CoyoteFrames - frameInterval, 0)
    
                    -- still apply upward velocity if it's there
                    if self.Velocity.Y < 0 then
                        self.Velocity.Y = self.Velocity.Y + self.Gravity*60*dt
                    end
                end
    
                if self.Floor then -- apply ground deceleration
                    self.Velocity.X = sign(self.Velocity.X) * math.max(math.abs(self.Velocity.X) - self.X_DECELERATION_GROUND*60*dt, 0)
                else -- apply air deceleration
                    self.Velocity.X = sign(self.Velocity.X) * math.max(math.abs(self.Velocity.X) - self.X_DECELERATION_AIR*60*dt, 0)
                end
                -- max velocity
                self.Velocity.X = math.min(math.abs(self.Velocity.X), self.TerminalVelocity.X) * sign(self.Velocity.X)
                self.Velocity.Y = math.min(math.abs(self.Velocity.Y), self.TerminalVelocity.Y) * sign(self.Velocity.Y)
    
                
                self.RotVelocity = math.lerp(self.RotVelocity, 0, 0.03*60*dt)
                self.InternalRotation =  self.InternalRotation + sign(self.RotVelocity)*self.Velocity:Magnitude()*2*dt  -- self.RotVelocity
            else
                self.RotVelocity = 0
                self.InternalRotation = 0
            end
            
            self.InternalDrawScale = self.InternalDrawScale:Lerp(V{1,1}, 0.15*60*dt)
        end,
    
        PutDown = function(self, ownerWasGrounded, ownerYVelocity) -- for when it's placed down gently with crouch
            self.Owner = nil
            self.Velocity = V{0,math.min(0, (ownerYVelocity and ownerYVelocity/2) or 0)}
            self.PickupDebounce = self.FRAMES_BETWEEN_DROP_AND_REGRAB
            if not ownerWasGrounded then
                self.CoyoteFrames = self.COYOTE_FRAMES_AFTER_DROP
            end
        end,
    
        Throw = function (self, ownerWasGrounded)
            self.CoyoteFrames = ownerWasGrounded and self.COYOTE_FRAMES_AFTER_GROUNDED_THROW
                                                  or self.COYOTE_FRAMES_AFTER_AIRBORN_THROW
        end,
    
        RunCollision = function (self, expensive, dt)
            -- normal collision pass
            local pushX, pushY = 0, 0
            local face, surfaceInfo
            local realPushX, realPushY = 0, 0
            local movedAlready
            local ignoreSound
            -- normal collision pass
            if self.Floor and self.Velocity.X == 0 then
                self:ValidateFloor(expensive)
            else
                self:ValidateFloor(expensive)
                local iterator = (expensive or not self.Collider)
                                          and self:CollisionPass(self._parent, true)
                                           or self:CollisionPass(self.Collider, true, false, true)
                
                for solid, hDist, vDist, tileID in iterator do
                    if not solid.Passthrough then
                        surfaceInfo = solid:GetSurfaceInfo(tileID)
                        face = Prop.GetHitFace(hDist,vDist)
                        pushX, pushY = 0,0
                        if solid._parent ~= self.Owner then
                            
                            if (self.Velocity.Y >= 0 and not surfaceInfo.Top.Passthrough and face == "bottom") or (self.Velocity.Y <= 0 and not surfaceInfo.Bottom.Passthrough and face == "top") then
                                pushY = math.abs(pushY) > math.abs(vDist or 0) and pushY or (vDist or 0)
                            end
                            
                            if (self.Velocity.X >= 0 and face == "right" and not surfaceInfo.Left.Passthrough) or (self.Velocity.X <= 0 and face == "left" and not surfaceInfo.Right.Passthrough) then
                                pushX = math.abs(pushX) > math.abs(hDist or 0) and pushX or (hDist or 0)
                            end
                        
                            realPushX, realPushY = pushX, pushY
                        end
                        local tpx, tpy = pushX, pushY
                        if math.abs(pushX) > 4 then pushX = 0 end
                        if math.abs(pushY) > 4 then pushY = 0 end
                        if pushY ~= 0 and math.abs(pushY) <= 4 and (pushX == 0) and self.DebounceY == 0 then
                            
                            self.DebounceY = self.Y_BOUNCE_DELAY
                            self.Position.Y = self.Position.Y + pushY + (1 * sign(pushY))
                            self.RotVelocity = self.RotVelocity + sign(self.Velocity.X)/20
                            movedAlready = true
                            if self.Velocity.Y > 0 and self.Velocity.Y < self.Y_MIN_BOUNCE_HEIGHT then
                                print("Y CASE 1", pushX, pushY, dt)
                                self.Velocity.Y = 0
                                ignoreSound = true
                            elseif not self.Floor then
                                print("Y CASE 2", self.Velocity:ToAngle())
                                self.Velocity.Y = math.min(
                                    -(sign(self.Velocity.Y) * (math.abs(self.Velocity.Y) - self.Y_BOUNCE_HEIGHT_LOSS)),
                                    0
                                )
                            end
                            self.InternalDrawScale.Y = math.clamp(1 - math.abs(self.Velocity.Y)/4, 0.3, 1)
                            
                            if face == "bottom" then
                                self.Floor = solid
                            end
                        end
                        print(tpx, tpy, self.Velocity)
                        if pushX ~= 0 and math.abs(pushX) < 4 and (pushY == 0) and self.DebounceX == 0 then
                            print("X CASE", pushX, pushY)
                            self.InternalDrawScale.X = math.clamp(1 - math.abs(self.Velocity.X)/4, 0.3, 1)
                            self.DebounceX = self.X_BOUNCE_DELAY
                            self.Position.X = self.Position.X + pushX + (1 * sign(pushX))
                            self.Velocity.X = math.abs(self.Velocity.X) * (face=="left" and 1 or face=="right" and -1 or -sign(self.Velocity.X))
                            self.RotVelocity = self.RotVelocity - sign(self.Velocity.Y)/20
                            self.CoyoteFrames = self.COYOTE_FRAMES_AFTER_VERTICAL_BOUNCE
                            movedAlready = true
                        end
                        
                    end
                end
    
            end
            
            -- just give up if corner clipping, tbh
            if math.abs(pushX) > 2 and math.abs(pushY) > 2 and not movedAlready then
                print("whatever", self.Velocity)
                
                self.Position = self.Position - (self.Velocity or V{0,0})*60*dt
                self.Velocity = -self.Velocity
                -- if self.DebounceX == 0 then
                --     self.DebounceX = self.X_BOUNCE_DELAY
                --     self.Velocity.X = -self.Velocity.X
                --     movedAlready = true
                -- end
                -- if self.DebounceY == 0 then
                --     self.DebounceY = self.Y_BOUNCE_DELAY
                --     self.Velocity.Y = -self.Velocity.Y
                --     movedAlready = true
                -- end
                movedAlready = true
                
            end
    
            if movedAlready and not ignoreSound then
                self.SFX.Bounce:SetVolume(math.clamp(self.Velocity:Magnitude()/8, 0.1, 0.3)/10)
                self.SFX.Bounce:Stop()
                self.SFX.Bounce:SetPitch(1 + math.random(-5,5)/45 * 0.5)
                self.SFX.Bounce:Play()
            end
    
            
            return realPushX, realPushY
        end,
    
        ValidateFloor = function (self, expensive)
            self.Position.Y = self.Position.Y + 2
            local foundFloor
    
            local iterator = expensive and self:CollisionPass(self._parent, true)
                                        or self:CollisionPass(self.Floor, true, false, true)
            
            for solid, hDist, vDist, tileID in iterator do
                local surfaceInfo = solid:GetSurfaceInfo(tileID)
                local face = Prop.GetHitFace(hDist,vDist)
    
                if solid == self.Floor and face == "bottom" then
                    foundFloor = true
                end
            end
            if foundFloor then
                
            else
                
                self.Floor = nil
            end
            self.Position.Y = self.Position.Y - 2
        end
    }
    newBall.Texture = Canvas.new((newBall.Size+V{2,2})())
    newBall.Shader = Shader.new("game/assets/shaders/outline.glsl"):Send("step",{1/(newBall.Size.X+2),1/(newBall.Size.Y+2)}) -- 1/ 24 (for tile size) / 12 (for tile count)

    return newBall
end

return Basketball