-- CHEXCORE EXAMPLE SCENE

-- create a Scene with this syntax:
local scene = Scene.new()

local mousePressed = false
local middleClickPressed = false
local lastDrawnPixel = nil -- Vector
local middleClickOrigin = nil -- Vector
local cameraOriginStorage = nil -- Vector



-- start with a Layer for the image:
local imageLayer = Layer.new("Image", 640, 360)

-- we'll use a Prop as a "canvas" to draw on:
local drawingCanvas = imageLayer:Adopt( Prop.new{
    Name = "DrawingCanvas",
    Size = imageLayer.Canvases[1]:GetSize(),
    Texture = Canvas.new( imageLayer.Canvases[1]:GetSize():Unpack() ),
    Position = V{0, 0},
    AnchorPoint = V{0, 0}
})

scene.Camera.Position = drawingCanvas.Texture:GetSize()/2

local cameraGoalZoom = scene.Camera.Zoom
local cameraGoalPosition = scene.Camera.Position

function scene.Camera:Update(dt)
    self.Zoom = V{self.Zoom}:Lerp(V{cameraGoalZoom}, 15*dt)()
    self.Position = self.Position:Lerp(cameraGoalPosition, 15*dt)

    if Input:IsDown("left") then
        cameraGoalPosition.X = cameraGoalPosition.X - 150*dt/cameraGoalZoom
    end
    if Input:IsDown("right") then
        cameraGoalPosition.X = cameraGoalPosition.X + 150*dt/cameraGoalZoom
    end
    if Input:IsDown("up") then
        cameraGoalPosition.Y = cameraGoalPosition.Y - 150*dt/cameraGoalZoom
    end
    if Input:IsDown("down") then
        cameraGoalPosition.Y = cameraGoalPosition.Y + 150*dt/cameraGoalZoom
    end
end


-- initialize the canvas with a color:
drawingCanvas.Texture:Activate()
love.graphics.setColor(1,1,1,1)
love.graphics.rectangle("fill", 0, 0, 1280, 720)
drawingCanvas.Texture:Deactivate()



scene:Adopt(imageLayer)



-- Scenes need to have at least one Layer to do anything!
local guiLayer = Layer.new("GUI", 1280, 720) -- specify the Name, and pixel width/height
-- attach the Layer to the Scene:
scene:Adopt(guiLayer)

guiLayer.Canvases[1].BlendMode = "subtract"

local cursor = guiLayer:Adopt(Prop.new{
    Name = "Cursor",
    AnchorPoint = V{0.5, 0.5},
    Size = V{16,16},
    Color =  V{1,1,0,0.5},
    Texture = Texture.new("chexcore/assets/images/crosshair.png"),
    Update = function(self, dt)

        self.Position = self.Position:Lerp(self:GetParent():GetMousePosition(), 1000*dt)
        self.Rotation = self.Rotation + dt
    end
})


-- now that we have the cursor, we can use its position to draw stuff
function drawingCanvas:Update(dt)
    local newMousePos = imageLayer:GetMousePosition()

    if mousePressed then
        drawingCanvas.Texture:Activate()
        love.graphics.setColor(0,0,0)
        cdrawlinethick( lastDrawnPixel[1], lastDrawnPixel[2], newMousePos[1], newMousePos[2], 1)
        lastDrawnPixel = newMousePos
        drawingCanvas.Texture:Deactivate()
    end  

    if middleClickPressed then
        cameraGoalPosition = cameraOriginStorage + (middleClickOrigin - newMousePos)*16
    end

end

-- we'll use an input listener for callbacks:
scene.Input = Input.new()
function scene.Input:Press(device, key)
    if key == "m_1" then
        mousePressed = true
        lastDrawnPixel = imageLayer:GetMousePosition()
    end

    if key == "m_3" then
        middleClickPressed = true
        cameraOriginStorage = scene.Camera.Position
        middleClickOrigin = imageLayer:GetMousePosition()
    end

    if key == "kp+" or key == "m_wheelup" then
        cameraGoalZoom = cameraGoalZoom + 0.2
    end

    if key == "kp-" or key == "m_wheeldown" then
        cameraGoalZoom = cameraGoalZoom - 0.2
    end
    
end

function scene.Input:Release(device, key)
    if key == "m_1" then
        mousePressed = false
    end
    if key == "m_3" then
        middleClickPressed = false
    end
end

return scene