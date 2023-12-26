local Sound = {
    -- properties
    Name = "Sound",

    -- internal properties
    _source = nil,

    _super = "Object",      -- Supertype
    _global = true
}

--local mt = {}
--setmetatable(Texture, mt)
local smt = setmetatable
function Sound.new(path, mode)
    local newSound = smt({}, Sound)
    newSound._source = love.audio.newSource(path, mode or "static")
    return newSound
end

local draw = cdraw
function Sound:Play()
    self._source:play()
end
function Sound:Pause()
    self._source:pause()
end
function Sound:Stop()
    self._source:stop()
end
function Sound:IsPlaying()
    return self._source:isPlaying()
end

return Sound