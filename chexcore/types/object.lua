local Object = {
    -- properties
    Name = "Object",        -- Easy identifier

    -- internal properties
    _super = "Object",      -- Supertype
    _parent = nil,          -- Reference to parent Object
    _children = nil,        -- Table of references to child Objects. Created at construction
}

-- Object metatable
setmetatable(Object, {})

---------------- Constructor -------------------
function Object.new()
    
end
------------------------------------------------

------------------ Methods ---------------------
function Object:GetChildren()
    
end

function Object:GetParent()
    
end

function Object:SetParent()
    
end
------------------------------------------------

return Object