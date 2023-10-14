require "chexcore"

local ParentCat = Cat.new{Name = "ParentCat"}
ParentCat:Adopt(Cat.new{Name = "ChildCat1", Val = 125})
ParentCat:Adopt(Cat.new{Name = "ChildCat2", SomeThing = true, Val = 75})
ParentCat:Adopt(Cat.new{Name = "ChildCat3", Val = 200})

--print(ParentCat._childHash)

-- ParentCat:GetChild("ChildCat1"):RemoveParent()
-- -ParentCat:GetChild("ChildCat2"):RemoveParent()
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
    print(child.Name, child.Val)
end






local arr = {1, 2, 3, 4, 5}
local dic = {val1 = 1, val2 = 5}



local Cat = {
    Age = 0,
    Breed = "Whatever"
}
Cat.__index = Cat

function Cat.new()
    local newCat = {}
    setmetatable(newCat, Cat)
    return newCat
end

local myCat = Cat.new()
--print(myCat.Breed)