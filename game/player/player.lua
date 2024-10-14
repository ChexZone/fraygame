local Player = {
    -- inherited properties
    Name = "Player",
    AnchorPoint = V{0.5, 1},
    Velocity = V{0, 0},
    Acceleration = V{0,0},
    Color = Constant.COLOR["ORANGE"]:Set("S",0.1,  "V",1),
    TailColor = V{196,223,238}/255,
    -- DiveExpiredColor = V{0.8,0.8,0.9,1},    -- color to multiply player by when the dive is expired
    DiveExpiredColor = Constant.COLOR.PURPLE:Lerp(Constant.COLOR.WHITE, 0.7),
    DiveExpiredGoalColor = V{0.75, 0.8, 0.9, 1},
    Visible = true,
    Solid = false,
    Rotation = math.rad(0),
    Position = V{80,-50},
    Size = V{24,24},

    FramesSinceInit = 0,                -- how many frames since the Player object was created

    VelocityLastFrame = V{0,0},         -- the velocity of the player the previous frame (valid after Player:UpdatePhysics())

    MaxSpeed = V{8, 10},                 -- the absolute velocity caps (+/-) of the player
    RunSpeed = 1.5,                     -- how fast the player runs by default
    DiveSpeed = 3,                      -- minimum speed during a dive
    Gravity = 0.15,                     -- how many pixels the player falls per frame
    JumpGravity = 0.14,                 -- how many pixels the player falls per frame while in the upward arc of a jump
    TouchEvents = {},                   -- used to ensure one touch event per object per frame
    AfterDoubleJumpGravity = 0.2,
    ParryGravity = 0.125,
    FramesSinceLastLunge = 0,              --
    TrailLength = 1,                    -- (range 0-1) how long the trail should be
    TrailColor = V{190/255, 140/255, 100/255, 0.7} + 0.3 ,       -- color of trail following player
    IsCrouchedHitbox = false,           -- whether the player's hitbox is in "crouched" state or not
    
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
    ParryWindow = 25,                 -- how many frames after hitting a wall the player is allowed to give the parry input
    ParryStatus = 0,                  -- live status of ParryWindow
    PounceParticlePower = 0,          -- basically to scale particles for PounceDust
    ImmediatelyAfterPounceCancelGravity = 1.25,-- the gravity of the player in the upward pounce arc after jump has been released immediately after being pressed
    TerminalVelocity = 3.5,             -- how many units per frame the player can fall
    TerminalDiveVelocity = 3,
    TerminalLungeVelocity = 4,         
    YPositionAtLedge = nil,             -- the Y position of the player at the last ledge they walked off
    TerminalLedgeLungeVelocity = 10,      -- terminal velocity out of a lunge off a ledge
    TerminalLedgeLungeVelocityGoal = 2,      -- terminal velocity out of a lunge off a ledge
    ActiveTerminalLedgeLungeVelocity = 3,   -- it will slowly lerp towards TerminalDiveVelocity
    LedgeLungeWindow = 30,              -- how many frames after a lunge can you fall off a ledge to do a ledge lunge 
    LedgeLungeTaperSpeed = 0.15,         -- how quickly ActiveTerminalLedgeLungeVelocity moves towards TerminalDiveVelocity
    HangTime = 3,                       -- how many frames of hang time are afforded in the jump arc
    HalfHangTime = 1,                   -- how many frames of hang time are afforded for medium-height jumps
    DoubleJumpHangTime = 3,             -- how many frames of hang time are afforded for double jumps
    HangTimeActivationTime = 16,        -- how many frames the player must hold jump before they are owed hang time
    HalfHangTimeActivationTime = 10,    -- activation energy for half hang time (medium-height jumps)
    DropHangTime = 3,                   -- how many frames of hang time are offered from falling off the side of a platform
    HangStatus = 0,                     -- tracker for the status of hang time
    RollTimeAfterLunge = 10,            -- how many frames after a lunge (downward dive) to also listen for roll inputs
    LungeBuffer = 0,                    -- measures above variable
    JumpPower = 3.7,                      -- the base initial upward momentum of a jump
    
    DiveExpired = false,                   -- whether the player has used up their dive in the air

    ParryPower = 2.65,                   -- the initial upward momentum of a parry
    LungePitch = 1,                     -- trends towards 1
    LungePitchTweenSpeed = 2.5,
    WallBumpHeight = 0.5,               -- tiny wall height bump
    LastParryFace = "none",             -- which wall side was last parried off of
    DoubleJumpFrameLength = 12,         -- how many frames a double jump takes
    DoubleJumpPower = 3,                -- the base initial upward momentum of a double jump
    DiveCancelPower = 2.25,                -- the base initial upward momentum of a dive cancel (a double jump out of a dive)
    DoubleJumpRequiredHeightFromGround = 5, -- number of pixels off the ground the player must be to be eligible to double jump
    DoubleJumpStoredSpeed = 0,          -- how fast the player was moving horizontally when they double jumped
    LastDoubleJumpWasDiveCancel = false, -- was the last double jump a dive cancel?
    FramesSincePounce = -1,                -- how many frames since the player last "pounced" (crouch + roll + jump)
    TimeAfterPounceCanDoubleJump = 5,   -- how many frames after a sideways pounce the player is allowed to double jump
    RollWindowPastJump = 3,             -- how many frames after jumping will an action input still result in a hold
    CrouchAnimBounds = V{40, 44},       -- the current bounds of the crouch animation (so it change)
    CrouchShimmyDelay = 0,              -- how many frames after crouching will pressing the action button still do a roll?
    LastRollPower = 0,                  -- records the last RollPower used for the previous roll\
    ShimmyPower = 3,                   -- how much RollPower the player gets while crouching
    RollPower = 5,                    -- the player's X velocity on the first frame of a roll
    MinPouncePower = 5.5,                  -- the X velocity out of a sideways pounce
    MaxPouncePower = 6.5,                  -- the X velocity out of a sideways pounce
    
    DiveCancelSpeedThreshold = 0,       -- how fast the player must be moving (X) to be eligible to dive cancel
    DiveWasLunge = false,               -- whether the last dive was a lunge or not (resets with dive state)
    DivePower = 5.25,                    -- the X velocity out of an aerial dive
    DiveUpwardVelocity = -0.5,         -- the Y velocity out of an aerial dive
    WeakDiveUpwardVelocity = -0.5,         -- the Y velocity out of an aerial dive that's been weakened by a double jump
    WeakDiveHangTime = 5,               -- how many frames the y velocity of the player will stay the same after a weak divided
    ParryDiveUpwardVelocity = -0.5,     -- the Y velocity out of a parry dive (an upward dive immediately after a parry, usually over an edge)
    DiveHangTime = 6,                   -- how many frames the y velocity of the palyer will stay the same after a normal dive
    DiveHangStatus = 0,             -- status of above variable
    LungeDownwardVelocity = 4,         -- the Y velocity out of a crouched aerial dive
    DiveGravity = 0.2,                  -- how much gravity the player has while diving
    ParryDiveGravity = 0.2,             -- how much gravity the player has 
    DiveLandRollThreshold = 1.8,          -- how fast the player must be moving (X) when landing after a dive to automatically roll 
    PounceHeight = 2.2,                 -- the upward Y velocity out of a sideways pounce 
    RolledOutOfDive = false,            -- set to true when rolling out of a dive
    RollLength = 14,                    -- how long the player must wait after a roll before rolling again (how many frames the roll animation lasts) 
    ShimmyLength = 5,                   -- how long the player must wait after a shimmy before shimmying again
    AccelerationSpeed = 0.12,            -- how much the player accelerates per frame to the goal speed
    AirAccelerationSpeed = 0.08,        -- how much the player accelerates per frame in the air
    PounceAccelerationSpeed = 0.155,      -- how much the player accelerates per frame during a pounce
    DiveAccelerationSpeed = 0.025,
    ParryDiveAccelerationSpeed = 0.025,
    LedgeUpwardClipDistance = 8,              -- how far up a wall is before the player can just walk up without any airtime
    LedgeDownwardClipDistance = 8,
    LastDiveWasParryDive = false,        -- was the last dive a parry dive?
    FramesAfterParryCanParryDive = 12,   -- how many frames after a parry will a player's dives become eligible for 
    FramesAfterDiveCanCancel = 5,       -- how many frames after diving the player is allowed to cancel the dive
    FramesAfterLungeCanCancel = 10,    -- how many frames after lunging the player is allowed to cancel the lunge
    XVelocityBeforeLastLunge = 0,       
    ForwardDeceleration = 0.2,          -- how much the player speed decreases while moving forward
    BackwardDeceleration = 0.7,         -- how fast the player speed decreases while "braking" on the ground
    IdleDeceleration = 0.2,             -- how fast the player halts to a stop while idle on the ground
    AirBackwardDeceleration = 0.25,     -- how much the player decelerates while in the air, against the movement direction
    AirForwardDeceleration = 0.2,      -- how much the player decelerates while in the air, moving in the same direction
    AirIdleDeceleration = 0.2,          -- how much the player decelerates while idle in the air
    DiveBackwardDeceleration = 0.08,     -- how much the player decelerates while in a dive, against the movement direction
    DiveForwardDeceleration = 0.07,      -- how much the player decelerates while in a dive, moving in the same direction
    DiveIdleDeceleration = 0.025,          -- how much the player decelerates while idle in a dive    
    ParryDiveBackwardDeceleration = 0.125,     -- how much the player decelerates while in a dive, against the movement direction
    ParryDiveForwardDeceleration = 0.125,      -- how much the player decelerates while in a dive, moving in the same direction
    ParryDiveIdleDeceleration = 0.125,          -- how much the player decelerates while idle in a dive    
    PounceForwardDeceleration = 0.22,   -- how much the player accelerates while in a pounce
    PounceIdleDeceleration = 0.16,   -- how mucgh the player decelerates while idle in a pounce
    PreviousFloorHeight = 0,      -- the last recorded height of the floor
    PounceBackwardDeceleration = 0.25, -- how much the player decelerates while moving backwards in a pounce
    PounceAnimCancelled = false,        -- during a pounce, whether to transition the player animation back to normal jump
    ConsecutivePouncesSpeedMult = 1.5, -- how much the player's speed is multiplied by during a new pounce (basically, how easily the player can speed up doing chained pounces)
    ConsecutiveLungesSpeedMult = 1.15,  -- how much the player's speed is multiplied by during a new pounce coming out of a downward lunge
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
    DJMomentumCancelOpportunity = 6,    -- how many frames after a double jump the player can release either direction and cancel momentum
    ActionFrames = 5,                   -- how many frames after an action input can still result in action
    ActionBuffer = 0,                   -- how many action frames are currently remaining

    

    -- vars
    XHitbox = nil,                      -- the player's hitbox for walls
    YHitbox = nil,                      -- the player's hitbox for ceilings/floors

    Floor = nil,                        -- the current Prop acting as the "floor"
    Wall = nil,                         -- the current Prop acting as the "wall" the player is against
    WallDirection = "none",             -- direction the player is leaning into the wall
    WallBumpDirection = "none",         -- the direction of the last wall the player dove into
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
    FramesSinceParry = -1,              -- will be -1 if the player.. isn't parrying
    FramesSinceGrounded = -1,           -- will be -1 if the player is in the air
    FramesSinceAgainstWall = -1,        -- will be -1 if the player is in the air
    FramesSinceRoll = -1,               -- will be -1 if the player is not in a roll state
    FramesSinceMoving = -1,             -- will be -1 if the player is currently idle
    FramesSinceIdle = -1,               -- will be -1 if the player is currently moving
    FramesSinceDive = -1,               -- will be -1 if the player isn't diving
    DiveBlock = 10,                     -- amount of frames the player is ineligible for diving due to something

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
    Color = V{1,0,0,0.4},
    Solid = true,
    AnchorPoint = V{0.5,1}
}
-- xHitbox is used to detect walls
local xHitboxBASE = Prop.new{
    Name = "xHitbox",
    Texture = Texture.new("chexcore/assets/images/square.png"),
    Size = V{8,X_HITBOX_HEIGHT},
    Visible = false,
    Color = V{0,0,1,0.4},
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
    newPlayer.TouchEvents = {} 


    newPlayer.LastSFX_ID = {}
    newPlayer.SFX = {
        Jump = {
            Sound.new("game/assets/sounds/jump1.wav", "static"):Set("Volume", 0.5),
            Sound.new("game/assets/sounds/jump2.wav", "static"):Set("Volume", 0.5)
        },
        DoubleJump = {
            Sound.new("game/assets/sounds/double_jump1.wav", "static"):Set("Volume", 0.5),
            Sound.new("game/assets/sounds/double_jump2.wav", "static"):Set("Volume", 0.5),
            Sound.new("game/assets/sounds/double_jump3.wav", "static"):Set("Volume", 0.5),
            Sound.new("game/assets/sounds/double_jump4.wav", "static"):Set("Volume", 0.5),
        },
        DiveCancel = {
            Sound.new("game/assets/sounds/backflip1.wav", "static"):Set("Volume", 0.4),
            Sound.new("game/assets/sounds/backflip2.wav", "static"):Set("Volume", 0.4),
        },
        Dive = {
            Sound.new("game/assets/sounds/dive1.wav", "static"):Set("Volume", 0.4),
        },
        DiveSqueak = {
            Sound.new("game/assets/sounds/squeak_dive.wav", "static"):Set("Volume", 0.05),
        },
        LedgeLunge = {
            Sound.new("game/assets/sounds/ledgelunge1.wav", "static"):Set("Volume", 0.4),
        },
        Parry = {
            Sound.new("game/assets/sounds/parry3.wav", "static"):Set("Volume", 0.25),
            Sound.new("game/assets/sounds/parry4.wav", "static"):Set("Volume", 0.25),
        },
        Parry2 = {
            Sound.new("game/assets/sounds/parry1.wav", "static"):Set("Volume", 0.025),
            Sound.new("game/assets/sounds/parry2.wav", "static"):Set("Volume", 0.025),
        },
        FailParry = {
            Sound.new("game/assets/sounds/parry_fail1.wav", "static"):Set("Volume", 0.2),
            Sound.new("game/assets/sounds/parry_fail2.wav", "static"):Set("Volume", 0.2),
            Sound.new("game/assets/sounds/parry_fail3.wav", "static"):Set("Volume", 0.2),
        },
        FailParrySqueak = {
            Sound.new("game/assets/sounds/squeak_ow.wav", "static"):Set("Volume", 0.3),
        },
        Bonk = {
            Sound.new("game/assets/sounds/bonk1.wav", "static"):Set("Volume", 0.15),
        },
        WeakRoll = {
            Sound.new("game/assets/sounds/roll_weak1.wav"):Set("Volume", 0.025)
        },
        Roll = {
            Sound.new("game/assets/sounds/roll1.wav"):Set("Volume", 0.035)
        },
        FastRoll = {
            Sound.new("game/assets/sounds/roll_fast1.wav"):Set("Volume", 0.04)
        },
        RollWhoosh = {
            Sound.new("game/assets/sounds/roll_whoosh1.wav"):Set("Volume", 0.15)
        },
        ShimmyWhoosh = {
            Sound.new("game/assets/sounds/shimmy1.wav"):Set("Volume", 0.1)
        },
        PounceSqueak = {
            Sound.new("game/assets/sounds/squeak_pounce.wav", "static"):Set("Volume", 0.03),
        },
    }

    newPlayer.SFX.Jump[1].Test = true

    Particles.new{
        Name = "RollKickoffDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 1},
        Texture = Texture.new("chexcore/assets/images/square.png"),
        RelativePosition = false,
        Size = V{4, 4},
        ParticleSize = V{16, 16},
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_kickoff.png", 1, 4):Properties{
            Duration = 0.35
        },
        
        ParticleLifeTime = 0.35,
        Color = V{0,0,0,0},
        ParticleColor = newPlayer.TrailColor,
        Update = function (self, dt)
            self.Position = self:GetParent().Positions
            -- print(self:ToString(true))
            -- if math.random(1, 100) == 1 then
            --     self:Emit{
            --         Position = self.Position
            --     }
            -- end

            -- print(self:GetParent():GetChildren())
    end}:Nest(newPlayer)

    Particles.new{
        Name = "PounceDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 0.5},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{4, 4},
        ParticleSize = V{16, 16},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_circle.png", 1, 3):Properties{Duration = 1},
        ParticleLifeTime = 1,
        Color = V{0,0,0,1},
        ParticleColor = newPlayer.TrailColor,
        Update = function (self, dt)
            self.Position = self:GetParent().Position
            -- print(self:ToString(true))
            -- if math.random(1, 100) == 1 then
            --     self:Emit{
            --         Position = self.Position
            --     }
            -- end

            -- print(self:GetParent():GetChildren())
    end}:Nest(newPlayer)
    
    Particles.new{
        Name = "ForwardLandDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 1},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{8,8},
        ParticleSize = V{8, 8},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_forward_land.png", 1, 4):Properties{Duration = 0.5},
        ParticleLifeTime = 0.5,
        Color = V{0,0,0,0},
        ParticleColor = newPlayer.TrailColor,
        Update = function (self, dt)
    end}:Nest(newPlayer)
    
    Particles.new{
        Name = "DoubleJumpDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 0.5},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{8,8},
        ParticleSize = V{16, 16},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_double_jump.png", 1, 4):Properties{Duration = 0.25},
        ParticleLifeTime = 0.25,
        Color = V{0,0,0,0},
        ParticleColor = newPlayer.TrailColor,
    }:Nest(newPlayer)

    Particles.new{
        Name = "DiveDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 0.5},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{8,8},
        ParticleSize = V{16, 16},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_dive.png", 1, 4):Properties{Duration = 0.3},
        ParticleLifeTime = 0.35,
        Color = V{0,0,0,0},
        ParticleColor = newPlayer.TrailColor,
    }:Nest(newPlayer)

    Particles.new{
        Name = "JumpDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 1},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{8,8},
        ParticleSize = V{8, 8},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_jump.png", 1, 4):Properties{Duration = 0.3},
        ParticleLifeTime = 0.3,
        Color = V{0,0,0,0},
        ParticleColor = newPlayer.TrailColor,
    }:Nest(newPlayer)

    
    
    newPlayer.InputListener = Input.new{
        a = "move_left",
        d = "move_right",
        space = "jump",
        lshift = "action",
        e = "action",
        s = "crouch",

        h = "HITBOXTOGGLE",
        j = "SLOWMODETOGGLE",
        k = "FASTMODETOGGLE",
        p = "PERFORMANCEMODETOGGLE"
    }

    newPlayer.LastFrameInputs = {}

    -- attach input to player
    function newPlayer.InputListener:Press(device, key)
        newPlayer.JustPressed[key] = true
    end


    local c = 0
    for _ in pairs(Player) do
        c=c+1
    end
    print(c)

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

