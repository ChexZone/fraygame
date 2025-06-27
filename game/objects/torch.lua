local Torch = {
    Name = "Torch",
    _super = "Prop"
}

function Torch.new()
    return Prop.new{
        Visible = false,
        Update = function (self,dt)
            self:GetChild("Base"):MoveTo(self:GetPoint(0.5,0.5) + V{0,2})
            self:GetChild("Flame"):MoveTo(self:GetPoint(0.5,0.5) + V{0,4})
            self:GetChild("LightSource"):MoveTo(self:GetPoint(0.5,0.5) + V{0,4})
        end
    }:With(Prop.new{
        Name = "Base",
        Size = V{24,22},
        AnchorPoint = V{0.5,0},
        Texture = Animation.new("game/assets/images/area/intro/torch_base.png",1,3):Properties{LeftBound=1,RightBound=2}
    }):With(Prop.new{
        Name = "Flame",
        Size = V{24,32},
        AnchorPoint = V{0.5,1},
        Texture = Animation.new("game/assets/images/area/intro/torch_fire_orange.png",1,8):Properties{LeftBound=1,RightBound=8, PlaybackScaling = 1 + math.random(-5,5)/50}
    }):With(LightSource.new():Properties{
        Color = HSV{0.1,0.4,1,1},
        Radius = 100,
        Sharpness = 0.5
    })
end

return Torch