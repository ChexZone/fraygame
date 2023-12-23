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
    -- loop through each child
    for child in self:EachChild() do
        child:Update(dt)
    end
end

-- the default rendering pipeline for a Layer
local lg = love.graphics
function Layer:Draw()


    -- default implementation is to draw all children to Canvases[1]
    self.Canvases[1]:Activate()
    lg.clear()

    -- test bit
    for j = 1, #self.Canvases do
        self.Canvases[j]:Activate()
        lg.setColor(1, 0, 1, 1)
        lg.rectangle("line", 0, 0, self.Canvases[j]:GetWidth(), self.Canvases[j]:GetHeight())
        -- for i = 1, self.Canvases[1]:GetWidth() do
        --     lg.points(i, i, i, self.Canvases[j]:GetHeight() - i, self.Canvases[j]:GetWidth() - i, self.Canvases[j]:GetHeight() - i, self.Canvases[j]:GetWidth() - i, i)
        -- end
    end
    

    -- end the test bit !!

    -- real bit

    -- loop through each Visible child
    for child in self:EachChild("Visible", true) do
        child:Draw()
    end

end

return Layer