local Player = {
    -- inherited properties
    Name = "Player",
    AnchorPoint = V{0.5, 1},
    Velocity = V{0, 0},
    Acceleration = V{0,0},
    Color = Constant.COLOR["ORANGE"]:Set("S",0.1,  "V",1),
    TailColor = V{196,223,238}/255,
    -- DiveExpiredColor = V{0.8,0.8,0.9,1},    -- color to multiply player by when the dive is expired
    DiveExpiredColor = Constant.COLOR.PURPLE:Lerp(Constant.COLOR.WHITE, 0.5),
    DiveExpiredGoalColor = V{0.75, 0.8, 0.9, 1},
    Visible = true,
    Solid = false,
    Rotation = math.rad(0),
    Position = V{80,-50},
    Size = V{24,24},

    FramesSinceInit = 0,                -- how many frames since the Player object was created

    VelocityLastFrame = V{0,0},         -- the velocity of the player the previous frame (valid after Player:UpdatePhysics())

    MaxSpeed = V{10, 10},                 -- the absolute velocity caps (+/-) of the player
    WalkSpeed = 1.5,                     -- how fast the player runs by default
    RunSpeed = 2.4,                     -- how fast the player runs by default
    DiveSpeed = 3,                      -- minimum speed during a dive
    Gravity = 0.15,                     -- how many pixels the player falls per frame
    JumpGravity = 0.14,                 -- how many pixels the player falls per frame while in the upward arc of a jump
    TouchEvents = {},                   -- used to ensure one touch event per object per frame
    AfterDoubleJumpGravity = 0.2,
    ParryGravity = 0.125,
    FramesSinceLastLunge = 0,              --
    TrailLength = 1,                    -- (range 0-1) how long the trail should be
    TrailColor = V{190/255 + 0.3, 140/255 + 0.3, 100/255 + 0.3, 1},       -- color of trail following player
    DefaultTrailColor = V{190/255 + 0.3, 140/255 + 0.3, 100/255 + 0.3, 1},       -- color of trail following player
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
    TerminalLedgeLungeVelocity = 11,      -- terminal velocity out of a lunge off a ledge
    TerminalLedgeLungeVelocityGoal = 8,      -- terminal velocity out of a lunge off a ledge
    ActiveTerminalLedgeLungeVelocity = 3,   -- it will slowly lerp towards TerminalDiveVelocity
    LedgeLungeWindow = 30,              -- how many frames after a lunge can you fall off a ledge to do a ledge lunge 
    LedgeLungeTaperSpeed = 0.15,         -- how quickly ActiveTerminalLedgeLungeVelocity moves towards TerminalDiveVelocity
    HangTime = 4,                       -- how many frames of hang time are afforded in the jump arc
    HalfHangTime = 1,                   -- how many frames of hang time are afforded for medium-height jumps
    DoubleJumpHangTime = 3,             -- how many frames of hang time are afforded for double jumps
    HangTimeActivationTime = 16,        -- how many frames the player must hold jump before they are owed hang time
    HalfHangTimeActivationTime = 10,    -- activation energy for half hang time (medium-height jumps)
    DropHangTime = 3,                   -- how many frames of hang time are offered from falling off the side of a platform
    HangStatus = 0,                     -- tracker for the status of hang time
    RollTimeAfterLunge = 10,            -- how many frames after a lunge (downward dive) to also listen for roll inputs
    LungeBuffer = 0,                    -- measures above variable
    JumpPower = 3.7,                      -- the base initial upward momentum of a jump
    
    FramesSinceHoldingLeft = 0,        -- resets to 0 when left is pressed or held
    FramesSinceHoldingRight = 0,       -- resets to 0 when right is pressed or held

    DiveExpired = false,                   -- whether the player has used up their dive in the air

    JumpFramesBeforeRunCancel = 99999999,      -- the amount of the player has to hold out a jump input to nullify run speed
    CantRunUntilGrounded = false,       -- if the JumpFramesBeforeRunCancel is reached, set this to true until grounded again
    ParryPower = 2.65,                   -- the initial upward momentum of a parry
    LungePitch = 1,                     -- trends towards 1
    LungePitchTweenSpeed = 2.5,
    WallBumpHeight = 0.5,               -- tiny wall height bump
    LastParryFace = "none",             -- which wall side was last parried off of
    DoubleJumpFrameLength = 12,         -- how many frames a double jump takes
    DoubleJumpPower = 3,                -- the base initial upward momentum of a double jump
    DiveCancelPower = 1.2,                -- the base initial upward momentum of a dive cancel (a double jump out of a dive)
    DiveCancelGravity = 0.12,            --
    DoubleJumpRequiredHeightFromGround = 5, -- number of pixels off the ground the player must be to be eligible to double jump
    DoubleJumpStoredSpeed = 0,          -- how fast the player was moving horizontally when they double jumped
    LastDoubleJumpWasDiveCancel = false, -- was the last double jump a dive cancel?
    FramesSincePounce = -1,                -- how many frames since the player last "pounced" (crouch + roll + jump)
    TimeAfterPounceCanDoubleJump = 5,   -- how many frames after a sideways pounce the player is allowed to double jump
    RollWindowPastJump = 3,             -- how many frames after jumping will an action input still result in a hold
    CrouchAnimBounds = V{40, 44},       -- the current bounds of the crouch animation (so it change)
    JumpAnimBounds = V{13, 16, 0.4},         -- the current bounds of the jump animation (it also change)
    SLOW_JUMP_ANIM_BOUNDS = V{13, 16, 0.4},
    FAST_JUMP_ANIM_BOUNDS = {V{133, 136, 0.6}, V{137, 140, 0.6}},
    CrouchShimmyDelay = 0,              -- how many frames after crouching will pressing the action button still do a roll?
    LastRollPower = 0,                  -- records the last RollPower used for the previous roll\
    ShimmyPower = 3,                   -- how much RollPower the player gets while crouching
    RollPower = 5,                    -- the player's X velocity on the first frame of a roll
    MinPouncePower = 5,                  -- the X velocity out of a sideways pounce
    MaxPouncePower = 6.5,                  -- the X velocity out of a sideways pounce
    
    DisablePlayerControl = false,       -- disables movement input for cutscenes
    InInteraction = false,               -- disables entering new transitions during current ones

    InLedgeLunge = false,                   -- if the player is currently in a "ledge lunge" (AKA lunged into a staircase ledge)
    WaitingForLedgeLunge = false,           -- if the player just did a lunge and is waiting for ledge lunge
    FramesOnGroundAfterLedgeLungeBeforeChainEnds = 15,
    LedgeLungeCharge = 0,                   -- charges up with consecutive ledge lunges to charge a pounce
    LedgeLungeBoostRate = 0.2,            -- how much LedgeLungeCharge increases with each ledge lunge
    LedgeLungeGroundedDepletionRate = 0.1,  -- how much power LedgeLungeCharge loses per frame 
    LedgeLungePounceDepletionRate = 0.05,   -- how much power LedgeLungeCharge loses per pounce
    LedgeLungeAerialDepletionRate = 0.001,    -- how much power LedgeLungeCharge loses per frame 
    LedgeLungeMaxCharge = 5,                -- how big LedgeLungeCharge can get
    LedgeLungeGraceFrames = 4,              -- how many frames after a ledge lunge before LedgeLungeGroundedDepletionRate takes effect
    LedgeLungeStartCharge = 0.2,            -- how much charge for the first ledge in a ledge lunge
    LedgeLungeChain = 0,                    -- the amount of consecutive ledge lunges before spending 30 frames on the ground
    LedgeLungeStairCount = 0,               -- how many stairs the player has lunged down since otherwise disconnecting form the floor
    OnGroundAfterLedgeLunge = false,        -- if the player is on the ground and did a ledge lunge in the last 30 frames
    FramesOnGroundSinceLedgeLunge = -1,     -- how many frames since last ledge lunge (resets to -1 after 30 frames)

    LastLungeDownwardVelocity = 0,      -- how hard the player last lunged
    DiveCancelSpeedThreshold = 0,       -- how fast the player must be moving (X) to be eligible to dive cancel
    DiveWasLunge = false,               -- whether the last dive was a lunge or not (resets with dive state)
    DivePower = 5.25,                    -- the X velocity out of an aerial dive
    DiveUpwardVelocity = -0.2,         -- the Y velocity out of an aerial dive
    DiveCoyoteFrames = 7,               -- how many frames after a dive the player velocity remains at 0
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
    RunForwardDeceleration = 0.18,          -- how much the player speed decreases while moving forward at running speed
    RunBackwardDeceleration = 0.1,         -- how fast the player speed decreases while "braking" on the ground
    RunIdleDeceleration = 0.2,             -- how fast the player halts to a stop while idle on the ground
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
    PounceBackwardDeceleration = 0.25, -- how much the player decelerates while moving backwards in a pounce
    ChargedPounceForwardDeceleration = 0.205,   -- how much the player accelerates while in a pounce
    ChargedPounceIdleDeceleration = 0.16,   -- how mucgh the player decelerates while idle in a pounce
    ChargedPounceBackwardDeceleration = 0.25, -- how much the player decelerates while moving backwards in a pounce
    PreviousFloorHeight = 0,      -- the last recorded height of the floor
    PounceAnimCancelled = false,        -- during a pounce, whether to transition the player animation back to normal jump
    ConsecutivePouncesSpeedMult = 1.5, -- how much the player's speed is multiplied by during a new pounce (basically, how easily the player can speed up doing chained pounces)
    ConsecutiveLungesSpeedMult = 1.15,  -- how much the player's speed is multiplied by during a new pounce coming out of a downward lunge
    MoveDir = 0,                        -- 1 for left, -1 for right, 0 for neutral
    
    SlidingStopAnimation = false,
    SlidingStopReboundAnimFrames = 8,
    SlidingStopMiniReboundAnimFrames = 3,
    SlidingStopReboundAnimationState = -1,


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
    ActionBuffer = 0,                   -- how many action frames are currently remaining until action is no longe pressed
    BounceDebounce = 8,                 -- minimum number of frames between bounces
    FramesAfterBounceBeforeCanDoubleJump = 16,  -- it's in the name
    FramesSinceBounce = -1,             -- how many frames since bouncing off a spring object (resets to -1 on land)
    ForceJumpHeldFrames = 0,            -- set this value to something greater than 0 to simulate holding jump

    -- vars
    XHitbox = nil,                      -- the player's hitbox for walls
    YHitbox = nil,                      -- the player's hitbox for ceilings/floors

    Floor = nil,                        -- the current Prop acting as the "floor"
    FloorTileNo = nil,                  -- if the Floor is a Tilemap, record the tile number
    FloorTileLayer = nil,               -- if the Floor is a Tilemap, record the tile layer
    Wall = nil,                         -- the current Prop acting as the "wall" the player is against
    WallTileNo = nil,                   -- if the Wall is a Tilemap, record the tile number
    WallTileLayer = nil,                -- if the Wall is a Tilemap, record the tile layer
    WallDirection = "none",             -- direction the player is leaning into the wall
    WallBumpDirection = "none",         -- the direction of the last wall the player dove into
    FloorPos = nil,                     -- the last recorded floor position (for deltas)
    WallPos = nil,
    FloorDelta = nil,                   -- the movement of the floor over the past frame (calculated near the start of the update cycle)
    FloorLeftEdge = nil,                -- last recorded left edge of the floor (not tilemaps)
    FloorRightEdge = nil,               -- last recorded right edge of the floor (not tilemaps)
    DistanceAlongFloor = nil,           -- how far the player's position is along the floor (not tilemaps)
    VelocityBeforeHittingGround = 0,    -- the Y velocity of the player the frame they made contact with the floor

    -- input vars
    JustPressed = {},                   -- all inputs from the previous frame
    FramesSinceJump = -1,               -- will be -1 if the player is on the ground, or they fell off something without jumping
    FramesSinceAirborne = -1,           -- will be -1 if player is on the ground
    FramesSinceHoldingJump = -1,        -- similar to above, but resets to -1 once the jump button has been released
    FramesSinceDoubleJump = -1,         -- will be -1 if the player is grounded, or in the air and hasn't double jumped
    FramesSinceParry = -1,              -- will be -1 if the player.. isn't parrying
    FramesSinceGrounded = -1,           -- will be -1 if the player is in the air
    FramesSinceAgainstWall = -1,        -- will be -1 if the player is in the air
    FramesSinceDepartedWall = -1,       -- opposite state of FramesSinceAgainstWall
    FramesSinceRoll = -1,               -- will be -1 if the player is not in a roll state
    FramesSinceMoving = -1,             -- will be -1 if the player is currently idle
    FramesSinceIdle = -1,               -- will be -1 if the player is currently moving
    FramesSinceDive = -1,               -- will be -1 if the player isn't diving
    FramesSinceWallKick = -1,           -- will be -1 if grounded or hasn't done a wall kick that frame
    WallKickHangTime = 6,               -- amount of hang time after wall kicking
    DiveBlock = 10,                     -- amount of frames the player is ineligible for diving due to something
    
    FramesAgainstWallBeforeDirectionChange = 8,    -- amount of frames against a wall in midair before changing directions
    WallSlideSpeed = 1.5,
    WallSlideDecelerationSpeed = 0.3,

    PlayingWallSFX = false,             -- whether the wall slide sound is being played currently
    WallSFXVolume = 0,
    WallSFXMaxVolume = 0.15,


    -- other stuff
    Canvas = nil,                       -- rendering the player is hard
    CanvasSize = V{128, 128, 0.25},
    TailPoints = nil,                   -- keeps track of where segments of the tail have been
    TailLength = 9,                     -- amount of tail segments to record
    TailVisibleLength = 4,              -- actual drawn length
    



    -- TEMPORARY
    NearbyInteractable = nil,
    NearbyHoldableItem = nil,
    HeldItem = nil,
    LastHeldItem = nil,         -- doesn't reset after dropping
    CaughtHeldItemMidairChain = 0,
    CaughtLastHeldItemFromMidair = false,

    ThrewItemInAir = false,
    FramesSinceHoldingItem = -1,
    LastThrowDirection = 0,       -- -1 "left" or 1 "right" - the last direction an object was thrown at (resets on land)
    LastCatchDirecton = 0,        -- -1 "left" or 1 "right" - the last direction an object was caught from (resets on land)
    FramesSinceDroppedItem = -1,
    FramesSinceThrownItem = -1,
    PickupAnimDebounce = 0,
    HeldItemAnimationFrameOffsets = {
        [68] = 1,
        [71] = 1,
        [75] = 1,
        [76] = 1,
        [86] = 1,
        [89] = 1,

        -- picking up item (grounded - idle)
        [81] = 12,
        [82] = 8,
        [83] = 3,
        -- (grounded-moving)
        [105] = 12,
        [106] = 8,
        [107] = 3,
        -- (midair)
        [93] = 11,
        [94] = 7,
        [95] = 2,

        -- rolling into an item (grounded)
        [25] = 12,
        [26] = 10,
        [27] = 5,
        -- (midair)
        [37] = 12,
        [38] = 10,
        [39] = 5,

        -- diving
        [17] = 5,
        [18] = 9,
        [19] = 10,
        [20] = 10,

        -- -- crouch animations
        -- [29] = 12, [30] = 12, [31] = 12, [32] = 12, [33] = 12,
        -- [41] = 12, [42] = 12, [43] = 12, [44] = 12
    },

    SFX = {
        Jump = {
            Sound.new("game/assets/sounds/jump1.wav", "static"):Set("Volume", 2.0),
            Sound.new("game/assets/sounds/jump2.wav", "static"):Set("Volume", 2.0)
        },
        DoubleJump = {
            Sound.new("game/assets/sounds/double_jump1.wav", "static"):Set("Volume", 0.25),
            Sound.new("game/assets/sounds/double_jump2.wav", "static"):Set("Volume", 0.25),
            Sound.new("game/assets/sounds/double_jump3.wav", "static"):Set("Volume", 0.25),
            Sound.new("game/assets/sounds/double_jump4.wav", "static"):Set("Volume", 0.25),
        },
        DiveCancel = {
            Sound.new("game/assets/sounds/backflip1.wav", "static"):Set("Volume", 1.6),
            Sound.new("game/assets/sounds/backflip2.wav", "static"):Set("Volume", 1.6),
        },
        Dive = {
            Sound.new("game/assets/sounds/dive1.wav", "static"):Set("Volume", 1.6),
        },
        DiveSqueak = {
            Sound.new("game/assets/sounds/squeak_dive.wav", "static"):Set("Volume", 0.2),
        },
        LedgeLunge = {
            Sound.new("game/assets/sounds/ledgelunge1.wav", "static"):Set("Volume", 1.6),
        },
        Parry = {
            Sound.new("game/assets/sounds/parry3.wav", "static"):Set("Volume", 1.0),
            Sound.new("game/assets/sounds/parry4.wav", "static"):Set("Volume", 1.0),
        },
        Parry2 = {
            Sound.new("game/assets/sounds/parry1.wav", "static"):Set("Volume", 0.1),
            Sound.new("game/assets/sounds/parry2.wav", "static"):Set("Volume", 0.1),
        },
        FailParry = {
            Sound.new("game/assets/sounds/parry_fail1.wav", "static"):Set("Volume", 0.8),
            Sound.new("game/assets/sounds/parry_fail2.wav", "static"):Set("Volume", 0.8),
            Sound.new("game/assets/sounds/parry_fail3.wav", "static"):Set("Volume", 0.8),
        },
        FailParrySqueak = {
            Sound.new("game/assets/sounds/squeak_ow.wav", "static"):Set("Volume", 1.2),
        },
        Bonk = {
            Sound.new("game/assets/sounds/bonk1.wav", "static"):Set("Volume", 0.6),
        },
        WeakRoll = {
            Sound.new("game/assets/sounds/roll_weak1.wav"):Set("Volume", 0.1)
        },
        Roll = {
            Sound.new("game/assets/sounds/roll1.wav"):Set("Volume", 0.14)
        },
        FastRoll = {
            Sound.new("game/assets/sounds/roll_fast1.wav"):Set("Volume", 0.16)
        },
        RollWhoosh = {
            Sound.new("game/assets/sounds/roll_whoosh2.wav"):Set("Volume", 0.75)
        },
        ShimmyWhoosh = {
            Sound.new("game/assets/sounds/shimmy1.wav"):Set("Volume", 0.25)
        },
        PounceSqueak = {
            Sound.new("game/assets/sounds/squeak_pounce.wav", "static"):Set("Volume", 0.12),
        },
        PushWallSqueak = {
            Sound.new("game/assets/sounds/push-wall-01.wav", "static"):Set("Volume", 1),
            -- Sound.new("game/assets/sounds/push-wall-02.wav", "static"):Set("Volume", 1),
            Sound.new("game/assets/sounds/push-wall-03.wav", "static"):Set("Volume", 1),
        },
        UpwardDive = {
            Sound.new("game/assets/sounds/upwarddive.wav", "static"):Set("Volume", 0.22)
        },
    
        PickUpItem = {
            Sound.new("game/assets/sounds/item_pickup1.wav", "static"):Set("Volume", 0.2),
            Sound.new("game/assets/sounds/item_pickup2.wav", "static"):Set("Volume", 0.2)
        },
    
        CatchItem = {
            Sound.new("game/assets/sounds/item_catch1.wav", "static"):Set("Volume", 0.4),
            Sound.new("game/assets/sounds/item_catch2.wav", "static"):Set("Volume", 0.4),
            Sound.new("game/assets/sounds/item_catch3.wav", "static"):Set("Volume", 0.4),
        },
    
        GrabItemFail = {
            Sound.new("game/assets/sounds/grab_fail.wav", "static"):Set("Volume", 0.2),
        },
    
        Boing = {
            Sound.new("game/assets/sounds/boing1.wav", "static"):Set("Volume", 0.04),
        },

        StaminaRefill = {
            Sound.new("game/assets/sounds/stamina_refill.wav", "static"):Set("Volume", 0.025),
        },

        WallSlide = {
            Sound.new("game/assets/sounds/wall_slide1.wav", "static"):Set("Volume", 0.1):Set("Loop", true),
        },

        WallKick = {
            Sound.new("game/assets/sounds/wallkick_1.wav", "static"):Set("Volume", 0.4),
            Sound.new("game/assets/sounds/wallkick_2.wav", "static"):Set("Volume", 0.4),
        },

        Footstep = {
            Sound.new("game/assets/sounds/footstep/default/footstep-01.wav", "static"):Set("Volume", 0.075),
            Sound.new("game/assets/sounds/footstep/default/footstep-02.wav", "static"):Set("Volume", 0.075),
            Sound.new("game/assets/sounds/footstep/default/footstep-03.wav", "static"):Set("Volume", 0.075),
            Sound.new("game/assets/sounds/footstep/default/footstep-04.wav", "static"):Set("Volume", 0.075),
            Sound.new("game/assets/sounds/footstep/default/footstep-05.wav", "static"):Set("Volume", 0.075),
            Sound.new("game/assets/sounds/footstep/default/footstep-06.wav", "static"):Set("Volume", 0.075),
            Sound.new("game/assets/sounds/footstep/default/footstep-07.wav", "static"):Set("Volume", 0.075),
            Sound.new("game/assets/sounds/footstep/default/footstep-08.wav", "static"):Set("Volume", 0.075),
        },

        FootstepGlass = {
            Sound.new("game/assets/sounds/footstep/glass/footstep-01.wav", "static"):Set("Volume", 0.065),
            Sound.new("game/assets/sounds/footstep/glass/footstep-02.wav", "static"):Set("Volume", 0.065),
            Sound.new("game/assets/sounds/footstep/glass/footstep-03.wav", "static"):Set("Volume", 0.065),
            Sound.new("game/assets/sounds/footstep/glass/footstep-04.wav", "static"):Set("Volume", 0.065),
            Sound.new("game/assets/sounds/footstep/glass/footstep-05.wav", "static"):Set("Volume", 0.065),
            Sound.new("game/assets/sounds/footstep/glass/footstep-06.wav", "static"):Set("Volume", 0.065),
            Sound.new("game/assets/sounds/footstep/glass/footstep-07.wav", "static"):Set("Volume", 0.065),
            Sound.new("game/assets/sounds/footstep/glass/footstep-08.wav", "static"):Set("Volume", 0.065),
        },

        FootstepGrass = {
            Sound.new("game/assets/sounds/footstep/grass/footstep-01.wav", "static"):Set("Volume", 0.05),
            Sound.new("game/assets/sounds/footstep/grass/footstep-02.wav", "static"):Set("Volume", 0.05),
            Sound.new("game/assets/sounds/footstep/grass/footstep-03.wav", "static"):Set("Volume", 0.05),
            Sound.new("game/assets/sounds/footstep/grass/footstep-04.wav", "static"):Set("Volume", 0.05),
            Sound.new("game/assets/sounds/footstep/grass/footstep-05.wav", "static"):Set("Volume", 0.05),
        },
        FootstepMetal = {
            Sound.new("game/assets/sounds/footstep/metal/footstep-01.wav", "static"):Set("Volume", 0.035),
            Sound.new("game/assets/sounds/footstep/metal/footstep-02.wav", "static"):Set("Volume", 0.035),
            Sound.new("game/assets/sounds/footstep/metal/footstep-03.wav", "static"):Set("Volume", 0.035),
            Sound.new("game/assets/sounds/footstep/metal/footstep-04.wav", "static"):Set("Volume", 0.035),
        }
    },

    -- internal properties
    _usingPerformanceMode = false,  -- the GameScene controls whether PerformanceMode is on. Player just listens. 
    _updateStep = false,    -- internally used for performance mode handling
    _super = "Prop",
    _global = true
}
local EMPTYVEC = V{0,0}

