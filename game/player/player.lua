local Player = {
    -- properties
    Name = "Player",           -- Easy identifier
    AnchorPoint = V{ 0.5, 1 },
    Velocity = V{.3, -1},
    Acceleration = V{0,0.15},
    Visible = true,
    Solid = false,
    Rotation = 0,
    Position = V{50,-50},
    Size = V{24,24},

    MaxSpeed = V{1.2, 3},
    AccelerationSpeed = 0.1,           -- how much the player accelerates per frame to the goal speed
    AirAccelerationSpeed = 0.08,       -- how much the player accelerates per frame in the air
    ForwardDeceleration = 0.2,        -- how much the player speed decreases while idle
    BackwardDeceleration = 0.5,
    IdleDeceleration = 0.2,
    AirBackwardDeceleration = 0.25,     -- how much the player decelerates while in the air, against the movement direction
    AirForwardDeceleration = 0.15,  -- how much the player decelerates while in the air, moving in the same direction
    AirIdleDeceleration = 0.1,     -- how much the player decelerates while idle in the air
    MoveDir = 0,                -- 1 for left, -1 for right, 0 for neutral

    -- vars
    XHitbox = nil,              -- the player's hitbox for walls
    YHitbox = nil,              -- the player's hitbox for ceilings/floors

    Floor = nil,                -- the current Prop acting as the "floor"
    FloorPos = nil,             -- the last recorded floor position (for deltas)
    FloorDelta = nil,           -- the movement of the floor over the past frame (calculated near the start of the update cycle)
    FloorLeftEdge = nil,        -- last recorded left edge of the floor (not tilemaps)
    FloorRightEdge = nil,       -- last recorded right edge of the floor (not tilemaps)
    DistanceAlongFloor = nil,   -- how far the player's position is along the floor (not tilemaps)

    -- input vars
    JustPressed = {},           -- all inputs from the previous frame
    FramesSinceJump = -1,       -- will be -1 if the player is on the ground, or they fell off something without jumping
    FramesSinceGrounded = -1,   -- will be -1 if the player is in the air
    
    -- internal properties
    _super = "Prop",      -- Supertype
    _global = true
}
local EMPTYVEC = V{0,0}

-- the black outline shader
Player.Shader = Shader.new("game/player/outline.glsl"):Send("step",{1/24/12,1/24/12}) -- 1/ 24 (for tile size) / 12 (for tile count)


-- yHitbox is used to detect floors/ceilings
local yHitboxBASE = Prop.new{
    Name = "yHitbox",
    Texture = Texture.new("chexcore/assets/images/square.png"),
    Size = V{8,16},
    Visible = false,
    Color = V{1,0,0,0.2},
    Solid = true,
    AnchorPoint = V{0.5,1}
}
-- xHitbox is used to detect walls
local xHitboxBASE = Prop.new{
    Name = "xHitbox",
    Texture = Texture.new("chexcore/assets/images/square.png"),
    Size = V{8,12},
    Visible = false,
    Color = V{0,0,1,0.2},
    Solid = true,
    AnchorPoint = V{0.5,1}
}

function Player.new()
    local newPlayer = setmetatable({}, Player)
    newPlayer.Texture = Animation.new("chexcore/assets/images/test/player-sprite.png", 12, 12):AddProperties{Duration = .72, LeftBound = 5, RightBound = 10}
    newPlayer.YHitbox = newPlayer:Adopt(yHitboxBASE:Clone())
    newPlayer.XHitbox = newPlayer:Adopt(xHitboxBASE:Clone())
    newPlayer.Position = Player.Position:Clone()
    newPlayer.Size = Player.Size:Clone()
    
    newPlayer.InputListener = Input.new{
        a = "move_left",
        d = "move_right",
        space = "jump",
    }

    newPlayer.LastFrameInputs = {}

    -- attach input to player
    function newPlayer.InputListener:Press(device, key)
        newPlayer.JustPressed[key] = true
    end

    return newPlayer
end

function Player:Decelerate(amt)
    amt = amt or self.BackwardDeceleration
    self.Velocity.X = self.Velocity.X - amt * sign(self.Velocity.X)
    if math.abs(self.Velocity.X) < amt then
        self.Velocity.X = 0
    end
end

----------------------- HITBOX ALIGNMENT FUNCTIONS -------------------------------
function Player:DisconnectFromFloor()
    self.Floor = nil
    self.FloorPos = nil
    self.FloorLeftEdge, self.FloorRightEdge = nil, nil
    self.DistanceAlongFloor = nil
    self.FloorDelta = nil
