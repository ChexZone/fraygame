local GameCamera = {
    -- properties
    Name = "GameCamera",
    Zoom = 1.5,
    ZoomSpeed = 5,

    DisplayHeight = 360,

    TrackingPosition = nil,

    FillWithFocus = false,

    Overrides = {},

    Focus = nil,    -- prop
    LastFocus = nil,

    DampeningFactor = V{15, 0},
    MaxDistancePerFrame = V{10, 5},
    MinDistancePerFrame = V{5, 5},
    MaxDistanceFromFocus = V{50, 60},
    RealMaxDistanceFromFocus = V{250, 50},
    DampeningFactorReeling = V{15, 2},
    MinDistancePerFrameReeling = V{1.5, 1.5},
    MaxDistancePerFrameReeling = V{5, 5},
    BorderSpeed = V{14, 14},
    Offset = V{0, 0},

    DampeningDampener = 0,  -- when changing to a new source, we want to slow down the camera first

    -- internal properties
    _super = "Camera",      -- Supertype
    _cache = setmetatable({}, {__mode = "k"}), -- cache has weak keys
    _global = true
}

function GameCamera._globalUpdate(dt)
    for camera in pairs(GameCamera._cache) do
        camera.DampeningDampener = math.lerp(camera.DampeningDampener, 1, 2*dt, 0.01)
        -- print(camera.DampeningDampener)
        if camera.Focus then
            local focus = camera.Focus

            camera.TrackingPosition = camera.TrackingPosition or camera.Position
            
            local dampening, maxDist, minDist, zoomSpeed
            local offsetX, offsetY = 0, 0
            if #camera.Overrides > 0 then -- use the latest override camera option
                local override = camera.Overrides[#camera.Overrides]
                focus = override.Focus or focus
                dampening = V{
                    camera.Reeling.X and (override.DampeningFactorReelingX or override.DampeningFactorX or camera.DampeningFactorReeling.X) or (override.DampeningFactorX  or camera.DampeningFactor.X),
                    camera.Reeling.Y and (override.DampeningFactorReelingY or override.DampeningFactorY or camera.DampeningFactorReeling.Y) or (override.DampeningFactorY  or camera.DampeningFactor.Y),
                }
                maxDist = V{
                    camera.Reeling.X and (override.MaxDistancePerFrameReelingX or override.MaxDistancePerFrameX or camera.MaxDistancePerFrameReeling.X) or (override.MaxDistancePerFrameX or camera.MaxDistancePerFrame.X),
                    camera.Reeling.Y and (override.MaxDistancePerFrameReelingY or override.MaxDistancePerFrameY or camera.MaxDistancePerFrameReeling.Y) or (override.MaxDistancePerFrameY or camera.MaxDistancePerFrame.Y),
                }*60*dt
                minDist = V{
                    camera.Reeling.X and (override.MinDistancePerFrameReelingX or override.MinDistancePerFrameX or camera.MinDistancePerFrameReeling.X) or (override.MinDistancePerFrameX or camera.MinDistancePerFrame.X),
                    camera.Reeling.Y and (override.MinDistancePerFrameReelingY or override.MinDistancePerFrameY or camera.MinDistancePerFrameReeling.Y) or (override.MinDistancePerFrameY or camera.MinDistancePerFrame.Y),
                }*60*dt
                zoomSpeed = override.ZoomSpeed
                offsetX = override.CameraOffsetX or offsetX
                offsetY = override.CameraOffsetY or offsetY
            else -- regular dampening
                dampening = V{
                    camera.Reeling.X and camera.DampeningFactorReeling.X or camera.DampeningFactor.X,
                    camera.Reeling.Y and camera.DampeningFactorReeling.Y or camera.DampeningFactor.Y
                }
                maxDist = V{
                    camera.Reeling.X and camera.MaxDistancePerFrameReeling.X or camera.MaxDistancePerFrame.X,
                    camera.Reeling.Y and camera.MaxDistancePerFrameReeling.Y or camera.MaxDistancePerFrame.Y,
                }*60*dt
                minDist = V{
                    camera.Reeling.X and camera.MinDistancePerFrameReeling.X or camera.MinDistancePerFrame.X,
                    camera.Reeling.Y and camera.MinDistancePerFrameReeling.Y or camera.MinDistancePerFrame.Y
                }*60*dt
                zoomSpeed = camera.ZoomSpeed
            end
            

            local focusPoint
            if focus:IsA("Player") then
                focusPoint = focus:GetPoint(.5,1) + V{offsetX, offsetY}
            else
                focusPoint = focus:GetPoint(.5,.5) + V{offsetX, offsetY}
            end
            
            if focus ~= camera.LastFocus then
                camera.LastFocus = focus
                camera.DampeningDampener = 0
            end
            
            local newPos = V{
                math.lerp(camera.TrackingPosition.X, focusPoint.X, dampening.X*dt*(camera.DampeningDampener^2)),
                math.lerp(camera.TrackingPosition.Y, focusPoint.Y, dampening.Y*dt*camera.DampeningDampener^2),
            }
            local dist = (camera.TrackingPosition - newPos)
            local focusDist = (focusPoint - newPos)

            if math.abs(dist.X) > maxDist.X or math.abs(focusDist.X) > camera.MaxDistanceFromFocus.X then
                newPos.X = camera.TrackingPosition.X - maxDist.X * sign(dist.X)
                camera.Reeling.X = true
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

            local goalZoom
            local fillWithFocus = camera.FillWithFocus or #camera.Overrides>0 and camera.Overrides[#camera.Overrides].Size:Magnitude()>0
            
            local customCameraSize
            local cameraSize = camera.Scene.GameplaySize
            if #camera.Overrides>0 and (camera.Overrides[#camera.Overrides].CameraSizeY or camera.Overrides[#camera.Overrides].CameraSizeX) then
                customCameraSize = V{
                    camera.Overrides[#camera.Overrides].CameraSizeX or camera.Overrides[#camera.Overrides].CameraSizeY * (cameraSize.Y/cameraSize.X),
                    camera.Overrides[#camera.Overrides].CameraSizeY or camera.Overrides[#camera.Overrides].CameraSizeX * (cameraSize.Y/cameraSize.X)
                }
            end
            
            if fillWithFocus or customCameraSize then
                local ratioFocusSize = focus.Size.Y/focus.Size.X
                local screenRatio = cameraSize.Y/cameraSize.X
                if ratioFocusSize < screenRatio then
                    -- use Y
                    goalZoom = cameraSize.X/(customCameraSize and customCameraSize.X or focus.Size.X) --customCameraSize and cameraSize.X/customCameraSize.X or cameraSize.X/focus.Size.X
                else
                    goalZoom = cameraSize.Y/(customCameraSize and customCameraSize.Y or focus.Size.Y)
                end
            else
                goalZoom = cameraSize.Y/camera.DisplayHeight
            end

            camera.Zoom = math.lerp(camera.Zoom, goalZoom, zoomSpeed * dt, 0.0025)
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

    newCamera.Overrides = {}
    newCamera.Reeling = V{false, false}

    GameCamera._cache[newCamera] = true
    return GameCamera:Connect(newCamera)
end


function GameCamera:GetFocus()
    return #self.Overrides > 0 and self.Overrides[#self.Overrides].Focus or self.Focus
end

return GameCamera