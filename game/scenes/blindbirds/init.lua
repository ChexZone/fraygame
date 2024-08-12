local sceneInput = Input.new{}

local currentCharacter = 1
local characters = {}

local zoomLevel = 1
local bgOpacity = 1

local scene = Scene.new{
    Update = function (self, dt)
        Scene.Update(self, dt)
        self.Camera.Position =V{0,0}
        self.Camera.Zoom = zoomLevel --+ (math.sin(Chexcore._clock)+1)/2
        self:GetLayer(1):GetChild("Background").Color[4] = bgOpacity

        for n = 1, 9 do
            if sceneInput._justPressed["kp" .. tostring(n)] then
                characters[currentCharacter].Texture = characters[currentCharacter].Animations[n]
                characters[currentCharacter].Texture.Clock = 0
                characters[currentCharacter].Texture.IsPlaying = true
            end
        end

        if sceneInput._justPressed["left"] then
            currentCharacter = currentCharacter - 1
        end

        if sceneInput._justPressed["right"] then
            currentCharacter = currentCharacter + 1
        end

        bgOpacity = bgOpacity * 0.9 + (1 * 0.1)

        zoomLevel = zoomLevel * 0.9 + 1 * 0.1
        if sceneInput._justPressed["space"] then
            zoomLevel = zoomLevel + 0.05
            bgOpacity = 0.9
        end

        if sceneInput._justPressed["lshift"] then
            -- zoomLevel = zoomLevel + 0.05
            bgOpacity = 0.9
        end

    end
}




-- Scenes have a list of Layers, which each hold their own Props


local gui = scene:AddLayer(Layer.new("GUI", 1920, 1080))

local bg = gui:Adopt(Prop.new{
    Name = "Background",
    Solid = true, Visible = true,
    Position = V{ 0, 0 },   -- V stands for Vector
    Size = V{ 1920, 1080 },
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("game/scenes/blindbirds/bg.png"),
    Update = function (self, dt)
    end
})

local recordWheel = gui:Adopt(Prop.new{
    Name = "Record",
    Solid = true, Visible = true,
    Position = V{ 0, -700 },   -- V stands for Vector
    Size = V{ 1850, 1850 },
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = 0,
    Texture = Texture.new("game/scenes/blindbirds/record.png"),
    Update = function (self, dt)
        self.Rotation = Chexcore._clock*1.5
    end
})

local characterWheel = gui:Adopt(recordWheel:Clone():AddProperties{Update = function (self, dt)
    -- character wheel functionality
    self.Rotation = self.Rotation * 0.975 + (math.rad(60) * (currentCharacter-1)) * 0.025

    

end, Color = V{0,0,1,0}})


----------------------------------------------------------------------------------------------
local function makeChar1()
    local chexFrame = characterWheel:Adopt(Prop.new{
        Name = "ChexIcon",
        Solid = true, Visible = true,
        Position = V{0,-250},
        -- Color = V{0,0,0,0},
        Size = V{600, 600},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/scenes/blindbirds/chexOutline.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(0.5,.95)
        end
    })
    --                             vvvv ("same parent")
    local chexBG = chexFrame:Clone(true):AddProperties{
        Name = "BG",
        Texture = Texture.new("game/scenes/blindbirds/chexBG.png")
    }

    local chexFade = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("chexcore/assets/images/square.png"),
        Color = V{0,0,0,0.5},
        Update = function (self)
            self.Position = self:GetParent():GetChild("ChexIcon").Position
            self.Color[4] = self.Color[4] * 0.97 + (currentCharacter == 1 and 0 or 0.7) * 0.03
        end
    }

    local chexGuy = chexBG:Adopt(Prop.new{
        Name = "Chex",
        Solid = true, Visible = true,
        Position = V{0,0},
        AnchorPoint = V{0.5,0.5},
        Size = V{512, 512},
        Animations = {
            Animation.new("game/scenes/blindbirds/chex_sleep.png", 1, 9):AddProperties{Duration = 2.3},
            Animation.new("game/scenes/blindbirds/chex_wakeup.png", 1, 9):AddProperties{Duration = 1, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_waiting.png", 1, 33):AddProperties{Duration = 5.5, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.8},
            Animation.new("game/scenes/blindbirds/chex_fallingasleep.png", 1, 19):AddProperties{Duration = 8},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.8/2},

        },
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0.5) - V{5,0}
        end
    }) chexGuy.Texture = chexGuy.Animations[1]; table.insert(characters, chexGuy)


    chexFrame:Adopt(Prop.new{
        Name = "Needle",
        Visible = true, Solid = true,
        AnchorPoint = V{0.5,1},
        Size = V{128, 128},
        Texture = Texture.new("game/scenes/blindbirds/recordNeedlepng.png"),
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0)
        end
    })
