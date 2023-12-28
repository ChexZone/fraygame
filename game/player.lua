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


    -- vars
    Floor = nil,    -- the current Prop acting as the "floor"
    

    -- internal properties
    _super = "Prop",      -- Supertype
    _global = true
}


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
    Size = V{6,16},
    Visible = true,
    Color = V{1,0,0,0.2},
    Solid = true,
    AnchorPoint = V{0.5,1}
}
local xHitboxBASE = Prop.new{
    Name = "xHitbox",
    Texture = Texture.new("chexcore/assets/images/square.png"),
    Size = V{10,10},
    Visible = true,
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
    if key == "jump" then
        -- print((self.FloorPos - self.Floor.Position))
        -- self.Velocity = self.Velocity - (self.FloorPos - self.Floor.Position)
        self:DisconnectFromFloor()
        print("jump")
        self.Velocity.Y = -3
    end
end

function Player:DisconnectFromFloor()
    self.Floor = nil
    self.FloorPos = nil
end

function Player:ConnectToFloor(floor)
    self.Floor = floor
    self.FloorPos = floor.Position:Clone()
end

function Player:Update(dt)
    local xHitbox = self:GetChild("xHitbox")
    local yHitbox = self:GetChild("yHitbox")

    ------------------- PHYSICS PROCESSING ----------------------------------

    -- update position before velocity, so that there is at least 1 frame of whatever Velocity is set by prev frame
    self.Position = self.Position + self.Velocity
    self.Velocity = self.Velocity + self.Acceleration

    print(self.Velocity.Y)
    -- also, if we're on a moving floor let's move with it
    if self.Floor then
        if self.FloorPos and self.FloorPos ~= self.Floor.Position then
            local delta = self.FloorPos - self.Floor.Position
            self.Velocity.Y = 0
            self.Position = self.Position - delta
            if not self.Floor:IsA("Tilemap") then
                self:SetEdge("bottom", self.Floor:GetEdge("top"))
            end
        end

        self.FloorPos = self.Floor.Position:Clone()
    end

    -- make sure the hitbox is repositioned BEFORE 
    xHitbox.Position.X = self.Position.X
    xHitbox.Position.Y = self.Position.Y - 3
    yHitbox.Position.X = self.Position.X
    yHitbox.Position.Y = self.Position.Y
    --print(hitbox.Position.Y)
    
    for solid, hDist, vDist, tileID in yHitbox:CollisionPass(self._parent, true) do
        
        if solid ~= yHitbox then
            local face = Prop.GetHitFace(hDist, vDist)

            --print(vDist)

            -- if face == "none" then -- uhhhh maybe clipping into the side of a tile
            --     self.Position.Y = self.Position.Y + (vDist or 0)
            -- elseif face == "top" or face == "bottom" then
            --     -- print("clip")
            --     self.Position.Y = self.Position.Y + vDist
            --     self.Velocity.Y = 0
            --     if hDist and math.abs(hDist) == 1 then
            --         print("h")
            --         self.Position.X = self.Position.X + hDist
            --     end
            -- elseif face == "left" or face == "right" then
            --     self.Position.X = self.Position.X + hDist
            --     self.Velocity.X = 0
            --     print("H", hDist, vDist)
            --     if vDist then
            --         print("v")
            --         self.Position.Y = self.Position.Y + vDist
            --     end
            -- end

            -- if face == "none" then
            --     self.Position.Y = self.Position.Y + (vDist or 0)
            -- end
           if vDist and vDist ~= 0 then
                self.Position.Y = self.Position.Y + vDist
                self.Velocity.Y = 0
                if vDist < 0 then -- object was the floor
                    self:ConnectToFloor(solid)
                end
           end
            -- if face == "left" or face == "right" then
            --     self.Position.X = self.Position.X + hDist
            --     self.Velocity.X = 0
            -- end
        end
    end

    for solid, hDist, vDist, tileID in xHitbox:CollisionPass(self._parent, true) do
        if solid ~= xHitbox and hDist and hDist ~= 0 then
            if math.abs(hDist) < xHitbox.Size.X then
                self.Position.X = self.Position.X + hDist
                self.Velocity.X = 0
            end
       end
    end



    if self.Floor then
        -- check if we've collided with the current floor or not
        yHitbox.Position.X = self.Position.X
        yHitbox.Position.Y = self.Position.Y + 1

        local hit, hDist, vDist = self.Floor:CollisionInfo(yHitbox)
        if not hit then
            self:DisconnectFromFloor()
        end
    end


    xHitbox.Position.X = self.Position.X
    xHitbox.Position.Y = self.Position.Y - 3
    yHitbox.Position.X = self.Position.X
    yHitbox.Position.Y = self.Position.Y
    ------------------ INPUT PROCESSING --------------------------
    local input = self.InputListener

    local moveDirection = (input:IsDown("move_left") and -1 or 0) + (input:IsDown("move_right") and 1 or 0)
    if moveDirection ~= 0 then
        self.Acceleration.X = moveDirection*0.05
        self.DrawScale.X = moveDirection
        
        if self.Texture.LeftBound < 13 then self.Texture:AddProperties{LeftBound = 5, RightBound = 10, Duration = 0.72, PlaybackScaling = 3 - math.abs(self.Velocity.X)*1.25} end
    else
        self.Velocity.X = 0
        self.Texture:AddProperties{LeftBound = 1, RightBound = 4, Duration = 1, PlaybackScaling = 1, IsPlaying = true, Loop = true}
    end

    self.Velocity.X = math.min(math.max(self.Velocity.X, -1.2), 1.2)
end

function Player:Draw(tx, ty)
    -- self:GetChild("hitbox").Position = self.Position
    -- print(self.Position, self:GetChild("hitbox").Position)
    Prop.Draw(self, tx, ty)
end


return Player