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

local function getTableAddress(tab) -- omits "0x"
   return oldtostring(tab):sub(10, 30)
end

local function pickStringChar(str)
    if str:find([["]]) then
        -- either [[]] or ''
        if str:find([[']]) then
            -- must be [[]]
            return '[['
        else--if str:find("]]") then
            -- must be ''
            return [[']]
        end
    elseif str:find([[']]) then
        -- either [[]] or ""
        if str:find([["]]) then
            -- must be [[]]
            return '[['
        else--if str:find("]]") then
            -- must be ""
            return [["]]
        end
    else
        -- both "" and '' are safe to use; use ""
        return [["]]
    end
end

local charList = {["'"] = {"'", "'"}, ['"'] = {'"', '"'}, ["[["] = {"[[", "]]"}}
local function makeStringString(str)
    local pick = charList[pickStringChar(str)]
    return pick[1] .. str .. pick[2]
end

local function serializeValue(val, queue, checklist)
    local out
    if type(val) == "table" then
        local tag = getTableAddress(val)
        if not checklist[tag] then
            queue[#queue+1] = val
            checklist[tag] = true
        end
        out = "@" .. tag
    elseif type(val) == "string" then
        out = makeStringString(val)
    else
        out = oldtostring(val)
    end
    return out
end

-- Serializes a table into a string. Records all referenced tables as well!
function _G.serialize(tab, upcast)
    local baseTag = getTableAddress(tab)
    local output = {} -- output may be multiple strings
    local queue = {tab} -- the current list of tables to serialize
    local checklist = {[baseTag] = true} -- hash of completed table values

    while queue[1] do
        local currentTable = queue[1]
        local currentTag = getTableAddress(currentTable)

        -- add tag name to output buffer
        output[#output+1] = currentTag .. ", "

        -- check for a metatable
        local mt = getmetatable(currentTable)
        -- confirm that there is a metatable, its __index is a table
        if mt and type(mt.__index) == "table" and not mt.__index._isObject then
            local mtTag = getTableAddress(mt)
            -- add the metatable to the queue only if it is unserialized
            if not checklist[mtTag] then
                queue[#queue+1] = mt
                checklist[mtTag] = true
            end
            output[#output+1] = mtTag .. ", "
        else
            output[#output+1] = ""
        end

        -- go through the table, store all primitives, and add any more tables to the queue
        local counter = 0
        output[#output+1] = "{\n  "
        for key, value in pairs(currentTable) do
            if counter > 0 then
                output[#output+1] = ",\n  "
            end

            -- serialize the key and value, and place them in the output buffer
            output[#output+1] = serializeValue(key, queue, checklist)
            output[#output+1] = " = "
            output[#output+1] = serializeValue(value, queue, checklist)

            -- remove the table from the queue if it is a parent
            if key == "_parent" and not upcast and queue[#queue] == currentTable._parent and currentTable._isObject then
                queue[#queue] = nil
            end

            counter = counter + 1
        end
        -- determine if the table is an Object or not, and apply its type if so
        if currentTable._isObject and currentTable.GetType then
            if counter > 0 then
                output[#output+1] = ",\n  "
            end
            output[#output+1] = serializeValue("_type", queue, checklist)
            output[#output+1] = ": "
            output[#output+1] = serializeValue(currentTable:GetType(), queue, checklist)

        end

        output[#output+1] = "\n};\n\n"

        -- remove the table from the queue
        table.remove(queue, 1)
    end
    
    output[#output+1] = "ROOT = " .. baseTag
    
    return table.concat(output)
end


-- Deserializes a string back into a family of tables. 
function _G.deserialize(str)
    local tableList = str:split(";")
    print(tableList[1])
end

-- new string methods:
local stringmt = getmetatable""

-- Limits a string to a set number of characters and appends with ' ...'
function stringmt.__index:limit(maxLength, ellipses)
    ellipses = ellipses == nil and true or false
    return #self <= maxLength and self or (self:sub(1, maxLength)..(ellipses and " ..." or ""))
end


-- from PiL2 20.4
-- Trims all whitespace from the beginning and end of a string
function stringmt.__index:trim()
    return (self:gsub("^%s*(.-)%s*$", "%1"))
end
local trim = stringmt.__index.trim


-- Splits a string into a table of strings with a custom delimiter (or "\n")
-- Converts number strings into numbers
-- If the delimiter exists multiple times in a row, it will be treated as a single delimiter
-- if 'trimWhitespace' is true, all whitespace before and after each substring will be removed
local tonumber = tonumber
function stringmt.__index:split(d, trimWhitespace)
    d = d or "\n"
    local out={}
    for str in string.gmatch(self, "([^"..d.."]+)") do
      out[#out+1] = tonumber(str) or trimWhitespace and trim(str) or str
    end
    return out
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