-- the black outline shader
Player.Shader = Shader.new("game/assets/shaders/outline.glsl"):Send("step",{1/Player.CanvasSize.X,1/Player.CanvasSize.Y}) -- 1/ 24 (for tile size) / 12 (for tile count)


local Y_HITBOX_HEIGHT = 16
local X_HITBOX_HEIGHT = 12
local Y_HITBOX_HEIGHT_CROUCH = 8
local X_HITBOX_HEIGHT_CROUCH = 6

local balls = 0

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
    
    -- set animation callbacks
    newPlayer.Texture:AddCallback({
        6, 9, -- walking footsteps
        86, 89, -- walking w/ held item
        
    }, function (frameNo)
        newPlayer:PlayQuietFootstepSound()
        
        
    end)

    newPlayer.Texture:AddCallback({
        113, 116 -- pushing against wall
    }, function()
        newPlayer:PlayCustomFootstepSound(nil, 0.5, nil, 0.35)
        if newPlayer.FramesSinceAgainstWall > 40 then
            newPlayer:PlaySFX("PushWallSqueak", 1.5, 0, 0.05)
        end
    end)

    newPlayer.Texture:AddCallback({
        62, 65, -- running footsteps
        68, 71, -- running w/ held item
    }, function ()
        newPlayer:PlayLoudFootstepSound()
        newPlayer:GetChild("RunFootstepDust"):Emit{
            Position = newPlayer.Position,
            Velocity = V{-newPlayer.Velocity.X, 0},
            Color = newPlayer.TrailColor,
            -- Acceleration = vel*-2,
            Size = V{8 * sign(newPlayer.DrawScale.X), 8} * math.clamp(math.abs(newPlayer.Velocity.X), 4, 8)/4
        }
    end)

    
    newPlayer.Texture:AddCallback({61}, function() -- running, back leg out
        newPlayer.LeapAnimSwitch = false
    end)
    newPlayer.Texture:AddCallback({64}, function() -- running, front leg out
        newPlayer.LeapAnimSwitch = true
    end)
    
    newPlayer.SweatTexture = Animation.new("chexcore/assets/images/test/player_sweat_drops.png", 1, 4):AddProperties{Duration = 0.5, LeftBound = 1, RightBound = 4}
    newPlayer.YHitbox = newPlayer:Adopt(yHitboxBASE:Clone())
    newPlayer.XHitbox = newPlayer:Adopt(xHitboxBASE:Clone())
    newPlayer.Position = Player.Position:Clone()
    newPlayer.Size = Player.Size:Clone()
    newPlayer.Canvas = Canvas.new(Player.CanvasSize())
    newPlayer.TailPoints = {}
    newPlayer.TouchEvents = {}
    newPlayer.JustPressed = {}
    newPlayer.DrawScale = V{1,1}

    newPlayer.LastSFX_ID = {}

    newPlayer.SFX.Jump[1].Test = true

    Prop.new{
        Name = "InteractIndicator",
        AnchorPoint = V{0.5,0.5},
        Texture = Animation.new("game/assets/images/interact-notifier.png", 4, 10):Properties{
            Duration = 0.8,
            LeftBound = 1, RightBound = 10,
            Loop = false
        },
        Size = V{32,32},
        Color = V{1,0,0},
        Visible = false,
        Position = V{348,2400},
    }:Nest(newPlayer)

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
            -- if math.random(1, 100) == 1 then
            --     self:Emit{
            --         Position = self.Position
            --     }
            -- end

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
            -- if math.random(1, 100) == 1 then
            --     self:Emit{
            --         Position = self.Position
            --     }
            -- end

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
        Name = "RunFootstepDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 1},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{8,8},
        ParticleSize = V{8, 8},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_run_footstep.png", 1, 4):Properties{Duration = 0.5},
        ParticleLifeTime = 0.5,
        Color = V{0,0,0,0},
        ParticleColor = newPlayer.TrailColor,
        Update = function (self, dt)
    end}:Nest(newPlayer)

    Particles.new{
        Name = "WallSlideDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 0.5},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{8,8},
        ParticleSize = V{8, 8},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_wall_slide.png", 1, 4):Properties{Duration = 0.5},
        ParticleLifeTime = 0.5,
        Color = V{0,0,0,0},
        ParticleColor = newPlayer.TrailColor,
        Update = function (self, dt)
    end}:Nest(newPlayer)

    Particles.new{
        Name = "WallKickDust",
        AnchorPoint = V{0.5, 0.5},
        ParticleAnchorPoint = V{0.5, 0.5},
        Texture = Texture.new("chexcore/assets/images/empty.png"),
        RelativePosition = false,
        Size = V{8,8},
        ParticleSize = V{8, 8},
        LoopAnim = false,
        ParticleTexture = Animation.new("chexcore/assets/images/test/player/dust_wall_kick.png", 1, 5):Properties{Duration = 0.3},
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
        a = "move_left", gp_dpleft = "move_left", gp_lsleft = "move_left",
        d = "move_right", gp_dpright = "move_right", gp_lsright = "move_right",
        w = "interact", gp_dpup = "interact", gp_lsup = "interact",
        space = "jump", gp_a = "jump", gp_b= "jump",
        lshift = "action", gp_x = "action", gp_y = "action", gp_leftshoulder = "action", gp_rightshoulder = "action",
        e = "action",
        s = "crouch", gp_dpdown = "crouch", gp_lsdown = "crouch",

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
    self.FloorTileNo = nil
    self.FloorTileLayer = nil

    self.FloorLeftEdge, self.FloorRightEdge = nil, nil
    self.DistanceAlongFloor = nil
    self.FloorSurfaceInfo = nil
    self.FramesSinceAirborne = 0
    -- if self.LedgeLungeStairCount == 0 then
        
    --     self.LedgeLungeChain = 0
    -- end
    


    self.OnGroundAfterLedgeLunge = false
    -- we actually don't do this until later; FloorDelta is set to nil once there are no more coyote frames (in UpdateFrameValues)
    -- self.FloorDelta = nil
end

function Player:DisconnectFromWall()
    self.Wall = nil
    self.FramesSinceDepartedWall = 0
    self.WallTileNo = nil
    self.WallTileLayer = nil
    self.WallDirection = "none"
end

function Player:GetFloorFriction()
    return self.FloorSurfaceInfo and self.FloorSurfaceInfo.Friction or 1
end

function Player:FloorPreventsJumping()
    return self.FloorSurfaceInfo and self.FloorSurfaceInfo.PreventJump
end


function Player:ConnectToFloor(floor, surfaceInfo, tileNo, tileLayer)
    
    -- if true then return flase end
    if not self.Floor then
        -- just landed
        self:PlayRegainStaminaSound()
        self.VelocityBeforeHittingGround = self.Velocity.Y
        self.FramesSinceGrounded = 0
        self.FloorSurfaceInfo = surfaceInfo.Top
        self.LastFloorSurfaceInfo = surfaceInfo.Top
        self.FloorTileNo = tileNo
        self.FloorTileLayer = tileLayer
        
        self:PlayLoudFootstepSound(1)
        if not self.Wall then
            Timer.Schedule(math.random(1,(self.FramesSinceDive > -1 and 2 or 3))/60, function ()
                (self.PlayLoudFootstepSound)(self, 1)
            end)
        end


        if self.FramesOnGroundSinceLedgeLunge > -1 then
            self.OnGroundAfterLedgeLunge = true
        end

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

function Player:ConnectToWall(wall, direction, surfaceInfo, tileNo, tileLayer)
    if not self.Wall then
        -- just touched wall
        self.FramesSinceAgainstWall = 0
    end
    self.Wall = wall
    self.WallDirection = direction
    self.WallPos = wall.Position:Clone()
    self.LastWallPos = wall.Position:Clone()

    -- collect wall material info
    self.WallSurfaceInfo = surfaceInfo[direction=="left" and "Left" or "Right"]
    self.LastWallSurfaceInfo = self.WallSurfaceInfo
    self.WallTileNo = tileNo
    self.WallTileLayer = tileLayer


    if self.FramesSinceDive == -1 and math.abs(self.Velocity.X) > self.WalkSpeed then
        self:PlayCustomFootstepSound(self:GetWallMaterial(), 0.75, 0, 0.4)
    end

    -- housekeeping
    self.FramesSincePounce = -1

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
            -- if not self.Floor:IsA("Tilemap") then


                self.FloorDelta = self.FloorPos - self.Floor.Position

                self.Position = (self.Position - self.FloorDelta)
                
                self:SetEdge("bottom", self.Floor:GetEdge("top", self.FloorTileNo, self.FloorTileLayer))
            -- else
            --     self.FloorDelta = self.FloorPos - self.Floor.Position
            --     self.Position = (self.Position - self.FloorDelta)
            --     self.Velocity.Y = 0
            -- end
        end
        -- print(self.Floor:GetEdge("top", self.FloorTileNo, self.FloorTileLayer))
        -- self.Position.Y = self.Floor:GetEdge("top", self.FloorTileNo, self.FloorTileLayer)
        -- self:SetEdge("bottom", self.Floor:GetEdge("top", self.FloorTileNo, self.FloorTileLayer))
        self.FloorPos = self.Floor.Position:Clone()
        
        self.PreviousFloorHeight = self:GetEdge("bottom")
    elseif self.LastFloor then
        self.LastFloorDelta = self.LastFloorPos - self.LastFloor.Position
    end
end

function Player:FollowWall()
    -- if true then return end
    if self.Wall then
        local wallSign = (self.WallDirection=="left"and-1 or 1)
        if self.WallPos and ((self.FramesSinceParry == -1 or self.FramesSinceParry > 5) and (self.FramesSinceRoll == -1)) and (self:GetBodyOrientation() == wallSign or self.MoveDir == wallSign)  --[[and self.WallPos ~= self.Wall.Position]] then
            -- if not self.Floor:IsA("Tilemap") then
            self:AlignHitboxes()
                self.WallDelta = self.WallPos - self.Wall.Position
                -- self.Position.X = self.Position.X - self.WallDelta.X*2

                if not self.Floor then
                    self.Position.Y = self.Position.Y - self.WallDelta.Y
                end
                -- self.Position = (self.Position - self.WallDelta) --+ V{2*(self.WallDirection=="left" and -1 or 1),0}
                
                if self.WallDirection == "left" then
                    self.YHitbox:SetEdge("left", self.Wall:GetEdge("right", self.WallTileNo, self.WallTileLayer))
                elseif self.WallDirection == "right" then
                    self.YHitbox:SetEdge("right", self.Wall:GetEdge("left", self.WallTileNo, self.WallTileLayer))
                end

                self.Position = self.YHitbox.Position --+ V{2 * sign(self.WallDelta.X),0}
                
                -- self.Position.X = self.Position.X  - self.WallDelta.X/4

                self.Velocity.X = 0
                
            -- else
            --     self.FloorDelta = self.FloorPos - self.Floor.Position
            --     self.Position = (self.Position - self.FloorDelta)
            --     self.Velocity.Y = 0
            -- end
        end

        self.WallPos = self.Wall.Position:Clone()
        
        -- self.PreviousFloorHeight = self:GetEdge("bottom")
    -- elseif self.LastFloor then
    --     self.LastFloorDelta = self.LastFloorPos - self.LastFloor.Position
    end
end

------- collison function
local justLanded, hitCeiling, inParry
local pushX, pushY
function Player:Unclip(forTesting, ignoreX, ignoreY)
    self.UnclipCount = self.UnclipCount + 1
    if self.Floor and not ignoreY then
        self.Position.Y = self.Position.Y + 1
    end
    justLanded = false
    hitCeiling = false
    
    
    
    if self.HeldItem and self.HeldItem.ExtendsHitbox then
        if not ignoreX then pushX = self:UnclipX(forTesting) end
        if not ignoreY then pushY = self:UnclipY(forTesting) end
        
    else
        if not ignoreX then pushX = self:UnclipX(forTesting) end
        if not ignoreY then pushY = self:UnclipY(forTesting) end
    end


    if (pushX == 0 or self.HeldItem) and hitCeiling then
        
        if inParry then
            -- skip
        else
            if self.FramesSincePounce > -1 and self.FramesSincePounce < 30 and self.MoveDir ~= 0 then
                -- if pouncing and hitting a ceiling, knock the player back down to the floor (makes pounce chaining easier in corridors)
                self.Velocity.Y = math.max(0, -self.Velocity.Y)
                self.DiveBlock = self.DiveBlock + 10
            else
                if self.FramesSinceDoubleJump == -1 then
                    self.Velocity.Y = math.max(0, self.Velocity.Y)
                end
                
            end
        end
    end
    
    

    return pushX, pushY
end

function Player:UnclipY(forTesting, returnFirstHit)
    -- make sure hitboxes are aligned first!!!
    self:AlignHitboxes()
    pushY = 0

    local yColliders = (self.HeldItem and self.HeldItem.ExtendsHitbox) and {self.HeldItem, self.YHitbox} or {self.YHitbox}
    local activeCollider

    for _, collider in ipairs(yColliders) do
        for solid, hDist, vDist, tileID, tileNo, tileLayer in collider:CollisionPass(self._parent, true) do
            


            local face = Prop.GetHitFace(hDist,vDist)
            -- we check the "sign" of the direction to make sure the player is "moving into" the object before clipping back
            local faceSign = face == "bottom" and 1 or face == "top" and -1 or 0
            if (solid ~= self.YHitbox and solid ~= self.XHitbox and solid ~= self.HeldItem) and (faceSign == sign(self.Velocity.Y +0.01) or face == "none" or returnFirstHit) and not solid.Passthrough then
                


                local surfaceInfo = solid:GetSurfaceInfo(tileID)

                if returnFirstHit and (face == "none" or (face == "bottom" and not surfaceInfo.Bottom.Passthrough) or (face == "top" and not surfaceInfo.Top.Passthrough) or (face == "right" and not surfaceInfo.Right.Passthrough) or (face == "left" and not surfaceInfo.Left.Passthrough)) then

                    return solid
                end
                
                if (self.Velocity.Y >= 0) and not surfaceInfo.Top.Passthrough and face == "bottom" and not (collider == self.HeldItem and not collider.CanBeOverhang) then

                    pushY = math.abs(pushY) > math.abs(vDist or 0) and pushY or (vDist or 0)
                    if not self.Floor then
                        -- just landed
                        justLanded = true
                    end
    
                    -- -4 IS ARBITRARY!! IDK IF IT WILL CAUSE PROBLEMS!!!!!!!!!!
                    if not forTesting and pushX == 0 and pushY >= -4 then
                        
                        if collider ~= self.HeldItem then
                            self:ConnectToFloor(solid, surfaceInfo, tileNo, tileLayer)
                        elseif self.HeldItem and self.HeldItem.CanBeOverhang and face == "bottom" then
                            self.ShouldCheckForHeldItemOverhang = true
                            -- self.Velocity.Y = 0
                        else
                            pushY = 0
                            --self.Position.X = self.Position.X - 1
                        end
                    end
                elseif self.Velocity.Y <= 0 and not surfaceInfo.Bottom.Passthrough and face == "top" then

                    pushY = math.abs(pushY) > math.abs(vDist or 0) and pushY or (vDist or 0)
                    hitCeiling = true
                end

                self:AlignHitboxes()

                if pushY ~= 0  then
                    activeCollider = collider
                    -- we used to break here, but for detection of other options, we don't anymore
                    -- break
                end
            end
    
            
            
            if collider ~= self.HeldItem and not self.TouchEvents[solid] and not solid:IsA("Tilemap") then
                self.TouchEvents[solid] = true
                if solid.OnTouchEnter then solid:OnTouchEnter(self) end
                if solid.OnTouchStay then solid:OnTouchStay(self) end
                if solid.InteractActivate then
                    if self.NearbyInteractable and self.NearbyInteractable.InteractLeave then
                        -- overlapping interactables; leave current one
                        self.NearbyInteractable:InteractLeave(self)
                    end
                    self.NearbyInteractable = solid
                    if solid.InteractEnter then solid:InteractEnter(self) end

                    -- set up interact notifier
                    local indicator = self:GetChild("InteractIndicator")
                    indicator.Position = solid.Position + (solid.InteractIndicatorOffset or V{30,-30})
                    indicator.Visible = true
                    indicator.Texture:Properties{
                        Clock = 0,
                        LeftBound = 1, RightBound = 10,
                        IsPlaying = true
                    }

                end
            end

            
        end
    end
    

    -- roll out of a fast dive
    if justLanded and self.FramesSinceDive > -1 then
        if math.abs(self.Velocity.X) > self.DiveLandRollThreshold and self.MoveDir == sign(self.Velocity.X) then
            self.PreviousFloorHeight = self.Position.Y
            self:Roll()
            self.RolledOutOfDive = true
            self.FramesSinceDive = -1
        else
            self:StartCrouch()
            -- self:EndCrouch()
        end
    end

    if not forTesting then
        -- try to "undo" if the player clipped too hard
        
        if activeCollider and math.abs(pushY) > self.YHitbox.Size.Y/2 then
            print("FIXING Y")
            -- self.Position.Y = self.Position.Y - self.VelocityLastFrame.Y
            self.Position.Y = self.Position.Y + pushY - sign(pushY) * 0.01
        else
            self.Position.Y = self.Position.Y + pushY - sign(pushY) * 0.01
        end
    end
    
    if justLanded and math.abs(self.Velocity.X) > 1 and not forTesting then
        local vel = V{40, 0} * math.clamp(math.abs(self.Velocity.X), 0.75, 5) * sign(self.DrawScale.X)
        self:GetChild("ForwardLandDust"):Emit{
            Color = self.TrailColor,
            Position = self.Position,
            Velocity = vel,
            Acceleration = vel*-2,
            Size = V{8 * sign(self.DrawScale.X), 8} * math.clamp(math.abs(self.Velocity.X), 4, 8)/4
        }
    end

    

    return pushY
end

function Player:UnclipX(forTesting)
    self:AlignHitboxes()

    -- reset holdable item check (we do it on this pass)
    self.NearbyHoldableItem = nil

    pushX = 0
    local xColliders = (self.HeldItem and self.HeldItem.ExtendsHitbox) and {self.HeldItem, self.XHitbox} or {self.XHitbox}
    local activeCollider

    for _, collider in ipairs(xColliders) do
        for solid, hDist, vDist, tileID, tileNo, tileLayer in collider:CollisionPass(self._parent, true) do
            
            local face = Prop.GetHitFace(hDist,vDist)
            local surfaceInfo = solid:GetSurfaceInfo(tileID)
            
            
            if (solid ~= self.YHitbox and solid ~= self.XHitbox and solid ~= self.HeldItem) and not solid.Passthrough then
    
                
                
                if (self.Velocity.X >= 0 and face == "right" and not surfaceInfo.Left.Passthrough) or (self.Velocity.X <= 0 and face == "left" and not surfaceInfo.Right.Passthrough) then
                    pushX = math.abs(pushX) > math.abs(hDist) and pushX or hDist
                    self:AlignHitboxes()
                    
                    self:ConnectToWall(solid, face, surfaceInfo, tileNo, tileLayer)
                end
            end
            
            if solid.IsHoldable then
                self.NearbyHoldableItem = solid
            end

            if surfaceInfo.Top.IsSpring and
                self.Velocity.Y > 0 and
                self.HeldItem ~= solid and
                (not (surfaceInfo.Top.RequiresActionReleased and self.InputListener:IsDown("action")) or (self.InputListener:IsDown("action") and self.InputListener:IsDown("crouch"))) and
                (solid:IsA("Tilemap") or (self.YHitbox:GetEdge("bottom") < solid:GetEdge("bottom") and self.YHitbox:GetEdge("bottom") > solid:GetEdge("top"))) and
                (self.FramesSinceBounce == -1 or self.FramesSinceBounce >= self.BounceDebounce) and
                (self.LastHeldItem ~= solid or self.FramesSinceDroppedItem > 12) then
                    self:ResetJumpStamina()
                    self.LeapAnimSwitch = not self.LeapAnimSwitch
                    self:Jump(true)
                    self.Velocity.Y = -(surfaceInfo.Top.SpringPower or self.JumpPower)
                    self:PlaySFX("DoubleJump")
                    self:PlaySFX("Boing", 0.7, 1)
                    
                    self.FramesSinceBounce = 0
                    self.ForceJumpHeldFrames = surfaceInfo.Top.ForceJumpHeldFrames or 6
                    -- if self.MoveDir ~= 0 then self.DrawScale.X = math.abs(self.DrawScale.X) * self.MoveDir end
                    if solid.ActivateSpring then solid:ActivateSpring(tileID) end
            end
        end
    
        if pushX ~= 0 then
            activeCollider = collider
            break
        end
    end

    if not forTesting then
        -- again, try to "undo" any extreme clipping
        if activeCollider and math.abs(pushX) > activeCollider.Size.X/2 then
            -- print("FIXING X")
            self.Position.X = self.Position.X - self.VelocityLastFrame.X
        else
            self.Position.X = self.Position.X + pushX
        end
    end

    inParry = (self.FramesSinceParry > -1 and self.FramesSinceParry < 10) and self.FramesSinceDoubleJump == -1 and self.FramesSinceDive == -1
    

    return pushX
end

local TILE_SIZE_LEDGE_LUNGE = 16
function Player:ValidateFloor()
    local wasOnGroundAfterLedgeLunge = self.OnGroundAfterLedgeLunge
    
    if self.Floor then
        -- check if we've collided with the current floor or not
        self:AlignHitboxes()
        self.YHitbox.Position.Y = self.Position.Y + 1
        
        self.Velocity.Y = 0
        local hit --, hDist, vDist = self.Floor:CollisionInfo(self.YHitbox)

        for solid, hDist, vDist, tileID, tileNo, tileLayer in self.YHitbox:CollisionPass(self.Floor, true, false, true) do
            local surfaceInfo = solid:GetSurfaceInfo(tileID)
            local face = Prop.GetHitFace(hDist,vDist)
            if self.Velocity.Y >= 0 and not surfaceInfo.Top.Passthrough and face == "bottom" then
                hit = solid
                self.FloorSurfaceInfo = surfaceInfo.Top
                self.LastFloorSurfaceInfo = surfaceInfo.Top
                self.FloorTileNo = tileNo
                self.FloorTileLayer = tileLayer
                self:SetTrailColor(self.FloorSurfaceInfo and self.FloorSurfaceInfo.DustColor or self.DefaultTrailColor)
                break
            end
        end
        if not hit then

            self:SetTrailColor(self.DefaultTrailColor)

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

                
                local ledgeLungeStairChain = self.LedgeLungeStairCount
                
                if self.FramesSinceRoll == -1 then
                    self.Texture.Clock = 0
                end
                self.HangStatus = self.DropHangTime+1
                -- set up coyote frames
                self.CoyoteBuffer = self.CoyoteFrames
    
                if self.FramesSinceLastLunge < self.LedgeLungeWindow and self:IsHoldingCrouch() and self.InputListener:IsDown("action") then
                    
                    -- next step: only ledge lunge when there's a tile below the player
                    local oldPosY = self.Position.Y
                    self.Position.Y = self.Position.Y + TILE_SIZE_LEDGE_LUNGE + 2
                    
                    local pushY = self:UnclipY(true)


                    if pushY ~= 0 then
                        local vx = self.Velocity.X
                        self:Dive()
                        Chexcore._frameDelay = Chexcore._frameDelay + 0.03333333
                        self.DiveExpired = false
                        self.Velocity.Y = self.TerminalLedgeLungeVelocity
                        -- self.Velocity.X = self.Velocity.X * 1.3 --(math.abs(self.Velocity.X) + 1) * sign(self.Velocity.X)
                        self.InLedgeLunge = true
                        self.LedgeLungeStairCount = ledgeLungeStairChain + 1
                        if self.WaitingForLedgeLunge then
                            if wasOnGroundAfterLedgeLunge or self.LedgeLungeChain == 0 then
                                self.LedgeLungeChain = self.LedgeLungeChain + 1
                            end
                            self.WaitingForLedgeLunge = false
                        end
                        
                        local faceDirection = self.MoveDir ~= 0 and self.MoveDir or sign(self.DrawScale.X)
                        self.Velocity.X = faceDirection * math.min(math.max(self.DivePower, math.abs(vx) - 0.55), 8)
                        self.FramesOnGroundSinceLedgeLunge = 0

                        if self.LedgeLungeCharge == 0 then
                            self.LedgeLungeCharge = self.LedgeLungeStartCharge 
                        else
                            self.LedgeLungeCharge = math.min(self.LedgeLungeCharge + self.LedgeLungeBoostRate, self.LedgeLungeMaxCharge)
                        end
                        
                        self.LungePitch = self.LungePitch + (self.LedgeLungeChain/20)
                        self:PlaySFX("LedgeLunge", self.LungePitch)
                        self.ActiveTerminalLedgeLungeVelocity = self.TerminalLedgeLungeVelocity
                        self.Position.Y = oldPosY + 6
                    else
                        self.Position.Y = oldPosY
                        -- self.LedgeLungeStairCount = 0
                    end

                    
                    self:AlignHitboxes()

                else
                    -- self.LedgeLungeStairCount = 0
                end
                
                self:DisconnectFromFloor()                
            end
        end
    end

    if self.ShouldCheckForHeldItemOverhang and self.HeldItem then
        
        self.HeldItem.Position.Y = self.HeldItem.Position.Y + 1
        
        local hit --, hDist, vDist = self.Floor:CollisionInfo(self.YHitbox)

        for solid, hDist, vDist, tileID in self.HeldItem:CollisionPass(self._parent, true) do
            local surfaceInfo = solid:GetSurfaceInfo(tileID)
            local face = Prop.GetHitFace(hDist,vDist)
            if (solid ~= self.XHitbox and solid ~= self.YHitbox and solid ~= self.HeldItem) and not solid.Passthrough and self.Velocity.Y >= 0 and not surfaceInfo.Top.Passthrough and face == "bottom" then
                hit = solid
                break
            end
        end

        if hit then
            self.Velocity.Y = 0
            
            self.IgnoreGravityThisFrame = true
        end
        
        self:UpdateHeldItem()
    end

    self:AlignHitboxes()
end

function Player:ValidateWall()
    
    if self.Wall then
        -- check if we've collided with the current floor or not
        self:AlignHitboxes()
        local dir = ((self.FramesSinceDive > -1 ) and self:GetBodyOrientation()) -- if diving, refer to body orientation only
            or (self.MoveDir ~= 0 and self.MoveDir)                           -- if holding a direction, refer to held direction
            or (self.WallDirection == "left" and -1 or 1)                     -- if idle, refer to direction of supposed wall
        local hit

        for _, collider in ipairs((self.HeldItem and self.HeldItem.ExtendsHitbox) and {self.XHitbox, self.HeldItem} or {self.XHitbox}) do
            collider.Position.X = collider.Position.X + dir
            -- hit = hit or self.Wall:CollisionInfo(collider)
            
            for solid, hDist, vDist, tileID, tileNo, tileLayer in collider:CollisionPass(self.Wall, true, false, true) do
                if solid then
                    local surfaceInfo = solid:GetSurfaceInfo(tileID)
                    local face = Prop.GetHitFace(hDist,vDist)
                    
                    if (self.Velocity.X >= 0 and face == "right" and not surfaceInfo.Left.Passthrough) or (self.Velocity.X <= 0 and face == "left" and not surfaceInfo.Right.Passthrough) or ((face=="left" or face=="right") and self.FramesSinceDive > -1) then
                        hit = solid
                        self.WallSurfaceInfo = surfaceInfo[face=="left" and "Left" or "Right"]
                        self.LastWallSurfaceInfo = self.WallSurfaceInfo
                        self.WallTileNo = tileNo
                        self.WallTileLayer = tileLayer
                    end
                end
            end

        end
        
        if not hit then
            self:DisconnectFromWall()
        else
            self.Velocity.X = 0
        end
    end
    self:UpdateHeldItem()
    self:AlignHitboxes()
end
---------------------------------------------------------------------------------

------------------------ INPUT PROCESSING -----------------------------
function Player:ProcessInput(dt)

    local input = self.InputListener

    if self.JustPressed["HITBOXTOGGLE"] then
        self.XHitbox.Visible = not self.XHitbox.Visible
        self.YHitbox.Visible = not self.YHitbox.Visible
        self:GetLayer():GetParent().GuiLayer:GetChild("StatsGui").Visible = not self:GetLayer():GetParent().GuiLayer:GetChild("StatsGui").Visible
    end

    if self.JustPressed["f11"] or ((input:IsDown("lalt") or input:IsDown("ralt")) and input:JustPressed("return")) then
        love.window.setFullscreen( not love.window.getFullscreen(), "desktop" )
    end

    if self.JustPressed["b"] then
        self:GetParent():Adopt(Basketball.new():Properties{Position = self.Position+V{0,-15}, Collider = self:GetParent():GetChild("_type", "Tilemap")})
        balls = balls + 1
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


    if self.DisablePlayerControl then
        self.MoveDir = 0
        return -- don't process any input
    end


    if self.NearbyInteractable and self.InputListener:JustPressed("interact") and not self.InInteraction then
        self.NearbyInteractable:InteractActivate(self)
    end

    -- crouch input
    if self.CrouchTime == 0 and self.InputListener:IsDown("crouch") and (self.FramesSinceRoll == -1 or self.FramesSinceRoll == 12) then
        if self.Floor then
            
            self:StartCrouch()       
        end
        
        if self.HeldItem then
            self:PutDownItem()
        end

    end
    

    -- action input
    if self.JustPressed["action"] then
        -- let the action input linger for a few frames in case player inputs early
        self.ActionBuffer = self.ActionFrames
    end


    -- check if the player is in the vicinity of a held item:
    if input:IsDown("action") then
        if self.HeldItem then
            
            self.ActionBuffer = 0
            if self.JustPressed["action"] then
                -- throw held item

                local lastThrowDir = self.LastThrowDirection
                self:ThrowItem()

                if not self.Floor then
                    local oldYVel = self.Velocity.Y
                    local djFrames = self.FramesSinceDoubleJump
                    self:DoubleJump(true)
                    self.FramesSinceDoubleJump = djFrames
                    self.ThrewItemInAir = true
                    self.Velocity.X = 0
                    
                    if self.CaughtHeldItemMidairChain > 0 then
                        if lastThrowDir == self.LastThrowDirection then
                            
                            self.Velocity.Y = oldYVel
                        end
                        
                        if self.CaughtHeldItemMidairChain then
                            self.DiveExpired = true
                        end
                        
                    end
                else
                    self:PlaySFX("DoubleJump")
                end
            end
        elseif self.NearbyHoldableItem and not input:IsDown("crouch") then
            local item = self.NearbyHoldableItem
            self:PickUpItem(self.NearbyHoldableItem, dt)
            self.ActionBuffer = 0

            -- if grabbing while airborne, do a little parry
            if not self.Floor and (self.NearbyHoldableItem.PickupDebounce == 0) then
                local djFrames = self.FramesSinceDoubleJump
                local oldYVel = self.Velocity.Y
                self:DoubleJump(true)
                self.FramesSinceDoubleJump = djFrames
                self:PlaySFX("CatchItem")
                local catchDir = item and sign(item.Velocity.X) or 0

                -- if already caught in midair from same direction, don't give enough height
                if self.CaughtHeldItemMidairChain > 0 then
                    self.Velocity.Y = oldYVel
                end
                self.LastCatchDirection = catchDir

                self.CaughtHeldItemMidairChain = self.CaughtHeldItemMidairChain + 1
                self.Velocity.X = 0
                self.DiveExpired = false
            end
        end
    end

    -- safeguard: drop item if held and crouching
    if input:IsDown("crouch") and self.HeldItem then
        self:PutDownItem()
    end


    local blockJump

    if not self.DiveExpired and  self.ActionBuffer > 0 and (not self.Floor and self.CoyoteBuffer == 0) and self.FramesSinceDive == -1 and (self.FramesSinceJump == -1 or self.FramesSinceJump > 4) and self.FramesSinceRoll == -1 and (self.FramesSincePounce == -1 or self.PounceAnimCancelled or self.FramesSinceDoubleJump > -1 or self.InputListener:IsDown("crouch")) then
        -- dive

        if not (self.MoveDir == 0 and input:IsDown("crouch")) then -- we don't let the dive action happen if holding neutral and crouch
            self:Dive()
        end
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
            if (self.Floor or self.CoyoteBuffer > 0) and not self:FloorPreventsJumping() then
                self:Jump()
                
                
            elseif not self.HeldItem and (self.FramesSincePounce == -1 or self.FramesSincePounce > self.TimeAfterPounceCanDoubleJump) and (self.FramesSinceDive == -1 or math.abs(self.Velocity.X) >= self.DiveCancelSpeedThreshold) and (self.FramesSinceBounce == -1 or self.FramesSinceBounce >= self.FramesAfterBounceBeforeCanDoubleJump) then
                
                local wallDir = self.WallDirection=="left" and -1 or 1
                --                                                                                                                                                                                                                                                                                                      LESS TIME WITHOUT USED DOUBLEJUMP V    V MORE TIME AFTER USED DOUBLEJUMP                                 
                if (
                    (self.Wall or (self.FramesSinceDepartedWall > -1 and self.FramesSinceDepartedWall < 20)) and 
                    (self.Velocity.Y >= self.WallSlideSpeed or self.FramesSinceDoubleJump > -1 or self.FramesSinceWallKick > -1)
                ) and
                    (wallDir==-1 and self.FramesSinceHoldingLeft or self.FramesSinceHoldingRight) < (self.FramesSinceDoubleJump == -1 and 15 or 30)
                and
                    self:GetBodyOrientation() == wallDir 
                and (
                    (self.FramesSinceWallKick == -1 or self.FramesSinceWallKick < 10) or ((self.FramesSinceWallKick > -1 or self.FramesSinceWallKick > 4) and self.Wall)
                ) and self.FramesSinceWallKick then
                    self:WallKick()
                elseif self.FramesSinceDoubleJump == -1 then
                    self:DoubleJump()
                end
                
            end
        end


    -- left/right input
    self.MoveDir = (input:IsDown("move_left") and -1 or 0) + (input:IsDown("move_right") and 1 or 0)

    if self.MoveDir == -1 then
        self.FramesSinceHoldingLeft = 0
    elseif self.MoveDir == 1 then
        self.FramesSinceHoldingRight = 0
    end

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
        
        accelSpeed = accelSpeed * self:GetFloorFriction()
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
    
end

function Player:IsHoldingCrouch()
    
    return self.InputListener:IsDown("crouch") or self.BlockCrouchEnd
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
function Player:PlaySFX(name, pitch, variance, volume)
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
    
    local soundToPlay = self.SFX[name][no]

    soundToPlay:Stop()
    
    soundToPlay:SetPitch(pitch + math.random(-5,5)/45 * variance)

    if volume or soundToPlay.BaseVolume then
        soundToPlay.BaseVolume = soundToPlay.BaseVolume or soundToPlay.Volume
        soundToPlay:SetVolume(soundToPlay.BaseVolume * (volume or 1))
    end

    soundToPlay:Play()
end

function Player:StopSFX(name)
    for _, sound in ipairs(self.SFX[name]) do
        sound:Stop()
    end
end

function Player:PlayWallSlideSound()
    self:PlaySFX("WallSlide", 1, 0)
    self.PlayingWallSFX = true
end

function Player:PlayRegainStaminaSound(force)
    if self.FramesSinceDoubleJump > -1 or self.FramesSinceDive > -1 or force then
        self:PlaySFX("StaminaRefill", 2)
    end
end

function Player:GetFloorMaterial()
    if self.FloorSurfaceInfo then
        return self.FloorSurfaceInfo.Material or "None"
    else
        return "None"
    end
end

function Player:GetWallMaterial()
    if self.WallSurfaceInfo then
        return self.WallSurfaceInfo.Material or "None"
    else
        return "None"
    end
end

function Player:PlayQuietFootstepSound()
    local bank = ("Footstep"..self:GetFloorMaterial())
    self:PlaySFX(self.SFX[bank] and bank or "Footstep", 0.7, 0, 0.5*2)
end

function Player:PlayLoudFootstepSound()
    local bank = ("Footstep"..self:GetFloorMaterial())
    self:PlaySFX(self.SFX[bank] and bank or "Footstep", 1, 0, 1*2)
end

-- bank can be "Glass" or "Metal" etc
-- pitch is the pitch multiplier
-- pitchVariance = 0 represents no variance
-- volume is volume multiplier
function Player:PlayCustomFootstepSound(bank, pitch, pitchVariance, volume)
    bank = ("Footstep"..(bank or self:GetFloorMaterial()))
    self:PlaySFX(self.SFX[bank] and bank or "Footstep", pitch or 1, pitchVariance or 0, (volume or 1)*2)
end

function Player:StopWallSlideSound()
    self.WallSFXVolume = math.lerp(self.WallSFXVolume, 0, 0.2)
    self.SFX.WallSlide[1]:SetVolume(self.WallSFXVolume)

    if self.WallSFXVolume <= 0.05 then
        self:StopSFX("WallSlide")
        self.PlayingWallSFX = false
    end
end

function Player:Jump(noSFX)


    -- check to make sure we can jump
    if self.CrouchTime > 0 then
        local holdingCrouch = self:IsHoldingCrouch()
        local success = self:EndCrouch()
        if not success then
            return false
        end
        self:ShrinkHitbox()
    end

    self.JumpBuffer = 0
    self.FramesSinceDive = -1
    self.DiveExpired = false
    self.Velocity.Y = -self.JumpPower
    
    ---- SFX ----
    
    if not noSFX and
        (math.clamp(self.FramesSinceRoll, 1, 11) ~= self.FramesSinceRoll or self.LastRollPower == self.ShimmyPower) 
    then self:PlaySFX("Jump") end
    -------------

    if self.FramesSinceLastLunge <= self.CoyoteFrames and not self.Floor then
        -- self.Position.Y = math.lerp(self.Position.Y, self.YPositionAtLedge, 0.8)
        -- self.Velocity.X = self.XVelocityBeforeLastLunge
    else 
        self.YPositionAtLedge = self.Position.Y
    end

    

    -- pounce handling
    if (self.FramesSinceRoll > -1 or (self.FramesSinceJump > -1 and self.FramesSinceJump <= self.RollWindowPastJump)) and self.LastRollPower == self.ShimmyPower then
        local heightBoost = math.min((self.LedgeLungeCharge*0.5 + self.LedgeLungeChain*0.25), 3)--math.max((self.LedgeLungeCharge - 6), 0) / 4
        self.LedgeLungeCharge = math.max(self.LedgeLungeCharge - self.LedgeLungePounceDepletionRate, 0)
        self.Velocity.X = sign(self.Velocity.X) * (math.min(math.max(self.MinPouncePower, math.abs(self.Velocity.X)), self.MaxPouncePower))
        self:PlayDynamicDashSound(nil, 0)
        self:PlaySFX("PounceSqueak", 1 + math.abs(self.Velocity.X)/30, 0)
        
        self.Velocity.Y = sign(self.Velocity.Y) * (self.PounceHeight + heightBoost)
        
        self.FramesSincePounce = 0
        self.FramesSinceRoll = -1
        self.PounceAnimCancelled = false
        self.PounceParticlePower = self.PounceParticlePower + 2.5


        local kickoffdust = self:GetChild("RollKickoffDust")
        kickoffdust:Emit{
            Position = V{self.Position.X, self.PreviousFloorHeight}, 
            Size = V{kickoffdust.ParticleSize.X * sign(self.DrawScale.X), kickoffdust.ParticleSize.Y}, 
            Color = self.TrailColor,
            Velocity = math.abs(self.Velocity.X) < 1 and V{0, 0} or V{-sign(self.DrawScale.X) * 35, 0}
        }
        self:ShrinkHitbox()
    else
        
        -- regular jump
        self:GetChild("JumpDust"):Emit{Position = self.Position, }

        if self:IsHoldingCrouch() then
            self:GrowHitbox()
        end
    end

    -- apply ledge lunge charge
    
    self.Velocity.X = self.Velocity.X + (self.LedgeLungeCharge*0.5) * sign(self.Velocity.X)

    if self.LedgeLungeStairCount == 0 and self.LedgeLungeChain > 0 then
        print("CHAINED", self.LedgeLungeStairCount)
        self.Velocity.X = self.Velocity.X + sign(self.Velocity.X) * self.LedgeLungeChain*0.4
        self.LedgeLungeChain = 0
    end

    self.FramesSinceJump = 0
    self.FramesSinceHoldingJump = 0
    
    if self.FloorDelta then
        -- player tends to "overshoot" when jumping
        self.Position = (self.Position + self.FloorDelta)
    end

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

    if self.FramesSinceRoll > 0 then
        self.CantRunUntilGrounded = true
    end

    if math.abs(self.Velocity.X) >= self.RunSpeed and self.FramesSinceRoll == -1 then
        self.JumpAnimBounds = self.LeapAnimSwitch and self.FAST_JUMP_ANIM_BOUNDS[1] or  self.FAST_JUMP_ANIM_BOUNDS[2]
        self.InFastJump = true
        -- self.LeapAnimSwitch = not self.LeapAnimSwitch
    else
        self.InFastJump = false
        self.JumpAnimBounds = self.SLOW_JUMP_ANIM_BOUNDS
    end

    self:DisconnectFromFloor()
end

function Player:WallKick()
    self:GrowHitbox()
    local wallDir = self.WallDirection == "left" and -1 or 1
    self.Velocity.Y = math.min(self.Velocity.Y, 0)
    self.Velocity.X = 5 * -wallDir
    self.JumpBuffer = 0
    
    self:PlayCustomFootstepSound(self:GetWallMaterial(), 0.8, nil, 1)
    self:SetBodyOrientation(-wallDir)
    self:DisconnectFromWall()
    self.WallSurfaceInfo = nil
    self:PlaySFX("Jump")
    self:PlaySFX("WallKick")
    self:GetChild("WallKickDust"):Emit{
        Position = self.Position - V{wallDir*4,5},
        Size = V{16*wallDir, 16},
        Color = self.TrailColor,
    }
    self.FramesSinceWallKick = 0
end

function Player:DoubleJump(ignoreRejection)
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
            self.Velocity.X = math.min(math.abs(self.Velocity.X), math.lerp(math.abs(self.Velocity.X), self.WalkSpeed, 0.5)) * self.MoveDir
        -- else
        --     self.Velocity.X = 0
        -- end
    end

    if self.DiveWasLunge then
        if (not ignoreRejection) and self.FramesSinceDive > -1 and self.FramesSinceDive < self.FramesAfterLungeCanCancel then
            -- don't let them dive cancel right after lunging
            return
        end
    else
        if (not ignoreRejection) and self.FramesSinceDive > -1 and self.FramesSinceDive < self.FramesAfterDiveCanCancel then
            -- don't let them dive cancel right after diving
            -- self.JumpBuffer = 0
            return
        end
    end

    


    -- first move the player down to make sure they're even allowed to double jump
    self.JumpBuffer = 0

    -- double jumping cancels run momentum
    self.CantRunUntilGrounded = true

    self:GetChild("DoubleJumpDust"):Emit{Position = self:GetPoint(0.5,0.5), Rotation = math.random(0,3)*math.rad(90), Color = self.TrailColor}
    
    
    
    self.Texture.Clock = 0

    self.JumpAnimBounds = self.SLOW_JUMP_ANIM_BOUNDS
    self.DoubleJumpStoredSpeed = math.abs(self.Velocity.X)
    
    if self.FramesSinceDive > -1 then
        -- this is a dive cancel; player can't carry momentum from dives
        if self.InputListener:IsDown("action") then
            -- player can maintain some velocity if they're holding action during a dive cancel
            self.Velocity.X = math.min(math.abs(self.Velocity.X), math.lerp(math.abs(self.Velocity.X), self.WalkSpeed, 0.5)) * self.MoveDir
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


    -- play a footstep sound regardless
    
    self:PlayCustomFootstepSound(self:GetWallMaterial(), 1.25, nil, 2)
    


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

    Timer.Schedule(0.1, function()
        self:PlayRegainStaminaSound(true)
    end)

    self.JumpBuffer = 0
    self:GetChild("DoubleJumpDust"):Emit{Position = self:GetPoint(0.5,0.5), Rotation = math.random(0,3)*math.rad(90), Color = self.TrailColor}
    
    -- local parrySpeed = ((self.WallDirection == "right" and self.MoveDir == 1) or (self.WallDirection == "left" and self.MoveDir == -1)) and 1 -- player is moving towards wall
    --     or self.MoveDir == 0 and 2.5    -- player is neutral
    --     or 3.25     -- player is holding against dive direction
    local parrySpeed = 3.125
    local wallDir = (self.WallBumpDirection == "right" and -1 or 1)

    self.Texture.Clock = 0
    self.Velocity.Y = -self.ParryPower
    self.Velocity.X = parrySpeed * wallDir
    self.LedgeLungeChain = 0
    -- self:SetBodyOrientation(-wallDir)

    self.FramesSinceDive = -1
    self.FramesSinceDoubleJump = -1
    self.DiveExpired = false
    self.CantRunUntilGrounded = true
    self.Texture.Clock = 0
    self.Texture.IsPlaying = true
    self.LastParryWall = self.Wall
    self.LastParryPos = self.Position:Clone()
    self.LastParryWallPos = self.Wall.Position:Clone()
    self.LastParryFace = self.WallBumpDirection
    self.FramesSinceParry = 0

    
    self:GetChild("WallKickDust"):Emit{
        Position = self.Position - V{-wallDir*4,5},
        Size = V{16*-wallDir, 16},
        Color = self.TrailColor
    }
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

    
    if self.Wall then
        self.LastFloor = self.Wall --> NOT a typo (i think)
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
        if self.Velocity.Y < 0 then
            self:PlaySFX("UpwardDive", 1, 0)
        end
    end

    if self.FramesSinceParry > -1 and self.FramesSinceParry < self.FramesAfterParryCanParryDive and self.FramesSinceDoubleJump == -1 then
        measuredVelocityY = -2.5
        self.LastDiveWasParryDive = true
        isParryDive = true
        
    else
        self.LastDiveWasParryDive = false
    end
    


    self.DrawScale.X = faceDirection
    self.Velocity.X = faceDirection * math.max(self.DivePower, math.abs(self.Velocity.X))
    self.Velocity.Y = math.min(self.DiveUpwardVelocity, measuredVelocityY + self.DiveUpwardVelocity) --math.min(-3.5, self.Velocity.Y - 3.5)

    
    if self.FramesSinceDoubleJump > -1 then
        self.Velocity.Y = math.min(self.WeakDiveUpwardVelocity, measuredVelocityY + self.WeakDiveUpwardVelocity)
        self.DiveHangStatus = self.WeakDiveHangTime
    else
        self.DiveHangStatus = self.DiveHangTime
    end

    if measuredVelocityY < -1 then
        isParryDive = true
        self.DiveHangStatus = 0
    end

    if isParryDive then
        self.DiveHangStatus = 0
        self.Velocity.Y = math.min(self.ParryDiveUpwardVelocity, measuredVelocityY + self.ParryDiveUpwardVelocity)
        self.Position.Y = self.Position.Y - 1 -- a  couple more pixels of height, just in case
    end

    if self.InputListener:IsDown("crouch") then
        -- lunge
        


        local extraLungeVelocity = self.LedgeLungeCharge*4
        self.Velocity.Y = self.LungeDownwardVelocity + extraLungeVelocity
        self.LastLungeDownwardVelocity = self.Velocity.Y
        
        if self.InputListener:JustPressed("action") then
            self.WaitingForLedgeLunge = true
        end

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

    self:GetChild("DiveDust"):Emit{Position = self:GetPoint(0.5,0.65), Rotation = math.random(0,3)*math.rad(90),Color = self.TrailColor,}


    
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
    local holdingCrouch = self:IsHoldingCrouch()
    local justLunged = self.FramesSinceDive <= 30
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
        Color = self.TrailColor,
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
            Color = self.TrailColor,
            Velocity = math.abs(self.Velocity.X) < 1 and V{0, 0} or V{-sign(self.DrawScale.X) * 35, 0}
        }
        self.Velocity.X = sign(self.DrawScale.X) * movementPower
        
        
    end
    
    

    self:ShrinkHitbox()

    self.FramesSinceRoll = 0
    
    local blockJump

    if self.InputListener:IsDown("jump") and self.FramesSinceJump <= self.RollWindowPastJump and self.TimeSinceCrouching < 5 and not self:FloorPreventsJumping() then
        -- rolled a few frames late after a jump - initiate a pounce instead
        blockJump = true
        
        self:Jump()
    end

    
    self.ActionBuffer = 0
    self.Texture.Clock = 0
    self.Texture.IsPlaying = true

    if movementPower == self.ShimmyPower and self.FramesSinceGrounded > 0 and not self.InputListener:IsDown("jump") then
        self:PlaySFX("ShimmyWhoosh", 1.2)
        
    else

        if self.LastRollPower == self.ShimmyPower then
            if not self.InLedgeLunge then self:PlaySFX("ShimmyWhoosh") else self:PlaySFX("ShimmyWhoosh", pitch) end
        else
            self:PlaySFX("RollWhoosh", pitch)
        end
        -- if self.FramesSinceLastLunge > 2 then
            -- self:PlaySFX("RollWhoosh", pitch)
        -- end
        
        self:PlayDynamicDashSound()
    end


    -- special case: rolling while against a wall (kind of a "ground parry")
    local wallSign = (self.WallDirection=="left" and -1 or 1)
    if self.Wall and self.MoveDir ~= -wallSign and self:GetBodyOrientation() == wallSign then
        self.Velocity.X = -self.Velocity.X/1.5
        self:PlaySFX("Parry")
        -- self.DrawScale.X = -self.DrawScale.X
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
    self:PlaySFX("DoubleJump", 1.5, 1, 0.2)
    self:PlayCustomFootstepSound(nil, 1.5, 0, 0.4)
    self:ShrinkHitbox()
