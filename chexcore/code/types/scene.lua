local Scene = {
    -- properties
    
    -- CHILDREN represent the Scene's Layers. Layers are added/removed
    -- via Adopt() and Disown() methods.

    Name = "Scene",
    Active = false, -- A Scene only updates when it's active
    

    -- internal properties
    _super = "Object",      -- Supertype
    _global = true
}

function Scene.new(properties)
    local newScene = Scene:SuperInstance()

    newScene.Layers = {}

    return Scene:Connect(newScene)
end


return Scene