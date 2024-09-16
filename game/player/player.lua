local Player = {
    -- inherited properties
    Name = "Player",
    AnchorPoint = V{ 0.5, 1 },
    Velocity = V{0, 0},
    Acceleration = V{0,0},
    Color = V{1,1,1,1},
    TailColor = V{196,223,238}/255,
    Visible = true,
    Solid = false,
    Rotation = 0,
    Position = V{80,-50},
    Size = V{24,24},

    FramesSinceInit = 0,                -- how many frames since the Player object was created

    VelocityLastFrame = V{0,0},         -- the velocity of the player the previous frame (valid after Player:UpdatePhysics())

    MaxSpeed = V{8, 6},                 -- the absolute velocity caps (+/-) of the player
    RunSpeed = 1.5,                     -- how fast the player runs by default
    Gravity = 0.15,                     -- how many pixels the player falls per frame
    JumpGravity = 0.14,                 -- how many pixels the player falls per frame while in the upward arc of a jump
    AfterDoubleJumpGravity = 0.2,
    TrailLength = 1,                    -- (range 0-1) how long the trail should be
    TrailColor = V{190/255, 140/255, 100/255, 0.4} + 0.3 ,       -- color of trail following player
    CrouchTime = 0,                     -- how many frames the player has been crouching for (0 if not crouching)
    TimeSinceCrouching = 0,             -- how many frames since the player last ended a crouch
    CrouchEndBuffer = 0,                -- for animations, pretty much
    CrouchDecelerationNeutral = 0.085,      -- how fast to decelerate the player to zero in a neutral crouch
    CrouchDecelerationForward = 0.085,      -- how fast to decelerate the player to zero holding the velocity direction
    CrouchDecelerationBackward = 0.15,     -- how fast to decelerate the player to zero holding against the velocity direction
    ImmediateJumpWindow = 7,            -- how many frames after a jump is considered "immediate jump"
    ImmediatelyAfterJumpGravity = 1,       -- the gravity of the player in the upward jump arc after the player releases jump and they've been in the air more than ImmediateJumpWindow frames
    AfterJumpGravity = 0.5,            -- the gravity of the player in the upward jump arc after jump has been released
    AfterPounceCancelGravity = 1,     -- the gravity of the player in the upward pounce arc after jump has been released 
    ImmediatelyAfterPounceCancelGravity = 1.25,-- the gravity of the player in the upward pounce arc after jump has been released immediately after being pressed
    TerminalVelocity = 3.5,             -- how many units per frame the player can fall
    HangTime = 3,                       -- how many frames of hang time are afforded in the jump arc
    HalfHangTime = 1,                   -- how many frames of hang time are afforded for medium-height jumps
    DoubleJumpHangTime = 3,             -- how many frames of hang time are afforded for double jumps
    HangTimeActivationTime = 16,        -- how many frames the player must hold jump before they are owed hang time
    HalfHangTimeActivationTime = 10,    -- activation energy for half hang time (medium-height jumps)
    DropHangTime = 3,                   -- how many frames of hang time are offered from falling off the side of a platform
    HangStatus = 0,                     -- tracker for the status of hang time
    JumpPower = 3.5,                      -- the base initial upward momentum of a jump
    DoubleJumpFrameLength = 12,         -- how many frames a double jump takes
    DoubleJumpPower = 3,                -- the base initial upward momentum of a double jump
    DoubleJumpRequiredHeightFromGround = 5, -- number of pixels off the ground the player must be to be eligible to double jump
    DoubleJumpStoredSpeed = 0,          -- how fast the player was moving horizontally when they double jumped
    TimeSincePounce = -1,                -- how many frames since the player last "pounced" (crouch + roll + jump)
    TimeAfterPounceCanDoubleJump = 5,   -- how many frames after a sideways pounce the player is allowed to double jump
    RollWindowPastJump = 3,             -- how many frames after jumping will an action input still result in a hold
    CrouchAnimBounds = V{40, 44},       -- the current bounds of the crouch animation (so it change)
    CrouchShimmyDelay = 0,              -- how many frames after crouching will pressing the action button still do a roll?
    LastRollPower = 0,                  -- records the last RollPower used for the previous roll\
    ShimmyPower = 3,                   -- how much RollPower the player gets while crouching
    RollPower = 4.5,                    -- the player's X velocity on the first frame of a roll
    PouncePower = 5.5,                  -- the X velocity out of a sideways pounce
    PounceHeight = 2.2,                 -- the upward Y velocity out of a sideways pounce 
    RollLength = 14,                    -- how long the player must wait after a roll before rolling again (how many frames the roll animation lasts) 
    ShimmyLength = 5,                   -- how long the player must wait after a shimmy before shimmying again
    AccelerationSpeed = 0.12,            -- how much the player accelerates per frame to the goal speed
    AirAccelerationSpeed = 0.08,        -- how much the player accelerates per frame in the air
    PounceAccelerationSpeed = 0.155,      -- how much the player accelerates per frame during a pounce
    ForwardDeceleration = 0.2,          -- how much the player speed decreases while moving forward
    BackwardDeceleration = 0.7,         -- how fast the player speed decreases while "braking" on the ground
    IdleDeceleration = 0.2,             -- how fast the player halts to a stop while idle on the ground
    AirBackwardDeceleration = 0.25,     -- how much the player decelerates while in the air, against the movement direction
    AirForwardDeceleration = 0.2,      -- how much the player decelerates while in the air, moving in the same direction
    AirIdleDeceleration = 0.2,          -- how much the player decelerates while idle in the air
    PounceForwardDeceleration = 0.25,   -- how much the player accelerates while in a pounce
    PounceIdleDeceleration = 0.16,   -- how mucgh the player decelerates while idle in a pounce
    PounceBackwardDeceleration = 0.25, -- how much the player decelerates while moving backwards in a pounce
    ConsecutivePouncesSpeedMult = 1.75, -- how much the player's speed is multiplied by during a new pounce (basically, how easily the player can speed up doing chained pounces)
    MoveDir = 0,                        -- 1 for left, -1 for right, 0 for neutral

    FramesSinceFlippedDirection = 0,   -- reset to 0 every time sign(DrawScale.X) changes
    LastFaceDirection = 0,             -- last recorded facing direction ( sign(DrawScale.X) )

    -- "safe ground" system for scenes to use
    LastPosition = nil,                 -- the previous frame's Position
    IdleStreak = 0,                     -- how many frames the player has been in the same Position
    POSITION_SAFETY_THRESHOLD = 30, -- how large IdleStreak must become to replace LastSafePosition
    LastSafePosition = nil,             -- ideally, a safe place to put the player back in.

    FramesSinceRespawn = 0,             -- resets to 0 each time the player is respawned (from falling) 


    CoyoteFrames = 6,                   -- when running off the side of an object, you get this many frames to jump
    CoyoteBuffer = 0,                   -- how many coyote frames are remaining
    JumpFrames = 4,                     -- how many frames after a jump input can still result in a jump
    JumpBuffer = 0,                     -- how many jump frames are currently remaining
    DJMomentumCancelOpportunity = 8,    -- how many frames after a double jump the player can release either direction and cancel momentum
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
    VelocityBeforeHittingGround = 0,    -- the Y velocity of the player the frame they made contact with the floor

    -- input vars
    JustPressed = {},                   -- all inputs from the previous frame
    FramesSinceJump = -1,               -- will be -1 if the player is on the ground, or they fell off something without jumping
    FramesSinceDoubleJump = -1,         -- will be -1 if the player is grounded, or in the air and hasn't double jumped
    FramesSinceGrounded = -1,           -- will be -1 if the player is in the air
    FramesSinceRoll = -1,               -- will be -1 if the player is not in a roll state
    FramesSinceMoving = -1,             -- will be -1 if the player is currently idle
    FramesSinceIdle = -1,               -- will be -1 if the player is currently moving

    -- other stuff
    Canvas = nil,                       -- rendering the player is hard
    CanvasSize = V{128, 128, 0.25},
    TailPoints = nil,                   -- keeps track of where segments of the tail have been
    TailLength = 9,                     -- amount of tail segments to record
    TailVisibleLength = 4,              -- actual drawn length
    

    -- internal properties
    _usingPerformanceMode = false,  -- the GameScene controls whether PerformanceMode is on. Player just listens. 
    _updateStep = false,    -- internally used for performance mode handling
    _super = "Prop",
    _global = true
}
local EMPTYVEC = V{0,0}