end

function Player:ConnectToFloor(floor)
    self.Floor = floor
    self.FloorPos = floor.Position:Clone()
    self.FloorLeftEdge = floor:GetEdge("left")
    self.FloorRightEdge = floor:GetEdge("right")
    self.FramesSinceGrounded = 0
    self.DistanceAlongFloor = (self.Position.X - self.FloorLeftEdge) + (self.FloorRightEdge - self.FloorLeftEdge)
    self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Loop = true}
end

function Player:AlignWithFloor()
    self.Position.X = math.floor(self.Position.X) + (self.Floor.Position.X - math.floor(self.Floor.Position.X))
end

function Player:AlignHitboxes()
    local xHitbox = self.XHitbox
    local yHitbox = self.YHitbox

    xHitbox.Position.X = self.Position.X
    xHitbox.Position.Y = self.Position.Y - 2
    yHitbox.Position.X = self.Position.X
    yHitbox.Position.Y = self.Position.Y
end

function Player:FollowFloor()
    if self.Floor then
        if self.FloorPos and self.FloorPos ~= self.Floor.Position then
            if not self.Floor:IsA("Tilemap") then
                self.FloorDelta = self.FloorPos - self.Floor.Position

                self.Position = (self.Position - self.FloorDelta)
                self:SetEdge("bottom", self.Floor:GetEdge("top"))
            else
                self.FloorDelta = self.FloorPos - self.Floor.Position
                self.Position = (self.Position - self.FloorDelta)
                self.Velocity.Y = 0
            end
        end

        self.FloorPos = self.Floor.Position:Clone()
    end
end

------- collison :O
function Player:Unclip()
    -- make sure hitboxes are aligned first!!!
    self:AlignHitboxes()
    local pushY = 0
    for solid, hDist, vDist, tileID in self.YHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)
        -- we check the "sign" of the direction to make sure the player is "moving into" the object before clipping back
        local faceSign = face == "bottom" and 1 or face == "top" and -1 or 0
        if solid ~= self.YHitbox and (face == "top" or face == "bottom") and faceSign == sign(self.Velocity.Y) then
            self.Velocity.Y = 0
            pushY = math.abs(pushY) > math.abs(vDist) and pushY or vDist
            if face == "bottom" then
                self:ConnectToFloor(solid)
            end
            self:AlignHitboxes()
        end
        
    end
    self.Position.Y = self.Position.Y + pushY

    local pushX = 0
    for solid, hDist, vDist, tileID in self.XHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)
        if solid ~= self.XHitbox and (face == "left" or face == "right") then
            self.Velocity.X = 0
            pushX = math.abs(pushX) > math.abs(hDist) and pushX or hDist
            self:AlignHitboxes()
        end
        
    end
    self.Position.X = self.Position.X + pushX
end

function Player:ValidateFloor()
    if self.Floor then
        -- check if we've collided with the current floor or not
        self.YHitbox.Position.X = self.Position.X
        self.YHitbox.Position.Y = self.Position.Y + 1
        
        self.Velocity.Y = 0

        local hit, hDist, vDist = self.Floor:CollisionInfo(self.YHitbox)
        if not hit then
            self:DisconnectFromFloor()
            
            self.Texture.Clock = 0
        end
    end
end
---------------------------------------------------------------------------------

------------------------ INPUT PROCESSING -----------------------------
function Player:ProcessInput()
    local input = self.InputListener
    
    -- jump input
    if self.JustPressed["jump"] and self.Floor then
        if self.FloorDelta then
            -- inherit the velocity of the floor object
            local amt = math.floor(self.FloorDelta.X*2+0.5)
            if math.abs(amt) > 1 then
                if sign(amt) == self.MoveDir then
                    -- player is moving against the direction of the floor - give them some leeway
                    self.Velocity.X = self.Velocity.X - amt/3
                else
                    self.Velocity.X = self.Velocity.X - amt
                end
                
            end
        end
        self:DisconnectFromFloor()
        self.Velocity.Y = -3
        self.FramesSinceJump = 0
    end
    
    self.MoveDir = (input:IsDown("move_left") and -1 or 0) + (input:IsDown("move_right") and 1 or 0)
    if self.MoveDir ~= 0 then
        
        local accelSpeed = self.Floor and self.AccelerationSpeed or self.AirAccelerationSpeed

        self.Acceleration.X = self.MoveDir*accelSpeed
        
        
    else
        -- connect to floor while idle
        if self.Floor and (not self.FloorDelta or self.FloorDelta ~= EMPTYVEC) then
            self:AlignWithFloor()
            
        end
        
        self.Acceleration.X = 0
    end
