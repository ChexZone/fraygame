_G._tostring = _G.tostring
local oldtostring = tostring
local replaceCoreLuaFunctions = true

-- first, some undoubtedly cool stuff

local defaultSort = function (a, b)
    a = type(a) == "table" and tostring(a) or a
    b = type(b) == "table" and tostring(b) or b
    return a < b
end

-- adapted from https://www.lua.org/pil/19.3.html
-- iterator which traverses a table in alphabetical order:
function _G.sortedPairs(t, f)
    f = f or defaultSort
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end


-- new string methods:
local stringmt = getmetatable""

-- Limits a string to a set number of characters and appends with ' ...'
function stringmt.__index:limit(maxLength, append)
    append = append == nil and true or false
    return #self <= maxLength and self or (self:sub(1, maxLength)..(append and " ..." or ""))
end



if replaceCoreLuaFunctions then
    -- new tostring function which provides better table visualizations and Object support!
    local function ctostring(tab, breaks, indent)
        if type(tab) ~= "table" then return oldtostring(tab) end
        if tab._isObject then
            if indent then
                return tab:ToString()
            else
                -- passing along 'indent' because it may act as the 'noTypeLabels' bool
                return tab:ToString(breaks, indent)
            end
        end

        indent = indent or 0
        if indent > 30 then return "..." end

        local output = breaks and ("{ # " .. _tostring(tab):sub(8, 22) .. "\n") or "{"

        local searched = 0
        for k, v in sortedPairs(tab) do
            searched = searched + 1
            local vVal = type(v) == "table" and "" .. ctostring(v, breaks, indent + 2) or (type(v) == "string" and ('"' .. ctostring(v) .. '"') or ctostring(v))
            output = output .. (breaks and (" "):rep(indent + (breaks and 2 or 0)) or "") .. ctostring(k) .. ": " .. vVal .. (breaks and ",\n" or ", ")
        end

        -- empty table visual
        if searched == 0 then
            return breaks and (output:sub(1, #output-1) .. " }") or (output .. " # ".._tostring(tab):sub(8, 22) .. " }")
        end

        return output:sub(1, #output-2) .. (breaks and (searched > 0 and ("\n" .. (" "):rep(indent)) or " ") or "") .. "}"
    end
    _G.tostring = ctostring
end

