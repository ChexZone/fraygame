require "chexcore"

-- some of the constructors are still somewhat manual but they'll get cleaned up !

-- Scenes contain all the components of the game
local scene = Scene.new{ MasterCanvas = Canvas.new(1920, 1080) }

-- Scenes have a list of Layers, which each hold their own Props
scene:AddLayer(Layer.new{
    Name = "Gameplay",
    Canvases = { Canvas.new(320, 180) }     -- pixel gameplay layer @ 320x180p
})

scene:AddLayer(Layer.new{
    Name = "GUI",
    Canvases = { Canvas.new(1920, 1080) }  -- hd gui layer @ 1920x1080p
})

-- test collidable
scene:GetLayer("Gameplay"):Adopt(Prop.new{
    Name = "Crate",
    Position = V{ 320, 180 } / 2,   -- V stands for Vector
    Size = V{ 64, 64 },
    AnchorPoint = V{ 0.5, 0.5 },
    Solid = true,
    Texture = Texture.new("chexcore/assets/images/crate.png")
})

for i = 1, 500 do
scene:GetLayer("Gameplay"):Adopt(Prop.new{
    Name = "Crate2",
    Position = V{ 320 / 8, 180 } / 2*(math.random() * 50) + V{250, 0},   -- V stands for Vector
    Size = V{ 64, 64 },
    AnchorPoint = V{ 0.5, 0.5 },
    Solid = true,
    Texture = Texture.new("chexcore/assets/images/crate.png")
})
end

-- ray origin
scene:GetLayer("Gameplay"):Adopt(Prop.new{
    Name = "RayOrigin",
    Position = scene:GetLayer("Gameplay"):GetChild("Crate").Position - V{64, 64},
    Size = V{ 8, 8 },
    AnchorPoint = V{ 0.5, 0.5 },
    Rotation = math.rad(0),
    Texture = Texture.new("chexcore/assets/images/arrow-right.png")
})

scene:GetLayer("Gameplay"):GetChild("RayOrigin").Draw = function(self)
    love.graphics.setColor(self.Color)
    --self.Texture:DrawToScreen(self.Position[1], self.Position[2], self.Rotation, self.Size[1], self.Size[2], self.AnchorPoint[1], self.AnchorPoint[2])
    for i = 1, 150 do
        local testRay = Ray.new(self.Position + V{0, Chexcore._clock*5 - 10}, Chexcore._clock/4 * i, 500)
        testRay:Draw(scene:GetLayer("Gameplay"))
        --local _, hitPos = testRay:Hits(scene:GetLayer("Gameplay"))
        --print(hitPos)

    end
    --self._parent._children[1].Rotation = self._parent._children[1].Rotation + 0.001
end

-- mounting a Scene makes it automatically update/draw
Chexcore.MountScene(scene)

function love.update(dt)
    Chexcore.Update(dt)
    print(1/dt)
    local p = scene:GetLayer("Gameplay"):GetChild("Crate")   -- easy to navigate hierarchy
    --p.Rotation = p.Rotation + 0.01  -- slowly rotate,,
end


-- local ParentCat = Cat.new{Name = "ParentCat"}
-- ParentCat:Adopt(Cat.new{Name = "ChildCat1", Val = 125})
-- ParentCat:Adopt(Cat.new{Name = "ChildCat2", SomeThing = true, Val = 75})
-- ParentCat:Adopt(Cat.new{Name = "ChildCat3", Val = 200})

-- print(ParentCat._childHash)

-- ParentCat:GetChild("ChildCat1"):Emancipate()
-- ParentCat:GetChild("ChildCat2"):Emancipate()
-- ParentCat:GetChild("ChildCat3"):Emancipate()

-- ParentCat:Adopt(Cat.new{Name = "ChildCat4", Val = 100})
-- ParentCat:Adopt(Cat.new{Name = "ChildCat5", Val = 50})
-- ParentCat:Adopt(Cat.new{Name = "ChildCat6", Val = 150})


-- ParentCat:SwapChildOrder(1, 3)
-- ParentCat:Disown(1)
-- ParentCat:Disown(ParentCat:GetChild(1))
-- ParentCat:Disown(3)

-- print(tostring(ParentCat._children, true))
-- print(ParentCat:Serialize())

-- for child in ParentCat:EachChild() do
--     print(child.Name, child.Val)
-- end

-- for child in ParentCat:EachChild() do
--     -- children that meet criteria
--     print(child.Name, child.Val)
-- end

--[[
local myScene = Scene.new{MasterCanvas = Canvas.new(1920,1080)}
myScene:AddLayer(Layer.new{Canvases = {Canvas.new(320*2, 180*2)}, Name = "Layer1"})
myScene:AddLayer(Layer.new{Canvases = {Canvas.new(1920, 1080)}, Name = "Layer2"})

Chexcore.MountScene(myScene)

local testProp = Prop.new{Size = V{64, 64}, AnchorPoint = V{0.5, 0.5}}

myScene:GetLayer(1):Adopt(testProp)


print(testProp.Texture:GetSize())


-- testing
function love.update(dt)
    Chexcore.Update(dt)
    
    V{math.random(255), math.random(255), math.random(255), math.random(255) ,math.random(255)}
    --print(gcinfo())

    local vec1 = V{ N{1}, N{2} }
    local vec2 = V{ 3, 4 }
    
    testProp.Position = testProp.Position + V{ 0.05, 0.055 }
    testProp.Rotation = testProp.Rotation + 0.01
    --print(vec1 + vec2) --> V{N{4}, N{6}}
    print(#myScene._children)
end

function love.draw()
    Chexcore.Draw()
    
end
]]

--print( vec1 + vec2 ) --> V{ N{2}, N{4}, N{6} } 

--print(N{-5.4} - N{-5.5})

-- local specialNum = N{5.5}
-- local realNum = 5.5
-- print( specialNum == realNum ) --> false; can't do this!!
-- print( specialNum() == realNum) --> true

-- Chexcore.UnmountScene(myScene)

-- myScene:GetLayer(1):Emancipate()

-- local parent = Vector.new{Name="Parent", 1, 2, 3}
-- local child = Vector.new{}
-- parent:Adopt(child) -- parent is now the parent of child
-- local child2 = child:Clone()
-- print(child == child2) -- false; different Objects
-- print(child2:GetParent()) -- nil; parent was not preserved
-- local child3 = child:Clone(true)
-- print(child3:GetParent()) -- [Object] Parent

-- local myCanvas = Canvas.new()
-- myCanvas:SetSize(500, 500)




-- local myVec = V{0, 0, 0}
-- local myVec2 = myVec:Clone(true)
-- myVec:Adopt(myVec2)
-- print( #myVec:Clone():GetChildren() ) --> V{1, 2, 3}
-- local serial = [[
--     PACKAGE { chexcore/code/misc/example } |
    
--     rootTable, {
--         "example" = @example
--     } |
        
--     ROOT = rootTable
-- ]]

-- local test = deserialize(serial)
-- test.example() --> This is an example function!