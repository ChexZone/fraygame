-- CHEXCORE EXAMPLE SCENE
local scene = Scene.new()

local CANVAS_SIZE = V{1280, 720}
local BG_COLOR, BRUSH_COLOR = V{0.8,0.85,0.95,1}, V{0,0,0,1}
local lastDrawnPixel -- Vector
local rightClickOrigin -- Vector
local middleClickOrigin -- Vector
local cameraOrigin -- Vector
local cameraOriginZoom -- Vector
local cameraGoalZoom -- number
local cameraGoalPos -- Vector

local brushWidth = 1
local drawMode = "brush"

-- start with a Layer for the image:
local imageLayer = scene:Adopt( Layer.new("Image", CANVAS_SIZE.X, CANVAS_SIZE.Y) )

-- we'll use a Prop as a "canvas" to draw on:
local drawingCanvas = imageLayer:Adopt( Prop.new{
    Name = "DrawingCanvas",
    Size = CANVAS_SIZE:Clone(),
    Texture = Canvas.new( imageLayer.Canvases[1]:GetSize():Unpack() ),
    Position = V{0, 0},
    AnchorPoint = V{0, 0}
})

-- initialize the canvas with a color:
drawingCanvas.Texture:Activate()
    love.graphics.setColor(BG_COLOR:Unpack())
    love.graphics.rectangle("fill", 0, 0, CANVAS_SIZE.X, CANVAS_SIZE.Y)
drawingCanvas.Texture:Deactivate()

scene.Camera.Position = CANVAS_SIZE/2

cameraGoalZoom = scene.Camera.Zoom
cameraGoalPos = scene.Camera.Position

function scene.Camera:Update(dt)
    cameraGoalZoom = math.clamp(cameraGoalZoom, 0.2, 100)
    self.Zoom = V{self.Zoom}:Lerp(V{cameraGoalZoom}, 30*dt)()
    self.Position = self.Position:Lerp(cameraGoalPos, 30*dt)
end


local guiLayer = scene:Adopt( Layer.new("GUI", 640, 360) ) -- specify the Name, and pixel width/height
guiLayer.ZoomInfluence = 0.5

guiLayer:Adopt(Prop.new{
    Name = "Cursor",
    AnchorPoint = V{0.5, 0.5},
    Size = V{16,16},
    Color =  V{1,0,1,0.5},
    Texture = Texture.new("chexcore/assets/images/crosshair.png"),
    Update = function(self, dt)
        self.Position = self.Position:Lerp(self:GetParent():GetMousePosition(), 1000*dt)
        self.Rotation = self.Rotation + dt
    end
})

-- now that we have the cursor, we can use its position to draw stuff
function drawingCanvas:Update(dt)
    local newMousePos = imageLayer:GetMousePosition()

    if Input:IsDown("m_1") then
        drawingCanvas.Texture:Activate()
            love.graphics.setColor(drawMode == "brush" and BRUSH_COLOR or drawMode == "erase" and BG_COLOR)

            if Input:JustPressed("m_1") then
                cdrawcircle("fill", math.round(lastDrawnPixel[1]), math.round(lastDrawnPixel[2]), brushWidth)
            end
            
            cdrawlinethick(math.round(lastDrawnPixel[1]), math.round(lastDrawnPixel[2]), math.round(newMousePos[1]), math.round(newMousePos[2]), brushWidth)
            lastDrawnPixel = newMousePos
        drawingCanvas.Texture:Deactivate()
    end

    if Input:IsDown("m_2") then
        cameraGoalZoom = cameraOriginZoom + (rightClickOrigin - newMousePos).Y/100
    elseif Input:IsDown("m_3") then
        cameraGoalPos = cameraOrigin + (middleClickOrigin - newMousePos)*6
    end
end

local keyResponses = { ["m_1"] = function()  lastDrawnPixel = imageLayer:GetMousePosition()  end,
                       ["m_2"] = function()
                            rightClickOrigin = imageLayer:GetMousePosition()
                            cameraOriginZoom = scene.Camera.Zoom
                        end,
                        ["m_3"] = function ()
                            middleClickOrigin = imageLayer:GetMousePosition()
                            cameraOrigin = scene.Camera.Position
                        end,
                        ["kp+"] = function()  cameraGoalZoom = cameraGoalZoom + 0.5  end,
                        ["kp-"] = function()  cameraGoalZoom = cameraGoalZoom - 0.5  end,
                        ["m_wheelup"] = function() cameraGoalZoom = cameraGoalZoom + 0.2  end,
                        ["m_wheeldown"] = function() cameraGoalZoom = cameraGoalZoom - 0.2  end,
                        ["e"] = function ()  drawMode = "erase"  end,
                        ["b"] = function ()  drawMode = "brush"  end,
                        ["c"] = function () cameraGoalPos = CANVAS_SIZE/2 end  }
scene.Input = Input.new()
function scene.Input:Press(device, key)
    if keyResponses[key] then keyResponses[key]() end
    if tonumber(key) then  brushWidth = tonumber(key)  end
end

return scene