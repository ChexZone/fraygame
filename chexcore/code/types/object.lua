local Object = {
    -- properties
    Name = "Object",        -- Easy identifier
    test = true,
    -- internal properties
    _isObject = true,       -- true for all Objects
    _super = "Object",      -- Supertype
    _superReference = nil,  -- Created at construction
    _parent = nil,          -- Reference to parent Object
    _children = nil,        -- Table of references to child Objects. Created at construction
    _childHash = nil,       -- Used to get quick access to Child objects
    _type = "Object",       -- the internal type of the object.
    _abstract = false,      -- Abstract types should not have instantiation
    _global = true          -- Is this type important enough to be globally referenced?
}
Object.__index = Object

-- Object metatable
local blankTables = {_children = true, _childHash = true}
setmetatable(Object, {
    __index = function(self, key)
        if blankTables[key] and _G.OBJSEARCH then
            -- print("Objectifying " .. key .. " for " .. tostring(_G.OBJSEARCH.Name))

            local newTab = {}
            _G.OBJSEARCH[key] = newTab
            _G.OBJSEARCH = nil
            return newTab
        end

        _G.OBJSEARCH = nil
    end
})

---------------- Constructor -------------------

-- !!!!! IMPORTANT !!!!! --- 
-- This constructor is not meant to be inherited.
-- It only applies to basic Objects! Custom constructors
-- are made for types created with Core:AddType().
-- See chexcore/init.lua!
function Object.new(properties)
    local obj = setmetatable({}, Object)
    if properties then
        for prop, val in pairs(properties) do
            obj[prop] = val
        end
    end
    return obj
end

------------------------------------------------

------------------ Methods ---------------------
function Object:Connect(instance)
    return setmetatable(instance, self)
end

local function advancedType(name, var)
    local out
    if name:sub(1,1) == "_" then
        out =  "Internal"
    elseif type(var) == "table" then
        out =  var._type or "table"
    elseif var == nil then
        out = "boolean"
    else
        out =  type(var)
    end
    return out
end

