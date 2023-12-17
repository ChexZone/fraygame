local Scene = {
    -- properties
    
    -- CHILDREN represent the Scene's Layers. Layers are added/removed
    -- via Adopt() and Disown() methods.

    Name = "Scene",
    Active = true,          -- A Scene only updates when it's active
    Visible = true,         -- A Scene only renders when it's visible
    MasterCanvas = nil,     -- The final canvas rendered to the screen

    -- internal properties
    _super = "Object",      -- Supertype
    _global = true
}

-- !! Using default constructor until otherwise required !! --
-- function Scene.new(properties)
--     local newScene = Scene:SuperInstance()

--     return Scene:Connect(newScene)
-- end
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --

-- default update pipeline for a Scene
function Scene:Update(dt)
    for layer in self:EachChild() do
        layer:Update(dt)
    end
end

-- the default rendering pipeline for a Scene
function Scene:Draw()
    -- go through all the Layers uh... think about it chex !!
    for layer in self:EachChild() do
        layer:Draw()
    end
end

-- the default implementation of layer combination for the Master Canvas
function Scene:CombineLayers()
    
end

-- function aliases
Scene.AddLayer = Object.Adopt
Scene.RemoveLayer = Object.Disown
Scene.SwapLayers = Object.SwapChildOrder
Scene.GetLayer = Object.GetChild


return Scene