require "chexcore"

local ParentCat = Cat.new{Name = "ParentCat"}
ParentCat:Adopt(Cat.new{Name = "ChildCat1", Val = 125})
ParentCat:Adopt(Cat.new{Name = "ChildCat2", SomeThing = true, Val = 75})
ParentCat:Adopt(Cat.new{Name = "ChildCat3", Val = 200})

--print(ParentCat._childHash)

-- ParentCat:GetChild("ChildCat1"):RemoveParent()
-- ParentCat:GetChild("ChildCat2"):RemoveParent()
-- ParentCat:GetChild("ChildCat3"):RemoveParent()

ParentCat:Adopt(Cat.new{Name = "ChildCat4", Val = 100})
ParentCat:Adopt(Cat.new{Name = "ChildCat5", Val = 50})
ParentCat:Adopt(Cat.new{Name = "ChildCat6", Val = 150})



--print(ParentCat:Serialize())


-- for child in ParentCat:EachChild() do
--     print(child.Name, child.Val)
-- end

for child in ParentCat:EachChild(function(c)
    -- function condition
    return c.Val >= 100
end) do
    -- children that meet criteria
    --print(i, child.Name, child.Val)
end


local myScene = Scene.new{}
myScene:Adopt(Cat.new{Name = "Bitch"})
myScene.whatever = function ()
    
end
print(deserialize([[
F_TESTFUN, {
    function(a, b) return a + b end
} |

023a5d01d600, {
    "whatever" = function: 0x023a5d01c718,
    "_children" = @023a5d01d7c8,
    "_childHash" = @023a5d01d810,
    "Layers" = @023a5d01d648,
    "_type" = "Scene"
  } |
  
  023a5d01d7c8, {
    1 = @023a5d01d748
  } |
  
    023a5d01d810  , {
    @023a5d01d748 = 1
  } |
  
  023a5d01d648, {

    } |
  
  023a5d01d748, {
    "_parent" = @023a5d01d600,
    "Name" = "Bitch",
    "_type" = "Cat"
  } |
  
  ROOT = 023a5d01d600]]))

local arr = {1, 2, 3, 4, 5}
local dic = {val1 = 1, val2 = 5}

