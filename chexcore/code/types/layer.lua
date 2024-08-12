local Layer = {
    -- properties

    Name = "Layer",
    Canvases = nil,         -- table of renderable canvases, created in constructor
    TranslationInfluence = 1,
    ZoomInfluence = 1,
    AutoClearCanvas = true,

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

    if self.AutoClearCanvas then
        lg.clear()
    end
    
    -- love.graphics.setColor(1,1,1,1)
    -- love.graphics.rectangle("fill", 0, 0, 1920,1080)
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

local In = Input
function Layer:GetMousePosition(canvasID)
    local normalizedPos, inWindow = In:GetMousePosition()
    local cameraPosition = self._parent.Camera.Position
    local cameraZoom = self._parent.Camera.Zoom
    local translationInfluence = self.TranslationInfluence
    local zoomInfluence = self.ZoomInfluence
    local masterCanvasSize = self._parent.MasterCanvas:GetSize()
    local activeCanvasSize = self.Canvases[canvasID or 1]:GetSize()
    local realScreenSize = getWindowSize()

    local screenToMasterRatio = 1/(masterCanvasSize:Ratio()/realScreenSize:Ratio())

    -- change mouse position normalization from (0,1) to (-0.5, 0.5)
    normalizedPos = (normalizedPos - 0.5)

    if screenToMasterRatio > 1 then -- increase y range for horizontal black bars
        normalizedPos[2] = normalizedPos[2] * screenToMasterRatio
    elseif screenToMasterRatio < 1 then -- increase x range for vertical black bars
        normalizedPos[1] = normalizedPos[1] / screenToMasterRatio
    end

    -- now we can actually use the normalizedPos of the mouse to find a spot onscreen
    local cameraSize = activeCanvasSize / ((cameraZoom-1) * zoomInfluence + 1)
    local finalPos = (cameraPosition * translationInfluence) + (normalizedPos * cameraSize)

    return finalPos, inWindow
end

return Layer