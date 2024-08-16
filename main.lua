require "chexcore"

love.mouse.setVisible(false)
-- some of the constructors are still somewhat manual but they'll get cleaned up !

-- Scenes contain all the components of the game
function love.load()


    -- Load the Chexcore example Scene!
    local scene = require"chexcore.scenes.example.init" -- path to the .lua file of the scene

    -- A scene will only be processed by Chexcore while it is "mounted"
    Chexcore.MountScene(scene)

    local v =  V{1} 
    v:Properties{X = 5}
    -- print(CONST(scene):AddProperties("a"))
    -- You can unmount (or deactivate) a scene by using Chexcore.UnmountScene(scene)
end
