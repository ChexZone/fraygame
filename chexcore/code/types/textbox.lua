local Textbox = {
    -- properties
    Name = "Textbox",
    Zoom = 1,
    
    -- internal properties
    _super = "Gui",      -- Supertype
    _global = true
}

function Textbox.new(properties)
    local newCamera = Textbox:SuperInstance()
    if properties then
        for prop, val in pairs(properties) do
            newCamera[prop] = val
        end
    end


    return Textbox:Connect(newCamera)
end

return Textbox