local Player = {
    -- properties
    Name = "Player",           -- Easy identifier
    AnchorPoint = V{ 0.5, 1 },
    Velocity = V{1, -1},
    Acceleration = V{0,0.025},
    Visible = true,
    Rotation = 0,
    Position = V{-20,-50},
    Size = V{24,24},
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


local hitboxPrototype = Prop.new{
    Name = "hitbox",
    Size = V{8,16},
    Visible = false,
    Solid = true,
    AnchorPoint = V{0.5,1}
}


function Player.new()
    local newPlayer = setmetatable({}, Player)
    newPlayer.Texture = Animation.new("chexcore/assets/images/test/player-sprite.png", 12, 12):AddProperties{Duration = .72, LeftBound = 5, RightBound = 10}
    newPlayer:Adopt(hitboxPrototype:Clone())
    newPlayer.Position = Player.Position:Clone()
    newPlayer.Size = Player.Size:Clone()
    
    return newPlayer
end

function Player:Update(dt)
    --self.Rotation = Chexcore._clock*0.5
    --self:SetEdge("bottom", wheel:GetChild("Semi1"):GetEdge("top"))
    local hitbox = self:GetChild("hitbox")

    self.Position = self.Position + self.Velocity
    self.Velocity = self.Velocity + self.Acceleration
    hitbox.Position.X = self.Position.X
    hitbox.Position.Y = self.Position.Y        --self.Texture = Texture.new("chexcore/assets/images/test/player" .. (math.floor(Chexcore._clock*4))%4+1 .. ".png")
    --self.Rotation = Chexcore._clock
    --crate2.Position = self:GetPoint((math.sin(Chexcore._clock)+1)/2, (math.cos(Chexcore._clock)+1)/2)
    --crate2:SetPosition(self:GetPoint((math.sin(Chexcore._clock*20)+1)/2, (math.cos(Chexcore._clock*20)+1)/2)())
    local hit = false
    for solid, hDist, vDist, tileID in hitbox:CollisionPass(self._parent, true) do
        if solid ~= self then
            hit = true
            local face = Prop.GetHitFace(hDist, vDist)
            if face == "top" or face == "bottom" then
                -- print("clip")
                self.Position.Y = self.Position.Y + vDist
                self.Velocity.Y = 0
                
            elseif face == "left" or face == "right" then
                self.Position.X = self.Position.X + hDist
                self.Velocity.X = -self.Velocity.X
                self.DrawScale.X = -self.DrawScale.X
            end
        end
    end

    if hit then
        
    end
end


return Player