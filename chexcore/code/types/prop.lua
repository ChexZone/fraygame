local Prop = {
    -- properties
    Name = "Prop",

    Size = V{ 16, 16 },     -- created in constructor
    Position = V{ 0, 0 },   -- created in constructor
    Color = V{ 1, 1, 1, 1 },-- created in constructor; values range from 0-1
    AnchorPoint = V{ 0, 0 },-- created in constructor; values range from 0-1
    Rotation = 0,
    DrawScale = 1,          -- only works with AnchorPoint = V{0, 0}

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
    local sx = self.Size[1] * (self.DrawScale-1)
    local sy = self.Size[2] * (self.DrawScale-1)
    
    self.Texture:DrawToScreen(
        self.Position[1] - sx/2,
        self.Position[2] - sy/2,
        self.Rotation,
        self.Size[1] + sx,
        self.Size[2] + sy,
        self.AnchorPoint[1],
        self.AnchorPoint[2]
    )
end

function Prop:Update(dt)
    --print(dt)
end

function Prop:GetLeftEdge()
    return self.Position[1] - self.Size[1] * self.AnchorPoint[1]
end

function Prop:GetRightEdge()
    return self.Position[1] + self.Size[1] * (1 - self.AnchorPoint[1])
end

function Prop:GetTopEdge()
    return self.Position[2] - self.Size[2] * self.AnchorPoint[2]
end

function Prop:GetBottomEdge()
    return self.Position[2] + self.Size[2] * (1 - self.AnchorPoint[2])
end

function Prop:SetLeftEdge(y)
    self.Position[1] = y + self.Size[1] * self.AnchorPoint[1]
end

function Prop:SetRightEdge(y)
    self.Position[1] = y - self.Size[1] * (1 - self.AnchorPoint[1])
end

function Prop:SetTopEdge(y)
    self.Position[2] = y + self.Size[2] * self.AnchorPoint[2]
end

function Prop:SetBottomEdge(y)
    self.Position[2] = y - self.Size[2] * (1 - self.AnchorPoint[2])
end
-- only works with axis-aligned bounding boxes !! i dont feel like doing all that math
-- use Rays for weird rotatey collision idk
function Prop:CollidesAABB(other)
    local sp, op = self.Position, other.Position
    local sap, oap = self.AnchorPoint, other.AnchorPoint
    local ss, os = self.Size, other.Size
    local sLeftEdge  = sp[1] - ss[1] * sap[1]
    local sRightEdge = sp[1] + ss[1] * (1 - sap[1])
    local sTopEdge  = sp[2] - ss[2] * sap[2]
    local sBottomEdge = sp[2] + ss[2] * (1 - sap[2])
    local oLeftEdge  = op[1] - os[1] * oap[1]
    local oRightEdge = op[1] + os[1] * (1 - oap[1])
    local oTopEdge  = op[2] - os[2] * oap[2]
    local oBottomEdge = op[2] + os[2] * (1 - oap[2])
    
    local hitLeft  = sRightEdge >= oLeftEdge
    local hitRight = sLeftEdge <= oRightEdge
    local hitTop   = sBottomEdge >= oTopEdge
    local hitBottom = sTopEdge <= oBottomEdge

    local hIntersect = hitLeft and hitRight
    local vIntersect = hitTop and hitBottom

    return hIntersect and vIntersect
end


-- this function is more expensive but also returns direction info
local function collisionInfo(self, other)
    local sp, op = self.Position, other.Position
    local sap, oap = self.AnchorPoint, other.AnchorPoint
    local ss, os = self.Size, other.Size
    local sLeftEdge  = sp[1] - ss[1] * sap[1]
    local sRightEdge = sp[1] + ss[1] * (1 - sap[1])
    local sTopEdge  = sp[2] - ss[2] * sap[2]
    local sBottomEdge = sp[2] + ss[2] * (1 - sap[2])
    local oLeftEdge  = op[1] - os[1] * oap[1]
    local oRightEdge = op[1] + os[1] * (1 - oap[1])
    local oTopEdge  = op[2] - os[2] * oap[2]
    local oBottomEdge = op[2] + os[2] * (1 - oap[2])
    
    local hitLeft  = sRightEdge >= oLeftEdge
    local hitRight = sLeftEdge <= oRightEdge
    local hitTop   = sBottomEdge >= oTopEdge
    local hitBottom = sTopEdge <= oBottomEdge

    local hIntersect = hitLeft and hitRight
    local vIntersect = hitTop and hitBottom

    local res = hIntersect and vIntersect

    if res then
        local hDir = (sLeftEdge >= oLeftEdge and sRightEdge <= oRightEdge) and 0 or
                             sLeftEdge >= oLeftEdge and (sLeftEdge - oRightEdge) or
                             sRightEdge <= oRightEdge and (sRightEdge - oLeftEdge) or false
        local vDir = (sTopEdge >= oTopEdge and sBottomEdge <= oBottomEdge) and 0 or
                             sTopEdge >= oTopEdge and (sTopEdge - oBottomEdge) or
                             sBottomEdge <= oBottomEdge and (sBottomEdge - oTopEdge) or false
        -- local vDir = not (sTopEdge < oTopEdge or sBottomEdge > oBottomEdge) and true or
        --                      sTopEdge >= oTopEdge and (sTopEdge - oBottomEdge) or
        --                      sBottomEdge <= oBottomEdge and (sBottomEdge - oTopEdge) or 0
        -- local vDir = not (sTopEdge < oTopEdge or sBottomEdge > oBottomEdge) and "outside" or
        --                      sTopEdge >= oTopEdge and "top" or
        --                      sBottomEdge <= oBottomEdge and "bottom" or "inside"


        return true, hDir, vDir
    end

    return false
end

function Prop.GetHitFaces(hDist, vDist, usingItWrong)
    if usingItWrong then
        hDist, vDist = vDist, usingItWrong
    end

    return not hDist and "outside" or hDist > 0 and "left" or hDist < 0 and "right" or "inside",
           not vDist and "inside" or vDist > 0 and "top" or vDist < 0 and "bottom" or "inside"
end

function Prop:CollisionPass(container)
    
    local nsf = function(c) return c ~= self end
    container = not container and self._parent:GetChildren(nsf) or container._type
        and (self._parent == container and container:GetChildren(nsf) or container:GetChildren())
        or container

    local i = 1
    return function ()
        local hit, hDir, vDir
        if not container[i] then return nil end

        repeat
            hit, hDir, vDir = collisionInfo(self, container[i])
            i = i + 1
        until not container[i] or hit

        if hit then
            return container[i-1], hDir, vDir
        else
            return nil
        end
    end
end



function Prop:GetTouching(container)
    -- container is either the children of the input Object, or the input list directly, or the child's parent by default
    local nsf = function(c) return c ~= self end
    container = not container and self._parent._children or container._type and container._children or container
    
    local touchList = {}
    for _, item in ipairs(container) do
        if item.Solid and item ~= self and self:CollidesAABB(item) then
            touchList[#touchList+1] = item
        end
    end

    return touchList
end

local sin, cos, abs, max, sqrt = math.sin, math.cos, math.abs, math.max, math.sqrt
-- -- expanded version
-- function Prop:DistanceFromPoint3(p)
--     local sx, sy = self.Size[1], self.Size[2]
--     local ox = sx * (0.5 - self.AnchorPoint[1])
--     local oy = sy * (0.5 - self.AnchorPoint[2])
--     local r = -self.Rotation
--     local rx = ox*cos(r) + oy*sin(r)
--     local ry = ox*sin(r) - oy*cos(r)
--     local relx = p[1]-rx-self.Position[1]
--     local rely = p[2]+ry-self.Position[2]
--     local rotx = relx*cos(r) - rely*sin(r)
--     local roty = relx*sin(r) + rely*cos(r)
--     local dx = max(abs(rotx) - sx / 2, 0)
--     local dy = max(abs(roty) - sy / 2, 0)
--     return sqrt(dx * dx + dy * dy)
-- end

-- shortened version
function Prop:DistanceFromPoint3(p)
    local sx, sy = self.Size[1], self.Size[2]
    local ox = sx * ( self.AnchorPoint[1] <= 1 and (0.5 - self.AnchorPoint[1]) or (self.AnchorPoint[1] - 1) )
    local oy = sy * ( self.AnchorPoint[2] <= 1 and (0.5 - self.AnchorPoint[2]) or (self.AnchorPoint[2] - 1) )
    local r = -self.Rotation
    local relx = p[1]-(ox*cos(r) + oy*sin(r))-self.Position[1]
    local rely = p[2]+(ox*sin(r) - oy*cos(r))-self.Position[2]
    local dx = max(abs(relx*cos(r) - rely*sin(r)) - sx / 2, 0)
    local dy = max(abs(relx*sin(r) + rely*cos(r)) - sy / 2, 0)
    return sqrt(dx * dx + dy * dy)
end

function Prop:DistanceFromPoint2(p)
    -- if dealing with custom anchors, move to a heavier function
    if self.AnchorPoint[1] ~= 0.5 or self.AnchorPoint[2] ~= 0.5 then return self:DistanceFromPoint3(p) end

    local sx, sy = self.Size[1], self.Size[2]
    local cx = self.Position[1]
    local cy = self.Position[2]
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