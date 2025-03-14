-- main.lua
local Cube = {
    Name = "Cube",
    
    _super = "Prop", _global = true
}

local ofs = 0
local shaderCode = [[
    extern number uShade;
    
    // Helper function to adjust saturation.
    vec3 adjustSaturation(vec3 col, float saturation) {
        // Compute luminance using standard weights.
        float intensity = dot(col, vec3(0.299, 0.587, 0.114));
        // Mix between grayscale and the original color.
        return mix(vec3(intensity), col, saturation);
    }
    
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        // Always sample the texture for any text/graphics.
        vec4 texColor = Texel(texture, texture_coords);
        
        // Define a border threshold.
        float border = 0.1;
        
        // Calculate a saturation factor: when uShade is lower (darker face), boost saturation.
        float saturationFactor = 1.0 + (1.0 - uShade) * 0.2;
        
        if (texture_coords.x < border || texture_coords.x > 1.0 - border ||
            texture_coords.y < border || texture_coords.y > 1.0 - border ||
            texColor.a > 0.1)
        {
            // Multiply the sampled color by uShade for brightness adjustment.
            vec3 baseColor = texColor.rgb * uShade;
            // Adjust saturation to make colors appear harsher at angles.
            baseColor = adjustSaturation(baseColor, saturationFactor);
            texColor.rgb = baseColor;
            return texColor * color;
        }
        else
        {
            // For the interior, use a flat off‑white yellow and adjust its saturation.
            vec3 flatColor = vec3(1.0 * uShade, 1.0 * uShade, 1.0 * uShade);
            flatColor = adjustSaturation(flatColor, saturationFactor);
            return vec4(flatColor, 1.0) * color;
        }
    }
]]

