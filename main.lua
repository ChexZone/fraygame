require "chexcore"

-- love.mouse.setVisible(false)
-- some of the constructors are still somewhat manual but they'll get cleaned up !

-- Scenes contain all the components of the game
function love.load()


    -- Load the Chexcore example Scene!
    
    Chexcore:AddType(require"game.player.player")
    Chexcore:AddType(require"game.player.gameScene")
    local scene = require"game.scenes.testzone.init"
    local player = Player.new():Nest(scene:GetLayer("Gameplay"))
    



    -- local scene = require"chexcore.scenes.example.doodle" -- path to the .lua file of the scene

    -- A scene will only be processed by Chexcore while it is "mounted"
    -- Chexcore.MountScene(scene)


    local particleData = {
        
        positions = {},
        sizes = {},
        rotations = {},

    }

    local test = {}


    test[3] = 3
    test[2] = 2
    print(#test) --> 3
    -- test[1] = nil
    -- print(#test) --> 3
    -- test[3] = nil
    -- print(#test) --> 2


    
    -- print(player:Serialize())
    -- You can unmount (or deactivate) a scene by using Chexcore.UnmountScene(scene)
end
