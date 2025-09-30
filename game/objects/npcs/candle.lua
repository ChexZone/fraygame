local Candle = {
    Name = "Candle",

    -- internal
    _global = true,
    _super = "RenderMask"
}

function Candle.new()
    local newCandle = setmetatable(RenderMask.new{
        Size = V{128, 128},
        AnchorPoint = V{0.5,0.5},
        ZIndex = 1000,
        Color = V{1,1,1,1},
        Update = function (self, dt)
            self.OldPosition = self.Position:Clone()
            
            self.Position = self.Position + V{math.sin(Chexcore._clock),0}

            local yOfs = (math.sin(Chexcore._clock*3)+1)/1.5

            
            local oPos = self.Position:Clone()
            self.Position.Y = self.Position.Y + yOfs


            self.FlameParticles:MoveTo(self.Position)
            self.FlameBase:MoveTo(self.Position)
            self.HeadBase:MoveTo(self.Position)
            local ofs = Vector.FromAngle(self.Eye.Angle)
            local ofs2 = V{0.5,0.45}
            if ofs.X > 0 then
                self.Eye.Size.X = 8
            else
                self.Eye.Size.X = -8
                ofs2.X = ofs2.X - 1
            end

            self.Eye:MoveTo(self.Position - ofs2 + ofs*self.Eye.Distance)

            self.FaceDirection = ofs.X

            local ofsPupil = Vector.FromAngle(self.Pupil.Angle)*self.Pupil.Distance

            self.Pupil:MoveTo(self.Eye.Position + ofsPupil + V{ofs.X > 0 and 1 or -1, 0.75})
            
            self.Light:MoveTo(self.Position)


            
            self.Position = oPos

            local posChange = self.Position - self.OldPosition
            self.AverageVelocity = (self.AverageVelocity or V{0,0}):Lerp(posChange, 0.1)

            print(self.AverageVelocity)
            -- print(posChange, self.Position, self.OldPosition)
        end
    }, Candle)

    newCandle.Light = newCandle:Adopt(LightSource.new():Properties{
        Radius = 20, Sharpness = 0
    })

    newCandle.FlameParticles = newCandle:Adopt(Particles.new{
        Name = "FlameParticles",
        Size = V{0,0},

        ParticleTexture = Texture.new("chexcore/assets/images/square.png"),
        -- ParticleTexture = Texture.new("game/assets/images/npc/candle/flame-particle.png"),
        ParticleSize = V{0, 0},
        Visible = false,
        ParticleSizeVelocity = V{20, 20},
        ParticleSizeAcceleration = V{-40, -40},
        ParticleColor = Vector.Hex"#ffc778",
        RelativePosition = true,
        ParticleLifeTime = 1.4,
        -- ParticleAnchorPoint = V{1,1},
        ParticleRotation = math.rad(45),
        Update = function (self, dt)
            self.Status = self.Status and self.Status + 1 or 0
            local moveSpeed = newCandle.AverageVelocity:Magnitude()
            print((10 - math.ceil(moveSpeed-0.75)))
            if self.Status % (10 - math.ceil(moveSpeed-0.75)) == 0 then
                -- local dir = math.random(2)==1 and -1 or 1
                self.Dir = self.Dir == -1 and 1 or -1
                local intensity = ((self.Status+1)%3+1)/1.8
                local dirIntensity = ((self.Status+2)%3+1)/2.5
                self:Emit{
                    -- Size = V{1,1},
                    SizeVelocity = V{10*intensity, 10*intensity},
                    SizeAcceleration = V{-20*intensity/self.ParticleLifeTime, -20*intensity/self.ParticleLifeTime},
                    Position =  V{0,4},
                    Velocity = moveSpeed < 1 and V{-10*self.Dir*dirIntensity - 4 * (newCandle.FaceDirection or 0), 0} or -(newCandle.AverageVelocity or V{0,0})*5,
                    Acceleration = V{16*self.Dir*dirIntensity,-17},
                    -- RotVelocity = math.random(-1,1)
                }
            end
        end
    })
    newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = newCandle.FlameParticles

    newCandle.FlameBase = newCandle:Adopt(Prop.new{
        Name = "FlameBase",
        AnchorPoint = V{0.5,0.5},
        Size = V{6,6},
        Visible = false,
        Texture = Texture.new("game/assets/images/npc/candle/flame-base.png")
    })
    -- newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = newCandle.FlameBase


    newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", Vector.Hex"#ff6700"):Send("thickness", 2):Send("step", V{1,1}/newCandle.Size)


    newCandle.HeadBase = newCandle:Adopt(Prop.new{
        Name = "HeadBase",
        AnchorPoint = V{0.5,0.5},
        Size = V{14,14},
        Visible = false,
        Texture = Texture.new("game/assets/images/npc/candle/head-base.png")
    })
    newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = newCandle.HeadBase

    newCandle.Eye = newCandle:Adopt(Prop.new{
        Name = "Eye",
        AnchorPoint = V{0.5,0.5},
        Size = V{8,8},
        Angle = 0, Distance = V{1,0.5},
        Visible = false,
        Texture = Texture.new("game/assets/images/npc/candle/eye-white.png"),
        Update =function (self, dt)
            -- self.Angle = self.Angle + 0.025
            local t = (newCandle.Target:GetPoint(0.5,0.5) - newCandle.Position)
            t.X, t.Y = t.Y, t.X
            self.Angle = (t):ToAngle()
        end
    })
    newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = newCandle.Eye

    newCandle.Pupil = newCandle.Eye:Adopt(Prop.new{
        Name = "Pupil",
        AnchorPoint = V{0.5,0.5},
        Size = V{2,2},
        Angle = 0, Distance = V{1.75,1.25},
        Visible = false,
        Texture = Texture.new("game/assets/images/npc/candle/eye-pupil.png"),
        Update =function (self, dt)
            -- self.Angle = self.Angle - 0.2
            local t = (newCandle.Target:GetPoint(0.5,0.5) - newCandle.Eye.Position)
            t.X, t.Y = t.Y, t.X
            self.Angle = (t):ToAngle()
        end
    })
    newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = newCandle.Pupil


    newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", Vector.Hex"#ff6700"):Send("thickness", 1):Send("step", V{1,1}/newCandle.Size)

    newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", Vector.Hex"#920037"):Send("thickness", 1):Send("step", V{1,1}/newCandle.Size)

    -- newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", Vector.Hex"#ff6700"):Send("thickness", 1):Send("step", V{1,1}/newCandle.Size)
    -- newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", Vector.Hex"#ff6700"):Send("thickness", 1):Send("step", V{1,1}/newCandle.Size)
    -- newCandle.RenderPipeline[#newCandle.RenderPipeline+1] = Shader.new("game/assets/shaders/custom-outline-thick.glsl"):Send("outlineColor", Vector.Hex"#ff6700"):Send("thickness", 1):Send("step", V{1,1}/newCandle.Size)

    return newCandle
end

return Candle