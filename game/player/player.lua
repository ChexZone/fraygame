local Player = {
    -- properties
    Name = "Player",
    AnchorPoint = V{ 0.5, 1 },
    Velocity = V{0, 0},
    Acceleration = V{0,0},
    Visible = true,
    Solid = false,
    Rotation = 0,
    Position = V{80,-50},
    Size = V{24,24},

    VelocityLastFrame = V{0,0},         -- the velocity of the player the previous frame (valid after Player:UpdatePhysics())

    MaxSpeed = V{6, 6},                 -- the absolute velocity caps (+/-) of the player
    RunSpeed = 1.2,                     -- how fast the player runs by default
    Gravity = 0.15,                     -- how many pixels the player falls per frame
    JumpGravity = 0.14,                 -- how many pixels the player falls per frame while in the upward arc of a jump
    AfterJumpGravity = 0.5,             -- the gravity of the player in the upward jump arc after jump has been released
    TerminalVelocity = 3.5,             -- how many units per frame the player can fall
    HangTime = 3,                       -- how many frames of hang time are afforded in the jump arc
    HalfHangTime = 1,                   -- how many frames of hang time are afforded for medium-height jumps
    HangTimeActivationTime = 16,        -- how many frames the player must hold jump before they are owed hang time
    HalfHangTimeActivationTime = 10,    -- activation energy for half hang time (medium-height jumps)
    DropHangTime = 3,                   -- how many frames of hang time are offered from falling off the side of a platform
    HangStatus = 0,                     -- tracker for the status of hang time
    JumpPower = 3,                      -- the base initial upward momentum of a jump
    RollPower = 4.5,
    RollLength = 14,
    AccelerationSpeed = 0.1,            -- how much the player accelerates per frame to the goal speed
    AirAccelerationSpeed = 0.08,        -- how much the player accelerates per frame in the air
    ForwardDeceleration = 0.2,          -- how much the player speed decreases while idle on the ground
    BackwardDeceleration = 0.5,         -- how fast the player speed decreases while "braking" on the ground
    IdleDeceleration = 0.2,             -- how fast the player halts to a stop while idle on the ground
    AirBackwardDeceleration = 0.25,     -- how much the player decelerates while in the air, against the movement direction
    AirForwardDeceleration = 0.15,      -- how much the player decelerates while in the air, moving in the same direction
    AirIdleDeceleration = 0.1,          -- how much the player decelerates while idle in the air
    MoveDir = 0,                        -- 1 for left, -1 for right, 0 for neutral

    CoyoteFrames = 6,                   -- when running off the side of an object, you get this many frames to jump
    CoyoteBuffer = 0,                   -- how many coyote frames are remaining
    JumpFrames = 4,                     -- how many frames after a jump input can still result in a jump
    JumpBuffer = 0,                     -- how many jump frames are currently remaining
    ActionFrames = 5,                   -- how many frames after an action input can still result in action
    ActionBuffer = 0,                   -- how many action frames are currently remaining

    -- vars
    XHitbox = nil,                      -- the player's hitbox for walls
    YHitbox = nil,                      -- the player's hitbox for ceilings/floors

    Floor = nil,                        -- the current Prop acting as the "floor"
    FloorPos = nil,                     -- the last recorded floor position (for deltas)
    FloorDelta = nil,                   -- the movement of the floor over the past frame (calculated near the start of the update cycle)
    FloorLeftEdge = nil,                -- last recorded left edge of the floor (not tilemaps)
    FloorRightEdge = nil,               -- last recorded right edge of the floor (not tilemaps)
    DistanceAlongFloor = nil,           -- how far the player's position is along the floor (not tilemaps)

    -- input vars
    JustPressed = {},                   -- all inputs from the previous frame
    FramesSinceJump = -1,               -- will be -1 if the player is on the ground, or they fell off something without jumping
    FramesSinceGrounded = -1,           -- will be -1 if the player is in the air
    FramesSinceRoll = -1,               -- will be -1 if the player is not in a roll state

    -- internal properties
    _super = "Prop",
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
        lshift = "action"
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
    
    -- we actually don't do this until later; FloorDelta is set to nil once there are no more coyote frames (in UpdateFrameValues)
    -- self.FloorDelta = nil
end

function Player:ConnectToFloor(floor)
    self.Floor = floor
    self.FloorPos = floor.Position:Clone()
    self.FloorLeftEdge = floor:GetEdge("left")
    self.FloorRightEdge = floor:GetEdge("right")
    self.FramesSinceGrounded = 0
    self.DistanceAlongFloor = (self.Position.X - self.FloorLeftEdge) + (self.FloorRightEdge - self.FloorLeftEdge)
    -- self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Loop = true}
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

    -- try to "undo" if the player clipped too hard
    if math.abs(pushY) > self.Size.Y/2 then
        self.Position.Y = self.Position.Y - self.VelocityLastFrame.Y
    else
        self.Position.Y = self.Position.Y + pushY
    end
    

    local pushX = 0
    for solid, hDist, vDist, tileID in self.XHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)
        if solid ~= self.XHitbox and (face == "left" or face == "right") then
            self.Velocity.X = 0
            pushX = math.abs(pushX) > math.abs(hDist) and pushX or hDist
            self:AlignHitboxes()
        end
        
    end

    -- again, try to "undo" and extreme clipping
    if math.abs(pushX) > self.Size.X/2 then
        self.Position.X = self.Position.X - self.VelocityLastFrame.X
    else
        self.Position.X = self.Position.X + pushX
    end
