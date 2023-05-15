Chexcore = require "chexcore"

local obj1 = Object.new{Name = "obj1"}
local obj2 = Object.new{Name = "obj2"}
local obj3 = Object.new{Name = "obj3"}
local obj4 = Object.new{Name = "obj4"}
local obj5 = Object.new{Name = "obj5"}

obj1:Adopt(obj2)
obj1:Adopt(obj3)
obj1:Adopt(obj4)
obj1:Adopt(obj5)

obj4:RemoveParent()

print(obj5:GetChildID())
print(obj4:GetChildID())
print(obj3:GetChildID())
print(obj2:GetChildID())
print(obj1:GetChildID())