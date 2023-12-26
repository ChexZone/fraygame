local Shader = {
    -- properties
    Name = "Shader",

    -- internal properties
    Code = "",

    _realShader = nil,  -- created in constructor
    _cache = setmetatable({}, {__mode = "v"}), -- cache has weak values
    _super = "Object",      -- Supertype
    _global = true
}

--local mt = {}
--setmetatable(Texture, mt)
local smt = setmetatable
function Shader.new(path)
    local newShader

    

    if Shader._cache[path] then
        newShader = Shader._cache[path]
    else
        newShader = smt({}, Shader)
        if path then
            if love.filesystem.getInfo(path) then
                local f = love.filesystem.newFile(path)
                newShader.Code = f:read()
                f:close()
            else
                newShader.Code = path
            end
            Shader._cache[path] = newShader
        end
        newShader._realShader = love.graphics.newShader(newShader.Code)
    end

    return newShader
end

local setShader = love.graphics.setShader
function Shader:Activate()
    setShader(self._realShader)
end

return Shader