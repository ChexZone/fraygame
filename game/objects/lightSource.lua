local LightSource = {
    Name = "LightSource",

    Radius = 2,         -- idk man just feel it out, start at 1
    Sharpness = 1,      -- 1 is fully sharp, 0 is fully blurred

    Color = V{1,1,1,1},   -- 

    _super = "Prop", _global = true
}

function LightSource.new(properties)

    

    local lightSource = Prop.new{
        Solid = false, Visible = true,
        Color = V{1, 1, 1, 1},
        AnchorPoint = V{ 0.5, 0.5 },
        Size = V{0, 0},
        Rotation = 0,
        DrawOverChildren = false,
    }
    lightSource.Color = rawget(lightSource, "Color") or LightSource.Color:Clone()

    setmetatable(lightSource, LightSource)
    return lightSource
end

function LightSource:Update(dt)
    -- update stuff with dt
end

local function isLightOnScreen(camPos, camSize, zoom, radius, light_tl, light_br)
    local hw = camSize[1] / (zoom) / 2
    local hh = camSize[2] / (zoom) / 2
    return not (camPos[1] + hw < light_tl[1] - radius or camPos[1] - hw > light_br[1] + radius or camPos[2] + hh < light_tl[2] - radius or camPos[2] - hh > light_br[2] + radius)
end

function LightSource:Draw(tx, ty)
    -- draw method with tx, ty offsets (draw at position minus tx, ty)
    local layer = self:GetLayer()
    local cam = layer:GetParent().Camera
    local tl, br = self:GetPoint(0,0), self:GetPoint(1,1)
    if isLightOnScreen(cam.Position, layer.Canvases[1]:GetSize(), cam.Zoom, self.Radius, tl, br) then
        self:GetScene():EnqueueLight(self, tl, br)
    end
end

return LightSource