function Player:DisconnectFromWall()
    self.Wall = nil
    self.WallDirection = "none"
end

function Player:ConnectToFloor(floor)
    
    if not self.Floor then
        -- just landed
        self.VelocityBeforeHittingGround = self.Velocity.Y
        self.FramesSinceGrounded = 0


    end
    self.Floor = floor
    self.LastFloor = floor
    self.FloorPos = floor.Position:Clone()
    self.LastFloorPos = floor.Position:Clone()
    self.FloorLeftEdge = floor:GetEdge("left")
    self.FloorRightEdge = floor:GetEdge("right")
    

    self.Position.Y = math.floor(self.Position.Y)
    self.DistanceAlongFloor = (self.Position.X - self.FloorLeftEdge) + (self.FloorRightEdge - self.FloorLeftEdge)
    -- self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Loop = true}
end

function Player:ConnectToWall(wall, direction)
    
    if not self.Wall then
        -- just touched wall
        self.FramesSinceAgainstWall = 0
    end
    self.Wall = wall
    self.WallDirection = direction

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

        self.PreviousFloorHeight = self:GetEdge("bottom")
    elseif self.LastFloor then
        self.LastFloorDelta = self.LastFloorPos - self.LastFloor.Position
    end
end

------- collison function
function Player:Unclip(forTesting)
    
    if self.Floor then
        self.Position.Y = self.Position.Y + 1
    end

    -- make sure hitboxes are aligned first!!!
    self:AlignHitboxes()
    local justLanded = false
    local hitCeiling = false
    local pushY = 0
    for solid, hDist, vDist, tileID in self.YHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)
        -- we check the "sign" of the direction to make sure the player is "moving into" the object before clipping back
        local faceSign = face == "bottom" and 1 or face == "top" and -1 or 0
        if solid ~= self.YHitbox and (faceSign == sign(self.Velocity.Y +0.01) or face == "none") and not solid.Passthrough then
            -- self.Velocity.Y = 0
            pushY = math.abs(pushY) > math.abs(vDist) and pushY or vDist
            if face == "bottom" then
                if not self.Floor then
                    -- just landed
                    justLanded = true
                end
                self:ConnectToFloor(solid)
            elseif face == "top" then
                hitCeiling = true
            end
            self:AlignHitboxes()
        end

        if not self.TouchEvents[solid] and not solid:IsA("Tilemap") then
            self.TouchEvents[solid] = true
            if solid.OnTouchEnter then solid:OnTouchEnter(self) end
            if solid.OnTouchStay then solid:OnTouchStay(self) end
        end
    end


    -- roll out of a fast dive
    if justLanded and self.FramesSinceDive > -1 and math.abs(self.Velocity.X) > self.DiveLandRollThreshold and self.MoveDir == sign(self.Velocity.X) then
        self.PreviousFloorHeight = self.Position.Y
        self:Roll()
        self.RolledOutOfDive = true
        self.FramesSinceDive = -1
    end

    if not forTesting then
        -- try to "undo" if the player clipped too hard
        if math.abs(pushY) > self.Size.Y/2 then
            self.Position.Y = self.Position.Y - self.VelocityLastFrame.Y
        else
            self.Position.Y = self.Position.Y + pushY - sign(pushY) * 0.01
        end
    end
    
    if justLanded and math.abs(self.Velocity.X) > 1 and not forTesting then
        local vel = V{40, 0} * math.clamp(math.abs(self.Velocity.X), 0.75, 5) * sign(self.DrawScale.X)
        self:GetChild("ForwardLandDust"):Emit{
            Position = self.Position,
            Velocity = vel,
            Acceleration = vel*-2,
            Size = V{8 * sign(self.DrawScale.X), 8} * math.clamp(math.abs(self.Velocity.X), 4, 8)/4
        }
    end


    local pushX = 0
    for solid, hDist, vDist, tileID in self.XHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)



        if solid ~= self.XHitbox and (face == "left" or face == "right") and not solid.Passthrough then
            
            -- check if this is a ledge
            local hit
            local i = 1
            while i <= self.LedgeUpwardClipDistance do
                self.XHitbox.Position.Y = self.XHitbox.Position.Y - 1
                hit = solid:CollisionInfo(self.XHitbox)
                if not hit then break end
                i = i + 1
            end
            
            self.XHitbox.Position.X = self.XHitbox.Position.Y + i-- self.LedgeUpwardClipDistance
            if not hit then
                self.Position.Y = self.Position.Y - i
            else
                -- if pushY == 0 then self.Velocity.X = 0 end
                pushX = math.abs(pushX) > math.abs(hDist) and pushX or hDist
                self:AlignHitboxes()

                self:ConnectToWall(solid, face)
            end



        end
        
    end

    if not forTesting then
        -- again, try to "undo" any extreme clipping
        if math.abs(pushX) > self.Size.X/2 then
            self.Position.X = self.Position.X - self.VelocityLastFrame.X
        else
            self.Position.X = self.Position.X + pushX
        end
    end

    local inParry = (self.FramesSinceParry > -1 and self.FramesSinceParry < 10) and self.FramesSinceDoubleJump == -1 and self.FramesSinceDive == -1
    if pushX == 0 and hitCeiling then
        
        if inParry then
            -- skip
        else
            if self.FramesSincePounce > -1 and self.FramesSincePounce < 30 and self.MoveDir ~= 0 then
                -- if pouncing and hitting a ceiling, knock the player back down to the floor (makes pounce chaining easier in corridors)
                self.Velocity.Y = math.max(0, -self.Velocity.Y)
                self.DiveBlock = self.DiveBlock + 10
            else
                self.Velocity.Y = math.max(0, self.Velocity.Y)
            end
        end
    end

    return pushX, pushY
