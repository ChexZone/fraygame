_G.Chexcore = {
    -- internal properties
    _clock = 0,             -- keeps track of total game run time

    _types = {},            -- stores all type references
    _scenes = {},           -- stores all mounted Scene references
    _globalUpdates = {},    -- for any types that want independent update control
    _globalDraws = {},      -- for any types that want independent draw control
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

    -- global updaters first
    for _, func in ipairs(Chexcore._globalUpdates) do
        func(dt)
    end

    -- update all active Scenes
    for sceneid, scene in ipairs(Chexcore._scenes) do
        if scene.Active then
            scene:Update(dt)
        end
    end
end

function Chexcore.Draw()
    -- global updaters first
    for _, func in ipairs(Chexcore._globalDraws) do
        func()
    end
    
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

    if type._globalUpdate then
        Chexcore._globalUpdates[#Chexcore._globalUpdates+1] = type._globalUpdate
    end
    if type._globalDraw then
        Chexcore._globalDraws[#Chexcore._globalDraws+1] = type._globalDraw
    end

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

local fps = 0
local FRAMELIMIT = 60
local frameTime = 0
function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
        frameTime = frameTime + dt

        if frameTime >= 1/FRAMELIMIT and love.graphics and love.graphics.isActive() then
            if love.update then love.update(1/FRAMELIMIT) end -- will pass 0 if love.timer is disabled

            frameTime = frameTime - 1/FRAMELIMIT
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end


		if love.timer then love.timer.sleep(0.001) end
	end
end
------------------------------------------------


-- !!!!!!!!!!!!!!!!!! INITIALIZATION STUFF !!!!!!!!!!!!!!!!!!!! --

-- load in some essential types
local types = {
    "chexcore.code.types.object",
    "chexcore.code.types.number",
    "chexcore.code.types.vector",
    "chexcore.code.types.ray",
    "chexcore.code.types.sound",
    "chexcore.code.types.texture",
    "chexcore.code.types.animation",
    "chexcore.code.types.prop",
    "chexcore.code.types.tilemap",
    "chexcore.code.types.specialObject",
    "chexcore.code.types.specialObject2",
    "chexcore.code.types.camera",
    "chexcore.code.types.sampleObject",
    "chexcore.code.types.scene",
    "chexcore.code.types.layer",
    "chexcore.code.types.canvas",
    "chexcore.code.types.shader"
}

for _, type in ipairs(types) do
    Chexcore:AddType(require(type))
end


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --

return Chexcore