end

function Player:EndCrouch() -- returns true if crouch could successfully end; false if there was a boundary in the way
    local px, py = self.Position()
    self:GrowHitbox(true)
    self.BlockCrouchEnd = false
    local solid = self:UnclipY(true, true)

    if type(solid)=="table" then
        self:ShrinkHitbox()
        self.BlockCrouchEnd = true
        self.Position.X = px; self.Position.Y = py
        return false
    else
        self.CrouchTime = 0
        self.TimeSinceCrouching = 0
        self:PlaySFX("DoubleJump", 1.3, 1, 0.125)
        return true
    end
    

    
end

function Player:ShrinkHitbox()
    if self.IsCrouchedHitbox then return end

    self.XHitbox.Size.Y = X_HITBOX_HEIGHT_CROUCH
    self.YHitbox.Size.Y = Y_HITBOX_HEIGHT_CROUCH

    self.IsCrouchedHitbox = true
end

function Player:GrowHitbox(noUnclip)
    if not self.IsCrouchedHitbox then return end

    if not self.Floor then
        self.XHitbox.Size.Y = math.lerp(X_HITBOX_HEIGHT, X_HITBOX_HEIGHT_CROUCH, 0.5)
        self.YHitbox.Size.Y = math.lerp(Y_HITBOX_HEIGHT, Y_HITBOX_HEIGHT_CROUCH, 0.5)
        
        self:AlignHitboxes()

        -- if not noUnclip then self:Unclip() end
    end

    self.XHitbox.Size.Y = X_HITBOX_HEIGHT
    self.YHitbox.Size.Y = Y_HITBOX_HEIGHT
    
    if not noUnclip then self:Unclip() end
    
    self.BlockCrouchEnd = false
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
local xscale_wallkick = {1.25, 1.25, 1.25, 1.1, 1.1, 1.1, 1.1, 1.1, 1, 0.8, 0.8, 0.9, 0.9, 0.9, 0.9, 0.9, 1}
local yscale_wallkick = {0.6, 0.6, 0.6, 0.7, 0.7, 0.7, 0.9, 0.9, 0.9, 0.9, 0.9}
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
    

    
    
    -- squash and stretch
    if false then

    elseif self.FramesSinceWallKick > -1 and self.FramesSinceWallKick < 9 then
        self.DrawScale.Y = yscale_wallkick[self.FramesSinceWallKick+1]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_wallkick[self.FramesSinceWallKick+1]
    elseif self.FramesSinceBounce > -1 and self.FramesSinceBounce < #yscale_jump then
        -- just bounced
        self.DrawScale.Y = yscale_jump[self.FramesSinceJump+1]
        self.DrawScale.X = sign(self.DrawScale.X) * xscale_jump[self.FramesSinceJump+1]
    elseif self.FramesSinceThrownItem > -1 and self.FramesSinceThrownItem < #xscale_doublejump and not self.Floor then
        self.DrawScale.Y = yscale_doublejump[self.FramesSinceThrownItem+1] or 1
        self.DrawScale.X = sign(self.DrawScale.X) * (xscale_doublejump[self.FramesSinceThrownItem+1] or 1)
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
                Color = self.TrailColor,
                SizeAcceleration = V{-60, 0} * chainFactor * speedFactor * 0.8,
                Rotation = -self.Velocity:ToAngle() -math.rad(90),
                Velocity = self.Velocity * 5,
                LifeTime = 0.8,
            }

        end
    end 

    
    

    -- check what anim state to put pounce in
    if self.FramesSincePounce > -1 and not self.PounceAnimCancelled then
        
        if math.abs(self.Velocity.X) <= self.RunSpeed + 0.5 then
            self.PounceAnimCancelled = true
            self.Texture.Clock = 0
            self.Texture.IsPlaying = true
        end
    end

    if not self.Floor and self.InFastJump and math.abs(self.Velocity.X) < self.RunSpeed then
        self.JumpAnimBounds = self.SLOW_JUMP_ANIM_BOUNDS
        self.InFastJump = false
        self.Texture.Clock = 0
        self.Texture.IsPlaying = true
    end

    if self.Texture.Clock ~= self.Texture.Clock then
        self.Texture.Clock = self.Texture.Duration
    end

    if self.FramesSinceWallKick > -1 and self.FramesSinceWallKick < 9 then
        if self.FramesSinceWallKick == 0 then
            self.Texture.Clock = 0
            self.Texture.IsPlaying = true
        end
        self.Texture:AddProperties{LeftBound = 125, RightBound = 127, Duration = 0.15, PlaybackScaling = 1, Loop = false}
    elseif self.FramesSinceThrownItem > -1 and self.FramesSinceThrownItem <= 12 and self.Floor then
        if self.MoveDir == 0 then
            -- just threw item on ground while idle
            self.Texture:AddProperties{LeftBound = 101, RightBound = 104, Duration = 0.2, PlaybackScaling = 1, Loop = false}
        else
            -- just threw item on ground while moving
            self.Texture:AddProperties{LeftBound = 91, RightBound = 92, Duration = 0.2, PlaybackScaling = 1, Loop = false}
        end
                
        
        if self.FramesSinceThrownItem == 0 then
            self.Texture.Clock = 0
            self.Texture.IsPlaying = true
        end
    elseif self.FramesSinceThrownItem > -1 and self.FramesSinceThrownItem <= 18 and not self.Floor then
        -- just threw item in midair
        self.Texture:AddProperties{LeftBound = 97, RightBound = 100, Duration = 0.3, PlaybackScaling = 1, Loop = false}

        if self.FramesSinceThrownItem == 0 then
            self.Texture.Clock = 0
            self.Texture.IsPlaying = true
        end
    elseif self.FramesSinceDroppedItem < 12 and self.FramesSinceDroppedItem > -1 and not self.Floor then
        -- just dropped item in midair
        self.Texture:AddProperties{LeftBound = 59, RightBound = 60, Duration = 0.2, PlaybackScaling = 1, Loop = false}
        if self.FramesSinceDroppedItem == 0 then
            self.Texture.Clock = 0
            self.Texture.IsPlaying = true
        end
    elseif self.FramesSinceHoldingItem > -1 and self.FramesSinceHoldingItem < 18 and self.PickupAnimDebounce == 0 then
        
        if self.FramesSinceRoll == -1 then

            if self.Floor then
                -- grabbed item from ground
                if self.MoveDir ~= 0 then
                    -- grabbed while moving
                    self.Texture:AddProperties{LeftBound = 105, RightBound = 108, Duration = 0.3, PlaybackScaling = 1, Loop = false}
                else
                    -- grabbed while idle
                    self.Texture:AddProperties{LeftBound = 81, RightBound = 84, Duration = 0.3, PlaybackScaling = 1, Loop = false}
                end
            else
                -- grabbed item in midair
                self.Texture:AddProperties{LeftBound = 93, RightBound = 96, Duration = 0.3, PlaybackScaling = 1, Loop = false}
            end
            if self.FramesSinceHoldingItem == 0 then
                self.Texture.Clock = 0
                self.Texture.IsPlaying = true
            end
        else
            -- player rolled into the object; cancel pickup animation
            self.PickupAnimDebounce = 30
        end

    elseif self.Wall and self.Floor and self.CrouchTime == 0 and sign(self.DrawScale.X) == (self.WallDirection == "left" and -1 or 1) and self.FramesSinceHoldingItem == -1 then 
        -- if self.Floor then
            -- standing on floor against a wall
            if self.MoveDir == 0 then
                -- idle
                self.Texture:AddProperties{LeftBound = 109, RightBound = 112, Duration = 1, PlaybackScaling = 1, Loop = true, IsPlaying = true}
            else
                -- moving
                self.Texture:AddProperties{LeftBound = 113, RightBound = 118, Duration = 1.4, PlaybackScaling = 1, Loop = true, IsPlaying = true}
            end
        -- else
            -- in the air against a wall

        -- end
        
    elseif self.Wall and self.ParryStatus == 0 and self.CrouchTime == 0 and sign(self.DrawScale.X) == (self.WallDirection == "left" and -1 or 1) and sign(self.DrawScale.X) == self.MoveDir and self.FramesSinceHoldingItem == -1 then
         -- in the air against wall
         self.Texture.IsPlaying = false
         self.Texture.Clock = 0
         self.Texture.RightBound = 124
         if self.Velocity.Y < -self.WallSlideSpeed then
             -- moving up quickly
             self.Texture.LeftBound = 121
         elseif self.Velocity.Y < 0 then
             -- moving up slowly
             self.Texture.LeftBound = 122
         elseif self.Velocity.Y < self.WallSlideSpeed then
             -- moving down slowly
             self.Texture.LeftBound = 123
         else
             -- moving down quickly
             self.Texture.LeftBound = 124
         end
    
    elseif self.ParryStatus > 0 then
        
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
        if self.HeldItem then
            self.Texture:AddProperties{LeftBound = 79, RightBound = 80, Duration = 0.4, PlaybackScaling = 1, Loop = false}
        elseif self.PounceAnimCancelled then
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
            if not self:IsHoldingCrouch() then
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
            if self.HeldItem then
                -- holding an object (arms up)
                self.Texture:AddProperties{LeftBound = 73, RightBound = 76, Duration = 1, PlaybackScaling = 1, IsPlaying = true, Loop = true}
            else
                
                if self.SlidingStopAnimation then
                    -- sliding
                    self.Texture:AddProperties{LeftBound = 128, RightBound = 130, Duration = 0.25, PlaybackScaling = math.abs(self.Velocity.X)/self.RunSpeed/1.5, IsPlaying = true, Loop = true}
                elseif self.SlidingStopReboundAnimationState > -1 then
                    if self.SlidingStopReboundAnimationState == self.SlidingStopReboundAnimFrames-1 then
                        self.Texture.Clock = 0
                    end
                    self.Texture:AddProperties{LeftBound = 131, RightBound = 132, Duration = 0.2, Loop = false, IsPlaying = true}
                else
                    self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Duration = 1, PlaybackScaling = 1, IsPlaying = true, Loop = true}
                end
            end
        else
            -- run anim
            self:SetBodyOrientation(self.MoveDir)
            if math.abs(self.Velocity.X) <= 1.5 then
                if self.HeldItem then
                    -- holding an object (arms up)
                    self.Texture:AddProperties{LeftBound = 85, RightBound = 90, Duration = 0.72, PlaybackScaling = 3 - math.abs(self.Velocity.X)*1.25, IsPlaying = true, Loop = true}
                else
                    self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 3 - math.abs(self.Velocity.X)*1.25, IsPlaying = true, Loop = true}
                end
            elseif math.abs(self.Velocity.X) >= self.RunSpeed then
                if self.HeldItem then
                    -- holding an object (arms up)
                    self.Texture:AddProperties{LeftBound = 67, RightBound = 72, Duration = 0.72, PlaybackScaling = 1 + math.abs(self.Velocity.X)*0.15, IsPlaying = true, Loop = true}
                else
                    if self.FramesSinceGrounded == 0 then
                        if self.LeapAnimSwitch then
                            self.Texture.Clock = 0
                        else
                            self.Texture.Clock = 0.36
                        end
                    end
                    self.Texture:AddProperties{LeftBound = 61, RightBound = 66, Duration = 0.72, PlaybackScaling = 1 + math.abs(self.Velocity.X)*0.18, IsPlaying = true, Loop = true}
                end
            else
                if self.HeldItem then
                    -- holding an object (arms up)
                    self.Texture:AddProperties{LeftBound = 85, RightBound = 90, Duration = 0.72, PlaybackScaling = 1 + math.abs(self.Velocity.X)*0.25, IsPlaying = true, Loop = true}
                else
                    self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 1 + math.abs(self.Velocity.X)*0.375, IsPlaying = true, Loop = true}
                end
            end
        end
    else -- no floor; in air
        if self.FramesSinceDoubleJump > -1 and self.FramesSinceDoubleJump < self.DoubleJumpFrameLength then
            -- just double jumped
            self.Texture:AddProperties{LeftBound = 11, RightBound = 12, Duration = self.DoubleJumpFrameLength/60, PlaybackScaling = 1, Loop = false, IsPlaying = true}
        elseif self.FramesSinceJump == 0 then
            -- just jumped
            if self.HeldItem then
                -- holding an object (arms up)
                self.Texture:AddProperties{LeftBound = 77, RightBound = 80, Duration = 0.4, PlaybackScaling = 1, Loop = false, Clock = 0}
            else
                if math.abs(self.Velocity.X) >= self.RunSpeed then
                    print("E")
                    self.Texture:AddProperties{LeftBound = 133, RightBound = 136, Duration = 0.4, PlaybackScaling = 1, Loop = false, Clock = 0}
                else
                    self.Texture:AddProperties{LeftBound = self.JumpAnimBounds[1], RightBound = self.JumpAnimBounds[2], Duration = self.JumpAnimBounds[3], PlaybackScaling = 1, Loop = false, Clock = 0}
                end
            end
        elseif self.FramesSinceJump == -1 and self.FramesSinceDoubleJump == -1 then
            -- just falling
            if self.HeldItem then
                -- holding an object (arms up)
                self.Texture:AddProperties{LeftBound = 79, RightBound = 80, Duration = 0.4, PlaybackScaling = 1, Loop = false}
            else
                self.Texture:AddProperties{LeftBound = 15, RightBound = 16, Duration = 0.4, PlaybackScaling = 1, Loop = false}
            end
        else
            -- middle of jump state
            if self.ShouldRestartJumpAnim then
                self.ShouldRestartJumpAnim = false
                self.Texture.Clock = 0
                self.Texture.IsPlaying = true
            end

            if self.HeldItem then
                -- holding an object (arms up)
                self.Texture:AddProperties{LeftBound = 77, RightBound = 80, Duration = 0.4, PlaybackScaling = 1, Loop = false, IsPlaying = true}
            else
                self.Texture:AddProperties{LeftBound = self.JumpAnimBounds[1], RightBound = self.JumpAnimBounds[2], Duration = self.JumpAnimBounds[3], PlaybackScaling = 1, Loop = false, IsPlaying = true}
            end
        end
    end
