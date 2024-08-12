local Input = {
    -- properties
    Name = "Input",           -- Easy identifier

    Active = true,            -- will only take input while Active
    CustomMap = nil,


    -- internal properties
    _isDown = {},
    _justPressed = {},
    _cache = setmetatable({}, {__mode = "k"}), -- cache has weak keys
    _super = "Object",      -- Supertype
    _global = true
}

Input._globalUpdate = function (dt)
    for k, _ in pairs(Input._justPressed) do
        listener._justPressed[k] = nil
    end

    for listener in pairs(Input._cache) do
        if listener.Active then
            for k, _ in pairs(listener._justPressed) do
                listener._justPressed[k] = nil
            end
        end
    end
end

local function sendInputDown(device, key)
    Input._isDown[key] = true

    for listener in pairs(Input._cache) do
        if listener.Active then
            listener._isDown[key] = true
            if listener.CustomMap and listener.CustomMap[key] then
                listener:Press(device, listener.CustomMap[key])
                listener._isDown[listener.CustomMap[key]] = true
                listener._justPressed[listener.CustomMap[key]] = true
            else
                listener:Press(device, key)
                listener._isDown[key] = true
                listener._justPressed[key] = true
            end
        end
    end
end
local function sendInputUp(device, key)
    Input._isDown[key] = false

    for listener in pairs(Input._cache) do
        if listener.Active then
            listener._isDown[key] = false
            if listener.CustomMap and listener.CustomMap[key] then
                listener:Release(device, listener.CustomMap[key])
                listener._isDown[listener.CustomMap[key]] = false
            else
                listener:Release(device, key)
            end
        end
    end
end

function Input.new(map)
    local newListener = setmetatable({}, Input)
    Input._cache[newListener] = true

    newListener.CustomMap = map
    newListener._isDown = {}
    newListener._justPressed = {}

    return newListener
end
-- Animation._globalUpdate = function (dt)
--     for anim in pairs(Animation._cache) do
--         if anim.IsPlaying then
--             anim:Update(dt * anim.PlaybackScaling)
--         end
--     end
-- end
function love.keypressed(key, scancode)
    sendInputDown("kb", key)
end

function love.keyreleased(key, scancode)
    sendInputUp("kb", key)
end

function love.mousepressed(x, y, button, isTouch)
    sendInputDown("mouse", "m_"..tostring(button))
end

function love.mousereleased(x, y, button, isTouch)
    sendInputUp("mouse", "m_"..tostring(button))
end

function love.wheelmoved(x, y)
    if y > 0 then
        sendInputDown("mouse", "m_wheelup")
        sendInputUp("mouse", "m_wheelup")
    elseif y < 0 then
        sendInputDown("mouse", "m_wheeldown")
        sendInputUp("mouse", "m_wheeldown")
    end
end


function Input:IsDown(key)
    return self.Active and (self._isDown[key] or false)
end

function Input:JustPressed(key)
    return self.Active and (self._justPressed[key] or false)
end

function Input:Press(device, key)
    -- dummy
end

function Input:Release(device, key)
    -- dummy
end

local getMousePos = love.mouse.getPosition
local getScreenSize = love.graphics.getDimensions
local vec = V

local oldX, oldY = 0, 0

-- returns a 2D vector with a 0-1 float range showing the XY position of the mouse on the screen.
-- also returns a boolean as a second argument, "true" if Chexcore thinks the mouse is on-screen and "false" otherwise 
function Input:GetMousePosition()
    local px, py = getMousePos()
    local sx, sy = getScreenSize()


    if oldX == px and oldY == py then
        if (px == sx-1 or px == 0) or (py == sy-1 or py == 0) then
            return vec{px/sx, py/sy}, false
        end
    end

    oldX = px; oldY = py
    return vec{px/sx, py/sy}, true
end

return Input