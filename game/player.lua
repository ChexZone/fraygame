local Player = {
    -- properties
    Name = "Player",           -- Easy identifier
    AnchorPoint = V{ 0.5, 1 },
    Velocity = V{.3, -1},
    Acceleration = V{0,0.15},
    Visible = true,
    Solid = false,
    Rotation = 0,
    Position = V{0,-50},
    Size = V{24,24},

    MaxSpeed = V{1.2, 3},

    -- vars
    Floor = nil,                -- the current Prop acting as the "floor"
    FloorPos = nil,             -- the last recorded floor position (for deltas)
    FloorDelta = nil,           -- the movement of the floor over the past frame (calculated near the start of the update cycle)
    FloorLeftEdge = nil,        -- last recorded left edge of the floor (not tilemaps)
    FloorRightEdge = nil,       -- last recorded right edge of the floor (not tilemaps)
    DistanceAlongFloor = nil,   -- how far the player's position is along the floor (not tilemaps)

    -- internal properties
    _super = "Prop",      -- Supertype
    _global = true
}
local EMPTYVEC = V{0,0}

Player.Shader = Shader.new([[
    uniform vec2 step;
    float rand(vec2 co){
        return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
    }
    vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
    {
        float alpha = Texel( texture, texturePos + vec2( step.x, 0.0f ) ).a +
        Texel( texture, texturePos + vec2( -step.x, 0.0f ) ).a +
        Texel( texture, texturePos + vec2( 0.0f, step.y ) ).a +
        Texel( texture, texturePos + vec2( 0.0f, -step.y ) ).a;

        if(
            alpha > 0.0f && Texel(texture,texturePos).a == 0.0f
        ) {
            return vec4( 0.0f,0.0f,0.0f, 1.0f );
        } else {
            return Texel(texture, texturePos) * col;
        }

    }
]]):Send("step",{1/24/12,1/24/12}) -- 1/ 24 (for tile size) / 12 (for tile count)


local yHitboxBASE = Prop.new{
    Name = "yHitbox",
    Texture = Texture.new("chexcore/assets/images/square.png"),
    Size = V{8,16},
    Visible = false,
    Color = V{1,0,0,0.2},
    Solid = true,
    AnchorPoint = V{0.5,1}
}
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
    newPlayer:Adopt(yHitboxBASE:Clone())
    newPlayer:Adopt(xHitboxBASE:Clone())
    newPlayer.Position = Player.Position:Clone()
    newPlayer.Size = Player.Size:Clone()
    
    newPlayer.InputListener = Input.new{
        a = "move_left",
        d = "move_right",
        space = "jump",
    }
    function newPlayer.InputListener:Press(device, key)
        newPlayer:Press(key)
    end
    
    return newPlayer
end


function Player:Press(key)
    if key == "jump" and self.Floor then
        -- print((self.FloorPos - self.Floor.Position))
        -- self.Velocity = self.Velocity - (self.FloorPos - self.Floor.Position)
        self:DisconnectFromFloor()
        self.Velocity.Y = -3
        self.Texture:AddProperties{LeftBound = 25, RightBound = 28, Duration = 0.4, PlaybackScaling = 1, Loop = false, Clock = 0}
    end
end

function Player:DisconnectFromFloor()
    self.Floor = nil
    self.FloorPos = nil
    self.FloorLeftEdge, self.FloorRightEdge = nil, nil
    self.DistanceAlongFloor = nil
end

function Player:ConnectToFloor(floor)
    self.Floor = floor
    self.FloorPos = floor.Position:Clone()
    self.FloorLeftEdge = floor:GetEdge("left")
    self.FloorRightEdge = floor:GetEdge("right")
    self.DistanceAlongFloor = (self.Position.X - self.FloorLeftEdge) + (self.FloorRightEdge - self.FloorLeftEdge)
    self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Loop = true}
end

function Player:AlignWithFloor()
    self.Position.X = math.floor(self.Position.X) + (self.Floor.Position.X - math.floor(self.Floor.Position.X))
end

function Player:AlignHitboxes(xHitbox, yHitbox)
    xHitbox = xHitbox or self:GetChild("xHitbox")
    yHitbox = yHitbox or self:GetChild("yHitbox")

    xHitbox.Position.X = self.Position.X
    xHitbox.Position.Y = self.Position.Y - 2
    yHitbox.Position.X = self.Position.X
    yHitbox.Position.Y = self.Position.Y
end