end
makeChar1()
----------------------------------------------------------------------------------------------
local function makeChar2()
    local chexFrame = characterWheel:Adopt(Prop.new{
        Name = "ChexIcon2",
        Solid = true, Visible = true,
        Position = V{0,-250},
        -- Color = V{0,0,0,0},
        Size = V{600, 600},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/scenes/blindbirds/cassyOutline.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(0.89,.725)
        end
    })
    --                             vvvv ("same parent")
    local chexBG = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("game/scenes/blindbirds/cassyRealOutline.png")
    }

    local chexFade = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("chexcore/assets/images/square.png"),
        Color = V{0,0,0,0.5},
        Update = function (self)
            self.Position = self:GetParent():GetChild("ChexIcon2").Position
            self.Color[4] = self.Color[4] * 0.97 + (currentCharacter == 2 and 0 or 0.7) * 0.03
        end
    }

    local chexGuy = chexBG:Adopt(Prop.new{
        Name = "Chex",
        Solid = true, Visible = true,
        Position = V{0,0},
        AnchorPoint = V{0.5,0.5},
        Size = V{512, 512},
        Animations = {
            Animation.new("game/scenes/blindbirds/cassy_headbob.png", 1, 12):AddProperties{Duration = 0.92307692307},
            Animation.new("game/scenes/blindbirds/cassy_headbob1.png", 1, 6):AddProperties{Duration = 0.92307692307/2, Loop = false},
            Animation.new("game/scenes/blindbirds/cassy_headbob2.png", 1, 6):AddProperties{Duration = 0.92307692307/2, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57},
            Animation.new("game/scenes/blindbirds/cassy_headbob3.png", 1, 6):AddProperties{Duration = 0.92307692307/2, Loop = false},
            Animation.new("game/scenes/blindbirds/cassy_headbob4.png", 1, 6):AddProperties{Duration = 0.92307692307/2, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_fallingasleep.png", 1, 19):AddProperties{Duration = 8},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57/2},

        },
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0.5)
        end
    }) chexGuy.Texture = chexGuy.Animations[1]; table.insert(characters, chexGuy)


    chexFrame:Adopt(Prop.new{
        Name = "Needle",
        Visible = true, Solid = true,
        AnchorPoint = V{0.5,1},
        Size = V{128, 128},
        Texture = Texture.new("game/scenes/blindbirds/recordNeedle3.png"),
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0)
        end
    })
end
makeChar2()
----------------------------------------------------------------------------------------------
local function makeChar3()
    local chexFrame = characterWheel:Adopt(Prop.new{
        Name = "ChexIcon3",
        Solid = true, Visible = true,
        Position = V{0,-250},
        -- Color = V{0,0,0,0},
        Size = V{600, 600},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/scenes/blindbirds/chexOutline.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(0.89,1-.725)
        end
    })
    --                             vvvv ("same parent")
    local chexBG = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("game/scenes/blindbirds/chexBG.png")
    }

    local chexFade = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("chexcore/assets/images/square.png"),
        Color = V{0,0,0,0.5},
        Update = function (self)
            self.Position = self:GetParent():GetChild("ChexIcon3").Position
            self.Color[4] = self.Color[4] * 0.97 + (currentCharacter == 3 and 0 or 0.7) * 0.03
        end
    }

    local chexGuy = chexBG:Adopt(Prop.new{
        Name = "Chex",
        Solid = true, Visible = true,
        Position = V{0,0},
        AnchorPoint = V{0.5,0.5},
        Size = V{512, 512},
        Animations = {
            Animation.new("game/scenes/blindbirds/chex_sleep.png", 1, 9):AddProperties{Duration = 2.3},
            Animation.new("game/scenes/blindbirds/chex_wakeup.png", 1, 9):AddProperties{Duration = 1, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_waiting.png", 1, 33):AddProperties{Duration = 5.5, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57},
            Animation.new("game/scenes/blindbirds/chex_fallingasleep.png", 1, 19):AddProperties{Duration = 8},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57/2},

        },
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0.5)
        end
    }) chexGuy.Texture = chexGuy.Animations[1]; table.insert(characters, chexGuy)


    chexFrame:Adopt(Prop.new{
        Name = "Needle",
        Visible = true, Solid = true,
        AnchorPoint = V{0.5,1},
        Size = V{128, 128},
        Texture = Texture.new("game/scenes/blindbirds/recordNeedlepng.png"),
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0)
        end
    })
