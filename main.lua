require "chexcore"

local ParentCat = Cat.new{Name = "ParentCat"}
ParentCat:Adopt(Cat.new{Name = "ChildCat1"})
ParentCat:Adopt(Cat.new{Name = "[[ChildCat2]]", SomeThing = true})
ParentCat:Adopt(Cat.new{Name = "ChildCat3"})

print(ParentCat._childHash)

ParentCat:GetChild("ChildCat1"):RemoveParent()

print(ParentCat._childHash)