end

function Player:ValidateFloor()
    if self.Floor then
        -- check if we've collided with the current floor or not
        self:AlignHitboxes()
        self.YHitbox.Position.Y = self.Position.Y + 1
        
        self.Velocity.Y = 0

        local hit, hDist, vDist = self.Floor:CollisionInfo(self.YHitbox)
        if not hit then

            -- first check to see if there's a ledge or slope right below us
            local i = 1
            while i <= self.LedgeDownwardClipDistance do
                self.XHitbox.Position.Y = self.XHitbox.Position.Y + 1
                hit = self.Floor:CollisionInfo(self.XHitbox)
                if hit then break end
                i = i + 1
            end
            self.XHitbox.Position.Y = self.XHitbox.Position.Y - i

            if hit and self.FramesSinceLastLunge >= self.LedgeLungeWindow then
                self.Position.Y = self.Position.Y + i
            else
                -- fine. we left the floor
                if self.Floor.LockPlayerVelocity then
                    -- lock in the player to the floor's movement arc
                    self.AerialMovementLockedToFloorPos = true
                elseif self.FloorDelta then
                    -- inherit some velocity of the floor object
                    local amt = math.floor(self.FloorDelta.X*2+0.5) / (self._usingPerformanceMode and 2 or 1)
                    if math.abs(amt) > 1 then
                        if -sign(amt) == self.MoveDir then
                            self.Velocity.X = self.Velocity.X - amt/2
                        end
                    end
                end
                self.YPositionAtLedge = self.Position.Y
                self:DisconnectFromFloor()
                if self.FramesSinceRoll == -1 then
                    self.Texture.Clock = 0
                end
                self.HangStatus = self.DropHangTime+1
                -- set up coyote frames
                self.CoyoteBuffer = self.CoyoteFrames
    
                if self.FramesSinceLastLunge < self.LedgeLungeWindow and self.InputListener:IsDown("crouch") and self.InputListener:IsDown("action") then
                    self:Dive()
                    self.DiveExpired = false
                    self.Velocity.Y = self.TerminalLedgeLungeVelocity
                    self.Velocity.X = self.Velocity.X * 1.2
                    self.InLedgeLunge = true
                    self.LungePitch = self.LungePitch + 0.1
                    self:PlaySFX("LedgeLunge", self.LungePitch)
                    self.ActiveTerminalLedgeLungeVelocity = self.TerminalLedgeLungeVelocity
                end
            end
        end
    end

    self:AlignHitboxes()
