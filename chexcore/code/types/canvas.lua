local Canvas = {
    -- properties

    Name = "Canvas",
    

    -- internal properties
    _realCanvas = nil,       -- Love2D "real canvas" created in constructor
    _size = V{320, 180},    -- Vector2 positional storage (created in constructor)
    _super = "Object",      -- Supertype
    _global = true
}

-- constructor
local newRealCanvas = love.graphics.newCanvas
function Canvas.new(width, height)
    local newCanvas = Canvas:SuperInstance()

    newCanvas._size = V{width or Canvas._size[1], height or Canvas._size[2]}
    newCanvas._realCanvas = newRealCanvas(newCanvas._size.X, newCanvas._size.Y)

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
    self._realCanvas = newRealCanvas(self._size[1], self._size[2])
end

return Canvas