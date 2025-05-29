local PlayerRagdoll = {
    Name = "PlayerRagdoll", _super = "Prop", _global = true
}

function PlayerRagdoll.new()
    local ragdoll = Prop.new{
        Name = "PlayerRagdoll",
        Canvas = Canvas.new(64, 64),
        HelperCanvas = Canvas.new(64, 64),
        DrawInForeground = true,
        Shader = Shader.new("game/assets/shaders/outline.glsl"):Send("step",{1/64,1/64}),
        Size = V{10,9},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/assets/images/player/ragdoll/head.png"),
        ZIndex = 5,
    
        Draw = function (self, tx, ty)
            self.Canvas:Activate()
            love.graphics.clear()
            -- love.graphics.circle("fill", 32, 32, 5)
            -- Prop.Draw(self, 32, 32)

        
            love.graphics.setColor(self.Color)
            

            for _, bodyPartName in ipairs{"RagdollBackLeg", "RagdollBackArm", "RagdollTorso", "RagdollFrontLeg", "RagdollFrontArm"} do
                local b = self:GetChild(bodyPartName)
                b.Texture:DrawToScreen(
                    b.Position[1] - self.Position[1] + 32,
                    b.Position[2] - self.Position[2] + 32,
                    b.Rotation,
                    b.Size[1],
                    b.Size[2],
                    b.AnchorPoint[1], b.AnchorPoint[2]
                )
            end




            -- HEAD
            self.Texture:DrawToScreen(
                32, 32,
                self.Rotation,
                self.Size[1],
                self.Size[2],
                self.AnchorPoint[1], self.AnchorPoint[2]
            )


            for _, bodyPartName in ipairs{"RagdollEye1", "RagdollEye2"} do
                local b = self:GetChild(bodyPartName)
                b.Texture:DrawToScreen(
                    b.Position[1] - self.Position[1] + 32,
                    b.Position[2] - self.Position[2] + 32,
                    b.Rotation,
                    b.Size[1],
                    b.Size[2],
                    b.AnchorPoint[1], b.AnchorPoint[2]
                )
            end


            self.Canvas:Deactivate()

            -- self.HelperCanvas:Activate()


            
            -- self.HelperCanvas:Deactivate()
            self.Shader:Activate()
            self.HelperCanvas:CopyFrom(self.Canvas)
            self.Shader:Deactivate()

            love.graphics.setColor(1,1,1)
            local sx = 64 * (self.DrawScale[1]-1)
            local sy = 64 * (self.DrawScale[2]-1)
            
            self.HelperCanvas:DrawToScreen(
                math.floor(self.Position[1] - tx),
                math.floor(self.Position[2] - ty),
                0, -- self.Rotation,
                64 + sx,
                64 + sy,
                0.5,
                0.5
            )
            
        end,

        Update = function (self, dt)
            if not self.MouseDropped then
                local newMousePos = self:GetLayer():GetMousePosition()
    
                self:MoveTo(newMousePos)
                
                
                self.Velocity = newMousePos - (self.MousePos or newMousePos)
    
    
                self.MousePos = newMousePos
    
                if Input:JustPressed("m_1") then
                    self.MouseDropped = true
                end
            else
                self.Position = self.Position + self.Velocity
                self.Velocity = self.Velocity + V{0,0.1}
                self.Velocity = self.Velocity:Filter(function (v)
                    return math.clamp(v, -5, 5)
                end)
                
                
            end
    
            local goalRot = self.Velocity:Magnitude()>0.5 and V{self.Velocity.X, -self.Velocity.Y}:ToAngle() or 0
    
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*10)
        end
    }

    
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollEye1",
        Visible = false,
        Size = V{4,4},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/assets/images/player/ragdoll/dead_eye.png"),
        ZIndex = 6,
    
        Update = function (self, dt)
            self:MoveTo(self:GetParent():GetPoint(0.4,0.5))
            
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollEye2",
        Visible = false,
        Size = V{4,4},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/assets/images/player/ragdoll/dead_eye.png"),
        ZIndex = 6,
    
        Update = function (self, dt)
            self:MoveTo(self:GetParent():GetPoint(0.8,0.5))
            
        end,
    })
    
    ragdoll.Torso = ragdoll:Adopt(Prop.new{
        Name = "RagdollTorso",
        Size = V{8,10},
        AnchorPoint = V{0.5,0},
        Visible = false,
        Texture = Texture.new("game/assets/images/player/ragdoll/torso.png"),
        ZIndex = 3,
    
        Update = function (self, dt)
            local p = self.Position:Clone()
            self:MoveTo(self:GetParent():GetPoint(0.5,0.9))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle() or self:GetParent().Rotation
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*4, 0.05)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollFrontArm",
        Size = V{5,8},
        AnchorPoint = V{0.5,0.2},
        Texture = Texture.new("game/assets/images/player/ragdoll/front_arm.png"),
        ZIndex = 4,
        Visible = false,
    
        Update = function (self, dt)
            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(0.2,0.25))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle()+torso.Rotation*1.5 or self:GetParent().Rotation
            
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*6, 0.05)
            -- self.Rotation = math.lerp(self.Rotation, torso.Rotation, dt*2, 0.05)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollBackArm",
        Size = V{5,8},
        Visible = false,
        AnchorPoint = V{0.5,0.2},
        Texture = Texture.new("game/assets/images/player/ragdoll/back_arm.png"),
        ZIndex = 2,
    
        Update = function (self, dt)
            -- local p = self.Position:Clone()
            -- local torso = self:GetParent().Torso
            -- self:MoveTo(torso:GetPoint(0.9,0.2))
            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(0.9,0.25))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle()+torso.Rotation or self:GetParent().Rotation
            
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*6, 0.05)
            -- self.Rotation = math.lerp(self.Rotation, torso.Rotation, dt*2, 0.05)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollFrontLeg",
        Size = V{6,8},
        Visible = false,
        AnchorPoint = V{0.5,0.2},
        Texture = Texture.new("game/assets/images/player/ragdoll/front_leg.png"),
        ZIndex = 4,
    
        Update = function (self, dt)
            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(0.2,0.85))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle()+torso.Rotation*1.5 or self:GetParent().Rotation
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*3, 0.05)
            -- self:MoveTo(torso:GetPoint(0.2,0.85))
            -- self.Rotation = math.lerp(self.Rotation, torso.Rotation, dt*3, 0.05)
        end,
    })
    
    ragdoll:Adopt(Prop.new{
        Name = "RagdollBackLeg",
        Size = V{6,8},
        Visible = false,
        AnchorPoint = V{0.5,0.2},
        Texture = Texture.new("game/assets/images/player/ragdoll/back_leg.png"),
        ZIndex = 2,
    
        Update = function (self, dt)
            local p = self.Position:Clone()
            local torso = self:GetParent().Torso
            self:MoveTo(torso:GetPoint(0.8,0.85))
            local dist = self.Position - p
            local goalRot = dist:Magnitude()>0.1 and V{dist[1], -dist[2]}:ToAngle()+torso.Rotation or self:GetParent().Rotation
            self.Rotation = math.lerp(self.Rotation, goalRot, dt*3, 0.05)
        end,
    })

    return setmetatable(ragdoll, PlayerRagdoll)
end

return PlayerRagdoll