end
makeChar3()
----------------------------------------------------------------------------------------------
local function makeChar4()
    local chexFrame = characterWheel:Adopt(Prop.new{
        Name = "ChexIcon4",
        Solid = true, Visible = true,
        Position = V{0,-250},
        -- Color = V{0,0,0,0},
        Size = V{600, 600},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/scenes/blindbirds/chexOutline.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(0.5,0.05)
        end
    })
    --                             vvvv ("same parent")
    local chexBG = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("game/scenes/blindbirds/chexBG.png")
    }

    local chexFade = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("chexcore/assets/images/square.png"),
        Color = V{0,0,0,0.5},
        Update = function (self)
            self.Position = self:GetParent():GetChild("ChexIcon4").Position
            self.Color[4] = self.Color[4] * 0.97 + (currentCharacter == 4 and 0 or 0.7) * 0.03
        end
    }

    local chexGuy = chexBG:Adopt(Prop.new{
        Name = "Chex",
        Solid = true, Visible = true,
        Position = V{0,0},
        AnchorPoint = V{0.5,0.5},
        Size = V{512, 512},
        Animations = {
            Animation.new("game/scenes/blindbirds/chex_sleep.png", 1, 9):AddProperties{Duration = 2.3},
            Animation.new("game/scenes/blindbirds/chex_wakeup.png", 1, 9):AddProperties{Duration = 1, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_waiting.png", 1, 33):AddProperties{Duration = 5.5, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57},
            Animation.new("game/scenes/blindbirds/chex_fallingasleep.png", 1, 19):AddProperties{Duration = 8},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57/2},

        },
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0.5)
        end
    }) chexGuy.Texture = chexGuy.Animations[1]; table.insert(characters, chexGuy)


    chexFrame:Adopt(Prop.new{
        Name = "Needle",
        Visible = true, Solid = true,
        AnchorPoint = V{0.5,1},
        Size = V{128, 128},
        Texture = Texture.new("game/scenes/blindbirds/recordNeedlepng.png"),
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0)
        end
    })
end
makeChar4()
----------------------------------------------------------------------------------------------
local function makeChar5()
    local chexFrame = characterWheel:Adopt(Prop.new{
        Name = "ChexIcon5",
        Solid = true, Visible = true,
        Position = V{0,-250},
        -- Color = V{0,0,0,0},
        Size = V{600, 600},
        AnchorPoint = V{0.5,0.5},
        Texture = Texture.new("game/scenes/blindbirds/buckbrokeOutline.png"),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(1-0.89,1-.725)
        end
    })
    --                             vvvv ("same parent")
    local chexBG = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("game/scenes/blindbirds/buckbrokeBG.png")
    }

    local chexFade = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("chexcore/assets/images/square.png"),
        Color = V{0,0,0,0.5},
        Update = function (self)
            self.Position = self:GetParent():GetChild("ChexIcon5").Position
            self.Color[4] = self.Color[4] * 0.97 + (currentCharacter == 5 and 0 or 0.7) * 0.03
        end
    }

    local chexGuy = chexBG:Adopt(Prop.new{
        Name = "Chex",
        Solid = true, Visible = true,
        Position = V{0,0},
        AnchorPoint = V{0.5,0.5},
        Size = V{512, 512},
        Animations = {
            Animation.new("game/scenes/blindbirds/chex_sleep.png", 1, 9):AddProperties{Duration = 2.3},
            Animation.new("game/scenes/blindbirds/chex_wakeup.png", 1, 9):AddProperties{Duration = 1, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_waiting.png", 1, 33):AddProperties{Duration = 5.5, Loop = false},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57},
            Animation.new("game/scenes/blindbirds/chex_fallingasleep.png", 1, 19):AddProperties{Duration = 8},
            Animation.new("game/scenes/blindbirds/chex_headbob1.png", 1, 40):AddProperties{Duration = 4.57/2},

        },
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0.5)
        end
    }) chexGuy.Texture = chexGuy.Animations[1]; table.insert(characters, chexGuy)


    chexFrame:Adopt(Prop.new{
        Name = "Needle",
        Visible = true, Solid = true,
        AnchorPoint = V{0.5,1},
        Size = V{128, 128},
        Texture = Texture.new("game/scenes/blindbirds/recordNeedle2.png"),
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0)
        end
    })
