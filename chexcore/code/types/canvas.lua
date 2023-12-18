local Canvas = {
    -- properties

    Name = "Canvas",
    realCanvas = nil,       -- Love2D "real canvas" created in constructor

    -- internal properties
    _size = V{320, 180},    -- Vector2 positional storage (created in constructor)
    _super = "Object",      -- Supertype
    _global = true
}

-- constructor
local newRealCanvas = love.graphics.newCanvas
function Canvas.new(width, height)
    local newCanvas = Canvas:SuperInstance()

    newCanvas._size = V{width or Canvas._size[1], height or Canvas._size[2]}
    newCanvas.realCanvas = newRealCanvas(newCanvas._size.X, newCanvas._size.Y)

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
    self._width, self._height = width or self._width, height or self._height
    self.realCanvas = newRealCanvas(self._width, self._height)
end

return Canvas