end

-- Animation picking
function Player:UpdateAnimation()
    if self.Floor then
        if self.MoveDir == 0 then
            -- idle anim
            self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Duration = 1, PlaybackScaling = 1, IsPlaying = true, Loop = true}
        else
            -- run anim
            self.DrawScale.X = self.MoveDir
            self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 3 - math.abs(self.Velocity.X)*1.25, IsPlaying = true}
        end
    else -- no floor; in air
        if self.FramesSinceJump == 0 then
            -- just jumped
            self.Texture:AddProperties{LeftBound = 25, RightBound = 28, Duration = 0.4, PlaybackScaling = 1, Loop = false, Clock = 0}
        elseif self.FramesSinceJump == -1 then
            -- just falling
            self.Texture:AddProperties{LeftBound = 27, RightBound = 28, Duration = 0.4, PlaybackScaling = 1, Loop = false}
        end
    end
end

function Player:UpdateFrameValues()
    if self.Floor then
        self.FramesSinceJump = -1
        if self.FramesSinceGrounded > -1 then
            self.FramesSinceGrounded = self.FramesSinceGrounded + 1
        end
    else -- no floor
        self.FramesSinceGrounded = -1
        if self.FramesSinceJump > -1 then
            self.FramesSinceJump = self.FramesSinceJump + 1
        end
    end
end

-- physics updates
local min, max = math.min, math.max
function Player:UpdatePhysics()
    -- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
    self.Position = self.Position + self.Velocity
    self.Velocity = self.Velocity + self.Acceleration

    local decelGoal = math.abs(self.MoveDir) > 0 and self.MaxSpeed.X or 0
    local speedOver = math.abs(self.Velocity.X) - decelGoal
    if speedOver > 0 then
        -- player is moving faster than the maximum horizontal speed
        if self.Floor then
            -- player is running; slow down at ground speed
            if self.MoveDir == 0 then
                -- player is idle
                
                self:Decelerate(self.IdleDeceleration)
            elseif sign(self.Velocity.X) == self.MoveDir then
                -- player is moving "with" the direction of their momentum; don't slow down as much
                self:Decelerate(self.ForwardDeceleration)
            else
                -- player is against the direction of momentum; normal deceleration
                self:Decelerate(self.BackwardDeceleration)
            end
        else
            -- player is in the air
            if self.MoveDir == 0 then
                -- player is idle
                self:Decelerate(self.AirIdleDeceleration)
            elseif sign(self.Velocity.X) == self.MoveDir then
                -- player is moving "with" the direction of their momentum; don't slow down as much
                self:Decelerate(self.AirForwardDeceleration)
            else
                -- player is against the direction of momentum; normal deceleration
                self:Decelerate(self.AirBackwardDeceleration)
            end
        end
        if math.abs(self.Velocity.X) < decelGoal then
            -- speed was fully "capped" and should be set as such
            self.Velocity.X = decelGoal * sign(self.Velocity.X)
        end
    end

    -- self.Velocity.X = min(max(self.Velocity.X, -self.MaxSpeed.X), self.MaxSpeed.X)
    self.Velocity.Y = min(max(self.Velocity.Y, -self.MaxSpeed.Y), self.MaxSpeed.Y)

end

------------------------ MAIN UPDATE LOOP -----------------------------
function Player:Update(dt)
    ------------------- PHYSICS PROCESSING ----------------------------------
    -- if we're on a moving floor let's move with it
    self:FollowFloor()

    -- update position based on velocity, velocity based on acceleration, etc
    self:UpdatePhysics()

    -- make sure collision is all good
    self:Unclip()

    -- confirm the floor remains the floor
    self:ValidateFloor()

    -- listen for inputs here
    self:ProcessInput()

    -- set the proper animation state
    self:UpdateAnimation()

    -- update frame values like FramesSinceJump and FramesSinceGrounded
    self:UpdateFrameValues()

    -- flush input buffer at the end (in case anyone other than ProcessInput was sneakily looking at inputs)
    for k, _ in pairs(self.JustPressed) do
        self.JustPressed[k] = false
    end
end

function Player:Draw(tx, ty)
    -- make sure hitboxes are re-aligned with player after position updates
    self:AlignHitboxes()

    Prop.Draw(self, tx, ty)
end

return Player