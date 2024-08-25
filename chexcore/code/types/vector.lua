local Vector = {
    -- properties
    Name = "Vector",
    
    -- internal properties
    _super = "Object",      -- Supertype
    _aliases = {"V"},
    _global = true
}

-- vector creation tries to be more optimized since it's frequent
local smt = setmetatable
function Vector.new(vec)
    return smt(vec, Vector)
end
-- SET A METATABLE FOR VECTOR FOR __call
setmetatable(Vector, {
    __call = function (_, vec)
        return smt(vec, Vector)
    end
})
-- custom indexing to react to X, Y, Z
local map, rg, rs, OBJ = {X = 1, Y = 2, Z = 3, A = 4, R = 1, G = 2, B = 3}, rawget, rawset, Object
function Vector.__index(t, d)
    return rg(t, map[d]) or rg(Vector, d) or Vector.__index2(t, d)
end
function Vector.__newindex(t, d, v)
    rs(t, map[d] or d, v)
end


-- also, Vectors can be __call()ed to unpack their data
local unpack = unpack
function Vector:__call()
    return unpack(self)
end

-- for normal people
function Vector:Unpack()
    return unpack(self)
end


-------------- regular methods ---------------------------------
local sin, cos =  math.sin, math.cos
function Vector.FromAngle(rad)
    return Vector{ cos(rad), sin(rad) }
end

local sqrt = math.sqrt
function Vector:Magnitude()
    local s = 0
    for _, v in ipairs(self) do
        s = s + v^2
    end
    return sqrt(s)
end

local ipairs = ipairs
function Vector:Filter(filter, ...)
    local nv = Vector{}
    for i = 1, #self do
        nv[i] = filter(self[i], ...)
    end
    return nv
end

function Vector:Normalize()
    return self / self:Magnitude()
end

-- returns a ratio of a Vector such that the first axis = 1.
function Vector:Ratio()
    local nv = Vector{1}
    for i = 2, #self do
        nv[i] = self[i]/self[1]
    end
    return nv
end

function Vector:ToAngle()
    return math.atan2(self[1], self[2])
end

function Vector:MoveXY(x, y)
    self[1] = self[1] + (x or 0)
    self[2] = self[2] + (y or 0)
end

function Vector:MoveXYZ(x, y, z)
    self[1] = self[1] + (x or 0)
    self[2] = self[2] + (y or 0)
    self[2] = self[3] + (z or 0)
end

function Vector:SetXY(x, y)
    self[1] = x or 0
    self[2] = y or 0
end

function Vector:SetXYZ(x, y, z)
    self[1] = x or 0
    self[2] = y or 0
    self[2] = z or 0