end
makeChar5()
----------------------------------------------------------------------------------------------
local function makeChar6()
    local chexFrame = characterWheel:Adopt(Prop.new{
        Name = "ChexIcon6",
        Solid = true, Visible = true,
        Position = V{0,-250},
        -- Color = V{0,0,0,0},
        Size = V{548, 548},
        AnchorPoint = V{0.5,0.5},
        Texture = Animation.new("game/scenes/blindbirds/andrewOutline.png", 1, 4),
        Update = function (self, dt)
            self.Position = self:GetParent():GetPoint(1-0.89,.725)
            -- self.Color[4] = self.Color[4] * 0.97 + (currentCharacter == 6 and 0 or 0.7) * 0.03
            local col = self.Color[1] * 0.97 + (currentCharacter == 6 and 1 or 0.7) * 0.03
            self.Color = V{col, col, col, 1}
        end
    })


    --                             vvvv ("same parent")
    local chexBG = chexFrame:Clone(true):AddProperties{
        Size = V{600, 600},
        Texture = Animation.new("game/scenes/blindbirds/andrewBG.png", 1, 4)
        
    }

    local chexFade = chexFrame:Clone(true):AddProperties{
        Texture = Texture.new("chexcore/assets/images/square.png"),
        Color = V{0,0,0,0.5},
        Size = V{555,555},
        Update = function (self)
            self.Position = self:GetParent():GetChild("ChexIcon6").Position
            self.Color[4] = self.Color[4] * 0.97 + (currentCharacter == 6 and 0 or 0.7) * 0.03
        end
    }

    local chexGuy = chexFrame:Adopt(Prop.new{
        Name = "Chex",
        Solid = true, Visible = true,
        Position = V{0,0},
        AnchorPoint = V{0.5,0.5},
        -- Color = V{0,0,0,0},
        Size = V{512, 512},
        Animations = {
            Animation.new("game/scenes/blindbirds/andrew_headbob.png", 1, 4):AddProperties{Duration = 0.38709677419},
            Animation.new("game/scenes/blindbirds/andrew_headbob2.png", 1, 4):AddProperties{Duration = 0.38709677419},
            Animation.new("game/scenes/blindbirds/andrew_transform1.png", 1, 8):AddProperties{Duration = .8, Loop = false},
            Animation.new("game/scenes/blindbirds/andrew_headbob3.png", 1, 4):AddProperties{Duration = 0.38709677419},
            Animation.new("game/scenes/blindbirds/andrew_transform2.png", 1, 12):AddProperties{Duration = 1, Loop = false},
            Animation.new("game/scenes/blindbirds/andrew_headbob5.png", 1, 4):AddProperties{Duration = 0.38709677419},
            Animation.new("game/scenes/blindbirds/andrew_transform3.png", 1, 9):AddProperties{Duration = 1, Loop = false},
            Animation.new("game/scenes/blindbirds/andrew_headbob4.png", 1, 64):AddProperties{Duration = 0.38709677419*16},

        },
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0.5)
        end
    }) chexGuy.Texture = chexGuy.Animations[5]; table.insert(characters, chexGuy)


    chexFrame:Adopt(Prop.new{
        Name = "Needle",
        Visible = true, Solid = true,
        AnchorPoint = V{0.5,1},
        Size = V{128, 128},
        Texture = Texture.new("game/scenes/blindbirds/recordNeedlepng.png"),
        Update = function (self)
            self.Position = self:GetParent():GetPoint(0.5,0)
        end
    })
end
makeChar6()
----------------------------------------------------------------------------------------------
return scene