end

function Player:UpdateFrameValues()
    if self.Floor then
        -- self.ShouldCheckForHeldItemOverhang = false
        self.InFastJump = false
        self.YPositionAtLedge = self.Position.Y
        self.InLedgeLunge = false
        self.FramesSinceAirborne = -1
        self.AerialMovementLockedToFloorPos = false
        self.FramesSinceDoubleJump = -1
        self.CantRunUntilGrounded = false
        self.FramesSinceJump = -1
        self.FramesSinceHoldingJump = -1
        self.DiveExpired = false
        if self.FramesSinceGrounded > -1 then
            self.FramesSinceGrounded = self.FramesSinceGrounded + 1
        end
        self.LastParryFace = "none"
        self.FramesSinceParry = -1
    else -- no floor
        self.FramesSinceGrounded = -1
        self.FramesSinceAirborne = self.FramesSinceAirborne + 1
        if self.FramesSinceJump > -1 then
            self.FramesSinceJump = self.FramesSinceJump + 1
        end
        if self.FramesSinceHoldingJump > -1 then
            self.FramesSinceHoldingJump = self.FramesSinceHoldingJump + 1
        end
        if self.FramesSinceDoubleJump > -1 then
            self.FramesSinceDoubleJump = self.FramesSinceDoubleJump + 1
        end
        if self.FramesSinceParry > -1 then
            self.FramesSinceParry = self.FramesSinceParry + 1
        end

        if self.FramesSinceDive == -1 then
            
            self.InLedgeLunge = false
        end

        if not self.InLedgeLunge and self.FramesSinceAirborne > 10 then
            
            self.LedgeLungeStairCount = 0
        end
    end

    -- print("EEF", self.Velocity.X, self.SlidingStopAnimation)
    local slowedDownEnough = math.abs(self.Velocity.X) < 0.5
    if self.SlidingStopAnimation and self.SlidingStopReboundAnimationState <= -1 and (slowedDownEnough or self.MoveDir == sign(self.Velocity.X)) then
        self.SlidingStopAnimation = false
        if slowedDownEnough then
            self.SlidingStopReboundAnimationState = self.SlidingStopReboundAnimFrames
            -- print("OOF", self.Velocity.X)
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

    if self.FramesSinceDepartedWall > -1 then
        self.FramesSinceDepartedWall = self.FramesSinceDepartedWall + 1
    end

    if self.FramesSinceLastLunge > -1 then
        self.FramesSinceLastLunge = self.FramesSinceLastLunge + 1
    end

    if self.InLedgeLunge then
        self.ActiveTerminalLedgeLungeVelocity = math.lerp(self.ActiveTerminalLedgeLungeVelocity, self.TerminalLedgeLungeVelocityGoal, self.LedgeLungeTaperSpeed)
    end

    if self.PickupAnimDebounce > 0 then
        self.PickupAnimDebounce = self.PickupAnimDebounce - 1
    end

    if self.SlidingStopReboundAnimationState > -1 then
        self.SlidingStopReboundAnimationState = self.SlidingStopReboundAnimationState - 1
    end

    if self.HeldItem then
        self.FramesSinceDroppedItem = -1
        self.FramesSinceThrownItem = -1
        self.FramesSinceHoldingItem = self.FramesSinceHoldingItem + 1
    else
        self.FramesSinceHoldingItem = -1
        self.FramesSinceDroppedItem = self.FramesSinceDroppedItem + 1

        if self.FramesSinceThrownItem > -1 then
            self.FramesSinceThrownItem = self.FramesSinceThrownItem + 1
        end
    end

    if self.ForceJumpHeldFrames > 0 then
        self.ForceJumpHeldFrames = self.ForceJumpHeldFrames - 1
    end
    
    if self.FramesOnGroundSinceLedgeLunge > -1 then
        if self.Floor then
            self.FramesOnGroundSinceLedgeLunge = self.FramesOnGroundSinceLedgeLunge + 1
            if self.FramesOnGroundSinceLedgeLunge > self.FramesOnGroundAfterLedgeLungeBeforeChainEnds then
                self.OnGroundAfterLedgeLunge = false
                self.FramesOnGroundSinceLedgeLunge = -1
                self.WaitingForLedgeLunge = false
                
                self.LedgeLungeChain = 0
            end
        else
            self.FramesOnGroundSinceLedgeLunge = 0
        end
    end

    if self.Floor then
        self.CaughtHeldItemMidairChain = 0
        self.ThrewItemInAir = false
        self.LastThrowDirection = 0
        self.LastCatchDirecton = 0
        self.FramesSinceDepartedWall = -1

        -- spring stuff
        self.FramesSinceBounce = -1

        if self.PlayingWallSFX then
            self:StopWallSlideSound()
        end
    else
        if self.FramesSinceBounce > -1 then
            self.FramesSinceBounce = self.FramesSinceBounce + 1
        end
    end

    -- wall kick sfx/particles stuff
    if self.Wall and self.MoveDir == (self.WallDirection=="left" and -1 or 1) then
        if self.PlayingWallSFX then
            self.SFX.WallSlide[1]:SetVolume(self.WallSFXVolume)
            local wallDir = self.WallDirection=="left" and -1 or 1
            if math.abs(self.Velocity.Y) < 1 then
                self.WallSFXVolume = math.lerp(self.WallSFXVolume, 0, 0.2)
            else
                self.WallSFXVolume = math.lerp(self.WallSFXVolume, self.WallSFXMaxVolume, 0.0575)

                local frequency = math.clamp(math.floor(8-math.abs(self.Velocity.Y*2)), 1, 8)
            
                if self.FramesSinceAgainstWall % frequency == frequency-1 then
                    self:GetChild("WallSlideDust"):Emit{
                        Position = self.Position - V{wallDir*4,5},
                        Size = V{16*wallDir, 16},
                        Color = self.TrailColor,
                    }
                end
            end
            
            if self.Velocity.Y > 0 then
                self.SFX.WallSlide[1]:SetPitch(1)
            elseif self.Velocity.Y < 0 then
                self.SFX.WallSlide[1]:SetPitch(1.5)
            end
            
        elseif not self.PlayingWallSFX and not self.Floor then
            self:PlayWallSlideSound()
        end
    else
        -- no wall
        if self.PlayingWallSFX then
            self:StopWallSlideSound()
        end
    end

    if not self.PlayingWallSFX then
        self.WallSFXVolume = 0
        self.SFX.WallSlide[1]:SetVolume(self.WallSFXVolume)
    end

    if self.FramesSinceWallKick > -1 then
        self.FramesSinceWallKick = self.FramesSinceWallKick + 1

        if self.Floor then
            self.FramesSinceWallKick = -1
        end
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
                
                if self.IsCrouchedHitbox then
                    
                    local s = self:EndCrouch()
                    if not s then
                        self:StartCrouch()
                        -- self.CrouchTime = 1
                        -- self.BlockCrouchEnd = true
                    end
                end
                
            end

            -- self.Texture.IsPlaying = true
        end

        
    end

    if self.ParryStatus > 0 then
        self.ParryStatus = self.ParryStatus - 1
    end

    if self.LedgeLungeCharge ~= 0  then
        local depletionRate
        if (self.FramesOnGroundSinceLedgeLunge == -1 or self.FramesOnGroundSinceLedgeLunge > self.LedgeLungeGraceFrames) then
            depletionRate = self.Floor and self.LedgeLungeGroundedDepletionRate or self.LedgeLungeAerialDepletionRate
        else
            depletionRate = self.LedgeLungeAerialDepletionRate
        end
        self.LedgeLungeCharge = math.max(self.LedgeLungeCharge - depletionRate, 0)
    
    
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

        if self.BlockCrouchEnd then
            self.CrouchTime = self.CrouchTime + 1
        end
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

    self.FramesSinceHoldingLeft = self.FramesSinceHoldingLeft + 1
    self.FramesSinceHoldingRight = self.FramesSinceHoldingRight + 1


    -- safeguard to make sure hitbox isn't small for no reason
    if self.Floor and self.FramesSinceRoll == -1 and self.CrouchTime == 0 and self.IsCrouchedHitbox then
        
        self:GrowHitbox()

        local success
    end

    

    self.FramesSinceInit = self.FramesSinceInit + 1
