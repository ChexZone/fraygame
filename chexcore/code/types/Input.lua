local Input = {
    -- properties
    Name = "Input",           -- Easy identifier

    Active = true,            -- will only take input while Active
    CustomMap = nil,


    -- internal properties
    _isDown = {},
    _cache = setmetatable({}, {__mode = "k"}), -- cache has weak keys
    _super = "Object",      -- Supertype
    _global = true
}
local function sendInputDown(device, key)
    for listener in pairs(Input._cache) do
        if listener.Active then
            listener._isDown[key] = true
            if listener.CustomMap and listener.CustomMap[key] then
                listener:Press(device, listener.CustomMap[key])
                listener._isDown[listener.CustomMap[key]] = true
            else
                listener:Press(device, key)
            end
        end
    end
end
local function sendInputUp(device, key)
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


function Input:IsDown(key)
    return self.Active and (self._isDown[key] or false)
end

function Input:Press(device, key)
    -- dummy
end

function Input:Release(device, key)
    -- dummy
end

return Input