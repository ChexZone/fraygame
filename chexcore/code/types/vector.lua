local Vector = {
    -- properties
    Name = "Vector",
    
    -- internal properties
    _super = "Object",      -- Supertype
    _aliases = {"V"},
    _global = true
}

-- vector creation tries to be optimized since it's frequent
local smt = setmetatable
function Vector.new(vec)
    return smt(vec, Vector)
end
-- SET A METATABLE FOR VECTOR FOR __call
setmetatable(Vector, {
    __call = function (self, vec)
        return smt(vec, Vector)
    end
})
-- custom indexing to react to X, Y, Z
local map, rg, rs, OBJ = {X = 1, Y = 2, Z = 3}, rawget, rawset, Object
function Vector.__index(t, d)
    return rg(t, map[d]) or Vector[d] or OBJ[d]
end
function Vector.__newindex(t, d, v)
    rs(t, map[d] or d, v)
end


-------------- regular methods ---------------------------------
local ipairs, sqrt = ipairs, math.sqrt
function Vector:Magnitude()
    local s = 0
    for _, v in ipairs(self) do
        s = s + v^2
    end
    return sqrt(s)
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



local concat = table.concat
function Vector:ToString()
    return "V{" .. concat(self, ", ") .. "}"
end

return Vector