end

function Player:ValidateWall()
    if self.Wall then
        -- check if we've collided with the current floor or not
        self:AlignHitboxes()
        local dir = (self.WallDirection == "left" and -1 or 1)
        self.XHitbox.Position.X = self.XHitbox.Position.X + dir
        local hit = self.Wall:CollisionInfo(self.XHitbox)
        if not hit then
            self:DisconnectFromWall()
        end
    end
    self:AlignHitboxes()
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

    if self.JustPressed["FASTMODETOGGLE"] then
        _G.FAST_MODE = not _G.FAST_MODE
        
    end
    -- crouch input
    if self.CrouchTime == 0 and self.InputListener:IsDown("crouch") and self.Floor and (self.FramesSinceRoll == -1 or self.FramesSinceRoll == 12) then
        self:StartCrouch()
    end
    

    -- action input
    if self.JustPressed["action"] then
        -- let the action input linger for a few frames in case player inputs early
        self.ActionBuffer = self.ActionFrames
    end

    local blockJump 

    if not self.DiveExpired and  self.ActionBuffer > 0 and (not self.Floor and self.CoyoteBuffer == 0) and self.FramesSinceDive == -1 and (self.FramesSinceJump == -1 or self.FramesSinceJump > 4) and self.FramesSinceRoll == -1 and (self.FramesSincePounce == -1 or self.PounceAnimCancelled or self.FramesSinceDoubleJump > -1 or self.InputListener:IsDown("crouch")) then
        -- dive
        self:Dive()
    elseif (self.ActionBuffer > 0 or self.LungeBuffer > 0) and (self.Floor or self.CoyoteBuffer > 0 or (self.FramesSinceJump > -1 and self.FramesSinceJump < self.RollWindowPastJump)) and ((self.CrouchTime > self.CrouchShimmyDelay and (self.FramesSinceRoll == -1 or self.FramesSinceRoll >= self.ShimmyLength)) or self.FramesSinceRoll == -1) then
        -- roll
        blockJump = self:Roll()
    end


        -- jump input
        if self.JustPressed["jump"] then
            -- let the jump input linger for a few frames in case player inputs early
            self.JumpBuffer = self.JumpFrames
        end

        if self.JumpBuffer > 0 and not blockJump then
            if (self.Floor or self.CoyoteBuffer > 0) then
                self:Jump()
                
            elseif self.FramesSinceDoubleJump == -1 and (self.FramesSincePounce == -1 or self.FramesSincePounce > self.TimeAfterPounceCanDoubleJump) and (self.FramesSinceDive == -1 or math.abs(self.Velocity.X) >= self.DiveCancelSpeedThreshold)  then
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

        -- connect to floor while crouching
        if self.Floor and self.FloorDelta and self.FloorDelta ~= EMPTYVEC and self.Velocity.X == 0 then
            self:AlignWithFloor()
        end
    elseif self.MoveDir ~= 0 then
        local accelSpeed = self.Floor and self.AccelerationSpeed or 
                            (self.FramesSinceDive > -1 and (self.LastDiveWasParryDive and self.ParryDiveAccelerationSpeed or self.DiveAccelerationSpeed)) or
                            (self.FramesSincePounce > -1 and self.PounceAccelerationSpeed or self.AirAccelerationSpeed)
        self.Acceleration.X = self.MoveDir*accelSpeed

        if self.FramesSinceDoubleJump > -1 and self.FramesSinceDoubleJump <= self.DJMomentumCancelOpportunity then
            if self.FramesSinceMoving == 0 and not self.LastDoubleJumpWasDiveCancel then
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

    -- print(self.MoveDir)
end

function Player:PlayDynamicDashSound(speed, delay)
    speed = speed or math.abs(self.Velocity.X)
    delay = delay or 0.15
    local pitch = math.lerp(self.LungePitch, 1, 0.2)
    if speed > 6 then
        Timer.Schedule(delay, function() self:PlaySFX("FastRoll", pitch) end)
    elseif speed > 5 then
        Timer.Schedule(delay, function() self:PlaySFX("Roll", pitch) end)
    else
        Timer.Schedule(delay, function() self:PlaySFX("WeakRoll", pitch) end)
    end
