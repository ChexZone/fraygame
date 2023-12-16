_G._tostring = _G.tostring
local oldtostring = tostring
local replaceCoreLuaFunctions = true
local pcall = pcall

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
local sortedPairs = _G.sortedPairs

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
local function rawSerialize(tab, upcast)
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
        if mt and ((type(mt.__index) == "table" and not mt.__index._isObject) or not mt.__index) then
            
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
            output[#output+1] = " = "
            output[#output+1] = serializeValue(currentTable:GetType(), queue, checklist)

        end

        output[#output+1] = "\n}|\n\n"

        -- remove the table from the queue
        table.remove(queue, 1)
    end
    
    output[#output+1] = "ROOT = " .. baseTag
    
    return table.concat(output)
end

function _G.serialize(tab, upcast)
    local status, result = pcall(rawSerialize, tab, upcast)
    return type(result) == "string" and result or nil
end

local function getStringBounds(s)
    local i = 1
    local out = {}
    
    while i <= #s do
        local delimPos = s:find("[\"%[']", i) -- matches either ', ", or [
        if delimPos then
            local delimiter = s:sub(delimPos, delimPos)
            if delimiter == '"' or delimiter == "'" then
                out[#out+1] = delimPos
                -- doesn't really matter, but for safety, put the other index at the end if not found:
                i = (s:find(delimiter, delimPos+1, true) or (#s-1)) + 1
                out[#out+1] = i-1
            elseif s:sub(delimPos, delimPos+1) == "[[" then
                out[#out+1] = delimPos
                i = (s:find("]]", delimPos+1, true) or (#s-1)) + 1
                out[#out+1] = i-1
            else
                -- it was probably a square bracket unrelated to strings
                i = delimPos + 1
            end
        else
            i = #s + 1
        end
    end

    return out
end

local function indexIsWithin(x, indices)
    for i = 1, #indices, 2 do
        if x >= indices[i] and x <= indices[i+1] then
            return true
        elseif x < indices[i] then
            return false
        end
    end
    return false
end

--------------------------------- SPECIAL SPLIT FUNCTIONS ----------------------------
-- !! HIGHLY NICHE FUNCTION - ONLY USE IF YOU KNOW !! --
local function splitByIndices(str, indices)
    local out = {}
    if #indices == 0 then return out end

    for i = 1, #indices do
        out[#out+1] = str:sub((indices[i-1] or 0) + 1, indices[i] - 1):trim()
    end

    out[#out+1] = str:sub(indices[#indices]+1, #str):trim()
    -- note: if you're trying to genericize this function, use this line instead of the above one:
    -- out[#out+1] = str:sub(indices[#indices]+1, #str):gsub("[\n\r]", ""):trim()
    
    return out
end

local function getSplitIndices(str, d, indices)
    local out = {}
    local left, right = 1, 0
    while right do
        left = right + 1
        repeat
            right = str:find(d, right+1, true)
        until not right or not indexIsWithin(right, indices)

        if right then
            out[#out+1] = right
        end
    end
    return out
end
--------------------------------- END SPECIAL SPLIT FUNCTIONS ----------------------------

local function merge(l1, l2)
    local p2 = 1
    local out = {}
    for p1, _ in ipairs(l1) do
        while l2[p2] and l2[p2] <= l1[p1] do
            out[#out+1] = l2[p2]
            p2 = p2 + 1
        end
        out[#out+1] = l1[p1]
    end
    for p2 = p2, #l2 do
        out[#out+1] = l2[p2]
    end
    return out
end

local stringDelims = {['"'] = true, ["'"] = true, ["["] = true}
local presetValues = {
    ['true'] = true,
    ['false'] = false,
    ['nil'] = nil
}


local function deserializeValue(val, referenceList)
    local identifier = val:sub(1,1)
    if tonumber(val) then
        -- value is a number
        val = tonumber(val)
    elseif identifier == "@" then
        -- value is a table reference
        val = val:sub(2, #val)
        if not referenceList[val] then
            -- create a new table
            referenceList[val] = {}
        end
        val = referenceList[val]

    elseif stringDelims[identifier] then
        -- value is a string
        if identifier == "[" then
            val = val:sub(3, #val-2)
        else
            val = val:sub(2, #val-1)
        end
    else
        -- value is some constant identifier
        val = presetValues[val]
    end

    return val
end

-- Deserializes a string back into a family of tables. 
local function rawDeserialize(serial)
    -- split by } + (whitespace) + ;
    local tableList = serial:split("}%s*|", true)
    local referenceList = {} -- list of table tags (keys) mapped to their tables (vals)
    local complete = {} -- list of references to complete tables
    local tbl -- saves the last created table in scope
    for _i, tblStr in ipairs(tableList) do
        if _i < #tableList then
            -- separate the table from metatata
            local metaTableSplit = tblStr:split("{", true, 1)

            -- table tag is first, metatable tag is second
            local metadata = metaTableSplit[1]:split(",", true)
            local tableTag, metaTag = metadata[1], (metadata[2] and metadata[2]:trim() or "")

            if tableTag:sub(1,2) == "F_" then
                -- this line should be interpreted as a function!
                    print(tableTag)
            else
                -- this line is a table as normal
                -- create a new table, if a reference to this one doesn't exist already
                tbl = referenceList[tableTag] or {}
                
                -- apply the metatable if it exists
                if #metaTag > 0 then
                    setmetatable(tbl, deserializeValue("@"..metaTag, referenceList))
                end

                -- now let's find out where those damned strings are...
                local valuesStr = metaTableSplit[2]
                
                local stringBounds = getStringBounds(valuesStr)
                local commaIndices = getSplitIndices(valuesStr, ",", stringBounds)
                local equalIndices = getSplitIndices(valuesStr, "=", stringBounds)
                local allIndices = merge(commaIndices, equalIndices)


                local finalValueSplit = splitByIndices(valuesStr, allIndices)

                

                for i = 1, #finalValueSplit, 2 do
                    local key = deserializeValue(finalValueSplit[i], referenceList)
                    local val = deserializeValue(finalValueSplit[i+1], referenceList)
                    
                    tbl[key or "_UNDEFINED"] = val
                end
                
                -- turn table into an object, if necessary
                if tbl._type and Chexcore._types[tbl._type] then
                    setmetatable(tbl, Chexcore._types[tbl._type])
                end
            end



            -- add the table to the reference list
            referenceList[tableTag] = tbl
            
        else
            -- we're at the "ROOT" definition (end)

            local rootReference = tblStr:split("%s*=%s*")[2]
            tbl = referenceList[rootReference] or tbl
        end
    end
    return tbl
end

function _G.deserialize(serial)
    local status, ret = pcall(rawDeserialize, serial)
    return ret or nil
end

-- new string methods:
local stringmt = getmetatable""

-- Limits a string to a set number of characters and appends with ' ...'
function stringmt.__index:limit(maxLength, ellipses)
    ellipses = ellipses == nil and true or false
    return #self <= maxLength and self or (self:sub(1, maxLength)..(ellipses and " ..." or ""))
end


-- Adapted from PiL2 20.4
-- Trims all whitespace/newlines from the beginning and end of a string
function stringmt.__index:trim()
    return self:gsub("^%s*(.-)%s*$", "%1")
end
local trim = stringmt.__index.trim


-- Splits a string into a table of strings with a custom delimiter (or "\n")
-- Converts number strings into numbers
-- If the delimiter exists multiple times in a row, it will be treated as a single delimiter
-- if 'trimWhitespace' is true, all whitespace before and after each substring will be removed
local tonumber = tonumber
local huge = math.huge
function stringmt.__index:split(pattern, trimWhitespace, limit, toIgnore)
    pattern = pattern or "\n"
    limit = limit or huge
    local out = {}
    local pos, count = 1, 0

    local left, right = 0, 0
    repeat
        if toIgnore then
            -- make sure we aren't within certain indices
            local tPos
            repeat
                tPos = right + 1
                left, right = self:find(pattern, tPos)
            until not left or not indexIsWithin(left, toIgnore)
        else
            -- standard find
            left, right = self:find(pattern, pos)
        end

        if left then
            -- capture from the last string position to the beginning
            out[#out+1] = trimWhitespace and trim(self:sub(pos, left-1)) or self:sub(pos, left-1)

            pos = right + 1
        else
            -- load the rest of the string into the output
            out[#out+1] = trimWhitespace and trim(self:sub(pos, #self)) or self:sub(pos, #self)
        end
        count = count + 1

        -- check if we've reached our max splits count
        if count >= limit then
            out[#out+1] = trimWhitespace and trim(self:sub(pos, #self)) or self:sub(pos, #self)
            break
        end
    until not left

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


--[[  
    filteredListIterator()
     - returns the full list of an object's children
    filteredListIterator( name )
     - returns the subset of children with the given name
    filteredListIterator( property, value )
     - returns the subset of children with the given property and value
    filteredListIterator( { property = val, ...} [, inclusive] )
     - searches for multiple properties. If inclusive is false, all properties must match.
    filteredListIterator( func )
     - returns the subset of children for which func(child) returns true

     The above signatures make up a wrapper signature referred to as "<FilterArg>"
]]
local STOP = 1000000
function _G.filteredListIterator(self, arg1, arg2)
    
    if not (arg1 or arg2) then  -- get entire set
        local i = 0
        return function()
            i = i + 1
            return self[i]
        end
    end
    
    if type(arg1) == "table" then
        -- filteredListIterator( { property = val, ...} [, inclusive] )
        if not arg2 then
            -- exclusive
            local i = 0
            return function()
                while STOP - i > 0 do
                    i = i + 1
                    local c = self[i]
                    if not c then return nil end
                    local match = true
                    for property, val in pairs(arg1) do
                        if c[property] ~= val then
                            match = false; break
                        end
                    end
                    if match then return c end
                end
            end
        else
            -- inclusive
            local i = 0
            return function()
                while STOP - i > 0 do
                    i = i + 1
                    local c = self[i]
                    if not c then return nil end
                    local match = false
                    for property, val in pairs(arg1) do
                        if c[property] == val then
                            match = true; break
                        end
                    end
                    if match then return c end
                end
            end
        end
    elseif arg2 ~= nil then
        -- filteredListIterator( property, value )
        local i = 0
        return function()
            while STOP - i > 0 do
                i = i + 1
                local c = self[i]
                if not c then return nil end
                if c[arg1] == arg2 then
                    return c
                end
            end
        end
    elseif type(arg1) == "function" then
        -- filteredListIterator( func )
        local i = 0
        return function()
            while STOP - i > 0 do
                i = i + 1
                local c = self[i]
                if not c then return nil end
                if arg1(c) then
                    return c
                end
            end
        end
    end
end

-- Too lazy to redocument. Same deal as above, just does the whole list at once
function _G.filteredList(self, arg1, arg2)
    
    if not (arg1 or arg2) then  -- get entire set
        local list = {}
        for i, ref in ipairs(self) do
            list[i] = ref
        end
        return list
    end
    
    local list = {}

    if type(arg1) == "table" then
        -- filteredList( { property = val, ...} [, inclusive] )
        if not arg2 then
            -- exclusive
            for _, child in ipairs(self) do
                local match = true
                for property, val in pairs(arg1) do
                    if child[property] ~= val then
                        match = false; break
                    end
                end
                if match then
                    list[#list+1] = child
                end
            end
        else
            -- inclusive
            for _, child in ipairs(self) do
                local match = false
                for property, val in pairs(arg1) do
                    if child[property] == val then
                        match = true; break
                    end
                end
                if match then
                    list[#list+1] = child
                end
            end
        end
    elseif arg2 ~= nil then
            -- filteredList( property, value )
            for _, child in ipairs(self) do
                if child[arg1] == arg2 then
                    list[#list+1] = child
                end
            end
    elseif type(arg1) == "function" then
        -- filteredList( func )
        for index, child in ipairs(self) do
            if arg1(child) then
                list[#list+1] = child
            end
        end
    end

    return list
end