local renderMax = 30
function Object:ToString(properties, typeLabels, displayMethods)
    if typeLabels ~= false then
        typeLabels = true
    end
    local out
    if properties then
        out = ("           [%s]%s%s           "):format(self._type, (" "):rep(math.min(35, 35-#self.Name-#self._type)), self.Name)
        local length = #out
        out = out .. "\n|" .. ("_"):rep(length-2) .. "|\n"
                  .. "|"..(" "):rep(length-2).."|\n"
        local sortedProperties = {}

        if type(properties) == "table" then
            -- list of properties
            for _, property in ipairs(properties) do
                local pType = advancedType(property, self[property])
                sortedProperties[pType] = sortedProperties[pType] or {}
                sortedProperties[pType][#sortedProperties[pType]+1] = property
            end
        else
            -- all properties 
            local propertiesAdded = {}

            for property, _ in pairs(self) do
                local pType = advancedType(property, self[property])
                sortedProperties[pType] = sortedProperties[pType] or {}
                sortedProperties[pType][#sortedProperties[pType]+1] = property
                propertiesAdded[property] = true
            end

            for property, _ in pairs(getmetatable(self)) do
                if not propertiesAdded[property] then
                    local pType = advancedType(property, self[property])
                    sortedProperties[pType] = sortedProperties[pType] or {}
                    sortedProperties[pType][#sortedProperties[pType]+1] = property
                end
            end
        end

        local ignore = {Internal = 0, userdata = 1, boolean = 2, number = 3, string = 4, ["function"] = 5}
        
        -- first print Object types (greedy)
        for propertyType, list in sortedPairs(sortedProperties) do
            if not ignore[propertyType] then
                if typeLabels then
                    local t = "| [" .. propertyType .. "]:"
                    out = out .. t .. (" "):rep(length-#t-1) .. "|\n"
                            .. "|" .. ("="):rep(#propertyType + 6) .. (" "):rep(length-#propertyType-8) .. "|\n"
                end

                for _, property in ipairs(list) do
                    out = out .. ("| %s%s%s |\n"):format(property, (" "):rep(length-4-#property-#tostring(self[property]):limit(renderMax)), tostring(self[property]):limit(renderMax))
                end

                if typeLabels then
                    out = out .. "|" .. ("- "):rep((length-2)/2) .. (length%2==1 and "-" or "") .. "|\n"
                end
            end
        end

        local priority = displayMethods and {"function",  "string", "number", "boolean", "userdata", "Internal"}
                                        or  {"string", "number", "boolean", "userdata", "Internal"}

        for _, propertyType in ipairs(priority) do
            if sortedProperties[propertyType] then
                table.sort(sortedProperties[propertyType])
                if typeLabels then
                    local t = "| [" .. propertyType .. "]:"
                    out = out .. t .. (" "):rep(length-#t-1) .. "|\n"
                            .. "|" .. ("="):rep(#propertyType + 6) .. (" "):rep(length-#propertyType-8) .. "|\n"
                end

                for _, property in ipairs(sortedProperties[propertyType]) do
                    local propertyString = tostring(self[property] and type(self[property]) == "table" and type(self[property].ToString) == "function" and self[property]:ToString() or type(self[property]) == "string" and ('"'..self[property]..'"') or self[property]):limit(renderMax)
                    out = out .. ("| %s%s%s |\n"):format(property, (" "):rep(length-4-#property-#propertyString), propertyString)
                end

                if typeLabels then
                    out = out .. "|" .. ("- "):rep((length-2)/2) .. (length%2==1 and "-" or "") .. "|\n"
                end
            end
        end

    else
        -- no properties, inline
        out = "["..self._type.."] "..self.Name
    end

    return out
end

--[[  
    Object:GetChild( name )
     - returns the child with the given name, or nil if not found
    Object:GetChild( property, value )
     - returns the child with the given property and value, or nil if not found
    Object:GetChild( { property = val, ...} [, inclusive] )
     - searches for multiple properties. If inclusive is false, all properties must match.
    Object:GetChild( func )
     - returns the first child for which func(child) returns true
]]
function Object:GetChild(arg1, arg2)
    if type(arg1) == "table" then
        -- Object:GetChild( { property = val, ...} [, inclusive] )
        if not arg2 then
            -- exclusive
            for index, child in ipairs(self._children) do
                local match = true
                for property, val in pairs(arg1) do
                    if child[property] ~= val then
                        match = false; break
                    end
                end
                if match then
                    return child, index
                end
            end
        else
            -- inclusive
            for index, child in ipairs(self._children) do
                local match = false
                for property, val in pairs(arg1) do
                    if child[property] == val then
                        match = true; break
                    end
                end
                if match then
                    return child, index
                end
            end
        end
    elseif arg2 ~= nil then
            -- Object:GetChild( property, value )
            for index, child in ipairs(self._children) do
                if child[arg1] == arg2 then
                    return child, index
                end
            end
    elseif type(arg1) == "function" then
        -- Object:GetChild( func )
        for index, child in ipairs(self._children) do
            if arg1(child) then
                return child, index
            end
        end
    else
        -- Object:GetChild( name )
        for index, child in ipairs(self._children) do
            if child.Name == arg1 then
                return child, index
            end
        end
    end

    return nil
end

--[[  
    Object:GetChildren()
     - returns the full list of an object's children
    Object:GetChildren( name )
     - returns the subset of children with the given name
    Object:GetChildren( property, value )
     - returns the subset of children with the given property and value
    Object:GetChildren( { property = val, ...} [, inclusive] )
     - searches for multiple properties. If inclusive is false, all properties must match.
    Object:GetChildren( func )
     - returns the subset of children for which func(child) returns true
]]
local filter = filteredList
local type2 = type
function Object:GetChildren(arg1, arg2)
    if not arg2 and type2(arg1) == "string" then
        return filter(self._children, "Name", arg1)
    end
    return filter(self._children, arg1, arg2)
end

--[[  
    Object:EachChild() has the same signatures as Object:GetChildren(),
    but returns an iterator rather than building the entire list.
    Example usage:

    for child in myObject:EachChild() do
        print(child.Name)
    end
]]
local iterFilter = filteredListIterator
function Object:EachChild(arg1, arg2)
    if not arg2 and type2(arg1) == "string" then
        return iterFilter(self._children, "Name", arg1)
    end
    return iterFilter(self._children, arg1, arg2)
end


function Object:GetParent()
    return self._parent
end

function Object:Adopt(child)
    if child._parent then
        child._parent:Disown(child)
    end

    local newPos = #self._children + 1
    self._childHash = rawget(self, "_childHash") or {}
    self._children = rawget(self, "_children") or {}

    self._childHash[child] = newPos
    self._children[newPos] = child

    child._parent = self

    return newPos
end

function Object:GetChildID()
    return self._parent and self._parent._childHash[self] or 0
end

local trm = table.remove
function Object:Disown(child)
    if type(child) == "table" then
        -- Object:Disown( child )
        local index = self._childHash[child]
        trm(self._children, index)
        self._childHash[child] = nil
        return child
    else
        -- Object:Disown( index )
        local obj = self._children[child]
        self._childHash[obj] = nil
        trm(self._children, child)
        return obj
    end
end

function Object:Emancipate()
    local parent = self._parent
    if parent then
        local index = parent._childHash[self]
        trm(parent._children, index)
        parent._childHash[self] = nil
        self._parent = nil

        -- shift elements on top back into place in the childHash
        for i = index, #parent._children do
            local child = parent._children[i]
            parent._childHash[child] = i
        end
    end
    return parent
end

function Object:IsChildOf(parent)
    -- return parent._childHash[self] and true or false
    -- i'm keeping this line here   bc   it was the original implementation and 
    --                                                               wow what  
    return parent == self._parent
end

function Object:GetType()
    return self._type
end

function Object:SuperInstance()
    return self._superReference.new()
end

function Object:Serialize(upcast)
    return serialize(self, upcast)
end
------------------------------------------------

return Object