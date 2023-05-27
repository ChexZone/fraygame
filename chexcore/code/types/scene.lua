local Scene = {
    -- properties
    Name = "Scene",
    Active = false, -- A Scene only updates when it's active
    Layers = nil,   -- list of all Layers, set in constructor

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