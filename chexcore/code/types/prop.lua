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
function Prop:DistanceFromPoint(p)
    -- local cPos = self.Position - (self.Position * (self.AnchorPoint - 0.5))
    -- local dist = ((p - cPos):Filter(abs) - self.Size/2):Filter(max, 0):Magnitude()
    -- return dist

    local cx = self.Position[1] - (self.Position[1] * (self.AnchorPoint[1] - 0.5))
    local cy = self.Position[2] - (self.Position[2] * (self.AnchorPoint[2] - 0.5))
    local dx = max(abs(p[1] - cx) - self.Size[1]/2, 0)
    local dy = max(abs(p[2] - cy) - self.Size[2]/2, 0)

    return sqrt(dx * dx + dy * dy)

    --local offset = (p - cPos):Filter(abs) - self.Size

    -- local trueDist = (self.Position - p):Magnitude()
    

    -- local dx = max(abs(p.X - cPos.X) - self.Size.X/2, 0)
    -- local dy = max(abs(p.Y - cPos.Y) - self.Size.Y/2, 0)
    -- local dist = sqrt(dx * dx + dy * dy)

    -- print(dist)

    -- rotated rectangles:
    -- local relx = p.X - cPos.X
    -- local rely = p.Y - cPos.Y
    -- local rotx = relx * cos(-self.Rotation) - rely * sin(-self.Rotation)
    -- local roty = rely * sin(-self.Rotation) - rely * cos(-self.Rotation)

    -- local dx = max(abs(rotx) - self.Size.X/2, 0)
    -- local dy = max(abs(roty) - self.Size.Y/2, 0)
    -- local dist = sqrt(dx * dx + dy * dy)
    --local betterDist = ((p - cPos):Filter(abs) - self.Size/2):Filter(max, 0):Magnitude()

    --print(dx, dy)
    --local dist = offset:Filter(max, 0):Magnitude()
    
end

return Prop