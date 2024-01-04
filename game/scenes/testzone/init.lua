local scene = Scene.new{
    Update = function (self, dt)
        Scene.Update(self, dt)
        self.Camera.Position = (self:GetDescendent("Player").Position - V{0, self:GetDescendent("Player").Size.Y/2})
        self.Camera.Zoom = 2 --+ (math.sin(Chexcore._clock)+1)/2
    end
}

-- Scenes have a list of Layers, which each hold their own Props
local bgTex = Texture.new("chexcore/assets/images/test/bg.png")
scene:AddLayer(Layer.new("Background", 320, 180)):AddProperties{ ZoomInfluence = 0, TranslationInfluence = 0.5,
Draw = function (self)
    self.Canvases[1]:Activate()
    love.graphics.setColor(1,1,1)
    bgTex:DrawToScreen(160,90 - scene.Camera.Position.Y/20,0,320,320,0.5,0.5)
    self.Canvases[1]:Deactivate()
end}

local mainLayer = scene:AddLayer(Layer.new("Gameplay", 640, 360))

mainLayer.Canvases[1].Shader = Shader.new[[
    vec4 origOut;
    float dist;
    vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
    origOut = (Texel(texture, texturePos) * col);

    if (origOut.a == 1.0f) {

        vec2 normalizedScreenPos = screenPos / love_ScreenSize.xy;

        dist = max(min(sqrt(pow(0.5 - normalizedScreenPos.x, 2) + pow(0.5 - normalizedScreenPos.y, 2)) * 8, 0.5), 0) * 0;
        return vec4(
            origOut.r - dist,
            origOut.g - dist,
            origOut.b - dist,
            1.0f
        );
    } else {
        return origOut;
    }

    
}
    
]]


scene:AddLayer(Layer.new("GUI", 1920, 1080))



local crate2
-- test collidable
local wheel = scene:GetLayer("Gameplay"):Adopt(Prop.new{
    Name = "Wheel",
    Solid = false, Visible = false,
    Position = V{ -96, 0 }, Size = V{ 128, 128 },
    Color = V{.8,.8,.8},
    AnchorPoint = V{ .5, .5 },
    Rotation = 0,
    DrawOverChildren = false,
    Texture = Texture.new("chexcore/assets/images/test/wheel.png"),
    Update = function (self, dt)
        self.Rotation = Chexcore._clock - math.rad(10)/2
        self.Position = V{-60 - 100 * math.cos(Chexcore._clock), 100 * math.sin(Chexcore._clock)}
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
    Texture = Texture.new("chexcore/assets/images/test/wheelbase.png"),
    Update = function (self, dt)
        --self.Rotation = Chexcore._clock - Chexcore._clock%math.rad(10)
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

mainLayer:Adopt(Prop.new{
    Name = "Semi5",
    Solid = true, Visible = true,
    Position = V{ 0, 0 },   -- V stands for Vector
    Size = V{ 20, 8 } * 2,
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
    Update = function (self, dt)
        self.Position = V{50 + math.sin(Chexcore._clock*2)*100, -80}
    end
})

mainLayer:Adopt(Prop.new{
    Name = "Semi6",
    Solid = true, Visible = true,
    Position = V{ 0, 0 },   -- V stands for Vector
    Size = V{ 20, 8 } * 2,
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("chexcore/assets/images/test/semisolid.png"),
    Update = function (self, dt)
        self.Position = V{300, -50 - math.sin(Chexcore._clock*1-0.25)*100}
    end
})

local tilemap = mainLayer:Adopt(Tilemap.new("chexcore/assets/images/test/tilemap.png", 32, 8, 8, {{
    11, 0, 0, 0, 0, 0, 0, 10,
    6, 11, 0, 0, 0, 0, 10, 7,
    4, 6, 1, 1, 1, 1, 7, 4,
    13, 13, 13, 13, 13, 13, 13, 13,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1,
}})):AddProperties{
    Position = V{64,0},
    AnchorPoint = V{0,0},
    Scale = 1,
    Active = true,
    Update = function (self, dt)
        self.Position.Y = self.Position.Y - 1
    end
}

tilemap:Clone(true):AddProperties{Position = V{199,0}}

return scene