end
function Player:PlaySFX(name, pitch, variance)
    pitch = pitch or 1
    variance = variance or 1
    local no = math.random(1, #self.SFX[name])
    if no == self.LastSFX_ID[name] then
        no = no+1
        if no > #self.SFX[name] then
            no = 1
        end
    end
    self.LastSFX_ID[name] = no
    
    self.SFX[name][no]:Stop()
    
    self.SFX[name][no]:SetPitch(pitch + math.random(-5,5)/45 * variance)
    self.SFX[name][no]:Play()
end

function Player:Jump()
    self.JumpBuffer = 0
    self.FramesSinceDive = -1
    self.DiveExpired = false
    self.Velocity.Y = -self.JumpPower

    ---- SFX ----
    self:PlaySFX("Jump")
    -------------

    if self.FramesSinceLastLunge <= self.CoyoteFrames and not self.Floor then
        self.Position.Y = math.lerp(self.Position.Y, self.YPositionAtLedge, 0.8)
        self.Velocity.X = self.XVelocityBeforeLastLunge
    else
        self.YPositionAtLedge = self.Position.Y
    end

    

    -- pounce  handling
    if (self.FramesSinceRoll > -1 or (self.FramesSinceJump > -1 and self.FramesSinceJump <= self.RollWindowPastJump)) and self.LastRollPower == self.ShimmyPower then
        self.Velocity.X = sign(self.Velocity.X) * math.min(math.max(self.MinPouncePower, math.abs(self.Velocity.X)), self.MaxPouncePower)
        self:PlayDynamicDashSound(nil, 0)
        self:PlaySFX("PounceSqueak", 1 + math.abs(self.Velocity.X)/30, 0)
        self.Velocity.Y = sign(self.Velocity.Y) * self.PounceHeight
        self.FramesSincePounce = 0
        self.FramesSinceRoll = -1
        self.PounceAnimCancelled = false
        self.PounceParticlePower = self.PounceParticlePower + 2.5
        -- self:PlaySFX("Pounce")
        -- if self.SFX.RollWhoosh[self.LastSFX_ID.RollWhoosh] then
        --     print("FUCK")
        --     self.SFX.RollWhoosh[self.LastSFX_ID.RollWhoosh]:Stop()
        -- end

        local kickoffdust = self:GetChild("RollKickoffDust")
        kickoffdust:Emit{
            Position = V{self.Position.X, self.PreviousFloorHeight}, 
            Size = V{kickoffdust.ParticleSize.X * sign(self.DrawScale.X), kickoffdust.ParticleSize.Y}, 
            Velocity = math.abs(self.Velocity.X) < 1 and V{0, 0} or V{-sign(self.DrawScale.X) * 35, 0}
        }

    else

        -- regular jump
        self:GetChild("JumpDust"):Emit{Position = self.Position, }
    end

    self.FramesSinceJump = 0
    
    self.FloorPositionAtJump = self.LastFloor and self.LastFloor.Position:Clone() or V{0,0}

    if self.LastFloor.LockPlayerVelocity then
        -- lock in the player to the floor's movement arc
        self.AerialMovementLockedToFloorPos = true
        
    elseif self.FloorDelta then
        
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
            self.Velocity.Y = self.Velocity.Y - self.FloorDelta.Y  / (self._usingPerformanceMode and 2 or 1)
        end
    end
    if self.FramesSinceRoll == 0 then
        self.Texture.Clock = 0 -- reset jump animation
    end
    self:DisconnectFromFloor()
end

function Player:DoubleJump()
    self:GrowHitbox()

    local pos = self.Position:Clone()
    local oldFloor = self.Floor
    local subdivisions = 3
    local howFarDownToCheck = 8

    
    if self.Velocity.Y > -1 then
        for i = 1, subdivisions do
            self.Position.Y = self.Position.Y + (howFarDownToCheck/subdivisions)
            -- self.Position.X = self.Position.X + (self.Velocity.X/subdivisions)
            local _, pushY = self:Unclip(true)

            if pushY ~= 0 then
                self.Position = pos
                if oldFloor ~= self.Floor then
                    self:DisconnectFromFloor()
                end
                return
            end
        end
    end

    self.Position = pos
    if oldFloor ~= self.Floor then
        self:DisconnectFromFloor()
    end

    if self.FramesSincePounce > -1 then
        -- if self.InputListener:IsDown("action") then
            self.Velocity.X = math.min(math.abs(self.Velocity.X), math.lerp(math.abs(self.Velocity.X), self.RunSpeed, 0.5)) * self.MoveDir
        -- else
        --     self.Velocity.X = 0
        -- end
    end

    if self.DiveWasLunge then
        if self.FramesSinceDive > -1 and self.FramesSinceDive < self.FramesAfterLungeCanCancel then
            -- don't let them dive cancel right after lunging
            return
        end
    else
        if self.FramesSinceDive > -1 and self.FramesSinceDive < self.FramesAfterDiveCanCancel then
            -- don't let them dive cancel right after diving
            -- self.JumpBuffer = 0
            return
        end
    end

    


    -- first move the player down to make sure they're even allowed to double jump
    self.JumpBuffer = 0

    self:GetChild("DoubleJumpDust"):Emit{Position = self:GetPoint(0.5,0.5), Rotation = math.random(0,3)*math.rad(90)}
    
    
    
    self.Texture.Clock = 0

    
    self.DoubleJumpStoredSpeed = math.abs(self.Velocity.X)
    
    if self.FramesSinceDive > -1 then
        -- this is a dive cancel; player can't carry momentum from dives
        if self.InputListener:IsDown("action") then
            -- player can maintain some velocity if they're holding action during a dive cancel
            self.Velocity.X = math.min(math.abs(self.Velocity.X), math.lerp(math.abs(self.Velocity.X), self.RunSpeed, 0.5)) * self.MoveDir
        else
            self.Velocity.X = 0
        end
        self.Velocity.Y = -self.DiveCancelPower
        self.LastDoubleJumpWasDiveCancel = true

        -- SFX
        self:PlaySFX("DiveCancel")
    else
        self.Velocity.X =  self.DoubleJumpStoredSpeed * self.MoveDir
        self.Velocity.Y = -self.DoubleJumpPower
        self.LastDoubleJumpWasDiveCancel = false

        -- SFX
        self:PlaySFX("DoubleJump")
    end

    
    self:SetBodyOrientation(self.MoveDir)

    self.FramesSinceDive = -1
    self.FramesSinceDoubleJump = 0
end

function Player:Parry()
    
    self:GrowHitbox()

    -- can parry if:
    -- - you haven't parried yet this jump (LastParryFace is "none") OR
    -- - your parry direction is the opposite wall (ex. "left" to "right") OR
    -- - the current X position of the wall you're parrying off is different from the last X position OR
    -- - the wall is a different Prop
    local allowedToParry = self.LastParryFace ~= self.WallBumpDirection
                        or math.abs(self.Position.X - self.LastParryPos.X + (self.LastParryWallPos.X - self.Wall.Position.X)) > 5
                        or self.Wall ~= self.LastParryWall

    if not allowedToParry then
        -- can't parry off the same wall twice!
        self.FramesSinceDive = -1
        self.FramesSinceDoubleJump = math.max(-1, self.FramesSinceDoubleJump)
        self:PlaySFX("FailParry")
        self:PlaySFX("FailParrySqueak")
        self:PlaySFX("Bonk")
        return
    end

    self.JumpBuffer = 0
    self:GetChild("DoubleJumpDust"):Emit{Position = self:GetPoint(0.5,0.5), Rotation = math.random(0,3)*math.rad(90)}
    
    -- local parrySpeed = ((self.WallDirection == "right" and self.MoveDir == 1) or (self.WallDirection == "left" and self.MoveDir == -1)) and 1 -- player is moving towards wall
    --     or self.MoveDir == 0 and 2.5    -- player is neutral
    --     or 3.25     -- player is holding against dive direction
    local parrySpeed = 3.125
    local wallDir = (self.WallBumpDirection == "right" and -1 or 1)

    self.Texture.Clock = 0
    self.Velocity.Y = -self.ParryPower
    self.Velocity.X = parrySpeed * wallDir

    -- self:SetBodyOrientation(-wallDir)

    self.FramesSinceDive = -1
    self.FramesSinceDoubleJump = -1
    self.DiveExpired = false
    self.Texture.Clock = 0
    self.Texture.IsPlaying = true
    self.LastParryWall = self.Wall
    self.LastParryPos = self.Position:Clone()
    self.LastParryWallPos = self.Wall.Position:Clone()
    self.LastParryFace = self.WallBumpDirection
    self.FramesSinceParry = 0

    self:PlaySFX("Parry")
    self:PlaySFX("Parry2")
end

function Player:BumpWall()
    self:GrowHitbox()

    self.JumpBuffer = 0    
    -- local parrySpeed = ((self.WallDirection == "right" and self.MoveDir == 1) or (self.WallDirection == "left" and self.MoveDir == -1)) and 1 -- player is moving towards wall
    --     or self.MoveDir == 0 and 2.5    -- player is neutral
    --     or 3.25     -- player is holding against dive direction
    local bumpSpeed = 1.25
    local wallDir = (self.WallDirection == "right" and -1 or 1)

    self.Texture.Clock = 0
    self.Velocity.Y = -self.WallBumpHeight
    self.Velocity.X = bumpSpeed * wallDir

    self:SetBodyOrientation(self.MoveDir == 0 and wallDir or self.MoveDir)

    self.WallBumpDirection = self.WallDirection
    self.FramesSinceDive = -1
    -- self.FramesSinceDoubleJump = -1
    self.FramesSinceDoubleJump = math.max(0, self.FramesSinceDoubleJump)

    -- 
    if self.Wall then
        self.LastFloor = self.Wall
        if self.Wall.LockPlayerVelocity then
            self.AerialMovementLockedToFloorPos = true
        else
            self.AerialMovementLockedToFloorPos = false
        end
    end

end

function Player:Dive()
    
    self:ShrinkHitbox()
    local oldX = self.Velocity.X
    self.ActionBuffer = 0
    local faceDirection = self.MoveDir ~= 0 and self.MoveDir or sign(self.DrawScale.X)
    local measuredVelocityY = 0
    local isParryDive = false

    if (self.FramesSinceDoubleJump == -1 and  math.abs(self.Velocity.Y) > 2.35) then
        measuredVelocityY = self.Velocity.Y/1.3
    end

    if self.FramesSinceParry > -1 and self.FramesSinceParry < self.FramesAfterParryCanParryDive and self.FramesSinceDoubleJump == -1 then
        measuredVelocityY = -2.5
        self.LastDiveWasParryDive = true
        isParryDive = true
    else
        self.LastDiveWasParryDive = false
    end
    
    self.DrawScale.X = faceDirection
    self.Velocity.X = faceDirection * self.DivePower
    self.Velocity.Y = math.min(self.DiveUpwardVelocity, measuredVelocityY + self.DiveUpwardVelocity) --math.min(-3.5, self.Velocity.Y - 3.5)
    -- self.WeakDiveHangStatus = 3
    if self.FramesSinceDoubleJump > -1 then
        self.Velocity.Y = math.min(self.WeakDiveUpwardVelocity, measuredVelocityY + self.WeakDiveUpwardVelocity)
        self.DiveHangStatus = self.WeakDiveHangTime
    else
        self.DiveHangStatus = self.DiveHangTime
    end

    if isParryDive then
        self.DiveHangStatus = 0
        self.Velocity.Y = math.min(self.ParryDiveUpwardVelocity, measuredVelocityY + self.ParryDiveUpwardVelocity)
        self.Position.Y = self.Position.Y - 1 -- a  couple more pixels of height, just in case
    end

    if self.InputListener:IsDown("crouch") then
        -- lunge
        self.Velocity.Y = self.LungeDownwardVelocity
        self.LungeBuffer = self.RollTimeAfterLunge
        -- self.Velocity.X = math.max(self.DivePower, ) * faceDirection
        self.XVelocityBeforeLastLunge = oldX
        self.DiveWasLunge = true
        self.FramesSinceLastLunge = 0
    else
        self.PounceParticlePower = self.PounceParticlePower + 2.25
        self.DiveWasLunge = false
        self:PlaySFX("DiveSqueak")
        self.Position.Y = self.Position.Y - 3
    end

    self:GetChild("DiveDust"):Emit{Position = self:GetPoint(0.5,0.65), Rotation = math.random(0,3)*math.rad(90)}


    
    self.FramesSinceDive = 0
    self.FramesSinceDoubleJump = -1
    self.DiveExpired = true

    ---- SFX ----
    -- local no =  math.random(1, #self.SFX.Dive)
    -- self.SFX.Dive[no]:Stop()
    -- self.SFX.Dive[no]:SetPitch(1 + math.random(-5,5)/45)
    -- self.SFX.Dive[no]:Play()

    self:PlaySFX("Dive", self.LungePitch)
    
    

    -- local no =  math.random(1, #self.SFX.DiveSqueak)
    -- self.SFX.DiveSqueak[no]:Stop()
    -- self.SFX.DiveSqueak[no]:SetPitch(1 + math.random(-5,5)/100)
    -- self.SFX.DiveSqueak[no]:Play()
    -------------
end

function Player:Roll()
    self.ActionBuffer = 0
    self.LungeBuffer = 0
    local holdingCrouch = self.InputListener:IsDown("crouch")
    local justLunged = self.FramesSinceDive <= 10
    local movementPower = ((self.CrouchTime > self.CrouchShimmyDelay or self.TimeSinceCrouching < 10) and holdingCrouch) and self.ShimmyPower or self.RollPower

    -- special case for if player just recently lunged to the ground
    if justLunged and holdingCrouch then
        movementPower = self.ShimmyPower
    end


    self.LastRollPower = movementPower


    
    local vel = V{80, 0} * math.clamp(math.abs(movementPower/2), 2, 5) * sign(self.DrawScale.X)
    self:GetChild("ForwardLandDust"):Emit{
        Position = self.Position,
        Velocity = vel,
        Acceleration = vel*-2,
        Size = V{8 * sign(self.DrawScale.X) * (movementPower == self.ShimmyPower and 1 or -1), 8} * math.clamp(math.abs(movementPower/2), 4, 8)/4 
    }  

    if self.CrouchTime > 0 then
        -- was crouching normally
        self.Velocity.X = sign(self.DrawScale.X) * math.max(movementPower, math.abs(self.Velocity.X) * self.ConsecutivePouncesSpeedMult)
    elseif (holdingCrouch and justLunged) then
        -- is crouching and just lunged into the ground
        self.Velocity.X = sign(self.DrawScale.X) * math.max(movementPower, math.abs(self.Velocity.X) * self.ConsecutiveLungesSpeedMult)
    else
        local kickoffdust = self:GetChild("RollKickoffDust")
        kickoffdust:Emit{
            Position = V{self.Position.X, self.PreviousFloorHeight}, 
            Size = V{kickoffdust.ParticleSize.X * sign(self.DrawScale.X), kickoffdust.ParticleSize.Y}, 
            Velocity = math.abs(self.Velocity.X) < 1 and V{0, 0} or V{-sign(self.DrawScale.X) * 35, 0}
        }
        self.Velocity.X = sign(self.DrawScale.X) * movementPower
        
        
    end
    
    

    self:ShrinkHitbox()

    self.FramesSinceRoll = 0
    
    local blockJump

    if self.InputListener:IsDown("jump") and self.FramesSinceJump <= self.RollWindowPastJump and self.TimeSinceCrouching < 5 then
        -- rolled a few frames late after a jump - initiate a pounce instead
        blockJump = true
        
        self:Jump()
    end

    
    self.ActionBuffer = 0
    self.Texture.Clock = 0
    self.Texture.IsPlaying = true

    if movementPower == self.ShimmyPower and self.FramesSinceGrounded > 0 and not self.InputListener:IsDown("jump") then
        self:PlaySFX("ShimmyWhoosh")
        
    else
        
        self:PlaySFX("RollWhoosh", pitch)
        self:PlayDynamicDashSound()
    end

    return blockJump
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
    if self.IsCrouchedHitbox then return end

    self.XHitbox.Size.Y = X_HITBOX_HEIGHT_CROUCH
    self.YHitbox.Size.Y = Y_HITBOX_HEIGHT_CROUCH

    self.IsCrouchedHitbox = true
end

function Player:GrowHitbox()
    
    if not self.IsCrouchedHitbox then return end

    if not self.Floor then
        self.XHitbox.Size.Y = math.lerp(X_HITBOX_HEIGHT, X_HITBOX_HEIGHT_CROUCH, 0.5)
        self.YHitbox.Size.Y = math.lerp(Y_HITBOX_HEIGHT, Y_HITBOX_HEIGHT_CROUCH, 0.5)
        
        self:AlignHitboxes()

        self:Unclip()
    end

    self.XHitbox.Size.Y = X_HITBOX_HEIGHT
    self.YHitbox.Size.Y = Y_HITBOX_HEIGHT
    
    self:Unclip()
    
    self.IsCrouchedHitbox = false
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
local xscale_dive = {1, 1.3, 1.3, 1.3, 1.3, 1.3, 1.3, 1.2, 1.1, 1.1, 1.1, 1.1, 1.1, 1}
local yscale_dive = {1, 0.6, 0.6, 0.7, 0.7, 0.7, 0.7, 0.7, 0.9, 0.9, 0.9, 0.9, 1}
local xscale_crouch_flip = {1.3, 1.2, 1.2, 1.1, 1.1, 1.1, 1}
local yscale_crouch_flip = {0.7, 0.8, 0.8, 0.9, 0.9, 0.9, 1}
local xscale_wall_squish = {0.7, 0.7, 0.7, 0.8, 0.8, 0.8, 0.9, 0.9, 0.9, 0.95, 0.95, 0.95, 0.975, 0.975, 1, 1, 1, 1, 1, 1, 1, 1, 1}
local yscale_wall_squish = {1.2, 1.1, 1.1, 1.1, 1.1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}





-- Animation picking
function Player:UpdateAnimation()

    -- print(self.Floor, self.Velocity)


    
    -- squash and stretch
    if false then
    elseif self.ParryStatus > 0 then
        local prog = self.ParryWindow - self.ParryStatus + 1
        self.DrawScale.Y = yscale_wall_squish[prog] or 1
        self.DrawScale.X = sign(self.DrawScale.X) * (xscale_wall_squish[prog] or 1)
    elseif self.FramesSinceDive > -1 then
        self.DrawScale.Y = yscale_dive[self.FramesSinceDive+1] or 1
        self.DrawScale.X = sign(self.DrawScale.X) * (xscale_dive[self.FramesSinceDive+1] or 1)
    elseif self.CrouchTime > 0 and self.FramesSinceFlippedDirection > 0 and self.FramesSinceFlippedDirection <= #xscale_crouch_flip then
        -- crouching, turned around
        self.DrawScale.Y = yscale_crouch_flip[self.FramesSinceFlippedDirection]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_crouch_flip[self.FramesSinceFlippedDirection]
    elseif not self.Floor and self.FramesSincePounce > -1 then
        -- just pounced
        self.DrawScale.Y = yscale_pounce[self.FramesSincePounce+1] or 1
        self.DrawScale.X = sign(self.DrawScale.X) * (xscale_pounce[self.FramesSincePounce+1] or 1)
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

    if true then
        local frequency = math.clamp(math.floor(7 - self.PounceParticlePower*4), 1, 10)

        local speed = self.Velocity:Magnitude()

        if speed < 1 then
            frequency = 1000000
        end
        if self.PounceParticlePower > 0 and (self.FramesSinceInit % frequency == 0) then
            local chainFactor = math.clamp(self.PounceParticlePower/4, 0.5, 1.1)
            local speedFactor = math.clamp(speed/6, 0.3, 1.3)
            local yOfs = self.FramesSinceDive > -1 and -6 or 0
            local xOfs = -self.Velocity.X
            self:GetChild("PounceDust"):Emit{
                Position = self:GetPoint(0.5,0.9) + V{xOfs, yOfs},
                Size = V{25, 12} * (self.FramesSincePounce % (2*frequency) == 0 and 0.8 or 1) * 1 * chainFactor * speedFactor,
                SizeVelocity = V{5,-17} * chainFactor * speedFactor,
                SizeAcceleration = V{-60, 0} * chainFactor * speedFactor * 0.8,
                Rotation = -self.Velocity:ToAngle() -math.rad(90),
                Velocity = self.Velocity * 5,
                LifeTime = 0.8,
            }

        end
    end 



    -- print(self:GetScene()._children)
    -- check what anim state to put pounce in
    if self.FramesSincePounce > -1 and not self.PounceAnimCancelled then
        
        if math.abs(self.Velocity.X) < self.MinPouncePower/2 then
            self.PounceAnimCancelled = true
            self.Texture.Clock = 0
            self.Texture.IsPlaying = true
        end
    end


    if self.Texture.Clock ~= self.Texture.Clock then
        self.Texture.Clock = self.Texture.Duration
    end


    if self.ParryStatus > 0 then
        self.Texture:AddProperties{LeftBound = 21, RightBound = 24, Duration = 0.3, PlaybackScaling = 1, Loop = false}
        if not self.Texture.IsPlaying then
            self.ShouldRestartJumpAnim = true
            self.ParryStatus = 0
        end
    elseif not self.Floor and self.FramesSinceDive > -1 then
        -- just dove
        local ratio = self.Velocity.Y / math.abs(self.Velocity.X)
        self.Texture:AddProperties{LeftBound = 17, RightBound = 100, PlaybackScaling = 1, Loop = false, IsPlaying = false}
        if ratio <= math.clamp(ratio, -1.5, -0.3) then
            self.Texture:SetFrame(self.Texture.LeftBound)
        elseif ratio == math.clamp(ratio, -0.3, 0) then
            self.Texture:SetFrame(self.Texture.LeftBound + 1)
        elseif ratio == math.clamp(ratio, 0, 0.75) then
            self.Texture:SetFrame(self.Texture.LeftBound + 2)
        elseif ratio == math.clamp(ratio, 0.5, 1.25) then
            self.Texture:SetFrame(self.Texture.LeftBound + 3)
        elseif ratio == math.clamp(ratio, 1.25, 2.5) then
            self.Texture:SetFrame(56)
        elseif ratio == math.clamp(2.5, 3.5) then
            self.Texture:SetFrame(57)
        else
            self.Texture:SetFrame(58)
        end
    elseif not self.Floor and self.FramesSincePounce > -1 and self.FramesSinceDoubleJump == -1 then
        -- just pounced

        if self.PounceAnimCancelled then
            self.Texture:AddProperties{LeftBound = 49, RightBound = 52, Duration = 0.3, PlaybackScaling = 1, Loop = false}
            self.Texture.PlaybackScaling = math.clamp(1/ (math.abs(self.Velocity.X) / 2) / 2.5, 0.2, 1.4)
            if  self.MoveDir == -sign(self.Velocity.X) then
                self.Texture.PlaybackScaling = 1
            end
        else
            self.Texture:AddProperties{LeftBound = 45, RightBound = 48, Duration = 0.6, PlaybackScaling = 1, Loop = false}
        end
        
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
            self.Texture:AddProperties{LeftBound = 37, RightBound = 39, Duration = 1/60*self.RollLength, PlaybackScaling = 1, Loop = false, IsPlaying = true}
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
            if self.ShouldRestartJumpAnim then
                self.ShouldRestartJumpAnim = false
                self.Texture.Clock = 0
                self.Texture.IsPlaying = true
            end
            self.Texture:AddProperties{LeftBound = 13, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false, IsPlaying = true}
        end
    end
end

function Player:UpdateFrameValues()
    
    
    if self.Floor then
        self.YPositionAtLedge = self.Position.Y
        self.InLedgeLunge = false
        self.AerialMovementLockedToFloorPos = false
        self.FramesSinceDoubleJump = -1
        self.FramesSinceJump = -1
        self.DiveExpired = false
        if self.FramesSinceGrounded > -1 then
            self.FramesSinceGrounded = self.FramesSinceGrounded + 1
        end
        self.LastParryFace = "none"
        self.FramesSinceParry = -1
    else -- no floor
        self.FramesSinceGrounded = -1
        if self.FramesSinceJump > -1 then
            self.FramesSinceJump = self.FramesSinceJump + 1
        end
        if self.FramesSinceDoubleJump > -1 then
            self.FramesSinceDoubleJump = self.FramesSinceDoubleJump + 1
        end
        if self.FramesSinceParry > -1 then
            self.FramesSinceParry = self.FramesSinceParry + 1
        end
    end

    
    if self.LungePitch ~= 1 then
        self.LungePitch = math.lerp(self.LungePitch, 1, self.LungePitchTweenSpeed/60)
    end

    if self.Wall then
        self.FramesSinceAgainstWall = self.FramesSinceAgainstWall + 1
    else
        self.FramesSinceAgainstWall = -1
    end

    if self.FramesSinceLastLunge > -1 then
        self.FramesSinceLastLunge = self.FramesSinceLastLunge + 1
    end

    if self.InLedgeLunge then
        self.ActiveTerminalLedgeLungeVelocity = math.lerp(self.ActiveTerminalLedgeLungeVelocity, self.TerminalLedgeLungeVelocityGoal, self.LedgeLungeTaperSpeed)
    end

    if self.FramesSinceRoll > -1 then
        self.FramesSinceRoll = self.FramesSinceRoll + 1
        if not self.Floor then
            self:GrowHitbox()
        end
        if self.FramesSinceRoll > self.RollLength then
            self.FramesSinceRoll = -1
            self.RolledOutOfDive = false
            
            if self.CrouchTime == 0 then
                if self.FramesSincePounce == -1 then self.Texture.Clock = 0 end
                self:GrowHitbox()
            end

            -- self.Texture.IsPlaying = true
        end

        
    end

    if self.ParryStatus > 0 then
        self.ParryStatus = self.ParryStatus - 1
    end

    if self.FramesSinceDive > -1 then
        self.FramesSinceDive = self.FramesSinceDive + 1
        
        if self.Floor then
            self.FramesSinceDive = -1
            self.DiveWasLunge = false
        end

        self:SetBodyOrientation(sign(self.Velocity.X))
    end

    if self.DiveBlock > 0 then
        self.DiveBlock = self.DiveBlock - 1
    end

    if self.DiveHangStatus > 0 then
        self.DiveHangStatus = self.DiveHangStatus - 1
    end

    if self.PounceParticlePower > 0 then
        self.PounceParticlePower = self.PounceParticlePower - 0.15
    end

    if self.CoyoteBuffer > 0 then
        self.CoyoteBuffer = self.CoyoteBuffer - 1
    elseif self.FloorDelta then
        -- reset floor delta at the end of coyote time
        self.FloorDelta = nil
    end

    if self.LungeBuffer > 0 then
        self.LungeBuffer = self.LungeBuffer - 1
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

    if self.FramesSincePounce > -1 then
        self.FramesSincePounce = self.FramesSincePounce + 1
        if self.Floor then
            self.FramesSincePounce = -1
        end
    end

    if self.CrouchTime > 0 and self.InputListener:IsDown("crouch") and self.Floor then
        self.CrouchTime = self.CrouchTime + 1
    elseif self.CrouchTime > 0 and (self.FramesSincePounce == -1 or self.PounceAnimCancelled) then
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


    -- safeguard to make sure hitbox isn't small for no reason
    if self.Floor and self.FramesSinceRoll == -1 and self.CrouchTime == 0 and self.IsCrouchedHitbox then
        self:GrowHitbox()
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
    if self.FramesSinceParry > -1 and self.FramesSinceDoubleJump == -1 and self.FramesSinceDive == -1 then
        self.Velocity.Y = self.Velocity.Y + self.ParryGravity
    elseif self.FramesSinceDive > -1 then
        -- the player has low dive gravity
        if self.DiveHangStatus > 0 then
            -- getting initial airtime in the weak dive state
            self.Velocity.Y = self.Velocity.Y + 0
        else
            if self.LastDiveWasParryDive then
                self.Velocity.Y = self.Velocity.Y + self.ParryDiveGravity
            else
                self.Velocity.Y = self.Velocity.Y + self.DiveGravity
            end
        end
        
    elseif self.HangStatus > 0 and self.Velocity.Y >= 0 then
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
                if self.FramesSincePounce > -1 then
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
      
    
    if self.RolledOutOfDive and self.Floor and self.MoveDir == -sign(self.Velocity.X) then
        -- players are allowed to cancel rolls that come from dives by inputting the other direction
        self.FramesSinceRoll = self.RollLength + 1
        self.Velocity.X = 0
    end



    local horizSpeed = self.FramesSinceDive > -1 and self.DiveSpeed or self.RunSpeed
    local decelGoal = math.abs(self.MoveDir) > 0 and horizSpeed or 0
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
            
            if self.FramesSinceDive > -1 then
                -- dive velocity
                if self.LastDiveWasParryDive then
                    -- parry dive
                    if self.MoveDir == 0 then
                        -- player is idle
                        self:Decelerate(self.ParryDiveIdleDeceleration)
                    elseif sign(self.Velocity.X) == self.MoveDir then
                        -- player is moving "with" the direction of their momentum; don't slow down as much
                        self:Decelerate(self.ParryDiveIdleDeceleration)
                    else
                        -- player is against the direction of momentum; normal deceleration
                        self:Decelerate(self.ParryDiveIdleDeceleration)
                    end
                else
                    -- regular dive
                    if self.MoveDir == 0 then
                        -- player is idle
                        self:Decelerate(self.DiveIdleDeceleration)
                    elseif sign(self.Velocity.X) == self.MoveDir then
                        -- player is moving "with" the direction of their momentum; don't slow down as much
                        self:Decelerate(self.DiveForwardDeceleration)
                    else
                        -- player is against the direction of momentum; normal deceleration
                        self:Decelerate(self.DiveBackwardDeceleration)
                    end
                end
                
            elseif self.FramesSincePounce > -1 then
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



    if self.FramesSinceDive > -1 then
        -- check for parrying
        local facingWall = (self.WallDirection == "left" and sign(self.DrawScale.X) == -1)
                        or (self.WallDirection == "right" and sign(self.DrawScale.X) == 1)
        if self.Wall and facingWall then
            -- if self.MoveDir == (self.WallDirection == "left" and -1 or self.WallDirection == "right" and 1 or 0) then
                self:BumpWall()
                self:Parry()
                self.ParryStatus = self.ParryWindow
            -- end
            self.FramesSinceDive = -1
        end
    end

    
    -- make sure touched objects are still being touched
    for solid in pairs(self.TouchEvents) do
        local hit, hDist, vDist = solid:CollisionInfo(self.YHitbox)
        if hit then
            if solid.OnTouchStay then solid:OnTouchStay(self, hDist, vDist) end
        else
            if solid.OnTouchLeave then solid:OnTouchLeave(self) end
            self.TouchEvents[solid] = false
        end
    end
    


    -- account for gravity
    local terminalVelocity = (self.InLedgeLunge and math.abs(self.Velocity.X) > 2 and self.FramesSinceDoubleJump == -1) and self.ActiveTerminalLedgeLungeVelocity or (self.FramesSinceDive > -1 and self.FramesSinceDoubleJump == -1) and (self.DiveWasLunge and self.TerminalLungeVelocity or self.TerminalDiveVelocity) or self.TerminalVelocity
    
    if self.Velocity.Y > terminalVelocity then
        self.Velocity.Y = terminalVelocity
    end


    if self.LastFloor then
        self.LastFloorPos = self.LastFloor.Position:Clone()
    end

    

    -- adhere to MaxSpeed
    
    -- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
    local MAX_Y_DIST = 1
    local MAX_X_DIST = 1
    local subdivisions = 1

    if math.abs(self.Velocity.X) > MAX_X_DIST then
        subdivisions = math.floor(1+math.abs(self.Velocity.X)/MAX_X_DIST)
    end

    if math.abs(self.Velocity.Y) > MAX_Y_DIST then
        subdivisions = math.max(subdivisions, math.floor(1+math.abs(self.Velocity.Y)/MAX_Y_DIST))
    end
    
    local posDelta = self.Velocity - (self.AerialMovementLockedToFloorPos and self.LastFloorDelta or EMPTYVEC)
    local interval = subdivisions == 1 and posDelta or posDelta / subdivisions

    local posBeforeMove = self.Position:Clone()

    local pushedX = false
    local pushedY = false
    local px, py
    for i = 1, subdivisions do
        self.Position = self.Position + interval
        px, py = self:Unclip()

        if px ~= 0 then pushedX = true end
        if py ~= 0 then pushedY = true end
    end

    local posAfterMove = self.Position

    
    if math.abs(posBeforeMove[1] - posAfterMove[1]) < 1 and pushedX then
        self.Velocity.X = 0
    end



    -- print("----------------------------", pushedX, math.abs(xBeforeMove - xAfterMove))

    -- special edge case for "falling" just off the corner of an object
    -- this happens when the player doesn't move far enough down for the x hitbox to touch the collider and move the player to the side
    -- the solution I think is just to force the movement and pray it doesn't create any edge case collision bugs
    if pushedY and self.Velocity.X == 0 and self.Acceleration.X == 0 and not self.Floor and math.abs(posAfterMove.Y - posBeforeMove.Y) < 1 then
        print("HANGING OFF LEDGE!!!")
        self.Position.Y = self.Position.Y + self.Velocity.Y
        self:Unclip()
    end

    -- print(posBeforeMove - posAfterMove)

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

    -- we do this manually inside UpdatePhysics now
    -- -- make sure collision is all good
    -- self:Unclip()

    -- update tail (based on physics)
    self:UpdateTail()
    
    -- confirm the floor remains the floor
    self:ValidateFloor()
    -- , and the wall
    self:ValidateWall()


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

    if self:HasChildren() then
        self:DrawChildren(tx, ty)
    end


    -- make sure hitboxes are re-aligned with player after position updates
    self:AlignHitboxes()

    -- draw the textures n shit to the canvas
    local speed = self.Velocity:Magnitude()

    local shouldDrawTrail = (self.FramesSincePounce > -1 and self.FramesSinceDoubleJump == -1) or
                            speed > 5 or
                            self.FramesSinceDive > -1
                            

    if shouldDrawTrail then
        self.TrailLength = math.lerp(self.TrailLength, 1, 0.2, 0.1)
    else
        self.TrailLength = math.lerp(self.TrailLength, 0, 0.05, 0.1)
    end

    

    if self.TrailLength > 0.1 then
        self:DrawTrail()
    end

    self.Canvas:Activate()

        self.DiveExpiredGoalColor = self.DiveExpiredGoalColor:Lerp((self.DiveExpired and self.FramesSinceDoubleJump > -1) and self.DiveExpiredColor or Constant.COLOR.WHITE, 0.1)


        love.graphics.clear()
        local sx = self.Size[1] * (self.DrawScale[1]-1)
        local sy = self.Size[2] * (self.DrawScale[2]-1)

        local shouldDrawTail = (self.CrouchTime == 0 or not self.Floor) and
                               (self.ParryStatus == 0)

        -- if not (self.Floor and self.Velocity.X == 0) then
        if shouldDrawTail then
            -- draw the tail
            local ofs_x, ofs_y = 0, 0
            if self.FramesSincePounce > -1 then
                ofs_y = -3
            end

            if self.FramesSinceDive > -1 then
                ofs_y = -3
            end

            love.graphics.setColor(self.Color * self.TailColor * self.DiveExpiredGoalColor)
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

        love.graphics.setColor(self.Color * self.DiveExpiredGoalColor)
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
            0,
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
        0,
        self.Canvas:GetWidth(),
        self.Canvas:GetHeight(),
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )



    self.Shader:Deactivate()
    
    if self.XHitbox.Visible then
        self.XHitbox:Draw(tx, ty)
        self.YHitbox:Draw(tx, ty)
    end
end

function Player:Respawn(pos)
    pos = pos or self.LastSafePosition
    
    self.FramesSinceRespawn = 0
    self.Position = pos
    self.Velocity[1] = 0; self.Velocity[2] = 0;
end

return Player