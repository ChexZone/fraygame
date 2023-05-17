local SpecialObject = {
    -- properties
    Name = "SpecialObject2",        -- Easy identifier

    -- internal properties
    _super = "SpecialObject",      -- Supertype
    _global = true
}

---------------- Constructor -------------------
function SpecialObject.new()
    local myObj = SpecialObject:SuperInstance()
    
    return SpecialObject:Connect(myObj)
end
------------------------------------------------

------------------ Methods ---------------------
function SpecialObject:Bark()
    print("wowf!")
end
----------------------------------------

return SpecialObject