end

-- physics updates
local min, max = math.min, math.max
function Player:UpdatePhysics()

    -- some logic for recording previous position
    if self.LastPosition == self.Position then -- player is 'idle'
        self.IdleStreak = self.IdleStreak + 1

        if self.Floor and self.IdleStreak == self.POSITION_SAFETY_THRESHOLD or not self.LastSafePosition then
            self.LastSafePosition = self.LastPosition
        end
    elseif self.IdleStreak > 0 then -- reset IdleStreak
        self.IdleStreak = 0
    end 

    self.LastPosition = self.Position:Clone()
    

    -- gravity is dependent on the jump state of the character
    if self.IgnoreGravityThisFrame then
        self.IgnoreGravityThisFrame = false
    elseif self.FramesSinceWallKick > -1 and self.FramesSinceWallKick < self.WallKickHangTime and not self.Wall then
        -- self.Velocity.Y = self.Velocity.Y + 0
    elseif self.FramesSinceParry > -1 and self.FramesSinceDoubleJump == -1 and self.FramesSinceDive == -1 then
        self.Velocity.Y = self.Velocity.Y + self.ParryGravity
    elseif self.FramesSinceDive > -1 then
        -- the player has low dive gravity
        
        if self.DiveHangStatus > 0 then
            
            -- getting initial airtime in the weak dive state
            self.Velocity.Y = self.Velocity.Y + 0
        else
            
            if self.FramesSinceDive >= self.DiveCoyoteFrames or self.LastDiveWasParryDive then
                if self.LastDiveWasParryDive then
                    self.Velocity.Y = self.Velocity.Y + self.ParryDiveGravity
                else
                    self.Velocity.Y = self.Velocity.Y + self.DiveGravity
                end
            end
        end
        
    elseif self.HangStatus > 0 and self.Velocity.Y >= 0 then
        -- the player is owed hang time
        
        self.Velocity.Y = 0
    elseif self.FramesSinceDoubleJump > -1 or ((self.CaughtHeldItemMidairChain > 0 or self.ThrewItemInAir)) then
        -- the player is in the air from a double jump
        if self.Velocity.Y < 0 then
            -- player is in the upward arc
            

            if self.LastDoubleJumpWasDiveCancel then
                -- less gravity for a dive cancel
                self.Velocity.Y = self.Velocity.Y + self.DiveCancelGravity
            else
                -- regular double jump gravity
                self.Velocity.Y = self.Velocity.Y + self.AfterDoubleJumpGravity
            end
            
            if self.Velocity.Y > 0 then

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
        if (self.InputListener:IsDown("jump") or self.ForceJumpHeldFrames > 0) then
            
            
            -- check if player has been holding jump long enough to cancel run speed
            if self.FramesSinceHoldingJump >= self.JumpFramesBeforeRunCancel then
                self.CantRunUntilGrounded = true
            end

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
            self.FramesSinceHoldingJump = -1
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
                    if self.FramesSinceDoubleJump == -1 then
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
        -- self.FramesSinceRoll = self.RollLength + 1
        
        -- self.Velocity.X = 0
    end

    
    


    local horizSpeed = self.FramesSinceDive > -1 and self.DiveSpeed or 
                        (((self.Floor or not self.CantRunUntilGrounded) and math.abs(self.Velocity.X) > self.RunSpeed) and self.RunSpeed or self.WalkSpeed)
    local decelGoal = math.abs(self.MoveDir) > 0 and horizSpeed or 0
    local speedOver = math.abs(self.Velocity.X) - decelGoal
    
    local decelAmt = 0
    
    if speedOver > 0 then
        -- player is moving faster than the maximum horizontal speed
        if self.Floor then
            -- player is running; slow down at ground speed

            if sign(self.Velocity.X) ~= self.MoveDir then
                if math.abs(self.Velocity.X) > 4.5 then
                    self.SlidingStopAnimation = true
                end
            end
           

            if self.MoveDir == 0 then
                -- player is idle
                if math.abs(self.Velocity.X) >= self.RunSpeed then
                    decelAmt = self.RunIdleDeceleration
                else
                    decelAmt = self.IdleDeceleration
                end
                
            elseif sign(self.Velocity.X) == self.MoveDir then
                -- player is moving "with" the direction of their momentum; don't slow down as much
                if math.abs(self.Velocity.X) >= self.RunSpeed then
                    -- player is running
                    decelAmt = self.RunForwardDeceleration
                else
                    -- player is walking
                    decelAmt = self.ForwardDeceleration
                end
                
            else
                -- player is against the direction of momentum; normal deceleration
                if math.abs(self.Velocity.X) >= self.RunSpeed then
                    -- player is running
                    decelAmt = self.RunBackwardDeceleration
                else
                    -- player is walking
                    decelAmt = self.BackwardDeceleration
                end            
            end
        else
            -- player is in the air
            
            if self.FramesSinceDive > -1 then
                -- dive velocity
                if self.LastDiveWasParryDive then
                    -- parry dive
                    if self.MoveDir == 0 then
                        -- player is idle
                        decelAmt = self.ParryDiveIdleDeceleration
                    elseif sign(self.Velocity.X) == self.MoveDir then
                        -- player is moving "with" the direction of their momentum; don't slow down as much
                        decelAmt = self.ParryDiveIdleDeceleration
                    else
                        -- player is against the direction of momentum; normal deceleration
                        decelAmt = self.ParryDiveIdleDeceleration
                    end
                else
                    -- regular dive
                    if self.MoveDir == 0 then
                        -- player is idle
                        decelAmt = self.DiveIdleDeceleration
                    elseif sign(self.Velocity.X) == self.MoveDir then
                        -- player is moving "with" the direction of their momentum; don't slow down as much
                        decelAmt = self.DiveForwardDeceleration
                    else
                        -- player is against the direction of momentum; normal deceleration
                        decelAmt = self.DiveBackwardDeceleration
                    end
                end
                
            elseif self.FramesSincePounce > -1 then

                if self.LedgeLungeCharge > 0 then
                    -- charged pounce velocity
                    if self.MoveDir == 0 then
                        -- player is idle
                        decelAmt = self.ChargedPounceIdleDeceleration
                    elseif sign(self.Velocity.X) == self.MoveDir then
                        -- player is moving "with" the direction of their momentum; don't slow down as much
                        decelAmt = self.ChargedPounceForwardDeceleration
                    else
                        -- player is against the direction of momentum; normal deceleration
                        decelAmt = self.ChargedPounceBackwardDeceleration
                    end
                else
                    -- pounce velocity
                    if self.MoveDir == 0 then
                        -- player is idle
                        decelAmt = self.PounceIdleDeceleration
                    elseif sign(self.Velocity.X) == self.MoveDir then
                        -- player is moving "with" the direction of their momentum; don't slow down as much
                        decelAmt = self.PounceForwardDeceleration
                    else
                        -- player is against the direction of momentum; normal deceleration
                        decelAmt = self.PounceBackwardDeceleration
                    end
                end
                
            else
                -- regular air velocity
                if self.MoveDir == 0 then
                    -- player is idle
                    decelAmt = self.AirIdleDeceleration
                elseif sign(self.Velocity.X) == self.MoveDir then
                    
                    -- player is moving "with" the direction of their momentum; don't slow down as much
                    decelAmt = self.AirForwardDeceleration
                else
                    -- player is against the direction of momentum; normal deceleration
                    decelAmt = self.AirBackwardDeceleration
                end
            end

        end

        self:Decelerate(decelAmt*self:GetFloorFriction())

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
            if self.NearbyInteractable == solid then
                self:DisconnectNearbyInteractable()
                if solid.InteractLeave then solid:InteractLeave(self) end
            end
            self.TouchEvents[solid] = false
        end
    end
    
    -- account for sliding against a wall
    local wallDir = self.WallDirection == "left" and -1 or 1
    if self.Wall and self.MoveDir == wallDir and self.FramesSinceParry ~= 0 and not self.HeldItem and (self.FramesSinceAgainstWall >= self.FramesAgainstWallBeforeDirectionChange or sign(self.DrawScale.X) == wallDir) and not self.Floor then
        self:SetBodyOrientation(wallDir)

        -- if moving too fast, slow 'er down to reach WallSlideSpeed        
        if self.Velocity.Y > self.WallSlideSpeed then
            self.Velocity.Y = math.max(self.Velocity.Y - self.WallSlideDecelerationSpeed, self.WallSlideSpeed)
        end
    end
    

    -- account for gravity
    local terminalVelocity = (self.InLedgeLunge and math.abs(self.Velocity.X) > 2 and self.FramesSinceDoubleJump == -1) and self.ActiveTerminalLedgeLungeVelocity or (self.FramesSinceDive > -1 and self.FramesSinceDoubleJump == -1) and (self.DiveWasLunge and (self.LedgeLungeCharge == 0 and self.TerminalLungeVelocity or self.LastLungeDownwardVelocity) or self.TerminalDiveVelocity) or self.TerminalVelocity
    
    
    if self.Velocity.Y > terminalVelocity then
        self.Velocity.Y = terminalVelocity
    end


    if self.LastFloor then
        self.LastFloorPos = self.LastFloor.Position:Clone()
    end

    

    -- adhere to MaxSpeed
    
    -- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
    local MAX_Y_DIST = 2
    local MAX_X_DIST = 2
    local subdivisions = 1

    if math.abs(self.Velocity.X) > MAX_X_DIST then
        subdivisions = math.floor(1+math.abs(self.Velocity.X)/MAX_X_DIST)
    end

    if math.abs(self.Velocity.Y) > MAX_Y_DIST then
        subdivisions = math.max(subdivisions, math.floor(1+math.abs(self.Velocity.Y)/MAX_Y_DIST))
    end
    
    local posDelta = self.Velocity
    local cam = self:GetLayer():GetParent().Camera
    if self.AerialMovementLockedToFloorPos then
        posDelta = posDelta - (self.LastFloorDelta or EMPTYVEC)
        
        cam.TrackingPosition = cam.TrackingPosition - (self.LastFloorDelta or EMPTYVEC)

        local roundingUpX = math.round(cam.TrackingPosition.X) > cam.TrackingPosition.X
        local roundingUpY = math.round(cam.TrackingPosition.Y) > cam.TrackingPosition.Y
        cam.TrackingPosition.X = math.floor(cam.TrackingPosition.X) + (self.LastFloor.Position.X % 1)
        cam.TrackingPosition.Y = math.floor(cam.TrackingPosition.Y) + (self.LastFloor.Position.Y % 1)

        -- cam.TrackingPosition.X = math.floor(cam.TrackingPosition.X) + (self.LastFloor.Position.X % 1)
        -- cam.TrackingPosition.Y = math.floor(cam.TrackingPosition.Y) + (self.LastFloor.Position.Y % 1)
    elseif self.Floor and self.Floor.LockPlayerVelocity then
        cam.TrackingPosition = cam.TrackingPosition - (self.FloorDelta or EMPTYVEC)
        local roundingUpX = math.round(cam.TrackingPosition.X) > cam.TrackingPosition.X
        local roundingUpY = math.round(cam.TrackingPosition.Y) > cam.TrackingPosition.Y
        cam.TrackingPosition.X = math.round(cam.TrackingPosition.X) + (self.Floor.Position.X % 1) - (roundingUpX and 1 or 0)
        cam.TrackingPosition.Y = math.round(cam.TrackingPosition.Y) + (self.Floor.Position.Y % 1) - (roundingUpY and 1 or 0)
    end

    if self.AerialMovementLockedToFloorPos or (self.Floor and self.Floor.LockPlayerVelocity) then
        
        
    end
     
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
    
    -- for i = 1, math.abs(posDelta.X) do
    --     self.Position.X = self.Position.X + 1 * sign(posDelta.X)
    --     local px = self:Unclip(false, false, true)
    --     if px ~= 0 then pushedX = true end
    -- end
    -- self.Position.X = self.Position.X + (math.abs(posDelta.X)%1)*sign(posDelta.X)
    -- local px = self:Unclip(false, false, true)
    -- if px ~= 0 then pushedX = true end

    -- for i = 1, math.abs(posDelta.Y) do
    --     print(i)
    --     self.Position.Y = self.Position.Y + 1 * sign(posDelta.Y)
    --     local py = self:Unclip(false, true, false)
    --     if py ~= 0 then pushedY = true end
    -- end
    -- self.Position.Y = self.Position.Y + (math.abs(posDelta.Y)%1)*sign(posDelta.Y)
    -- local py = self:Unclip(false, true, false)
    -- if py ~= 0 then pushedY = true end

    local posAfterMove = self.Position

    
    if math.abs(posBeforeMove[1] - posAfterMove[1]) < 1 and pushedX then
        self.Velocity.X = 0
       
    end




    -- special edge case for "falling" just off the corner of an object
    -- this happens when the player doesn't move far enough down for the x hitbox to touch the collider and move the player to the side
    -- the solution I think is just to force the movement and pray it doesn't create any edge case collision bugs
    
    if pushedY and not self.HeldItem and self.Velocity.X == 0 and self.Acceleration.X == 0 and not self.Floor and math.abs(posAfterMove.Y - posBeforeMove.Y) < 1 then
        print("HANGING OFF LEDGE!!!")
        self.Position.Y = self.Position.Y + self.Velocity.Y
        self:Unclip()
    end


    self.VelocityLastFrame = self.Velocity -- other guys use this later
    self.Velocity = self.Velocity + self.Acceleration
    
    self.Velocity.X = min(max(self.Velocity.X, -self.MaxSpeed.X), self.MaxSpeed.X)
    self.Velocity.Y = min(max(self.Velocity.Y, -self.MaxSpeed.Y), self.MaxSpeed.Y)