end

function Player:ValidateFloor()
    if self.Floor then
        -- check if we've collided with the current floor or not
        self.YHitbox.Position.X = self.Position.X
        self.YHitbox.Position.Y = self.Position.Y + 1
        
        self.Velocity.Y = 0

        local hit, hDist, vDist = self.Floor:CollisionInfo(self.YHitbox)
        if not hit then
            if self.FloorDelta then
                -- inherit some velocity of the floor object
                local amt = math.floor(self.FloorDelta.X*2+0.5)
                if math.abs(amt) > 1 then
                    if -sign(amt) == self.MoveDir then
                        self.Velocity.X = self.Velocity.X - amt/2
                    end
                end
            end
            self:DisconnectFromFloor()
            if self.FramesSinceRoll == -1 then
                self.Texture.Clock = 0
            end
            self.HangStatus = self.DropHangTime+1
            -- set up coyote frames
            self.CoyoteBuffer = self.CoyoteFrames
        end
    end
end
---------------------------------------------------------------------------------

------------------------ INPUT PROCESSING -----------------------------
function Player:ProcessInput()
    local input = self.InputListener

    -- jump input
    if self.JustPressed["jump"] then
        -- let the jump input linger for a few frames in case player inputs early
        self.JumpBuffer = self.JumpFrames
    end

    if self.JumpBuffer > 0 and (self.Floor or self.CoyoteBuffer > 0) then
        self:Jump()
    end

    -- action input
    if self.JustPressed["action"] then
        -- let the action input linger for a few frames in case player inputs early
        self.ActionBuffer = self.ActionFrames
    end

    if self.ActionBuffer > 0 and (self.Floor or self.CoyoteBuffer > 0) and self.FramesSinceRoll == -1 then
        -- roll
        self.Velocity.X = sign(self.DrawScale.X) * self.RollPower
        self.FramesSinceRoll = 0
        self.ActionBuffer = 0
        self.Texture.Clock = 0
        self.Texture.IsPlaying = true
    end

    -- left/right input
    self.MoveDir = (input:IsDown("move_left") and -1 or 0) + (input:IsDown("move_right") and 1 or 0)
    if self.MoveDir ~= 0 then
        local accelSpeed = self.Floor and self.AccelerationSpeed or self.AirAccelerationSpeed
        self.Acceleration.X = self.MoveDir*accelSpeed
    else
        -- connect to floor while idle
        if self.Floor and self.FloorDelta and self.FloorDelta ~= EMPTYVEC and self.Velocity.X == 0 then
            self:AlignWithFloor()
        end
        
        self.Acceleration.X = 0
    end
end

function Player:Jump()
    self.JumpBuffer = 0
    self.Velocity.Y = -self.JumpPower
    self.FramesSinceJump = 0
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

        -- give some height if the dy is up
        if self.FloorDelta.Y > 0.5 then
            self.Velocity.Y = self.Velocity.Y - self.FloorDelta.Y
        end
    end
    if self.FramesSinceRoll == 0 then
        self.Texture.Clock = 0 -- reset jump animation
    end
    self:DisconnectFromFloor()
end


