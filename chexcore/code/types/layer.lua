local Layer = {
    -- properties

    Name = "Layer",
    Canvases = nil,         -- table of renderable canvases, created in constructor

    -- internal properties
    _super = "Object",      -- Supertype
    _global = true
}

function Layer.new(properties)
    local newLayer = Layer:SuperInstance()
    if properties then
        for prop, val in pairs(properties) do
            newLayer[prop] = val
        end
    end

    newLayer.Canvases = newLayer.Canvases or {}

    return Layer:Connect(newLayer)
end

-- default update pipeline for a Layer
function Layer:Update(dt)
    
end

-- the default rendering pipeline for a Layer
function Layer:Draw()
    --print(self.Name)
end

return Layer