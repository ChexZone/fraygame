local Canvas = {
    -- properties
    Name = "Canvas",
    
    BlendMode = "alpha",    -- the LOVE BlendMode to apply to a Canvas when drawing it
    AlphaMode = "alphamultiply",    -- same as above, but AlphaBlendMode

    -- internal properties
    _drawable = nil,       -- Love2D "real canvas" created in constructor
    _size = V{320, 180},    -- Vector2 positional storage (created in constructor)
    _super = "Texture",      -- Supertype
    _global = true
}

local lg = love.graphics

-- constructor
local newRealCanvas = love.graphics.newCanvas
function Canvas.new(width, height)
    local newCanvas = Canvas:SuperInstance()

    newCanvas._size = V{width or Canvas._size[1], height or Canvas._size[2]}
    newCanvas._drawable = newRealCanvas(newCanvas._size.X, newCanvas._size.Y)

    return Canvas:Connect(newCanvas)
end

-- size getters...
function Canvas:GetWidth()
    return self._size.X
end

function Canvas:GetHeight()
    return self._size.Y
end

function Canvas:GetSize()
    return V{self._size[1], self._size[2]}
end

-- size setter
function Canvas:SetSize(width, height)
    self._size[1], self._size[2] = width or self._size[1], height or self._size[2]
    self._drawable = newRealCanvas(self._size[1], self._size[2])
end


local draw, setBlendMode, getBlendMode = cdraw, lg.setBlendMode, lg.getBlendMode
function Canvas:DrawToScreen(...)
    -- prepare the Canvas's render conditions
    local mode, alphaMode = getBlendMode()
    setBlendMode(self.BlendMode == "ignore" and mode or self.BlendMode, self.AlphaMode == "ignore" and alphaMode or self.AlphaMode)

    -- render the Canvas
    draw(self._drawable, ...)
end

local setCanvas = lg.setCanvas
function Canvas:Activate()
    setCanvas(self._drawable)
end

return Canvas