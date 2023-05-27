Chexcore = require "chexcore"

local ParentCat = Cat.new{Name = "ParentCat"}
ParentCat:Adopt(Cat.new{Name = "ChildCat1"})
ParentCat:Adopt(Cat.new{Name = "ChildCat2"})
ParentCat:Adopt(Cat.new{Name = "ChildCat3"})

local ChildCat = ParentCat:GetChild("ChildCat2")

--print(serialize(ChildCat))


local testScene = Scene.new()



local a, b, c = {}, {}, {}
a[1] = b; b[1] = a; b[2] = c; c[1] = a
local mt = setmetatable({}, a)
setmetatable(a, mt)
setmetatable(b, mt)
setmetatable(c, mt)


local saveData = {
	{User = "Gregory", HighScore = 1234567, Cheats = true},
	{User = "Fregory", HighScore = 3, Cheats = false},
	{User = "Grefory", HighScore = 1080, Cheats = false}
}
  local saveDataTxt = serialize(saveData)

local serial = ParentCat:Serialize()

deserialize(serial)