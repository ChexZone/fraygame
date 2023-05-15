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
function Chexcore:AddType(type)
    -- check: if there is no type name, assign it to the default Object.Name
    type._type = type._type or type.Name

    Chexcore._types[type._type] = type

    -- insert into global namespace, if needed
    if rawget(type, "_global") then
        _G[type._type] = type
    end

    -- assume the type may not have a metatable yet
    local metatable = getmetatable(type) or {}

    -- apply the supertype, if there is one
    if type._type ~= "Object" then
        metatable.__index = Chexcore._types[type._super] or nil
    end


    -- apply a reference to the supertype
    type._superReference = metatable.__index

    setmetatable(type, metatable)
end
------------------------------------------------


-- !!!!!!!!!!!!!!!!!! INITIALIZATION STUFF !!!!!!!!!!!!!!!!!!!! --

-- load in some essential types
local types = {
    "chexcore.types.object",
    "chexcore.types.specialObject",
    "chexcore.types.specialObject2"
}

for _, type in ipairs(types) do
    Chexcore:AddType(require(type))
end


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --

return Chexcore