-- Animation picking
function Player:UpdateAnimation()
    if self.FramesSinceRoll > -1 and self.FramesSinceRoll ~= self.RollLength then
        -- player is in a roll (regardless of air state)
        if self.Floor then
            self.Texture:AddProperties{LeftBound = 25, RightBound = 27, Duration = 1/60*self.RollLength, PlaybackScaling = 1, Loop = false}
        else
            -- this animation is 1px up to make the black outline work
            self.Texture:AddProperties{LeftBound = 37, RightBound = 39, Duration = 1/60*self.RollLength, PlaybackScaling = 1, Loop = false}
        end
    elseif self.Floor then
        -- player is grounded
        if self.MoveDir == 0 then
            -- idle anim
            self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Duration = 1, PlaybackScaling = 1, IsPlaying = true, Loop = true}
        else
            -- run anim
            self.DrawScale.X = self.MoveDir
            if math.abs(self.Velocity.X) <= 1.5 then
                self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 3 - math.abs(self.Velocity.X)*1.25, IsPlaying = true, Loop = true}
            else
                self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 1 + math.abs(self.Velocity.X)*0.25, IsPlaying = true, Loop = true}
            end
        end
    else -- no floor; in air
        if self.FramesSinceJump == 0 then
            -- just jumped
            self.Texture:AddProperties{LeftBound = 13, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false, Clock = 0}
        elseif self.FramesSinceJump == -1 then
            -- just falling
            self.Texture:AddProperties{LeftBound = 15, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false}
        else
            -- middle of jump state
            self.Texture:AddProperties{LeftBound = 13, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false}
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

    if self.FramesSinceRoll > -1 then
        self.FramesSinceRoll = self.FramesSinceRoll + 1
        if self.FramesSinceRoll > self.RollLength then
            self.FramesSinceRoll = -1
            self.Texture.Clock = 0
            -- self.Texture.IsPlaying = true
        end
    end

    if self.CoyoteBuffer > 0 then
        self.CoyoteBuffer = self.CoyoteBuffer - 1
    elseif self.FloorDelta then
        -- reset floor delta at the end of coyote time
        self.FloorDelta = nil
    end

    if self.JumpBuffer > 0 then
        self.JumpBuffer = self.JumpBuffer - 1
    end

    if self.ActionBuffer > 0 then
        self.ActionBuffer = self.ActionBuffer - 1
    end

    if self.HangStatus > 0 then
        self.HangStatus = self.HangStatus - 1
    end
end

-- physics updates
local min, max = math.min, math.max
function Player:UpdatePhysics()

    
    -- gravity is dependent on the jump state of the character
    if self.HangStatus > 0 and self.Velocity.Y >= 0 then
        -- the player is owed hang time
        
        self.Velocity.Y = 0
    elseif self.FramesSinceJump > -1 then
        -- the player is in the air from a jump
        if self.InputListener:IsDown("jump") then
            
            -- the player is still holding jump and should get maximum height
            if self.Velocity.Y < 0 then
                -- player is moving upwards
                self.Velocity.Y = self.Velocity.Y + self.JumpGravity

                if self.Velocity.Y > 0 then
                    -- give the player a couple grace frames
                    self.Velocity.Y = 0
                    self.HangStatus = self.HangTime+1 -- + 1 because the update function decreases it
                end
            else
                -- player is moving down
                self.Velocity.Y = self.Velocity.Y + self.Gravity
            end
        else
            -- the player jumped but isn't holding jump anymore
            if self.Velocity.Y < 0 then
                -- end the jump arc immediately
                self.Velocity.Y = self.Velocity.Y + self.AfterJumpGravity

                -- check if we crossed the velocity threshold
                if self.Velocity.Y > 0 then
                    -- give the player a couple grace frames
                    

                    -- in this case, only give hang time if the jump was beyond a threshold of frames long
                    if self.FramesSinceJump >= self.HangTimeActivationTime then
                        -- jump was high enough to deserve full hang time
                        self.Velocity.Y = 0
                        self.HangStatus = self.HangTime+1 -- + 1 because the update function decreases it
                    elseif self.FramesSinceJump >= self.HalfHangTimeActivationTime then
                        -- jump deserves some hang time, but not as much
                        self.Velocity.Y = 0
                        self.HangStatus = self.HalfHangTime+1 -- + 1 because the update function decreases it
                    end
                end
            else
                -- regular gravity
                self.Velocity.Y = self.Velocity.Y + self.Gravity
            end
        end
    else
        self.Velocity.Y = self.Velocity.Y + self.Gravity
    end
    

    
    local decelGoal = math.abs(self.MoveDir) > 0 and self.RunSpeed or 0
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


    -- account for gravity
    if self.Velocity.Y > self.TerminalVelocity then
        self.Velocity.Y = self.TerminalVelocity
    end

    -- adhere to MaxSpeed

    -- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
    self.Position = self.Position + self.Velocity
    self.VelocityLastFrame = self.Velocity -- other guys use this later
    self.Velocity = self.Velocity + self.Acceleration
    
    self.Velocity.X = min(max(self.Velocity.X, -self.MaxSpeed.X), self.MaxSpeed.X)
    self.Velocity.Y = min(max(self.Velocity.Y, -self.MaxSpeed.Y), self.MaxSpeed.Y)
end

------------------------ MAIN UPDATE LOOP -----------------------------
function Player:Update(dt)
    ------------------- PHYSICS PROCESSING ----------------------------------
    -- if we're on a moving floor let's move with it
    self:FollowFloor()

    -- listen for inputs here
    self:ProcessInput()

    

    -- update position based on velocity, velocity based on acceleration, etc
    self:UpdatePhysics()

    

    -- make sure collision is all good
    self:Unclip()

    -- confirm the floor remains the floor
    self:ValidateFloor()

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