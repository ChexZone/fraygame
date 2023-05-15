local Object = {
    -- properties
    Name = "Object",        -- Easy identifier

    -- internal properties
    _super = "Object",      -- Supertype
    _superReference = nil,  -- Created at construction
    _parent = nil,          -- Reference to parent Object
    _children = nil,        -- Table of references to child Objects. Created at construction
    _childHash = nil,       -- Used to get quick access to Child objects
    _type = "Object",       -- the internal type of the object. 
    _global = true          -- Is this type important enough to be globally referenced?
}
Object.__index = Object

-- Object metatable
local blankTables = {_children = true, _childHash = true}
setmetatable(Object, {
    __index = function(self, key)
        if blankTables[key] then
            self[key] = {}
            return self[key]
        end
    end
})

---------------- Constructor -------------------
function Object.new()
    local newObj = setmetatable({}, Object)

    -- apply children table

    return newObj
end
------------------------------------------------

------------------ Methods ---------------------
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
    elseif arg2 then
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

function Object:GetChildren()
    local children = {}
    for i, ref in ipairs(self._children) do
        children[i] = ref
    end
    return children
end

function Object:GetParent()
    return self._parent
end

function Object:AddChild(child)
    if child._parent then
        child._parent:RemoveChild(child)
    end

    local newPos = #self._children + 1
    self._childHash[child] = newPos
    self._children[newPos] = child

    child._parent = self

    return newPos
end

function Object:RemoveChild(child)
    local index = self._childHash[child]
    table.remove(self._children, index)
    
    self._childHash[child] = nil
end

function Object:IsChildOf(parent)
    return parent._childHash[self] and true or false
end

function Object:SuperInstance()
    return self._superReference.new()
end
------------------------------------------------

return Object