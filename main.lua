Chexcore = require "chexcore"

local ParentCat = Cat.new{Name = "ParentCat"}
ParentCat:Adopt(Cat.new{Name = "ChildCat1"})
ParentCat:Adopt(Cat.new{Name = "ChildCat2"})
ParentCat:Adopt(Cat.new{Name = "ChildCat3"})

print(serialize(ParentCat))


local testScene = Scene.new()



local a, b, c = {}, {}, {}
a[1] = b; b[1] = a; b[2] = c; c[1] = a
local mt = setmetatable({}, a)
setmetatable(a, mt)
setmetatable(b, mt)
setmetatable(c, mt)

local testTable = {
    Files = {
        A = {
            Name = "John",
            Position = {x = 5, y = 10},
            Level = 10,
        },
        B = {
            Name = "Jimmy",
            Position = {x = 0, y = 0},
            Level = 69,
        },
        C = {
            Name = "Jack",
            Position = {x = 0, y = 20},
            Level = 1,
        }
    }
}


