local Gui = {
    -- properties
    Name = "Gui",
    
    -- internal properties
    _trackingMouse = false,   -- internal flag for if the Gui is tracking the mouse
    _isUnderMouse = false,    -- NOT always being polled! Use Gui:IsUnderMouse() instead
    _selectedBy = {},       -- set in constructor
    _beingUsed = false,     -- (internal only, for performance) is the gui active with the mouse right now?

    _super = "Prop",      -- Supertype
    _global = true,

    -- list of "active" gui elements (as referenced by whether they have "OnHover" methods, etc)
    _hoverEvents = setmetatable({}, {__mode = "k"}),
    _selectEvents = setmetatable({}, {__mode = "k"})
}
local rg, rs, next = rawget, rawset, next
local Input = Input

Gui._priorityGlobalUpdate = function ()
    for guiElement, _ in pairs(Gui._hoverEvents) do
        local newHoverStatus = guiElement:IsUnderMouse()

        if newHoverStatus ~= guiElement._isUnderMouse then
            if newHoverStatus == true then -- hover entered
                if guiElement.OnHoverStart then guiElement:OnHoverStart() end
            else                            -- hover exited
                if guiElement.OnHoverEnd then guiElement:OnHoverEnd() end
            end
            rs(guiElement, "_isUnderMouse", newHoverStatus)
        end
    end

    -- which mouse button got pressed just this frame?
    local justPressed = Input:JustPressed("m_1") and 1 or
                            Input:JustPressed("m_2") and 2 or
                            Input:JustPressed("m_3") and 3 or
                            Input:JustPressed("m_4") and 4 or
                            Input:JustPressed("m_5") and 5 or false

    for guiElement, _ in pairs(Gui._selectEvents) do
        if guiElement._isUnderMouse then
            guiElement._beingUsed = true

            -- deactivate any currently active elements
            for n in pairs(guiElement._selectedBy) do
                if not Input:IsDown("m_"..n) then
                    guiElement._selectedBy[n] = nil
                    if guiElement.OnSelectEnd then guiElement:OnSelectEnd(n) end
                end
            end

            if justPressed then -- need to send some click event
                if guiElement.OnSelectStart then guiElement:OnSelectStart(justPressed) end
                guiElement._selectedBy[justPressed] = true
            end
            
        elseif guiElement._beingUsed then -- need to reset selection state
            for n in pairs(guiElement._selectedBy) do
                guiElement._selectedBy[n] = nil
                if guiElement.OnSelectEnd then guiElement:OnSelectEnd(n) end
            end
            guiElement._beingUsed = false
        end
    end
end

local listeners = {
    OnHoverStart = function (obj, key, val)
        rs(obj, key, val)
        Gui._hoverEvents[obj] = true
        obj._trackingMouse = true
        rs(obj, "_isUnderMouse", rg(obj, "_isUnderMouse") or false)
    end,
    OnHoverEnd = function (obj, key, val)
        rs(obj, key, val)
        Gui._hoverEvents[obj] = true
        obj._trackingMouse = true
        rs(obj, "_isUnderMouse", rg(obj, "_isUnderMouse") or false)
    end,
    OnSelectStart = function (obj, key, val)
        rs(obj, key, val)
        Gui._hoverEvents[obj] = true
        Gui._selectEvents[obj] = true
        obj._trackingMouse = true
        rs(obj, "_isUnderMouse", rg(obj, "_isUnderMouse") or false)
    end,
    OnSelectEnd = function (obj, key, val)
        rs(obj, key, val)
        Gui._hoverEvents[obj] = true
        Gui._selectEvents[obj] = true
        obj._trackingMouse = true
        rs(obj, "_isUnderMouse", rg(obj, "_isUnderMouse") or false)
    end
}


function Gui.__newindex(obj, key, val)
    if listeners[key] then
        listeners[key](obj, key, val)
    else
        rs(obj, key, val)
    end
end

function Gui.new(properties)
    local newGui = Gui:Connect( Gui:SuperInstance() )
    
    if properties then
        for prop, val in pairs(properties) do
            newGui[prop] = val
        end
    end

    newGui._selectedBy = rg(newGui, "_selectedBy") or {}

    return newGui
end


function Gui:GetMouseTracking()
    return self._trackingMouse
end

function Gui:SetMouseTracking(b)
    if b then
        self._trackingMouse = true
        Gui._hoverEvents[self] = true
        Gui._selectEvents[self] = true
    else
        self._trackingMouse = false
        Gui._hoverEvents[self] = nil
        Gui._selectEvents[self] = nil
    end
end


return Gui