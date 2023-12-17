local Canvas = {
    -- properties

    Name = "Canvas",
    realCanvas = nil,       -- Love2D "real canvas" created in constructor

    -- internal properties
    _width = 128, _height = 128,
    _super = "Object",      -- Supertype
    _global = true
}

-- constructor
local newRealCanvas = love.graphics.newCanvas
function Canvas.new(width, height)
    local newCanvas = Canvas:SuperInstance()

    newCanvas._width, newCanvas._height = width or Canvas._width, height or Canvas._height

    newCanvas.realCanvas = newRealCanvas(newCanvas._width, newCanvas._height)

    return Canvas:Connect(newCanvas)
end

-- size getters...
function Canvas:GetWidth()
    return self._width
end

function Canvas:GetHeight()
    return self._height
end

function Canvas:GetSize()
    return self._width, self._height
end

-- size setter
function Canvas:SetSize(width, height)
    self._width, self._height = width or self._width, height or self._height
    self.realCanvas = newRealCanvas(self._width, self._height)
end

return Canvas