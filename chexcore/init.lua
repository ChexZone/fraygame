local Chexcore = {

    -- internal properties
    _types = {}
}

---------------- LOVE2D BINDINGS ----------------
function love.update(dt) Chexcore.update(dt) end
function love.draw() Chexcore.draw() end
------------------------------------------------

---------------- UPDATE LOOPS ------------------
function Chexcore.update(dt)
    
end

function Chexcore.draw()
    
end
------------------------------------------------

--------------- CORE METHODS -------------------
function Chexcore:AddType(name, type)
    Chexcore._types[name] = type

    -- assume the type may not have a metatable yet
    local metatable = getmetatable(type) or setmetatable(type, {})

    -- apply the supertype, if there is one
    metatable.__index = Chexcore._types[type._super] or nil
end
------------------------------------------------


-- !!!!!!!!!!!!!!!!!! INITIALIZATION STUFF !!!!!!!!!!!!!!!!!!!! --

-- load in some essential types
local types = {
    Object = require "chexcore.types.object"
}

for name, type in pairs(types) do
    Chexcore:AddType(name, type)
end

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --

return Chexcore