function Cube.new(letters)
    
    local newCube = Prop.new{
        Name = "Cube",
        
        Position = V{2500,1500},
        AnchorPoint = V{0.5,0.5},
        Size = V{64,64}
    }

    local cubeShader = love.graphics.newShader(shaderCode)
    -- Global settings so they're accessible everywhere
    local s = 50               -- half-size of cube face
    local cameraZ = 300        -- moves the cube in front of the camera
    local d = 300              -- perspective distance
    local roundAmount = 0.8   -- normalized rounding (0 = none, 1 = max)

    local cubeFaces = {}
    local rotX, rotY, rotZ = 0, 0, 0

    -- Rotate a vector by Euler angles (rx, ry, rz)
    local function rotateVec(v, rx, ry, rz)
        local x, y, z = v.x, v.y, v.z
        -- Rotate around x-axis.
        local newY = y * math.cos(rx) - z * math.sin(rx)
        local newZ = y * math.sin(rx) + z * math.cos(rx)
        y, z = newY, newZ
        -- Rotate around y-axis.
        local newX = x * math.cos(ry) + z * math.sin(ry)
        newZ = -x * math.sin(ry) + z * math.cos(ry)
        x, z = newX, newZ
        -- Rotate around z-axis.
        newX = x * math.cos(rz) - y * math.sin(rz)
        newY = x * math.sin(rz) + y * math.cos(rz)
        return { x = newX, y = newY, z = z }
    end

    -- Simple perspective projection (assumes z > 0)
    local function project(v, w, h)
        local factor = d / v.z
        local x2d = v.x * factor + (w or love.graphics.getWidth()) / 2
        local y2d = v.y * factor + (h or love.graphics.getHeight()) / 2
        return x2d, y2d
    end


    -- Create a canvas for a cube face:
    -- an off‑white yellow background with a rounded border and a bold letter "A".
    -- Update the createFaceCanvas function to make the letter A larger and bolder
    local i = 0
    local function createFaceCanvas()
        i = i + 1
        local canvas = love.graphics.newCanvas(100, 100)
        love.graphics.setCanvas(canvas)
        love.graphics.clear(1,1,1,1)  -- Off-white yellow background
        
        -- -- Draw the border
        -- love.graphics.setColor({0.35, 0.35, 0.9 * 0.35, 1})
        -- love.graphics.setLineWidth(3)
        -- love.graphics.rectangle("line", 5, 5, 90, 90, 50, 50)
        
        -- Create a larger, bolder font for the letter A
        local font = love.graphics.newFont("chexcore/assets/fonts/futura.ttf", 72, "normal")  -- Increase size and use bold if available
        love.graphics.setFont(font)
        
        -- Center the A vertically and horizontally
        love.graphics.setColor({0.35, 0.35, 0.9 * 0.35, 1})  -- Black text

        love.graphics.printf((letters or {"A","B","C","D","E","F","G"})[i], 0, 7, 100, "center")  -- Adjusted vertical position
        
        love.graphics.setCanvas()
        return canvas
    end

    --------------------------------------------------------------------------------
    -- Rounding helper:
    local function roundCorner(u, v, r)
        local absU = math.abs(u)
        local absV = math.abs(v)
        if absU > 1 - r and absV > 1 - r then
            local signU = u >= 0 and 1 or -1
            local signV = v >= 0 and 1 or -1
            local du = absU - (1 - r)
            local dv = absV - (1 - r)
            local dist = math.sqrt(du * du + dv * dv)
            if dist > r then
                local scale = r / dist
                du = du * scale
                dv = dv * scale
            end
            u = (1 - r + du) * signU
            v = (1 - r + dv) * signV
        end
        return u, v
    end

    --------------------------------------------------------------------------------
    -- Generate a subdivided and rounded face mesh.
    local function generateRoundedFaceMesh(face, resolution, roundAmount)
        local vertices = {}
        local indices = {}
        local v1 = face.vertices[1]
        local v2 = face.vertices[2]
        local v4 = face.vertices[4]
        local edge1 = { x = v2.x - v1.x, y = v2.y - v1.y, z = v2.z - v1.z }
        local edge2 = { x = v4.x - v1.x, y = v4.y - v1.y, z = v4.z - v1.z }
        
        for j = 0, resolution do
            local v_norm = j / resolution * 2 - 1
            for i = 0, resolution do
                local u_norm = i / resolution * 2 - 1
                local ru, rv = roundCorner(u_norm, v_norm, roundAmount)
                local fu = (ru + 1) / 2
                local fv = (rv + 1) / 2
                local pos = {
                    x = v1.x + edge1.x * fu + edge2.x * fv,
                    y = v1.y + edge1.y * fu + edge2.y * fv,
                    z = v1.z + edge1.z * fu + edge2.z * fv,
                }
                table.insert(vertices, { pos.x, pos.y, pos.z, i / resolution, j / resolution })
            end
        end
        
        for j = 0, resolution - 1 do
            for i = 0, resolution - 1 do
                local index = j * (resolution + 1) + i + 1
                local indexRight = index + 1
                local indexBelow = index + (resolution + 1)
                local indexBelowRight = indexBelow + 1
                table.insert(indices, index)
                table.insert(indices, indexBelow)
                table.insert(indices, indexRight)
                
                table.insert(indices, indexRight)
                table.insert(indices, indexBelow)
                table.insert(indices, indexBelowRight)
            end
        end
        return vertices, indices
    end

    local resolution = 10  -- subdivisions per face

    -- Define cube faces with 4 corners and a face normal.
    cubeFaces = {
        { name = "front", vertices = { {x=-s, y=-s, z=s}, {x=-s, y=s, z=s}, {x=s, y=s, z=s}, {x=s, y=-s, z=s} }, normal = {x=0, y=0, z=1} },
        { name = "back",  vertices = { {x=s, y=-s, z=-s}, {x=s, y=s, z=-s}, {x=-s, y=s, z=-s}, {x=-s, y=-s, z=-s} }, normal = {x=0, y=0, z=-1} },
        { name = "left",  vertices = { {x=-s, y=-s, z=-s}, {x=-s, y=s, z=-s}, {x=-s, y=s, z=s}, {x=-s, y=-s, z=s} }, normal = {x=-1, y=0, z=0} },
        { name = "right", vertices = { {x=s, y=-s, z=s}, {x=s, y=s, z=s}, {x=s, y=s, z=-s}, {x=s, y=-s, z=-s} }, normal = {x=1, y=0, z=0} },
        { name = "top",   vertices = { {x=-s, y=-s, z=-s}, {x=-s, y=-s, z=s}, {x=s, y=-s, z=s}, {x=s, y=-s, z=-s} }, normal = {x=0, y=-1, z=0} },
        { name = "bottom",vertices = { {x=-s, y=s, z=s}, {x=-s, y=s, z=-s}, {x=s, y=s, z=-s}, {x=s, y=s, z=s} }, normal = {x=0, y=1, z=0} },
    }
    
    -- For each face, create its texture and rounded mesh.
    for _, face in ipairs(cubeFaces) do
        face.canvas = createFaceCanvas()
        face.baseVertices, face.indices = generateRoundedFaceMesh(face, resolution, roundAmount)
    end

    ofs = ofs + 1
    newCube.Offset = ofs

    function newCube:Update(dt)
        -- rotZ = math.rad(90)
        -- -- rotY = math.rad(0)
        -- rotX = math.rad(180)
        -- -- rotZ = (rotZ or 0) + dt * 0.8
        -- rotY = (rotY or 0) + dt * 0.8
        -- -- rotX = (rotX or 0) + dt * 0.8
        -- rotY = (math.sin(love.timer.getTime()*3))/2
        -- rotX = math.rad(180) + (math.sin(love.timer.getTime()*6))/4

        -- self.Size = V{
        --     64 + math.sin(Chexcore._clock*6)*20,
        --     64 + math.sin(Chexcore._clock*6)*20,
        -- }

        if self.Name ~= "Tracking" then
            self.Lifetime = self.Lifetime or 0
            self.Position = V{2500,1500} + V{
                60 * math.cos(self.Lifetime + 2*math.pi*self.Offset/10),
                60 * math.sin(self.Lifetime + 2*math.pi*self.Offset/10)
            }
            if _G.bigCube.Scared then
                self.Lifetime = self.Lifetime - dt*0.7
            end
            self.Lifetime = self.Lifetime + dt
        end
        self.Size = V{32 + math.sin(Chexcore._clock*3 + self.Offset*2)*6, 32 + math.sin(Chexcore._clock*3 + self.Offset*2)*6}

        -- self.Color = HSV{
        --     (newCube.Offset/10 + Chexcore._clock/2)%1, 0.5, 1
        -- }
        -- roundAmount = math.sin(love.timer.getTime() * 2) * 0.5 + 0.5
    end
    local sin, cos, abs, max, sqrt, floor = math.sin, math.cos, math.abs, math.max, math.sqrt, math.floor
    local lg = love.graphics

    newCube.Texture = Canvas.new(160,160)
    newCube.Canvas2 = Canvas.new(160,160)
    newCube.DrawInForeground = true
    function newCube:Draw(tx, ty, isForeground)
    
        -- if self.DrawInForeground and not isForeground then
        --     print(self)
        --     self:GetLayer():DelayDrawCall(Prop.Draw, self, tx, ty, true)
        --     return 
        -- end

        self.Canvas2:Activate()
        
        love.graphics.clear(0.2, 0.2, 0.2, 0) -- Clear with dark background

        -- Draw a big center circle to cover any remaining pixels inside the cube.
        local backColor = {0.65, 0.65, 0.65, 1}  -- Same color as used for backfaces and corner circles.
        local center3d = { x = 0, y = 0, z = 0 }         -- Cube center in model coordinates.
        local rotatedCenter = rotateVec(center3d, rotX, rotY, rotZ)
        rotatedCenter.z = rotatedCenter.z + cameraZ       -- Translate center into view space.
        local centerX, centerY = project(rotatedCenter, 160, 160)     -- Get screen coordinates.
        
        -- Choose a local radius that covers the interior gap.
        -- (Adjust the multiplier as needed. Here we use 's' (half the cube’s face size).)
        local centerLocalRadius = s
        local factor = d / rotatedCenter.z                -- Perspective scaling factor.
        local centerScreenRadius = centerLocalRadius * factor
        
        love.graphics.setColor(self.BackColor or backColor)
        love.graphics.circle("fill", centerX, centerY, centerScreenRadius)


        -- ... now proceed with your existing code that builds and draws the cube faces and corner circles:
    local allRenderables = {}
    
    -- Process each cube face with robust orientation testing.
    for i, face in ipairs(cubeFaces) do
        local transformedVerts = {}
        local totalZ = 0
        local count = 0

        -- Rotate the face normal.
        local rotatedNormal = rotateVec(face.normal, rotX, rotY, rotZ)
        
        -- Compute face center.
        local center = { x = 0, y = 0, z = 0 }
        for j, v in ipairs(face.vertices) do
            center.x = center.x + v.x
            center.y = center.y + v.y
            center.z = center.z + v.z
        end
        center.x = center.x / #face.vertices
        center.y = center.y / #face.vertices
        center.z = center.z / #face.vertices
        
        -- Rotate and translate the face center.
        local rotatedCenter = rotateVec(center, rotX, rotY, rotZ)
        rotatedCenter.z = rotatedCenter.z + cameraZ

        -- Use dot product between the rotated normal and the rotated center.
        local dotProduct = rotatedNormal.x * rotatedCenter.x +
                           rotatedNormal.y * rotatedCenter.y +
                           rotatedNormal.z * rotatedCenter.z
        local isBackFace = (dotProduct > 0)

        for _, vertex in ipairs(face.baseVertices) do
            local pos = { x = vertex[1], y = vertex[2], z = vertex[3] }
            local tpos = rotateVec(pos, rotX, rotY, rotZ)
            tpos.z = tpos.z + cameraZ
            
            -- If any vertex is behind the camera, force back-face rendering.
            if tpos.z <= 0 then
                isBackFace = true
                break
            end
            
            totalZ = totalZ + tpos.z
            count = count + 1
            
            local x2d, y2d = project(tpos, 160, 160)
            table.insert(transformedVerts, { x2d, y2d, vertex[4], vertex[5] })
        end
        
        if count == 0 then
            goto continue
        end
        
        local avgZ = totalZ / count
        local shade = 0.25 + 0.75 * math.max(-rotatedNormal.z, 0)
        
        table.insert(allRenderables, {
            type = "face",
            meshVerts = transformedVerts,
            z = avgZ,
            canvas = face.canvas,
            shade = shade,
            indices = face.indices,
            isBack = isBackFace,
            priority = isBackFace and 1 or 3
        })
        ::continue::
    end

    -- Re-introduce circles for the cube corners.
    local localRadius = s * roundAmount * (1 - 1/math.sqrt(2)) * 1.4
    local insetFactor = 1.65  -- Factor to control how far inward the circle center moves.
    local uniqueCorners = {
        {x=-s, y=-s, z=s},   -- Front-left-top
        {x=-s, y=s,  z=s},   -- Front-left-bottom
        {x=s,  y=s,  z=s},   -- Front-right-bottom
        {x=s,  y=-s, z=s},   -- Front-right-top
        {x=s,  y=-s, z=-s},  -- Back-right-top
        {x=s,  y=s,  z=-s},  -- Back-right-bottom
        {x=-s, y=s,  z=-s},  -- Back-left-bottom
        {x=-s, y=-s, z=-s},  -- Back-left-top
    }
    
    for i, corner in ipairs(uniqueCorners) do
        local len = math.sqrt(corner.x^2 + corner.y^2 + corner.z^2)
        local insetDistance = localRadius * insetFactor
        local circleCenter = {
            x = corner.x - (corner.x / len) * insetDistance,
            y = corner.y - (corner.y / len) * insetDistance,
            z = corner.z - (corner.z / len) * insetDistance,
        }
        
        local pos3d = rotateVec(circleCenter, rotX, rotY, rotZ)
        pos3d.z = pos3d.z + cameraZ
        
        if pos3d.z <= 0 then
            goto nextCorner
        end
        
        local x2d, y2d = project(pos3d, 160, 160)
        local factor = d / pos3d.z
        local screenRadius = localRadius * factor
        
        table.insert(allRenderables, {
            type = "circle",
            x = x2d,
            y = y2d,
            z = pos3d.z,
            radius = screenRadius,
            pos3d = pos3d,
            priority = 0  -- Fixed low priority so circles always render behind faces.
        })
        ::nextCorner::
    end

    -- Sort renderables: lower priority first (drawn first) and then by depth.
    table.sort(allRenderables, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return a.z > b.z
    end)


    -- Draw each renderable.
    -- table.reverse(allRenderables)
    for _, item in ipairs(allRenderables) do
        if item.type == "face" then
            local mesh = love.graphics.newMesh(item.meshVerts, "triangles")
            mesh:setVertexMap(item.indices)
            if item.isBack then
                -- Back faces: draw with the constant backColor.
                love.graphics.setShader()
                mesh:setTexture(nil)
                love.graphics.setColor(self.BackColor or self.Color - V{0.3,0.3,0.3,0})
                love.graphics.draw(mesh)
            else
                -- Front faces: render with texture and shader.
                love.graphics.setShader(cubeShader)
                cubeShader:send("uShade", item.shade)
                mesh:setTexture(item.canvas)
                love.graphics.setColor(self.Color)
                love.graphics.draw(mesh)
            end
        elseif item.type == "circle" then
            -- Circles: use the same constant backColor.
            love.graphics.setShader()
            love.graphics.setColor(self.BackColor or self.Color - V{0.3,0.3,0.3,0})
            love.graphics.circle("fill", item.x, item.y, item.radius)
        end
    end

    love.graphics.setShader()


        self.Canvas2:Deactivate()

        self.Texture:Activate()
        love.graphics.clear()
        if self.Shader then self.Shader:Activate() end
        
        self.Canvas2:DrawToScreen(160/2,160/2,
        0,
        160,
        160,
        0.5,0.5)

        if self.Shader then self.Shader:Deactivate() end
        self.Texture:Deactivate()

        


        if self.Name == "Track" then
            self.GoalRot = V{
                math.rad(-82) -(floor(self.Position[1] + self:GetLayer():GetParent().Camera.Position[1])/250*1.5),
                math.rad(-35) + (floor(self.Position[2] + self:GetLayer():GetParent().Camera.Position[2])/200*1.5),
                math.rad(270)
            }

            if self.Scared then

    
                self.GoalRot[2] = self.GoalRot[2] + math.rad(180)
            else
                self.GoalRot = V{
                    math.rad(-110) - (floor(self.Position[2] + self:GetLayer():GetParent().Camera.Position[2])/225*1.5),
                    math.rad(-285) + (floor(self.Position[1] + self:GetLayer():GetParent().Camera.Position[1])/315*1.5),
                    math.rad(270)
                }
                self.GoalRot[3] = self.GoalRot[3] - math.rad(90)
            end

            -- print(floor(self.Position[1] - self:GetLayer():GetParent().Camera.Position[1]))
            rotX = math.lerp(rotX, self.GoalRot.X, 0.2) --(floor(self.Position[1] - self:GetLayer():GetParent().Camera.Position[1])/300*1.5)
            rotY = math.lerp(rotY, self.GoalRot.Y, 0.2)
            rotZ = math.lerp(rotZ, self.GoalRot.Z, 0.2)
            

            
            -- rotY = 
        else
            rotX = self.Offset + Chexcore._clock
            rotY = self.Offset + Chexcore._clock
        end

        -- rotZ = math.rad(270)

        local oldshader
        if self.Shader then
            self.Shader:Activate()
        end
        if self.DrawOverChildren and self:HasChildren() then
            self:DrawChildren(tx, ty)
        end
        lg.setColor(1,1,1,1)
        local sx = self.Size[1] * (self.DrawScale[1]-1)
        local sy = self.Size[2] * (self.DrawScale[2]-1)
        self.Texture:DrawToScreen(
            floor(self.Position[1] - tx),
            floor(self.Position[2] - ty),
            self.Rotation,
            self.Size[1] + sx,
            self.Size[2] + sy,
            self.AnchorPoint[1],
            self.AnchorPoint[2]
        )
        if not self.DrawOverChildren and self:HasChildren() then
            self:DrawChildren(tx, ty)
        end
    
        if self.Shader then
            self.Shader:Deactivate()
        end
    end

    return newCube
end


-- Modified shader: inner parts (based on UV) render flat off‑white yellow.
-- Modified to ensure opacity remains constant while only brightness changes





--------------------------------------------------------------------------------

function love.draw2()
    
    
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Rounded Cube Demo – Subdivided Mesh with Rounded Corners", 10, 10)
end

return Cube