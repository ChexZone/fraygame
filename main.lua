require "chexcore"

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


local myScene = Scene.new{Name = "Scene1"}
myScene:AddLayer(Layer.new{Canvases = {Canvas.new(320, 180)}})
Chexcore.MountScene(myScene)



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

local myCanvas = Canvas.new()
myCanvas:SetSize(500, 500)

print( V{1, 2, 3} )

print( V{1, 2, 3}() ) -- call() the Vector to unpack values


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