end

function Player:Teleport(x, y)
    x, y = y and x or x[1], y or x[2]

    local distX, distY = self.Position.X - x,
                         self.Position.Y - y

    self.Position.X = x
    self.Position.Y = y

    -- update tail points to avoid tail jitter
    for _, p in ipairs(self.TailPoints) do
        p[1] = p[1] - distX
        p[2] = p[2] - distY
    end

    self:DisconnectFromWall()
end

function Player:DisconnectNearbyInteractable()
    self.NearbyInteractable = nil
    local indicator = self:GetChild("InteractIndicator")
    indicator.Texture:Properties{
        Clock = 0,
        LeftBound = 11, RightBound = 20,
        Duration = 0.6,
        IsPlaying = true
    }
    Timer.Schedule(indicator.Texture.Duration, function ()
        if not self.NearbyInteractable then -- check to make sure it wasn't recently reactivated
            indicator.Visible = false
        end
    end)
end

local insert = table.insert
function Player:UpdateTail()
    local dist = (self.Position - self.LastPosition):Magnitude()
    if self.FramesSinceRespawn == 0 then
        self.TailPoints = {}
        return
    end
    local tp = self.TailPoints
    -- if (tp[1] ~= self.Position) or #tp < self.TailLength then
        insert(tp, 1, self.Position:Clone())
        if tp[self.TailLength+1] then
            tp[self.TailLength+1] = nil
        end
    -- end
