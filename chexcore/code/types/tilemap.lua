local Tilemap = {
    -- properties
    Name = "Tilemap",           -- Easy identifier
    Atlas = nil,                -- Texture identifying the atlas
    Tiles = {},
    Layers = {{{}}},
    TileSize = 8,
    Solid = true,

    Scale = .5,

    -- internal properties
    _numChunks = V{1, 1},
    _drawChunks = {},
    _chunkSize = 32,
    _super = "Prop",      -- Supertype
    _global = true
}

--[[
    ex. usage
    local tilemap = Tilemap.new("atlasPath", 16, 128, 128) -- initializes a new 16px tile tilemap with 128x128 tiles
]]

local newQuad = love.graphics.newQuad
function Tilemap.new(atlasPath, tileSize, width, height, layers)
    local newTilemap = Tilemap:SuperInstance()
    
    newTilemap.Atlas = Texture.new(atlasPath)
    newTilemap.Tiles = {}
    newTilemap.TileSize = tileSize

    newTilemap.Size[1] = width; newTilemap.Size[2] = height

    if not layers then
        -- generate tiles
        newTilemap.Layers = {{}}
        local activeLayer = newTilemap.Layers[1]
        for i = 1, height do
            for j = 1, width do
                activeLayer[#activeLayer+1] = math.random(0,1)
            end
        end
    else
        newTilemap.Layers = layers
    end

    local rows, cols = newTilemap.Atlas:GetHeight()/tileSize, newTilemap.Atlas:GetWidth()/tileSize
    for row = 0, rows-1 do
        for col = 0, cols-1 do
            newTilemap.Tiles[#newTilemap.Tiles+1] = newQuad(col*tileSize, row*tileSize, tileSize, tileSize, cols*tileSize, rows*tileSize)
        end
    end

    setmetatable(newTilemap, Tilemap)

    -- set up canvases for segmented drawing
    newTilemap._drawChunks = {}
    newTilemap._numChunks = V{math.ceil(width/newTilemap._chunkSize), math.ceil(height/newTilemap._chunkSize)}
    for col = 1, newTilemap._numChunks.X do
        for row = 1, newTilemap._numChunks.Y do
            newTilemap._drawChunks[#newTilemap._drawChunks+1] = Canvas.new(
                                                                    newTilemap._chunkSize * tileSize,
                                                                    newTilemap._chunkSize * tileSize
                                                                )
        end
    end

    newTilemap:DrawChunks()

    return newTilemap
end

function Tilemap:GetMap(n)
    return n and self.Layers[n] or self.Layers[1]
end

function Tilemap:DrawChunks()
    for row = 1, self._numChunks[2] do
        for col = 1, self._numChunks[1] do
            self:DrawChunk(col, row)
        end
    end
end

function Tilemap:DrawChunk(x, y)
    local currentChunk = self._drawChunks[x + (y-1)*self._numChunks[1]]
    currentChunk:Activate()
    love.graphics.clear()
    love.graphics.setColor(1,1,1,1)
    -- render this chunk's allotted tiles
    local yOfs = (y-1) * self._chunkSize + 1
    local xOfs = (x-1) * self._chunkSize + 1

    for y = yOfs, math.min(yOfs + self._chunkSize - 1, self.Size[2]) do
        for x = xOfs, math.min(xOfs + self._chunkSize - 1, self.Size[1]) do
            local tile = self:GetTile(x, y)
            --print(x,y, tile)
            if tile and tile > 0 then
                cdrawquad(self.Atlas._drawable, self.Tiles[tile], self.TileSize, self.TileSize, (x-xOfs)*self.TileSize, (y-yOfs)*self.TileSize, 0, self.TileSize, self.TileSize)
            end
        end
    end

    currentChunk:Deactivate()
end

function Tilemap:GetTile(layer, x, y)
    x, y, layer = y and x or layer, y or x, y and layer or 1
    
    if x > self.Size[1] or y > self.Size[2] then
        return false
    else
        return self:GetMap(layer)[x + (y-1)*self.Size[1]]
    end
end

function Tilemap:SetTile(layer, x, y, val)
    x, y, layer, val = val and x or layer, val and y or x, val and layer or 1, val or y
    if x <= self.Size[1] and y <= self.Size[2] then
        self:GetMap(layer)[x + (y-1)*self.Size[1]] = val
        
        -- redraw the changed chunk
        self:DrawChunk(math.ceil(x/self._chunkSize), math.ceil(y/self._chunkSize))
    end
end

local floor = math.floor
function Tilemap:Draw(tx, ty)
    love.graphics.setColor(self.Color)
    local sx = self._chunkSize * self.TileSize * self.Scale
    local sy = self._chunkSize * self.TileSize * self.Scale

    local ax, ay = self.Size[1]*self.TileSize*self.AnchorPoint[1]*self.Scale,
                   self.Size[2]*self.TileSize*self.AnchorPoint[2]*self.Scale

    

    for row = 1, self._numChunks[2] do
        for col = 1, self._numChunks[1] do
            --print(row, col)
            local currentChunk = self._drawChunks[col + (row-1)*self._numChunks[1]]
            currentChunk:DrawToScreen(
                floor(self.Position[1] - tx + sx*(col-1) - ax),
                floor(self.Position[2] - ty + sy*(row-1) - ay),
                self.Rotation,-- + Chexcore._clock,
                sx, sy
            )
        end
    end
end

local function boxCollide(sLeftEdge,sRightEdge,sTopEdge,sBottomEdge,oLeftEdge,oRightEdge,oTopEdge,oBottomEdge)
    local hitLeft  = sRightEdge >= oLeftEdge
    local hitRight = sLeftEdge <= oRightEdge
    local hitTop   = sBottomEdge >= oTopEdge
    local hitBottom = sTopEdge <= oBottomEdge

    local hIntersect = hitLeft and hitRight
    local vIntersect = hitTop and hitBottom

    if hIntersect and vIntersect then

        local hDir, vDir, hFlag, vFlag
        if sLeftEdge >= oLeftEdge and sRightEdge <= oRightEdge then
            hDir = 0
        elseif sLeftEdge >= oLeftEdge then
            hDir = sLeftEdge - oRightEdge
            hFlag = true
        elseif sRightEdge <= oRightEdge then
            hDir = sRightEdge - oLeftEdge
            hFlag = true
        else
            hDir = false
        end

        if sTopEdge >= oTopEdge and sBottomEdge <= oBottomEdge then
            vDir = 0
        elseif sTopEdge >= oTopEdge then
            vDir = sTopEdge - oBottomEdge
            vFlag = true
        elseif sBottomEdge <= oBottomEdge then
            vDir = sBottomEdge - oTopEdge
            vFlag = true
        else
            vDir = false
        end

        if (hDir == 0 and hFlag) or (vDir == 0 and vFlag) then
            return false
        end

        return true, hDir, vDir
    end

    return false
end

local function getInfo(self, other, ss)
    if not self.Solid then return false end

    local sp, op = self.Position, other.Position
    local sap, oap = self.AnchorPoint, other.AnchorPoint
    local os = other.Size
    local sLeftEdge  = floor(sp[1] - ss[1] * sap[1])
    local sRightEdge = floor(sp[1] + ss[1] * (1 - sap[1]))
    local sTopEdge  = floor(sp[2] - ss[2] * sap[2])
    local sBottomEdge = floor(sp[2] + ss[2] * (1 - sap[2]))
    local oLeftEdge  = floor(op[1] - os[1] * oap[1])
    local oRightEdge = floor(op[1] + os[1] * (1 - oap[1]))
    local oTopEdge  = floor(op[2] - os[2] * oap[2])
    local oBottomEdge = floor(op[2] + os[2] * (1 - oap[2]))

    local success = boxCollide(sLeftEdge,sRightEdge,sTopEdge,sBottomEdge, oLeftEdge,oRightEdge,oTopEdge,oBottomEdge)

    return success, sLeftEdge,sRightEdge,sTopEdge,sBottomEdge, oLeftEdge,oRightEdge,oTopEdge,oBottomEdge
end


function Tilemap:CollisionInfo(other, preference)
    local tilemapSize = self.Size*self.TileSize*self.Scale
    local success, sLeftEdge,sRightEdge,sTopEdge,sBottomEdge,
                   oLeftEdge,oRightEdge,oTopEdge,oBottomEdge = getInfo(self, other, tilemapSize)
    if not success then
        return false
    else
        local sWidth = sRightEdge - sLeftEdge
        local sHeight = sBottomEdge - sTopEdge
        local diffX = oLeftEdge - sLeftEdge
        local diffY = oTopEdge - sTopEdge
        local progX, progY = diffX/sWidth, diffY/sHeight
        
        local xStart = math.max(math.ceil(progX * self.Size[1]),1)
        local yStart = math.max(math.ceil(progY * self.Size[2]),1)
        
        diffX = oRightEdge - sLeftEdge
        diffY = oBottomEdge - sTopEdge
        progX, progY = math.min(diffX/sWidth, 1), math.min(diffY/sHeight, 1)

        local xEnd = math.ceil(progX * self.Size[1]) 
        local yEnd = math.ceil(progY * self.Size[2])

        local realTileX = tilemapSize[1]/self.Size[1]
        local realTileY = tilemapSize[2]/self.Size[2]
        
        local boxLeft, boxRight, boxTop, boxBottom, tileID

        local storeHit, storeHDist, storeVDist

        local hitInfo = {}

        for x = xStart, xEnd do
            for y = yStart, yEnd do
                
                tileID = self:GetTile(x, y)
                if tileID and tileID > 0 then
                    boxLeft = sLeftEdge + realTileX * (x-1)
                    boxRight = sLeftEdge + realTileX * (x)
                    boxTop = sTopEdge + realTileY * (y-1)
                    boxBottom = sTopEdge + realTileY * (y)

                    local hit, hDist, vDist = boxCollide(boxLeft,boxRight,boxTop,boxBottom,oLeftEdge,oRightEdge,oTopEdge,oBottomEdge)


                    if hit then
                        hitInfo[#hitInfo+1] = {hDist, vDist, tileID}
                    end
                end
            end
        end
        if #hitInfo > 0 then
            return hitInfo
        end
    end
end

return Tilemap