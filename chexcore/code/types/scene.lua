local Scene = {
    -- properties
    
    -- CHILDREN represent the Scene's Layers. Layers are added/removed
    -- via Adopt() and Disown() methods.

    Name = "Scene",
    Active = true,          -- A Scene only updates when it's active
    Visible = true,         -- A Scene only renders when it's visible
    MasterCanvas = nil,     -- The final canvas rendered to the screen

    -- internal properties
    _super = "Object",      -- Supertype
    _global = true
}

-- !! Using default constructor until otherwise required !! --
-- function Scene.new(properties)
--     local newScene = Scene:SuperInstance()

--     return Scene:Connect(newScene)
-- end
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --

-- default update pipeline for a Scene
function Scene:Update(dt)
    for layer in self:EachChild() do
        layer:Update(dt)
    end
end

-- the default rendering pipeline for a Scene
local lg = love.graphics
function Scene:Draw()
    
    -- go through all the Layers uh... think about it chex !!
    for layer in self:EachChild() do
        
        layer:Draw()
        
    end
    
    -- we use this later
    local windowSize = V{lg.getDimensions()}

    -- make sure the MasterCanvas exists (lazy solution for now)
    self.MasterCanvas = self.MasterCanvas or Canvas.new(windowSize.X, windowSize.Y)
    local canvasSize = self.MasterCanvas:GetSize()

    -- render all layers to the MasterCanvas
    self:CombineLayers()

    -- draw the MasterCanvas
   
    local canvasRatio, windowRatio = canvasSize.X / canvasSize.Y, windowSize.X / windowSize.Y
    local scaleByWidth = canvasRatio > windowRatio
    local pixelWidth = scaleByWidth and windowSize.X or windowSize.Y * canvasRatio
    local pixelHeight = scaleByWidth and windowSize.X/canvasRatio or windowSize.Y

    -- claim render space and draw
    lg.setCanvas()
    lg.setColor(1,1,1,1)
    self.MasterCanvas:DrawToScreen(windowSize.X/2, windowSize.Y/2, 0, pixelWidth, pixelHeight, 0.5, 0.5)

end

-- the default implementation of layer combination for the MasterCanvas. No I/O, just apply all the Layers to Canvases
function Scene:CombineLayers()
    -- test bit !!
    self.MasterCanvas:Activate()
    lg.clear()
    lg.setColor(1,1,1,1)

    -- collect a list of all Canvases from all Layers
    local canvases = {}
    for layer in self:EachChild() do
        for _, canvas in ipairs(layer.Canvases) do
            canvases[#canvases+1] = canvas
        end
    end

    local masterCanvasSize = self.MasterCanvas:GetSize()

    for _, canvas in ipairs(canvases) do
        -- by default, we'll just stretch each Canvas to fit the MasterCanvas. 
        -- maybe make this a property later ?
        canvas:DrawToScreen(0, 0, 0, masterCanvasSize.X, masterCanvasSize.Y)
    end


end

-- function aliases
Scene.AddLayer = Object.Adopt
Scene.RemoveLayer = Object.Disown
Scene.SwapLayers = Object.SwapChildOrder
Scene.GetLayer = Object.GetChild


return Scene