end

------------------------ MAIN UPDATE LOOP -----------------------------
function Player:Update(engine_dt)
    self._usingPerformanceMode = self:GetLayer():GetParent().PerformanceMode
    -- also, engine_dt will be 1/60 in normal mode and 1/30 in performance mode
    
    local dt = 1/60 -- player value changes should always assume 60hz updates

    self.UnclipCount = 0


    -- self.Color = V{math.random(0,1),math.random(0,1),math.random(0,1)}
    ------------------- PHYSICS PROCESSING ----------------------------------
    

    -- process the held item, if there is one
    self:UpdateHeldItem()

    -- if we're on a moving floor let's move with it
    self:FollowFloor()



    -- listen for inputs here
    self:ProcessInput(engine_dt)

    -- update position based on velocity, velocity based on acceleration, etc
    self:UpdatePhysics()

    -- we do this manually inside UpdatePhysics now
    -- -- make sure collision is all good
    -- self:Unclip()

    -- update tail (based on physics)
    self:UpdateTail()
    
    -- confirm the floor remains the floor
    self:ValidateFloor()

        -- same with wall
        self:FollowWall()

        -- validate the wall early
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

        self.DiveExpiredGoalColor = self.DiveExpiredGoalColor:Lerp((self.DiveExpired) and self.DiveExpiredColor or Constant.COLOR.WHITE, 0.1)


        love.graphics.clear()
        local sx = self.Size[1] * (self.DrawScale[1]-1)
        local sy = self.Size[2] * (self.DrawScale[2]-1)

        local shouldDrawTail = (self.CrouchTime == 0 or not self.Floor) and
                               (self.ParryStatus == 0) and
                               (not self.Floor or self.Velocity:Magnitude() > 1.7)

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

        if self.HeldItem and self.FramesSinceHoldingItem > 1 then -- draw the held item with the player shader to merge the outlines
            local hsx, hsy = 0, 0
            if self.HeldItem.SquashWithPlayer then
                hsx, hsy = self.HeldItem.Size[1] * (self.DrawScale[1]-1),
                           self.HeldItem.Size[2] * (self.DrawScale[2]-1)
            end
            love.graphics.setColor(self.HeldItem.Color);
            (self.HeldItem.HeldTexture or self.HeldItem.Texture):DrawToScreen(
                self.Canvas:GetWidth()/2,
                self.Canvas:GetHeight()/2 + self.HeldItem.VerticalOffset + (self.HeldItemAnimationFrameOffsets[self.Texture.CurrentFrame] or 0),
                self.HeldItem.Rotation,
                (self.HeldItem.Size.X + hsx) * (sign(self.DrawScale.X) == -1 and -1 or 1),
                self.HeldItem.Size.Y + hsy,
                0.5, 0.5
            )
        end

        -- draw sweat drops if double jumped
        
        local shouldDrawSweat = self.FramesSinceDoubleJump >= 15 --or self.SweatTexture.CurrentFrame == 1
        
        if shouldDrawSweat then
            love.graphics.setColor(1,1,1)
            if self.FramesSinceDoubleJump == 15 then
                self.SweatTexture.Clock = 0
                self.SweatTexture.IsPlaying = true
            end
            self.SweatTexture:DrawToScreen(
                self.Canvas:GetWidth()/2-(1*self:GetBodyOrientation()),
                self.Canvas:GetHeight()/2-2,
                self.Rotation,
                self.Size[1] + sx,
                self.Size[2] + sy,
                0.5, 0.5
            )
        end

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

    if self.Shader then self.Shader:Activate() end

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
    


    if self.Shader then self.Shader:Deactivate() end
    
    if self.XHitbox.Visible then
        self.XHitbox:Draw(tx, ty)
        self.YHitbox:Draw(tx, ty)
    end
