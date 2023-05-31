Chexcore = require "chexcore"

local ParentCat = Cat.new{Name = "ParentCat"}
ParentCat:Adopt(Cat.new{Name = "ChildCat1"})
ParentCat:Adopt(Cat.new{Name = "[[ChildCat2]]"})
ParentCat:Adopt(Cat.new{Name = "ChildCat3"})

local serial = ParentCat:Serialize()
deserialize(serial)

local test = " This pattern will be detected: } \n ; This pattern will be ignored: ';}' "
--print( tostring(test:splitPattern("}%s*;", true, nil, getStringBounds(test)), true) )

--print(tostring(("a }     ; b"):splitPattern("}%s*;", nil, nil, {1, 3}), true))