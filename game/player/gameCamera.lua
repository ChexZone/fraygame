local GameCamera = {
    -- properties
    Name = "GameCamera",
    Zoom = 1,

    Focus = nil,    -- prop
    DampeningFactor = 60,
    
    -- internal properties
    _super = "Camera",      -- Supertype
    _cache = setmetatable({}, {__mode = "k"}), -- cache has weak keys
    _global = true
}

function GameCamera._globalUpdate(dt)
    for camera in pairs(GameCamera._cache) do
        if camera.Focus then
            camera.Position = camera.Position:Lerp(camera.Focus.Position, camera.DampeningFactor*dt)
        end
    end
end

function GameCamera.new(properties)
    local newCamera = GameCamera:SuperInstance()
    if properties then
        for prop, val in pairs(properties) do
            newCamera[prop] = val
        end
    end

    GameCamera._cache[newCamera] = true
    return GameCamera:Connect(newCamera)
end

return GameCamera