end

function Player:ResetJumpStamina()


    self:PlayRegainStaminaSound()

    self.ThrewItemInAir = false
    self.DiveExpired = false
    self.LastParryWall = nil
    self.WallBumpDirection = "none"
    self.FramesSinceDive = -1
    self.FramesSinceJump = -1
    self.FramesSinceDoubleJump = -1
    self.FramesSinceParry = -1
    self.FramesSincePounce = -1
    self.CaughtHeldItemMidairChain = 0

    
end

function Player:Respawn(pos)
    pos = pos or self.LastSafePosition
    
    self.FramesSinceRespawn = 0
    self.Position = pos
    self.Velocity[1] = 0; self.Velocity[2] = 0;
end

function Player:UpdateHeldItem()
    if self.HeldItem then
        -- self.HeldItem.Position = self.Position + V{0, self.HeldItem.VerticalOffset - 12 + (self.HeldItemAnimationFrameOffsets[self.Texture.CurrentFrame] or 0)}
        self.HeldItem.Position = self.Position + V{-0.5, self.HeldItem.VerticalOffset - 12}
    end
end

function Player:PickUpItem(item, dt)
    -- pick up nearby item
    local origItemPosition = item.Position:Clone()
    if item.PickupDebounce == 0 then
        self:PlaySFX("PickUpItem")
        self.HeldItem = item
        self.LastHeldItem = item
        item.Owner = self
        local itemHadFloor = not item.Floor
        item.Floor = nil
        
        self.FramesSinceHoldingItem = 0
        
        if item.ExtendsHitbox then
            -- make sure there's no collision fuckery

            for i = 0, 5, 5 do
                self:UpdateHeldItem()
                item.Position.Y = item.Position.Y + i
                local heldItemFloor = item.Floor
                local pushX, pushY = item:RunCollision(true, dt)
                if math.abs(pushX) > 3 or pushY ~= 0 then
                    if self.InputListener:JustPressed("action") then
                        self:PlaySFX("GrabItemFail", 1, 0)
                    end
                    self:PutDownItem()
                    item.Position = origItemPosition
                    item.Floor = heldItemFloor
                    return
                elseif pushX ~= 0 then -- we can handle a little bit of X pushing
                    self.Position.X = self.Position.X + pushX
                    Chexcore._frameDelay = Chexcore._frameDelay + 0.03333333
                else
                    Chexcore._frameDelay = Chexcore._frameDelay + 0.03333333
                end
            end
        end
        self.CaughtLastHeldItemFromMidair = itemHadFloor
    end
end

function Player:PutDownItem()
    -- put down held item
    self.HeldItem:PutDown(self.Floor and true, self.Velocity.Y)
    self:PlaySFX("PickUpItem", 0.7)
    self.FramesSinceHoldingItem = -1
    self.FramesSinceDroppedItem = 0
    self.HeldItem = nil

    -- pause in midair if on the way down
    if not self.Floor then
        self.Velocity.Y = math.min(-1, self.Velocity.Y)
    end
end

function Player:ThrowItem()
    local item = self.HeldItem
    self:PutDownItem()
    self.FramesSinceThrownItem = 0
    local dir = self.MoveDir ~= 0 and self.MoveDir or sign(self.DrawScale.X)
    local itemYVel = self.Floor and (item.GROUNDED_THROW_HEIGHT or -1) or (item.MIDAIR_THROW_HEIGHT or -1)
    item.Velocity = V{math.max(item.MinThrowSpeed or 3.5, (1.75 + math.abs(self.Velocity.X))) * dir, itemYVel}
    -- item.Position.X = item.Position.X - 10* dir
    self.LastThrowDirection = dir
    item:Throw(not not self.Floor)
end

function Player:SetTrailColor(r,g,b,a)
    if g then -- SetTrailColor(r, g, b, a)
        self.TrailColor[1] = r
        self.TrailColor[2] = g
        self.TrailColor[3] = b
        self.TrailColor[4] = a
    else -- SetTrailColor(V{col})
        self.TrailColor[1] = r[1]
        self.TrailColor[2] = r[2]
        self.TrailColor[3] = r[3]
        self.TrailColor[4] = r[4]
    end
end

return Player