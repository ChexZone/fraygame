local Prop = {
    -- properties
    Name = "Prop",

    Size = V{ 16, 16 },     -- created in constructor
    Position = V{ 0, 0 },   -- created in constructor
    Color = V{ 1, 1, 1, 1 },-- created in constructor; values range from 0-1
    AnchorPoint = V{ 0, 0 },-- created in constructor; values range from 0-1
    Rotation = 0,

    Solid = false,          -- is the object collidable?

    Texture = Texture.new("chexcore/assets/images/diamond.png"),    -- default sample texture
    Visible = true,         -- whether or not the Prop's :Draw() method is called

    -- internal properties
    _super = "Object",      -- Supertype
    _global = true
}

-- constructor
local rg, V = rawget, V
function Prop.new(properties)
    local newProp = Prop._standardConstructor(properties)
    
    newProp.Position = rg(newProp, "Position") or V{ Prop.Position.X, Prop.Position.Y }
    newProp.Size = rg(newProp, "Size") or V{ Prop.Size.X, Prop.Size.Y }
    newProp.Color = rg(newProp, "Color") or V{ Prop.Color.X, Prop.Color.Y, Prop.Color.Z, Prop.Color.A }
    newProp.AnchorPoint = rg(newProp, "AnchorPoint") or V{ Prop.AnchorPoint.X, Prop.AnchorPoint.Y }

    return newProp
end

local lg = love.graphics
function Prop:Draw()
    lg.setColor(self.Color)
    self.Texture:DrawToScreen(self.Position[1], self.Position[2], self.Rotation, self.Size[1], self.Size[2], self.AnchorPoint[1], self.AnchorPoint[2])
end

function Prop:Update(dt)
    --print(dt)
end

local sin, cos, abs, max, sqrt = math.sin, math.cos, math.abs, math.max, math.sqrt
-- function Prop:DistanceFromPoint(p)
--     local cx = self.Position[1] + (self.Position[1] * (self.AnchorPoint[1] - 0.5))
--     local cy = self.Position[2] + (self.Position[2] * (self.AnchorPoint[2] - 0.5))
--     local relx, rely = p.X - cx, p.Y - cy
--     local rotx = relx*cos(-self.Rotation) - rely*sin(-self.Rotation)
--     local roty = relx*sin(-self.Rotation) - rely*cos(-self.Rotation)
--     local dx = max(abs(rotx) - self.Size[1] / 2, -99999)
--     local dy = max(abs(roty) - self.Size[2] / 2, -99999)
--     print(dx, dy)
--     return sqrt( dx * dx + dy * dy )
--     --print(self, cx, self.Position.X, cy, self.Position.Y)
--     --local relX, relY = p[1] - adjustedPX, p[2] - adjustedPY
-- end
function Prop:DistanceFromPoint3(p)
    local sx, sy = self.Size[1], self.Size[2]
    local ox = sx * (0.5 - self.AnchorPoint[1])
    local oy = sy * (0.5 - self.AnchorPoint[2])
    local r = -self.Rotation
    local cx, cy = self.Position[1], self.Position[2]
    local rx = ox*cos(r) + oy*sin(r)
    local ry = ox*sin(r) - oy*cos(r)
    local relx = p[1]-rx-cx
    local rely = p[2]+ry-cy
    local rotx = relx*cos(r) - rely*sin(r)
    local roty = relx*sin(r) + rely*cos(r)
    local dx = max(abs(rotx) - sx / 2, 0)
    local dy = max(abs(roty) - sy / 2, 0)
    return sqrt(dx * dx + dy * dy)
end

function Prop:DistanceFromPoint2(p)
    -- if dealing with custom anchors, move to a heavier function
    if self.AnchorPoint[1] ~= 0.5 or self.AnchorPoint[2] ~= 0.5 then return self:DistanceFromPoint3(p) end

    local sx, sy = self.Size[1], self.Size[2]
    local cx = self.Position[1] + sx * (0.5 - self.AnchorPoint[1])
    local cy = self.Position[2] + sy * (0.5 - self.AnchorPoint[2])
    local relx = p[1]-cx
    local rely = p[2]-cy
    local r = -self.Rotation
    local rotx = relx*cos(r) - rely*sin(r)
    local roty = relx*sin(r) + rely*cos(r)
    local dx = max(abs(rotx) - sx / 2, 0)
    local dy = max(abs(roty) - sy / 2, 0)
    return sqrt(dx * dx + dy * dy)
end

function Prop:DistanceFromPoint(p)
    -- if dealing with rotation, move to a heavier function
    if self.Rotation ~= 0 then return self:DistanceFromPoint2(p) end

    local sx, sy = self.Size[1], self.Size[2]
    local cx = self.Position[1] + sx * (0.5 - self.AnchorPoint[1])
    local cy = self.Position[2] + sy * (0.5 - self.AnchorPoint[2])
    local dx = max(abs(p[1] - cx) - sx/2, 0)
    local dy = max(abs(p[2] - cy) - sy/2, 0)
    return sqrt(dx * dx + dy * dy)
end

return Prop