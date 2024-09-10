local GameScene = {
    -- properties
    Name = "GameScene",

    Player = nil,   -- will search for this at runtime
    
    DeathHeight = 300, -- if the player's height is greater than this, respawn it
    InRespawn = false,  -- whether the player is in a respawn sequence or not

    GuiLayer = nil,     -- set in constructor


    -- internal properties
    _super = "Scene",      -- Supertype
    _global = true
}

function GameScene.new(properties)
    local newGameScene = GameScene:SuperInstance()
    if properties then
        for prop, val in pairs(properties) do
            newGameScene[prop] = val
        end
    end


    newGameScene.GuiLayer = newGameScene:Adopt(Layer.new("GUI", 1280, 720, true))

    newGameScene.fallGuiTop = newGameScene.GuiLayer:Adopt(Prop.new{
        Name = "FallGuiTop",
        Texture = Texture.new("chexcore/assets/images/test/fallGui.png"),
        Size = V{1280, 720},
        Position = V{1280/2, 720},
        AnchorPoint = V{0.5, 0},
        Visible = false,
    })

    newGameScene.fallGuiBottom = newGameScene.GuiLayer:Adopt(Prop.new{
        Name = "FallGuiBottom",
        Texture = Texture.new("chexcore/assets/images/test/fallGui.png"),
        Size = V{1280, 720},
        Position = V{1280/2, 720*2},
        AnchorPoint = V{0.5, 1},
        Rotation = math.rad(180),
        Visible = false,
    })


    return GameScene:Connect(newGameScene)
end

local Scene = Scene
function GameScene:Update(dt)
    if not self.Player then
        self.Player = self:GetDescendant(Object.IsA, "Player")
    else
        -- print(self.Player.Position)
        if not self.InRespawn and self.Player.Position.Y > self.DeathHeight and self.Player.LastSafePosition then
            self.InRespawn = true
            self.fallGuiBottom.Visible = true
            self.fallGuiTop.Visible = true

            Timer.Schedule(0.5, function ()
                self.Player:Respawn(self.Player.LastSafePosition)
            end)

            Timer.Schedule(1.2, function ()
                self.InRespawn = false
                self.fallGuiBottom.Visible = false
                self.fallGuiTop.Visible = false
                self.fallGuiTop.Position = V{1280/2, 720}
                self.fallGuiBottom.Position = V{1280/2, 720*2}
                self.fallGuiTop.Rotation = 0
                self.fallGuiBottom.Rotation = math.rad(180)
            end)
            
        end

        if self.InRespawn then
            -- self.fallGuiTop.Rotation = self.fallGuiTop.Rotation + 0.002
            -- self.fallGuiBottom.Rotation = self.fallGuiBottom.Rotation - 0.002
            self.fallGuiTop.Position.Y = self.fallGuiTop.Position.Y - 35
            self.fallGuiBottom.Position.Y = self.fallGuiBottom.Position.Y - 35

            -- self.fallGuiTop.Size.Y = self.fallGuiTop.Size.Y + 5
        end
    end

    -- make sure gui layer is on top
    
    local guiID = self.GuiLayer:GetChildID()
    if guiID ~= #self._children then
        self:SwapChildOrder(guiID, #self._children)
    end

    return Scene.Update(self, dt)
end

return GameScene