function Player:Update(dt)
    local xHitbox = self:GetChild("xHitbox")
    local yHitbox = self:GetChild("yHitbox")

    ------------------- PHYSICS PROCESSING ----------------------------------



    -- if we're on a moving floor let's move with it
    if self.Floor then
        if self.FloorPos and self.FloorPos ~= self.Floor.Position then
            if not self.Floor:IsA("Tilemap") then
                -- moving tile collision stuff
                self.FloorDelta = self.FloorPos - self.Floor.Position
                -- local newLeftEdge = self.Floor:GetEdge("left")
                -- local newRightEdge = self.Floor:GetEdge("right")

                
                -- self.FloorLeftEdge = newLeftEdge
                -- self.FloorRightEdge = newRightEdge
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

    -- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
    self.Position = self.Position + self.Velocity
    self.Velocity = self.Velocity + self.Acceleration
    
    -- make sure the hitbox is repositioned BEFORE 
    self:AlignHitboxes(xHitbox, yHitbox)


    local pushY = 0
    for solid, hDist, vDist, tileID in yHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)
        if solid ~= yHitbox and (face == "top" or face == "bottom") then
            self.Velocity.Y = 0
            --self.Position.Y = self.Position.Y + vDist
            pushY = math.abs(pushY) > math.abs(vDist) and pushY or vDist
            if face == "bottom" then
                
                self:ConnectToFloor(solid)
            end
            self:AlignHitboxes(xHitbox, yHitbox)
        end
        
    end
    self.Position.Y = self.Position.Y + pushY

    print(self.Floor)
    
    local pushX = 0
    for solid, hDist, vDist, tileID in xHitbox:CollisionPass(self._parent, true) do
        local face = Prop.GetHitFace(hDist,vDist)
        if solid ~= xHitbox and (face == "left" or face == "right") then
            self.Velocity.X = 0
            pushX = math.abs(pushX) > math.abs(hDist) and pushX or hDist
            self:AlignHitboxes(xHitbox, yHitbox)
        end
        
    end
    self.Position.X = self.Position.X + pushX

    --print(hitbox.Position.Y)
    
    -- for solid, hDist, vDist, tileID in yHitbox:CollisionPass(self._parent, true) do
        
    --     if solid ~= yHitbox then
    --        if vDist and vDist ~= 0 and math.abs(vDist) < yHitbox.Size.Y then
    --             self.Position.Y = self.Position.Y + vDist
    --             self.Velocity.Y = 0
    --             --print(hDist, vDist)
    --             if vDist < 0 then -- object was the floor
    --                 self:ConnectToFloor(solid)
    --             end
    --             -- self:AlignHitboxes(xHitbox, yHitbox)
    --             break
    --        end
    --     end
    -- end

    -- for solid, hDist, vDist, tileID in xHitbox:CollisionPass(self._parent, true) do
    --     if solid ~= xHitbox and hDist and hDist ~= 0 then
    --         if math.abs(hDist) < xHitbox.Size.X then
    --             self.Position.X = self.Position.X + hDist
    --             -- self.Velocity.X = 0
                
    --             break
    --         end
    --    end
    -- end

    -- confirm the floor remains the floor
    if self.Floor then
        -- check if we've collided with the current floor or not
        yHitbox.Position.X = self.Position.X
        yHitbox.Position.Y = self.Position.Y + 1
        
        self.Velocity.Y = 0

        local hit, hDist, vDist = self.Floor:CollisionInfo(yHitbox)
        if not hit then
            self:DisconnectFromFloor()
            self.Texture:AddProperties{LeftBound = 27, RightBound = 28, Duration = 0.4, PlaybackScaling = 1, Loop = false, Clock = 0}
        end
    end

    -- print(self.Floor)


    ------------------ INPUT PROCESSING --------------------------
    local input = self.InputListener

    local moveDirection = (input:IsDown("move_left") and -1 or 0) + (input:IsDown("move_right") and 1 or 0)
    if moveDirection ~= 0 then
        self.Acceleration.X = moveDirection*0.05
        self.DrawScale.X = moveDirection
        
        if self.Floor then
            self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 3 - math.abs(self.Velocity.X)*1.25, IsPlaying = true} 
        end
    else
        -- connect to floor while idle
        if self.Floor and (not self.FloorDelta or self.FloorDelta ~= EMPTYVEC) then
            self:AlignWithFloor()
        end
        self.Velocity.X = 0

        if self.Floor then
            self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Duration = 1, PlaybackScaling = 1, IsPlaying = true, Loop = true}
        end
    end

    self.Velocity.X = math.min(math.max(self.Velocity.X, -self.MaxSpeed.X), self.MaxSpeed.X)
    self.Velocity.Y = math.min(math.max(self.Velocity.Y, -self.MaxSpeed.Y), self.MaxSpeed.Y)
end

function Player:Draw(tx, ty)
    -- self:GetChild("hitbox").Position = self.Position
    -- print(self.Position, self:GetChild("hitbox").Position)

    -- make sure hitboxes are re-aligned with player after position updates
    self:AlignHitboxes()

    Prop.Draw(self, tx, ty)
end


return Player