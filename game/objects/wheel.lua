local Wheel = {
    Name = "Wheel", _super = "Prop", _global = true
}

function Wheel.new()
    local wheel = Prop.new{
        Name = "Wheel",
        Solid = false, Visible = true,
        Position = V{ -96, 0 }, Size = V{ 128, 128 },
        Color = V{.8,.8,.8},
        AnchorPoint = V{ 0.5,0.5 },
        Rotation = 0,
        DrawOverChildren = false,
        Texture = Texture.new("chexcore/assets/images/test/wheel.png"),
        Update = function (self, dt)
            self.Rotation = Chexcore._clock - math.rad(10)/2
            -- self.Position = V{-60 - 100 * math.cos(Chexcore._clock), 100 * math.sin(Chexcore._clock)}
        end
    }
    wheel:Adopt(Prop.new{
        Name = "WheelBase",
        Solid = false, Visible = true,
        Position = V{ -96, 0 },   -- V stands for Vector
        Size = V{ 128, 128 },
        Color = V{.9,.9,.9},
        AnchorPoint = V{ .5, .5 },
        Rotation = 0,
        Texture = Texture.new("chexcore/assets/images/test/wheelbase.png"),
        Update = function (self, dt)
            self.Size = self._parent.Size
            self.Rotation = Chexcore._clock - Chexcore._clock%math.rad(10)
            --crate2.Position = self:GetPoint((math.sin(Chexcore._clock)+1)/2, (math.cos(Chexcore._clock)+1)/2)
            self.Position = self._parent.Position

            --crate2:SetPosition(self:GetPoint((math.sin(Chexcore._clock*20)+1)/2, (math.cos(Chexcore._clock*20)+1)/2)())
        end
    })
    wheel:Adopt(Prop.new{
        Name = "WheelBase",
        Solid = false, Visible = true,
        Position = V{ -96, 0 },   -- V stands for Vector
        Size = V{ 128, 128 },
        Color = V{.9,.9,.9},
        AnchorPoint = V{ .5, .5 },
        Rotation = 0,
    
        Texture = Texture.new("chexcore/assets/images/test/wheel.png"),
        Update = function (self, dt)
            
            self.Position = self._parent.Position
            self.Size = self._parent.Size
            self.Rotation = Chexcore._clock - Chexcore._clock%math.rad(10)
            --crate2.Position = self:GetPoint((math.sin(Chexcore._clock)+1)/2, (math.cos(Chexcore._clock)+1)/2)
            --crate2:SetPosition(self:GetPoint((math.sin(Chexcore._clock*20)+1)/2, (math.cos(Chexcore._clock*20)+1)/2)())
        end
    })
    wheel:Adopt(Prop.new{
        Name = "Semi1",
        Solid = true, Visible = true,
        Position = V{ 340, 220 } / 2,   -- V stands for Vector
        Size = V{ 20, 8 } * 2,
        AnchorPoint = V{ 0.5, 0.5 },
        Rotation = 0,
        Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(0.5, 0)
        end
    })
    wheel:Adopt(Prop.new{
        Name = "Semi2",
    
        Solid = true, Visible = true,
        Position = V{ 340, 220 } / 2,   -- V stands for Vector
        Size = V{ 20, 8 } * 2,
        AnchorPoint = V{ 0.5, 0.5 },
        Rotation = 0,
        Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(0.5, 1)
        end
    })
    wheel:Adopt(Prop.new{
        Name = "Semi3",
    
        Solid = true, Visible = true,
        Position = V{ 340, 220 } / 2,   -- V stands for Vector
        Size = V{ 20, 8 } * 2,
        AnchorPoint = V{ 0.5, 0.5 },
        Rotation = 0,
        Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(0, 0.5)
        end
    })
    wheel:Adopt(Prop.new{
        Name = "Semi4",
    
        Solid = true, Visible = true,
        Position = V{ 340, 220 } / 2,   -- V stands for Vector
        Size = V{ 20, 8 } * 2,
        AnchorPoint = V{ 0.5, 0.5 },
        Rotation = 0,
        Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(1, 0.5)
        end
    })

    return wheel
end

return Wheel