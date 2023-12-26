local Layer = {
    -- properties

    Name = "Layer",
    Canvases = nil,         -- table of renderable canvases, created in constructor
    TranslationInfluence = 1,
    ZoomInfluence = 1,

    -- internal properties
    _super = "Object",      -- Supertype
    _global = true
}

function Layer.new(properties, width, height)
    local newLayer = Layer:SuperInstance()
    if type(properties) == "table" then
        for prop, val in pairs(properties) do
            newLayer[prop] = val
        end
    elseif type(properties) == "string" then
        newLayer.Name = properties
        newLayer.Canvases = { Canvas.new(width, height) }
    end

    newLayer.Canvases = newLayer.Canvases or {}

    return Layer:Connect(newLayer)
end

-- default update pipeline for a Layer
function Layer:Update(dt)
    -- loop through each child
    for child in self:EachDescendent("Active", true) do
        child:Update(dt)
    end
end

-- the default rendering pipeline for a Layer
local lg = love.graphics
function Layer:Draw(tx, ty)
    -- tx, ty: translation values from camera (layers are responsible for handling this)

    -- default implementation is to draw all children to Canvases[1]
    self.Canvases[1]:Activate()
    lg.clear()
    
    tx = tx * self.TranslationInfluence - self.Canvases[1]:GetWidth()/2
    ty = ty * self.TranslationInfluence - self.Canvases[1]:GetHeight()/2

    -- loop through each Visible child
    for child in self:EachChild() do
        if child.Visible then
            child:Draw(tx, ty)
        else
            child:DrawChildren(tx, ty)
        end
    end
    self.Canvases[1]:Deactivate()
end

return Layer