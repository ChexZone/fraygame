local GameCamera = {
    -- properties
    Name = "GameCamera",
    Zoom = 1,

    TrackingPosition = nil,

    Focus = nil,    -- prop
    DampeningFactor = V{5, 0},
    MaxDistancePerFrame = V{5, 5},
    MinDistancePerFrame = V{1.5, 0},
    MaxDistanceFromFocus = V{50, 50},
    RealMaxDistanceFromFocus = V{250, 80},

    Offset = V{0, 0},

    DampeningFactorReeling = V{15, 2},
    MaxDistancePerFrameReeling = V{3, 3},

    -- internal properties
    _super = "Camera",      -- Supertype
    _cache = setmetatable({}, {__mode = "k"}), -- cache has weak keys
    _global = true
}

function GameCamera._globalUpdate(dt)
    for camera in pairs(GameCamera._cache) do
        print(camera.Reeling)
        if camera.Focus then
            camera.TrackingPosition = camera.TrackingPosition or camera.Position
            local dampening = V{
                camera.Reeling.X and camera.DampeningFactorReeling.X or camera.DampeningFactor.X,
                camera.Reeling.Y and camera.DampeningFactorReeling.Y or camera.DampeningFactor.Y
            }
            local maxDist = V{
                camera.Reeling.X and camera.MaxDistancePerFrameReeling.X or camera.MaxDistancePerFrame.X,
                camera.Reeling.Y and camera.MaxDistancePerFrameReeling.Y or camera.MaxDistancePerFrame.Y,
            }*60*dt
            local minDist = V{
                camera.MinDistancePerFrame.X,
                camera.MinDistancePerFrame.Y,
            }*60*dt
            local focusPoint = camera.Focus:GetPoint(.5,.5)
            
            
            local newPos = V{
                math.lerp(camera.TrackingPosition.X, focusPoint.X, dampening.X*dt),
                math.lerp(camera.TrackingPosition.Y, focusPoint.Y, dampening.Y*dt),                
            }
            local dist = (camera.TrackingPosition - newPos)
            local focusDist = (focusPoint - newPos)

            if math.abs(dist.X) > maxDist.X or math.abs(focusDist.X) > camera.MaxDistanceFromFocus.X then
                newPos.X = camera.TrackingPosition.X - maxDist.X * sign(dist.X)
                camera.Reeling.X = true
                print("reeling")
            elseif math.abs(focusDist.X) < minDist.X then
                camera.Reeling.X = false
                newPos.X = focusPoint.X
            end

            if math.abs(dist.Y) > maxDist.Y or math.abs(focusDist.Y) > camera.MaxDistanceFromFocus.Y  then
                newPos.Y = camera.TrackingPosition.Y - maxDist.Y * sign(dist.Y)
                camera.Reeling.Y = true
            elseif math.abs(focusDist.Y) < minDist.Y then
                camera.Reeling.Y = false
                newPos.Y = focusPoint.Y
            end

            focusDist = (focusPoint - newPos)

            if math.abs(focusDist.X) > camera.RealMaxDistanceFromFocus.X then
                newPos.X = focusPoint.X - sign(focusDist.X) * camera.RealMaxDistanceFromFocus.X
            end

            if math.abs(focusDist.Y) > camera.RealMaxDistanceFromFocus.Y then
                newPos.Y = focusPoint.Y - sign(focusDist.Y) * camera.RealMaxDistanceFromFocus.Y
            end

            -- if (newPos - focusPoint):Magnitude() > camera.RealMaxDistanceFromFocus then
            --     local outAngle = -angle:Normalize()
            --     newPos = camera.Position + outAngle * camera.RealMaxDistanceFromFocus
            --     print(outAngle * camera.RealMaxDistanceFromFocus)
            -- end

            camera.TrackingPosition = newPos
            camera.Position = camera.TrackingPosition + camera.Offset
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

    newCamera.Reeling = V{false, false}

    GameCamera._cache[newCamera] = true
    return GameCamera:Connect(newCamera)
end

return GameCamera