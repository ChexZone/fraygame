local Prop = {
    -- properties
    Name = "Prop",

    Size = V{ 16, 16 },     -- created in constructor
    Position = V{ 0, 0 },   -- created in constructor
    Color = V{ 1, 1, 1, 1 },-- created in constructor; values range from 0-1
    AnchorPoint = V{ 0, 0 },-- created in constructor; values range from 0-1
    Rotation = 0,

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


return Prop