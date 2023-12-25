_G.Chexcore = {
    -- internal properties
    _clock = 0,             -- keeps track of total game run time

    _types = {},            -- stores all type references
    _scenes = {}            -- stores all mounted Scene references
}

-- when an Object is indexed, this variable helps keep the referenced up the type chain
_G.OBJSEARCH = nil

-- set default LOVE values
love.graphics.setDefaultFilter("nearest", "nearest", 1)

-- helper functions to make life easier ~ 
require "chexcore.code.misc.helper"

---------------- LOVE2D BINDINGS ----------------
function love.update(dt) Chexcore.Update(dt) end
function love.draw() Chexcore.Draw() end
------------------------------------------------

---------------- UPDATE LOOPS ------------------
function Chexcore.Update(dt)
    Chexcore._clock = Chexcore._clock + dt
    -- update all active Scenes
    for sceneid, scene in ipairs(Chexcore._scenes) do
        if scene.Active then
            scene:Update(dt)
        end
    end
end

function Chexcore.Draw()
    -- draw all visible Scenes
    for id, scene in ipairs(Chexcore._scenes) do
        if scene.Visible then
            scene:Draw()
        end
    end

end
------------------------------------------------

--------------- CORE METHODS -------------------
function Chexcore:AddType(type)
    -- check: if there is no type name, assign it to the default Object.Name
    type._type = type._type or type.Name or "NewObject"

    Chexcore._types[type._type] = type
    -- insert into global namespace, if needed
    if rawget(type, "_global") then
        _G[type._type] = type
    end
    
    if type._aliases then
        for _, alias in ipairs(type._aliases) do
            Chexcore._types[alias] = type

            if rawget(type, "_global") then
                _G[alias] = type
            end
        end
    end

    type._standardConstructor = function (properties)
        local obj = type:SuperInstance()
        if properties then
            for prop, val in pairs(properties) do
                obj[prop] = val
            end
        end
        return type:Connect(obj)
    end

    -- apply a basic constructor if one is not present
    if not (type._abstract or type.new) then
        type.new = type._standardConstructor
    elseif type._abstract then
        type.new = false
    end

    -- assume the type may not have a metatable yet
    local metatable = getmetatable(type) or {}

    

    -- apply the supertype, if there is one
    -- Object's basic type has a special metatable, so it is ignored
    --print(type.Name .. ": ")
    --print(metatable)
    if type._type ~= "Object" then
        metatable.__index = Chexcore._types[type._super]
    end
    
    -- apply a reference to the supertype
    type._superReference = Chexcore._types[type._super]

    type.__index2 = function(obj, key)
        if rawget(type, key) then
            _G.OBJSEARCH = nil
            return rawget(type, key)
        else
            if not _G.OBJSEARCH then
                -- mount the object
                _G.OBJSEARCH = obj
            end
            
            return Chexcore._types[type._super][key]
        end
    end

    type.__index = type.__index or type.__index2
    
    return setmetatable(type, metatable)
end

function Chexcore.MountScene(scene)
    Chexcore._scenes[#Chexcore._scenes+1] = scene
end

function Chexcore.UnmountScene(scene)
    for i = 1, #Chexcore._scenes do
        if Chexcore._scenes[i] == scene then
            table.remove(Chexcore._scenes, i)
            return true
        end
    end
    return false
end


------------------------------------------------


-- !!!!!!!!!!!!!!!!!! INITIALIZATION STUFF !!!!!!!!!!!!!!!!!!!! --

-- load in some essential types
local types = {
    "chexcore.code.types.object",
    "chexcore.code.types.number",
    "chexcore.code.types.vector",
    "chexcore.code.types.ray",
    "chexcore.code.types.texture",
    "chexcore.code.types.prop",
    "chexcore.code.types.specialObject",
    "chexcore.code.types.specialObject2",
    "chexcore.code.types.camera",
    "chexcore.code.types.sampleObject",
    "chexcore.code.types.scene",
    "chexcore.code.types.layer",
    "chexcore.code.types.canvas",
}

for _, type in ipairs(types) do
    Chexcore:AddType(require(type))
end


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --

return Chexcore