local Particles = {
    -- properties
    Name = "Particles",
    
    -- internal properties
    _super = "Prop",      -- Supertype
    _global = true
}

function Particles.new(properties)
    local newParticles = Particles:SuperInstance()
    if properties then
        for prop, val in pairs(properties) do
            newParticles[prop] = val
        end
    end


    return Particles:Connect(newParticles)
end

return Particles