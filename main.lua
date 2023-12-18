require "chexcore"

local ParentCat = Cat.new{Name = "ParentCat"}
ParentCat:Adopt(Cat.new{Name = "ChildCat1", Val = 125})
ParentCat:Adopt(Cat.new{Name = "ChildCat2", SomeThing = true, Val = 75})
ParentCat:Adopt(Cat.new{Name = "ChildCat3", Val = 200})

--print(ParentCat._childHash)

-- ParentCat:GetChild("ChildCat1"):Emancipate()
-- ParentCat:GetChild("ChildCat2"):Emancipate()
-- ParentCat:GetChild("ChildCat3"):Emancipate()

ParentCat:Adopt(Cat.new{Name = "ChildCat4", Val = 100})
ParentCat:Adopt(Cat.new{Name = "ChildCat5", Val = 50})
ParentCat:Adopt(Cat.new{Name = "ChildCat6", Val = 150})


--ParentCat:SwapChildOrder(1, 3)
--ParentCat:Disown(1)
-- ParentCat:Disown(ParentCat:GetChild(1))
-- ParentCat:Disown(3)

-- print(tostring(ParentCat._children, true))
--print(ParentCat:Serialize())


-- for child in ParentCat:EachChild() do
--     print(child.Name, child.Val)
-- end

-- for child in ParentCat:EachChild() do
--     -- children that meet criteria
--     print(child.Name, child.Val)
-- end


local myScene = Scene.new{Name = "Scene1"}
myScene:AddLayer(Layer.new{Canvases = {Canvas.new(320, 180)}})



--Chexcore.MountScene(myScene)
--Chexcore.UnmountScene(myScene)

--myScene:GetLayer(1):Emancipate()

local myVec = V{0, 0, 0}
myVec:Move(1, 2)
print( myVec ) --> V{1, 2, 3}
-- local serial = [[
--     PACKAGE { chexcore/code/misc/example } |
    
--     rootTable, {
--         "example" = @example
--     } |
        
--     ROOT = rootTable
-- ]]

-- local test = deserialize(serial)
-- test.example() --> This is an example function!