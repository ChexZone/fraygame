local SpecialObject = {
    -- properties
    Name = "SpecialObject2",        -- Easy identifier

    -- internal properties
    _super = "SpecialObject",      -- Supertype
    _global = true
}
SpecialObject.__index = SpecialObject

---------------- Constructor -------------------
function SpecialObject.new()
    local myObj = SpecialObject:SuperInstance()
    
    return setmetatable(myObj, SpecialObject)
end
------------------------------------------------

------------------ Methods ---------------------
function SpecialObject:Bark()
    print("wowf!")
end
----------------------------------------

return SpecialObject