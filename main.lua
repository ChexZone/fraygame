Chexcore = require "chexcore"

local Homer = Cat.new{Name = "Homer"}
local Meowscles = Cat.new{Name = "Meowscles"}
local MysteriousFigure = Cat.new{Name = "???"}


local children = MysteriousFigure:GetChildren()

-- print(MysteriousFigure:ToString(true))
local myTab = {
    subtable = {
        nestedSubtable = {
            val1 = "hello",
            val2 = "world!"
        }
    },
    array = {"a", "b", "c", "d", "e"}
}

Homer:Adopt(Meowscles)
Homer:Adopt(MysteriousFigure)
print(tostring(Cat.new(), true, false))