-- the black outline shader
Player.Shader = Shader.new("game/player/outline.glsl"):Send("step",{1/Player.CanvasSize.X,1/Player.CanvasSize.Y}) -- 1/ 24 (for tile size) / 12 (for tile count)


local Y_HITBOX_HEIGHT = 16
local X_HITBOX_HEIGHT = 12
local Y_HITBOX_HEIGHT_CROUCH = 8
local X_HITBOX_HEIGHT_CROUCH = 6

-- yHitbox is used to detect floors/ceilings
local yHitboxBASE = Prop.new{
    Name = "yHitbox",
    Texture = Texture.new("chexcore/assets/images/square.png"),
    Size = V{8,Y_HITBOX_HEIGHT},
    Visible = false,
    Color = V{1,0,0,0.2},
    Solid = true,
    AnchorPoint = V{0.5,1}
}
-- xHitbox is used to detect walls
local xHitboxBASE = Prop.new{
    Name = "xHitbox",
    Texture = Texture.new("chexcore/assets/images/square.png"),
    Size = V{8,X_HITBOX_HEIGHT},
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
    newPlayer.Canvas = Canvas.new(Player.CanvasSize())
    newPlayer.TailPoints = {}
    
    newPlayer.InputListener = Input.new{
        a = "move_left",
        d = "move_right",
        space = "jump",
        lshift = "action",
        s = "crouch",

        h = "HITBOXTOGGLE",
        j = "SLOWMODETOGGLE",
        p = "PERFORMANCEMODETOGGLE"
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
    if not self.Floor then
        self.VelocityBeforeHittingGround = self.Velocity.Y
        self.FramesSinceGrounded = 0
    end
    self.Floor = floor
    self.FloorPos = floor.Position:Clone()
    self.FloorLeftEdge = floor:GetEdge("left")
    self.FloorRightEdge = floor:GetEdge("right")
    
    self.Position.Y = math.floor(self.Position.Y)
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

------- collison function
function Player:Unclip()
    
    if self.Floor then
        self.Position.Y = self.Position.Y + 1
    end

    -- make sure hitboxes are aligned first!!!
    self:AlignHitboxes()
    local pushY = 0
    for solid, hDist, vDist, tileID in self.YHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)
        -- we check the "sign" of the direction to make sure the player is "moving into" the object before clipping back
        local faceSign = face == "bottom" and 1 or face == "top" and -1 or 0
        if solid ~= self.YHitbox and (faceSign == sign(self.Velocity.Y +0.01) or face == "none") then
            -- self.Velocity.Y = 0
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
        self.Position.Y = self.Position.Y + pushY - sign(pushY) * 0.01
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

    -- again, try to "undo" any extreme clipping
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
                local amt = math.floor(self.FloorDelta.X*2+0.5) / (self._usingPerformanceMode and 2 or 1)
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

    if self.JustPressed["HITBOXTOGGLE"] then
        self.XHitbox.Visible = not self.XHitbox.Visible
        self.YHitbox.Visible = not self.YHitbox.Visible
        self:GetLayer():GetParent().GuiLayer:GetChild("StatsGui").Visible = not self:GetLayer():GetParent().GuiLayer:GetChild("StatsGui").Visible
    end

    if self.JustPressed["PERFORMANCEMODETOGGLE"] then
        self:GetLayer():GetParent().PerformanceMode = not self:GetLayer():GetParent().PerformanceMode
    end

    if self.JustPressed["SLOWMODETOGGLE"] then
        if _G.TRUE_FPS then
            _G.TRUE_FPS = nil
        else
            _G.TRUE_FPS = 5
        end
    end

    -- crouch input
    if self.CrouchTime == 0 and self.InputListener:IsDown("crouch") and self.Floor and (self.FramesSinceRoll == -1 or self.FramesSinceRoll == 12) then
        self:StartCrouch()
    end
    
    -- print("SPEED:",self.Velocity.X)

    -- action input
    if self.JustPressed["action"] then
        -- let the action input linger for a few frames in case player inputs early
        self.ActionBuffer = self.ActionFrames
    end

    -- print(self.FramesSinceJump, self.RollWindowPastJump)
    local blockJump
    if self.ActionBuffer > 0 and (self.Floor or self.CoyoteBuffer > 0 or (self.FramesSinceJump > -1 and self.FramesSinceJump < self.RollWindowPastJump)) and ((self.CrouchTime > self.CrouchShimmyDelay and (self.FramesSinceRoll == -1 or self.FramesSinceRoll >= self.ShimmyLength)) or self.FramesSinceRoll == -1) then
        -- roll
        local movementPower = (self.CrouchTime > self.CrouchShimmyDelay or self.TimeSinceCrouching < 10) and self.ShimmyPower or self.RollPower
        self.LastRollPower = movementPower

        
        

        if self.CrouchTime > 0 then
            self.Velocity.X = sign(self.DrawScale.X) * math.max(movementPower, math.abs(self.Velocity.X) * self.ConsecutivePouncesSpeedMult)
        else
            self.Velocity.X = sign(self.DrawScale.X) * movementPower
        end
        
        self:ShrinkHitbox()

        self.FramesSinceRoll = 0
        
        if self.InputListener:IsDown("jump") and self.FramesSinceJump <= self.RollWindowPastJump and self.TimeSinceCrouching < 5 then
            -- rolled a few frames late after a jump - initiate a pounce instead
            blockJump = true
            
            self:Jump()
        end

        
        self.ActionBuffer = 0
        self.Texture.Clock = 0
        self.Texture.IsPlaying = true
    end


        -- jump input
        if self.JustPressed["jump"] then
            -- let the jump input linger for a few frames in case player inputs early
            self.JumpBuffer = self.JumpFrames
        end
    
        if self.JumpBuffer > 0 and not blockJump then
            if (self.Floor or self.CoyoteBuffer > 0) then
                self:Jump()
                
            elseif self.FramesSinceDoubleJump == -1 and (self.TimeSincePounce == -1 or self.TimeSincePounce > self.TimeAfterPounceCanDoubleJump)  then
                
                self:DoubleJump()
            end
        end


    -- left/right input
    self.MoveDir = (input:IsDown("move_left") and -1 or 0) + (input:IsDown("move_right") and 1 or 0)

    if self.CrouchTime > 0 and self.Floor then
        -- crouching; shouldnt move
        self.Acceleration.X = 0
        
        local amt
        if self.MoveDir == 0 then -- holding neutral
            amt = self.CrouchDecelerationNeutral
        elseif sign(self.Velocity.X) == self.MoveDir then -- holding sliding direction
            amt = self.CrouchDecelerationForward
        else -- holding against sliding direction
            amt = self.CrouchDecelerationBackward
        end
        self:SetBodyOrientation(self.MoveDir)
        -- self.DrawScale.X = self.MoveDir == 0 and self.DrawScale.X or self.MoveDir
        self:Decelerate(amt)

    elseif self.MoveDir ~= 0 then
        local accelSpeed = self.Floor and self.AccelerationSpeed or 
                            (self.TimeSincePounce > -1 and self.PounceAccelerationSpeed or self.AirAccelerationSpeed)
        self.Acceleration.X = self.MoveDir*accelSpeed

        if self.FramesSinceDoubleJump > -1 and self.FramesSinceDoubleJump <= self.DJMomentumCancelOpportunity then
            if self.FramesSinceMoving == 0 then
                self.Velocity.X = self.DoubleJumpStoredSpeed * self.MoveDir
            elseif self.MoveDir == -self:GetBodyOrientation() then
                self.Velocity.X = -self.Velocity.X
                self:SetBodyOrientation(self.MoveDir)
            end
        end
    else
        -- connect to floor while idle
        if self.Floor and self.FloorDelta and self.FloorDelta ~= EMPTYVEC and self.Velocity.X == 0 then
            self:AlignWithFloor()
        end
        
        -- no goal direction in this state
        self.Acceleration.X = 0

        if self.FramesSinceDoubleJump > -1 and self.FramesSinceDoubleJump <= self.DJMomentumCancelOpportunity then
            self.Velocity.X = 0
        end
    end
end

function Player:Jump()
    self.JumpBuffer = 0
    self.Velocity.Y = -self.JumpPower
    
    -- pounce  handling
    if (self.FramesSinceRoll > -1 or (self.FramesSinceJump > -1 and self.FramesSinceJump <= self.RollWindowPastJump)) and self.LastRollPower == self.ShimmyPower then
        self.Velocity.X = sign(self.Velocity.X) * math.max(self.PouncePower, math.abs(self.Velocity.X))
        self.Velocity.Y = sign(self.Velocity.Y) * self.PounceHeight
        self.TimeSincePounce = 0
        self.FramesSinceRoll = -1
    end

    self.FramesSinceJump = 0
    
    if self.FloorDelta then
        -- inherit the velocity of the floor object
        local amt = math.floor(self.FloorDelta.X*2+0.5)  / (self._usingPerformanceMode and 2 or 1)
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

function Player:DoubleJump()
    -- first move the player down to make sure they're even allowed to double jump
    self.JumpBuffer = 0
    local p = self.Position:Clone()
    local f = self.Floor
    self.Position.Y = self.Position.Y + self.DoubleJumpRequiredHeightFromGround
    
    self:Unclip()
    if p + V{0, self.DoubleJumpRequiredHeightFromGround} ~= self.Position then
        self.Position = p
        self.Floor = f
        return
    end
    self.Floor = f
    self.Position = p

    self.FramesSinceDoubleJump = 0
    self.Texture.Clock = 0
    self.Velocity.Y = -self.DoubleJumpPower
    self.DoubleJumpStoredSpeed = math.abs(self.Velocity.X)
    self.Velocity.X = self.DoubleJumpStoredSpeed * self.MoveDir
    self:SetBodyOrientation(self.MoveDir)
end

local bounds = {
    V{29, 33, 0.25}, -- leftbound, rightbound, animDuration
    V{41, 44, 0.25}
}

function Player:StartCrouch()
    self.CrouchTime = 1
    self.TimeSinceCrouching = -1
    self.CrouchAnimBounds = bounds[math.random(#bounds)]
    self:ShrinkHitbox()
end

function Player:EndCrouch()
    self.CrouchTime = 0
    self.TimeSinceCrouching = 0
    self:GrowHitbox()
end

function Player:ShrinkHitbox()
    self.XHitbox.Size.Y = X_HITBOX_HEIGHT_CROUCH
    self.YHitbox.Size.Y = Y_HITBOX_HEIGHT_CROUCH
end

function Player:GrowHitbox()
    self.XHitbox.Size.Y = X_HITBOX_HEIGHT
    self.YHitbox.Size.Y = Y_HITBOX_HEIGHT
end

function Player:SetBodyOrientation(dir)
    
    self.DrawScale.X = sign(dir ~= 0 and dir or self:GetBodyOrientation())
end

function Player:GetBodyOrientation()
    return sign(self.DrawScale.X)
end


local yscale_jump = {0.75, 0.8, 0.8, 0.85, 0.85, 1.28, 1.28, 1.28, 1.28, 1.28, 1.25, 1.25, 1.25, 1.25, 1.25, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1, 1.1}
local xscale_jump = {1.3, 1.25, 1.25, 1.15, 1.15, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85, 0.9, 0.9, 0.9, 0.95, 0.95, 0.95, 1, 1, 1, 1, 1}
local yscale_doublejump = {0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.1, 1.1, 1.1, 1.1}
local xscale_doublejump = {1.25, 1.25, 1.25, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.9, 0.9, 0.9, 0.9, 0.9, 1}
local yscale_roll = {0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 1, 1,1,1,1,1,1,1,1,1}
local xscale_roll = {1.25, 1.25, 1.25, 0.7, 0.7, 0.7, 0.7, 0.8, 0.8, 0.8, 0.8, 0.9, 0.9, 0.9, 0.9, 0.9, 1}
local yscale_land = {0.8, 0.8, 0.8, 0.8, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9}
local yscale_land_small = {0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 1, 1}
local xscale_crouch = {1.3, 1.2, 1.2, 1.1, 1.1, 1.1, 1}
local yscale_crouch = {0.7, 0.8, 0.8, 0.9, 0.9, 0.9, 1}
local xscale_pounce = {1, 1, 1.3, 1.3, 1.3, 1.2, 1.2, 1.2, 1.2, 1.1, 1.1, 1.1}
local yscale_pounce = {1, 1, 0.8, 0.8, 0.8, 0.8, 0.8, 0.9, 0.9}
local xscale_crouch_flip = {1.3, 1.2, 1.2, 1.1, 1.1, 1.1, 1}
local yscale_crouch_flip = {0.7, 0.8, 0.8, 0.9, 0.9, 0.9, 1}





-- Animation picking
function Player:UpdateAnimation()

    -- print(self.Floor, self.Velocity)



    
    -- squash and stretch
    if false then
    elseif self.CrouchTime > 0 and self.FramesSinceFlippedDirection > 0 and self.FramesSinceFlippedDirection <= #xscale_crouch_flip then
        -- crouching, turned around
        self.DrawScale.Y = yscale_crouch_flip[self.FramesSinceFlippedDirection]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_crouch_flip[self.FramesSinceFlippedDirection]
    elseif not self.Floor and self.TimeSincePounce > -1 then
        -- just pounced
        self.DrawScale.Y = yscale_pounce[self.TimeSincePounce+1] or 1
        self.DrawScale.X = sign(self.DrawScale.X) * (xscale_pounce[self.TimeSincePounce+1] or 1)
    elseif self.Floor and self.CrouchTime > 0 and self.CrouchTime < #xscale_crouch then
        -- just crouched
        self.DrawScale.Y = yscale_crouch[self.CrouchTime]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_crouch[self.CrouchTime]
    elseif self.FramesSinceDoubleJump > -1 and self.FramesSinceDoubleJump < #yscale_doublejump then
        -- just double jumped
        self.DrawScale.Y = yscale_doublejump[self.FramesSinceDoubleJump+1]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_doublejump[self.FramesSinceDoubleJump+1]
    elseif self.FramesSinceJump > -1 and self.FramesSinceJump < #yscale_jump then
        -- just jumped
        self.DrawScale.Y = yscale_jump[self.FramesSinceJump+1]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_jump[self.FramesSinceJump+1]
    elseif self.FramesSinceRoll > -1 and self.FramesSinceRoll < #yscale_roll then
        -- just rolled
        self.DrawScale.Y = yscale_roll[self.FramesSinceRoll+1]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_roll[self.FramesSinceRoll+1]
    elseif self.FramesSinceGrounded > -1 and self.FramesSinceGrounded < #yscale_land then
        -- just landed on the ground
        if self.VelocityBeforeHittingGround >= self.TerminalVelocity then
            -- player was falling at terminal velocity (bigger visual impact)
            self.DrawScale.Y = yscale_land[self.FramesSinceGrounded+1]
        elseif self.VelocityBeforeHittingGround > 0.5 then
            -- player was falling less than terminal velocity (smaller visual impact)
            self.DrawScale.Y = yscale_land_small[self.FramesSinceGrounded+1]
        else
            -- player was not falling (no visual impact)
            self.DrawScale.Y = 1
        end
        self.DrawScale.X = sign(self.DrawScale.X)
    else
        self.DrawScale.X = sign(self.DrawScale.X)
        self.DrawScale.Y = 1
    end
    
    if not self.Floor and self.TimeSincePounce > -1 and self.FramesSinceDoubleJump == -1 then
        -- just pounced
        self.Texture:AddProperties{LeftBound = 45, RightBound = 48, Duration = 0.6, PlaybackScaling = 1, Loop = false}
    elseif self.CrouchEndBuffer > 0 then
        -- is in the end of a crouch
        self.CrouchEndBuffer = self.CrouchEndBuffer - 1
        self.Texture:AddProperties{LeftBound = 35, RightBound = 36, Duration = 4/60, PlaybackScaling = 1, Loop = false}
    elseif self.CrouchTime > 0 and self.Floor then
            -- is crouching
            if not self.InputListener:IsDown("crouch") then
                -- crouch just ended - we'll use this animation instead
                self.CrouchEndBuffer = 4
                self.Texture:AddProperties{LeftBound = 35, RightBound = 36, Duration = 4/60, PlaybackScaling = 1, Loop = false}
                self.Texture:SetFrame(35)
                self.Texture.Clock = 0
            else
                local animationBegun = self.Texture.LeftBound == self.CrouchAnimBounds[1] and self.Texture.RightBound == self.CrouchAnimBounds[2]
                self.Texture:AddProperties{LeftBound = self.CrouchAnimBounds[1], RightBound = self.CrouchAnimBounds[2], Duration = self.CrouchAnimBounds[3], PlaybackScaling = 1, Loop = false}
                if (not animationBegun) then self.Texture:SetFrame(self.CrouchAnimBounds[1]); self.Texture.IsPlaying = true end
            end
           
    elseif self.FramesSinceRoll > -1 and self.FramesSinceRoll ~= self.RollLength then
        -- player is in a roll (regardless of air state)
        if self.Floor then
            if self.CrouchTime > self.CrouchShimmyDelay then
                self.Texture:AddProperties{LeftBound = 29, RightBound = 33, Duration = 0.25, PlaybackScaling = 1, Loop = false}
                if self.FramesSinceRoll == 0 then
                    self.Texture:SetFrame(29)
                end
            else
                self.Texture:AddProperties{LeftBound = 25, RightBound = 27, Duration = 1/60*self.RollLength, PlaybackScaling = 1, Loop = false}
            end
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
            self:SetBodyOrientation(self.MoveDir)
            if math.abs(self.Velocity.X) <= 1.5 then
                self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 3 - math.abs(self.Velocity.X)*1.25, IsPlaying = true, Loop = true}
            else
                self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 1 + math.abs(self.Velocity.X)*0.25, IsPlaying = true, Loop = true}
            end
        end
    else -- no floor; in air
        if self.FramesSinceDoubleJump > -1 and self.FramesSinceDoubleJump < self.DoubleJumpFrameLength then
            -- just double jumped
            self.Texture:AddProperties{LeftBound = 11, RightBound = 12, Duration = self.DoubleJumpFrameLength/60, PlaybackScaling = 1, Loop = false, IsPlaying = true}
        elseif self.FramesSinceJump == 0 then
            -- just jumped
            self.Texture:AddProperties{LeftBound = 13, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false, Clock = 0}
        elseif self.FramesSinceJump == -1 and self.FramesSinceDoubleJump == -1 then
            -- just falling
            self.Texture:AddProperties{LeftBound = 15, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false}
        else
            -- middle of jump state
            self.Texture:AddProperties{LeftBound = 13, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false, IsPlaying = true}
        end
    end
end

function Player:UpdateFrameValues()
    
    if self.Floor then
        self.FramesSinceDoubleJump = -1
        self.FramesSinceJump = -1
        if self.FramesSinceGrounded > -1 then
            self.FramesSinceGrounded = self.FramesSinceGrounded + 1
        end
    else -- no floor
        self.FramesSinceGrounded = -1
        if self.FramesSinceJump > -1 then
            self.FramesSinceJump = self.FramesSinceJump + 1
        end
        if self.FramesSinceDoubleJump > -1 then
            self.FramesSinceDoubleJump = self.FramesSinceDoubleJump + 1
        end
    end

    if self.FramesSinceRoll > -1 then
        self.FramesSinceRoll = self.FramesSinceRoll + 1
        if self.FramesSinceRoll > self.RollLength then
            self.FramesSinceRoll = -1
            
            
            if self.CrouchTime == 0 then
                if self.TimeSincePounce == -1 then self.Texture.Clock = 0 end
                self:GrowHitbox()
            end

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

    self.FramesSinceRespawn = self.FramesSinceRespawn + 1

    local newFaceDir = sign(self.DrawScale.X)
    if newFaceDir ~= self.LastFaceDirection then
        self.FramesSinceFlippedDirection = 0
    else
        self.FramesSinceFlippedDirection = self.FramesSinceFlippedDirection + 1
    end
    self.LastFaceDirection = newFaceDir

    if self.TimeSincePounce > -1 then
        self.TimeSincePounce = self.TimeSincePounce + 1
        if self.Floor then
            self.TimeSincePounce = -1
        end
    end

    if self.CrouchTime > 0 and self.InputListener:IsDown("crouch") and self.Floor then
        self.CrouchTime = self.CrouchTime + 1
    elseif self.CrouchTime > 0 then
        self:EndCrouch()
    end

    if self.TimeSinceCrouching > -1 then
        self.TimeSinceCrouching = self.TimeSinceCrouching + 1
    end

    if self.MoveDir == 0 then
        self.FramesSinceMoving = -1
        self.FramesSinceIdle = self.FramesSinceIdle + 1
    else
        self.FramesSinceIdle = -1
        self.FramesSinceMoving = self.FramesSinceMoving + 1
    end

    self.FramesSinceInit = self.FramesSinceInit + 1
end

-- physics updates
local min, max = math.min, math.max
function Player:UpdatePhysics()

    -- some logic for recording previous position
    if self.LastPosition == self.Position then -- player is 'idle'
        self.IdleStreak = self.IdleStreak + 1

        if self.IdleStreak == self.POSITION_SAFETY_THRESHOLD or not self.LastSafePosition then
            self.LastSafePosition = self.LastPosition
        end
    elseif self.IdleStreak > 0 then -- reset IdleStreak
        self.IdleStreak = 0
    end

    self.LastPosition = self.Position:Clone()
    
    -- gravity is dependent on the jump state of the character
    if self.HangStatus > 0 and self.Velocity.Y >= 0 then
        -- the player is owed hang time

        self.Velocity.Y = 0
    elseif self.FramesSinceDoubleJump > -1 then

        -- the player is in the air from a double jump
        if self.Velocity.Y < 0 then
            -- player is in the upward arc

            self.Velocity.Y = self.Velocity.Y + self.AfterDoubleJumpGravity
            if self.Velocity.Y > 0 then

                -- print("e")
                -- give the player a couple grace frames
                self.Velocity.Y = 0
                self.HangStatus = self.DoubleJumpHangTime+1 -- + 1 because the update function decreases it                
            end
        else
            -- player is in the downward arc
            self.Velocity.Y = self.Velocity.Y + self.Gravity
        end
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
                if self.TimeSincePounce > -1 then
                    -- pounce height cancel
                    if self.FramesSinceJump <= self.ImmediateJumpWindow then
                        -- immediate pounce height cancel gravity
                        self.Velocity.Y = self.Velocity.Y + self.ImmediatelyAfterPounceCancelGravity
                    else
                        self.Velocity.Y = self.Velocity.Y + self.AfterPounceCancelGravity
                    end
                    
                elseif self.FramesSinceJump <= self.ImmediateJumpWindow then
                    self.Velocity.Y = self.Velocity.Y + self.ImmediatelyAfterJumpGravity
                else
                    -- normal after jump gravity
                    self.Velocity.Y = self.Velocity.Y + self.AfterJumpGravity
                end

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
    elseif not self.Floor then
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
            if self.TimeSincePounce > -1 then
                -- pounce velocity
                if self.MoveDir == 0 then
                    -- player is idle
                    self:Decelerate(self.PounceIdleDeceleration)
                elseif sign(self.Velocity.X) == self.MoveDir then
                    -- player is moving "with" the direction of their momentum; don't slow down as much
                    self:Decelerate(self.PounceForwardDeceleration)
                else
                    -- player is against the direction of momentum; normal deceleration
                    self:Decelerate(self.PounceBackwardDeceleration)
                end
            else
                -- regular air velocity
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

local insert = table.insert
function Player:UpdateTail()
    local dist = (self.Position - self.LastPosition):Magnitude()
    -- print(self.FramesSinceRespawn)
    if self.FramesSinceRespawn == 0 then
        self.TailPoints = {}
        return
    end
    local tp = self.TailPoints
    if #tp < self.TailLength or (tp[1] ~= self.Position) then
        insert(tp, 1, self.Position:Clone())
        if tp[self.TailLength+1] then
            tp[self.TailLength+1] = nil
        end
    end
end

------------------------ MAIN UPDATE LOOP -----------------------------
function Player:Update(engine_dt)
    self._usingPerformanceMode = self:GetLayer():GetParent().PerformanceMode
    -- also, engine_dt will be 1/60 in normal mode and 1/30 in performance mode
    
    local dt = 1/60 -- player value changes should always assume 60hz updates

    -- self.Color = V{math.random(0,1),math.random(0,1),math.random(0,1)}
    ------------------- PHYSICS PROCESSING ----------------------------------
    -- if we're on a moving floor let's move with it
    self:FollowFloor()

    -- listen for inputs here
    self:ProcessInput()

    -- update position based on velocity, velocity based on acceleration, etc
    self:UpdatePhysics()

    -- update tail (based on physics)
    self:UpdateTail()

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

    self._updateStep = not self._updateStep
    if self._usingPerformanceMode and not self._updateStep then
        self:Update(engine_dt)
    end
end

function Player:DrawTrail()
    if not self.HelperCanvas then
        self.HelperCanvas = self.Canvas:Clone()
        self.HelperCanvas.AlphaMode = "premultiplied"
        self.HelperCanvas.BlendMode = "lighten"
    end
    

    
    self.HelperCanvas:Activate()

    local points = {}
    love.graphics.clear()
    love.graphics.setColor(1,1,1,1)
    local p1 = self.TailPoints[1]
        local cx = self.Canvas:GetWidth()/2
        local cy = self.Canvas:GetHeight()/2 + 4 * self.DrawScale.Y
        for i, point in ipairs(self.TailPoints) do
            -- if i == 1 or i % 2 == 0 then
                points[#points+1] = point[1] - p1[1] + cx
                points[#points+1] = point[2] - p1[2] + cy
            -- end
        end
        
        local c = -sign(self.DrawScale.X)
        local len = math.floor(#points * self.TrailLength)
        for i = 3, len, 2 do
            -- cdrawcircle("fill", points[i-2], points[i-1], (#points-i)/3)
            local width = ((len-i)/4) * self.TrailLength + 0.5
            -- if width < 0.5 then width = 0 end

            -- love.graphics.setColor(1, 1, 1, 0.1)
            cdrawlinethick(points[i-2], points[i-1], points[i], points[i+1], width)
            -- cdrawlinethick(points[i-2], points[i-1]+1, points[i], points[i+1]+1, width)
            -- cdrawlinethick(points[i-2]+c, points[i-1], points[i]+c, points[i+1], width)
            -- cdrawlinethick(points[i-2]+c, points[i-1]+1, points[i]+c, points[i+1]+1, width)
        end

    self.HelperCanvas:Deactivate()
end

function Player:Draw(tx, ty)
    -- make sure hitboxes are re-aligned with player after position updates
    self:AlignHitboxes()

    -- draw the textures n shit to the canvas
    local speed = self.Velocity:Magnitude()

    local shouldDrawTrail = (self.TimeSincePounce > -1 and self.FramesSinceDoubleJump == -1) or
                            speed > 5
                            

    if shouldDrawTrail then
        self.TrailLength = math.lerp(self.TrailLength, 1, 0.2, 0.1)
    else
        self.TrailLength = math.lerp(self.TrailLength, 0, 0.05, 0.1)
    end

    

    if self.TrailLength > 0.1 then
        self:DrawTrail()
    end

    self.Canvas:Activate()
        love.graphics.clear()
        local sx = self.Size[1] * (self.DrawScale[1]-1)
        local sy = self.Size[2] * (self.DrawScale[2]-1)

        local shouldDrawTail = (self.CrouchTime == 0)

        -- if not (self.Floor and self.Velocity.X == 0) then
        if shouldDrawTail then
            -- draw the tail
            local ofs_x, ofs_y = 0, 0
            if self.TimeSincePounce > -1 then
                ofs_y = -3
            end

            love.graphics.setColor(self.Color * self.TailColor)
            local points = {}
            local p1 = self.TailPoints[1]
            local cx = self.Canvas:GetWidth()/2
            local cy = self.Canvas:GetHeight()/2 + 6 * self.DrawScale.Y
            for i = 1, self.TailVisibleLength do
                local point = self.TailPoints[i]
                if not point then break end
                -- if i == 1 or i % 2 == 0 then
                    points[#points+1] = point[1] - p1[1] + cx + ofs_x
                    points[#points+1] = point[2] - p1[2] + cy + ofs_y
                -- end
            end
            
            local c = -sign(self.DrawScale.X)
            for i = 3, #points, 2 do
                cdrawline(points[i-2], points[i-1], points[i], points[i+1])
                cdrawline(points[i-2], points[i-1]+1, points[i], points[i+1]+1)
                cdrawline(points[i-2]+c, points[i-1], points[i]+c, points[i+1])
                cdrawline(points[i-2]+c, points[i-1]+1, points[i]+c, points[i+1]+1)
            end
        end
        -- end

        love.graphics.setColor(self.Color)
        self.Texture:DrawToScreen(
            self.Canvas:GetWidth()/2,
            self.Canvas:GetHeight()/2,
            self.Rotation,
            self.Size[1] + sx,
            self.Size[2] + sy,
            0.5, 0.5
        )
    self.Canvas:Deactivate()

    -- love.graphics.draw(self.HelperCanvas._drawable, 0, 0)
    if self.TrailLength > 0.1 then
        love.graphics.setColor(self.TrailColor)
        self.HelperCanvas:DrawToScreen(
            math.floor(self.Position[1] - tx),
            math.floor(self.Position[2] - ty + self.Canvas:GetHeight()/2 - self.Size.Y*self.DrawScale.Y/2),
            self.Rotation,
            self.Canvas:GetWidth(),
            self.Canvas:GetHeight(),
            self.AnchorPoint[1],
            self.AnchorPoint[2]
        )
    end

    self.Shader:Activate()

    love.graphics.setColor(1, 1, 1)
    self.Canvas:DrawToScreen(
        math.floor(self.Position[1] - tx),
        math.floor(self.Position[2] - ty + self.Canvas:GetHeight()/2 - self.Size.Y*self.DrawScale.Y/2),
        self.Rotation,
        self.Canvas:GetWidth(),
        self.Canvas:GetHeight(),
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )

    if self:HasChildren() then
        self:DrawChildren(tx, ty)
    end

    self.Shader:Deactivate()
    
    love.graphics.setColor(1,0,0,1)

end

function Player:Respawn(pos)
    pos = pos or self.LastSafePosition
    
    self.FramesSinceRespawn = 0
    self.Position = pos
    self.Velocity[1] = 0; self.Velocity[2] = 0;
end

return Player