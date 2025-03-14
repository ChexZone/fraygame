local function transitionCurve(x)
    return math.clamp(4*((1.6*x-1)^2+(1.35*x-1)^3)+(x/2), 0, 2)
end

local Door = {
    
    Name = "Door",
    Texture = Texture.new("game/assets/images/cave-door.png"),
    TransitionTime = 0,
    Position = V{348,2560},
    Goal = nil, -- can be another door, or a Position
    Solid = true,
    Passthrough = true,

    SFX = {
        MarimbaStart = {
            Sound.new("game/assets/sounds/object/door/door-transition-01.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/object/door/door-transition-02.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/object/door/door-transition-03.wav", "static"):Set("Volume", 0.3),
            Sound.new("game/assets/sounds/object/door/door-transition-04.wav", "static"):Set("Volume", 0.3),
        },
        MarimbaEnd = {
            Sound.new("game/assets/sounds/object/door/door-transition-end-01.wav", "static"):Set("Volume", 0.2),
            Sound.new("game/assets/sounds/object/door/door-transition-end-02.wav", "static"):Set("Volume", 0.2),
            Sound.new("game/assets/sounds/object/door/door-transition-end-03.wav", "static"):Set("Volume", 0.2),
            Sound.new("game/assets/sounds/object/door/door-transition-end-04.wav", "static"):Set("Volume", 0.2),
        },

        TransitionWhoosh = {
            Sound.new("game/assets/sounds/object/door/whoosh.wav", "static"):Set("Volume", 0.3),
        }
    },

    InteractEnter = function (self, player)
        print("interact start",player)
    end,

    InteractLeave = function (self, player)
        print("interact leave", player)
    end,

    InteractActivate = function (self, player)
        player.TransitionUses = (player.TransitionUses or -1) + 1
        self.SFX.MarimbaStart[1+player.TransitionUses%#self.SFX.MarimbaStart]:Play()
        self.SFX.TransitionWhoosh[1+player.TransitionUses%#self.SFX.TransitionWhoosh]:Play()
        local oldZ = player.ZIndex
        local oldForeground = player.DrawInForeground
        -- player.DisablePlayerControl = true
        player.InTransition = true
        player.DrawInForeground = true
        player.ZIndex = 10000
        player:DisconnectNearbyInteractable()
        player.InInteraction = true
        self.InTransition = true
        self.TransitionSizeCurve = transitionCurve
        self.TransitionTime = 0
        self.TransitionEffect.GoalRadius = 1400

        Timer.Schedule(1, function ()
            -- player.DisablePlayerControl = false
            local goalPos
            if self.Goal:IsA("Vector") then
                goalPos = self.Goal
            else
                -- goalPos is another Door
                goalPos = self.Goal.Position
                self.Goal.TransitionEffect.Size = V{self.TransitionEffect.GoalRadius, self.TransitionEffect.GoalRadius}
                self.Goal.TransitionEffect.GoalRadius = 0
                self.Goal.InTransition = true
                self.Goal.TransitionEffect.Visible = true
                -- self.InTransition = false
                -- self.TransitionEffect.Size = V{0,0}

            end
            
            local diff = player.Position - goalPos
            -- player.Position = self.GoalPos:Clone()
            Timer.ScheduleFrames(1, function ()
                player:Teleport(goalPos)
                self.SFX.MarimbaEnd[1+player.TransitionUses%#self.SFX.MarimbaEnd]:Play()
                self.TransitionEffect.Size = V{0,0}
                self.TransitionEffect.GoalRadius = 0
                local cam = player:GetLayer():GetParent().Camera
                cam.TrackingPosition = cam.TrackingPosition - diff
                cam.Position = cam.Position - diff
            end)
        end)

        Timer.Schedule(2, function ()
            self.TransitionSizeCurve = nil
            player.DrawInForeground = oldForeground
            player.ZIndex = oldZ
            -- player.DisablePlayerControl = false
            self.InTransition = false
            
            if self.Goal.InTransition then
                self.Goal.InTransition = false
                self.Goal.TransitionEffect.Size = V{0,0}
            end
            self.TransitionEffect.Size = V{0,0}
            
            player.InInteraction = false
        end)
    end,

    Update = function (self, dt)
        if self.InTransition then
            
            self.TransitionEffect.Position = self.Position - V{0, 10}
            self.TransitionEffect.Visible = true

            if self.TransitionSizeCurve then
                self.TransitionEffect.Size.X = self.TransitionEffect.GoalRadius * self.TransitionSizeCurve(self.TransitionTime*1.2)/4
                self.TransitionEffect.Size.Y = self.TransitionEffect.GoalRadius * self.TransitionSizeCurve(self.TransitionTime*1.2)/4
            elseif self.TransitionEffect.GoalRadius == 0 then
                self.TransitionEffect.Size.X = math.lerp(self.TransitionEffect.Size.X, self.TransitionEffect.GoalRadius, 0.1*60*dt, 5)
                self.TransitionEffect.Size.Y = math.lerp(self.TransitionEffect.Size.Y, self.TransitionEffect.GoalRadius, 0.1*60*dt, 5)
            else
                self.TransitionEffect.Size.X = math.lerp(self.TransitionEffect.Size.X, self.TransitionEffect.GoalRadius, 0.01*60*dt, 10)
                self.TransitionEffect.Size.Y = math.lerp(self.TransitionEffect.Size.Y, self.TransitionEffect.GoalRadius, 0.01*60*dt, 10)    
            end
            self.TransitionTime = self.TransitionTime + dt
        else
            self.TransitionEffect.Visible = false
            self.TransitionTime = 0
        end
    end,

    _super = "Prop", _global = true
}


local TRANSITION_POSITIONS = {
    -- V{xOfs, yOfs, segments, scale, timeScale}
    left_upper = {
        V{-200, -50, 3, 3, 4},
        V{-250, -20, 5, 2, 3},
        V{-150, -80, 4, 1, 2},
    },
    left_lower = {
        V{-200, 50, 3, 3, 4},
        V{-250, 20, 5, 2, 3},
        V{-150, 80, 4, 1, 2},    
    },
    right_upper = {
        V{200, -50, 3, 3, 4},
        V{250, -20, 5, 2, 3},
        V{150, -80, 4, 1, 2},
    },
    right_lower = {
        V{200, 50, 3, 3, 4},
        V{250, 20, 5, 2, 3},
        V{150, 80, 4, 1, 2},    
    },
}



function Door.new()
    local newDoor = Door:SuperInstance():Properties{
        AnchorPoint = V{0.5,1},
        Size = V{48, 32},
        InteractIndicatorOffset = V{0,-50},
    }


    newDoor.TransitionEffect = newDoor:Adopt(Prop.new{
        Draw = function (self, tx, ty)

            -- love.graphics.setColor(1,0,0,1)

            -- love.graphics.ellipse2("fill",
            --     math.floor(self.Position[1] - tx),
            --     math.floor(self.Position[2] - ty),
            --     self.Size.X*1.1,
            --     self.Size.Y*1.1, Chexcore._clock*1.75
            --     ,7
            -- )

            love.graphics.setColor(self.Color)
            love.graphics.ellipse2("fill",
                math.floor(self.Position[1] - tx),
                math.floor(self.Position[2] - ty),
                self.Size.X,
                self.Size.Y, (1+(self:GetParent().TransitionTime or 0))^4/2
                ,6
            )


            
            
            -- for _, v in ipairs(self.Positions) do
                
            --     love.graphics.ellipse2("fill",
            --         math.floor(self.Position[1] - tx + v[1]*(2-math.log(self.Size.X))),
            --         math.floor(self.Position[2] - ty + v[2]*(2-math.log(self.Size.Y))),
            --         self.Size.X * 0.1 * v[4],
            --         self.Size.Y * 0.1 * v[4], Chexcore._clock*2*v[5]
            --         ,v[3]
            --     )
            -- end
            -- local sx = self.Size[1] * (self.DrawScale[1]-1)
            -- local sy = self.Size[2] * (self.DrawScale[2]-1)

            -- self.Texture:DrawToScreen(
            --     floor(self.Position[1] - tx),
            --     floor(self.Position[2] - ty),
            --     self.Rotation,
            --     self.Size[1] + sx,
            --     self.Size[2] + sy,
            --     self.AnchorPoint[1],
            --     self.AnchorPoint[2]
            -- )
        end,

        Position = newDoor.Position - V{0,10},
        Size = V{0,0},
        Color = V{34,32,52}/255,
        DrawInForeground = true,
        ZIndex = 9999,
    })
    Door:Connect(newDoor)
    return newDoor
end

return Door