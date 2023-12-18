local SpecialObject = {
    -- properties
    Name = "SpecialObject",        -- Easy identifier
    Test = true,

    -- internal properties
    _super = "Object",      -- Supertype
    _global = true
}

---------------- Constructor -------------------
function SpecialObject.new()
    local myObj = SpecialObject:SuperInstance()
    
    return SpecialObject:Connect(myObj)
end
------------------------------------------------

------------------ Methods ---------------------
function SpecialObject:Meow()
    print("meow!")
end
----------------------------------------

return SpecialObject