end
-- i could write code like this!~
function Vector:AddAxis(init)
    self[#self+1] = init or 0
end

-- basic linear interpolation
local clamp, abs = math.clamp, math.abs
local function lerp2(v1, v2, t, snapDelta)
    local v3 = Vector{}
    t = clamp(t, 0, 1)
    for i = 1, #v1 do
        v3[i] = v1[i] + ((v2[i] or v1[i]) - v1[i]) * t
        if abs(v3[i] - v2[i]) < snapDelta then
            v3[i] = v2[i]
        end
    end
    return v3
end


function Vector.Lerp(v1, v2, t, snapDelta)
    if snapDelta then return lerp2(v1, v2, t, snapDelta) end
    local v3 = Vector{}
    t = clamp(t, 0, 1)
    for i = 1, #v1 do
        v3[i] = v1[i] + ((v2[i] or v1[i]) - v1[i]) * t
    end
    return v3
end

-------------- relational operator stuff ----------------------------
-- addition
function Vector.__add(v1, v2)
    if type(v1) == "number" then -- number -> vector = number
        for i = 1, #v2 do
            v1 = v1 + v2[i]
        end
        return v1
    elseif type(v2) == "number" then -- vector -> number = vector
        local nVec = Vector.new{}
        for i = 1, #v1 do
            nVec[i] = v1[i] + v2
        end
        return nVec
    else -- vector -> vector = vector
        local nVec = Vector.new{}
            for i = 1, #v1 do
                nVec[i] = rg(v2, i) and v1[i] + v2[i] or v1[i]
            end
        return nVec
    end
end

-- subtraction
function Vector.__sub(v1, v2)
    if type(v1) == "number" then -- number -> vector = number
        for i = 1, #v2 do
            v1 = v1 - v2[i]
        end
        return v1
    elseif type(v2) == "number" then -- vector -> number = vector
        local nVec = Vector.new{}
        for i = 1, #v1 do
            nVec[i] = v1[i] - v2
        end
        return nVec
    else -- vector -> vector = vector
        local nVec = Vector.new{}
            for i = 1, #v1 do
                nVec[i] = rg(v2, i) and v1[i] - v2[i] or v1[i]
            end
        return nVec
    end
end

-- modulo
function Vector.__mod(v1, v2)
    if type(v1) == "number" then -- number -> vector = number
        for i = 1, #v2 do
            v1 = v1 % v2[i]
        end
        return v1
    elseif type(v2) == "number" then -- vector -> number = vector
        local nVec = Vector.new{}
        for i = 1, #v1 do
            nVec[i] = v1[i] % v2
        end
        return nVec
    else -- vector -> vector = vector
        local nVec = Vector.new{}
            for i = 1, #v1 do
                nVec[i] = rg(v2, i) and v1[i] % v2[i] or v1[i]
            end
        return nVec
    end
end

-- multiplication
function Vector.__mul(v1, v2)
    if type(v1) == "number" then -- number -> vector = number
        for i = 1, #v2 do
            v1 = v1 * v2[i]
        end
        return v1
    elseif type(v2) == "number" then -- vector -> number = vector
        local nVec = Vector.new{}
        for i = 1, #v1 do
            nVec[i] = v1[i] * v2
        end
        return nVec
    else -- vector -> vector = vector
        local nVec = Vector.new{}
            for i = 1, #v1 do
                nVec[i] = rg(v2, i) and v1[i] * v2[i] or v1[i]
            end
        return nVec
    end
end

-- division
function Vector.__div(v1, v2)
    if type(v1) == "number" then -- number -> vector = number
        for i = 1, #v2 do
            v1 = v1 / v2[i]
        end
        return v1
    elseif type(v2) == "number" then -- vector -> number = vector
        local nVec = Vector.new{}
        for i = 1, #v1 do
            nVec[i] = v1[i] / v2
        end
        return nVec
    else -- vector -> vector = vector
        local nVec = Vector.new{}
            for i = 1, #v1 do
                nVec[i] = rg(v2, i) and v1[i] / v2[i] or v1[i]
            end
        return nVec
    end
end

-- exponentiation
function Vector.__pow(v1, v2)
    if type(v1) == "number" then -- number -> vector = number
        for i = 1, #v2 do
            v1 = v1 ^ v2[i]
        end
        return v1
    elseif type(v2) == "number" then -- vector -> number = vector
        local nVec = Vector.new{}
        for i = 1, #v1 do
            nVec[i] = v1[i] ^ v2
        end
        return nVec
    else -- vector -> vector = vector
        local nVec = Vector.new{}
            for i = 1, #v1 do
                nVec[i] = rg(v2, i) and v1[i] ^ v2[i] or v1[i]
            end
        return nVec
    end
end

function Vector.__concat(v1, v2)
    if type(v1) == "table" then
        return v1:ToString() .. v2
    else
        return v1 .. v2:ToString()
    end
end

-- equality
function Vector.__eq(v1, v2)
    if #v1 ~= #v2 then return false end

    for i = 1, #v1 do
        if v1[i] ~= v2[i] then return false end
    end

    return true
end

-- negation
function Vector.__unm(v)
    return v * -1
end

local concat, tostring = table.concat, tostring
function Vector:ToString()
    local out = {}
    for _, item in ipairs(self) do
        out[#out+1] = tostring(item)
    end
    
    return "V{" .. concat(out, ", ") .. "}"
end

return Vector



