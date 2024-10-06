local Tilemap = {
    -- properties
    Name = "Tilemap",           -- Easy identifier
    Atlas = nil,                -- Texture identifying the atlas
    Tiles = {},
    Layers = {{{}}},
    TileSize = 8,
    LayerParallax = {}, 
    LayerOffset = {},
    LayerColors = {},
    CollisionLayers = {},
    Solid = true,

    Scale = 1,

    -- internal properties
    _numChunks = V{1, 1},
    _drawChunks = {},
    _chunkSize = 32,
    _super = "Prop",      -- Supertype
    _cache = setmetatable({}, {__mode = "k"}), -- cache has weak keys
    _global = true
}

Tilemap._globalUpdate = function (dt)
    for tilemap, _ in pairs(Tilemap._cache) do
        if tilemap:HasChildren() then
            for child in tilemap:EachChild("_followingTilemap", true) do
                child.Position = tilemap.Position + (tilemap._dimensions * tilemap.TileSize) * child._tilemapOriginPoint
            end
        end
    end
end

--[[
    ex. usage
    local tilemap = Tilemap.new("atlasPath", 16, 128, 128) -- initializes a new 16px tile tilemap with 128x128 tiles
]]

local newQuad = love.graphics.newQuad
function Tilemap.new(atlasPath, tileSize, width, height, layers)
    local newTilemap = Tilemap:SuperInstance()
    
    newTilemap.Atlas = Texture.new(atlasPath)
    newTilemap.Tiles = {}
    newTilemap.LayerParallax = {}
    newTilemap.LayerOffset = {}
    newTilemap.CollisionLayers = {}
    newTilemap.TileSize = tileSize

    newTilemap.Size[1] = width; newTilemap.Size[2] = height

    newTilemap._dimensions = V{width, height}
    
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

    for i, _ in pairs(newTilemap.Layers) do
        newTilemap.CollisionLayers[i] = true
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

    newTilemap:GenerateChunks()

    
    Tilemap._cache[newTilemap] = true
    return newTilemap
end

function Tilemap:GetMap(n)
    return n and self.Layers[n] or self.Layers[1]
end

function Tilemap:DrawChunks(layer)
    for row = 1, self._numChunks[2] do
        for col = 1, self._numChunks[1] do
            if layer then self:DrawChunk(layer, col, row) else self:DrawChunk(col, row) end
        end
    end
end

function Tilemap:DrawChunk(layer, x, y)
    x, y, layer = y and x or layer, y or x, y and layer or nil
    for layerID = layer or 1, layer or #self.Layers do
        local currentChunk = self._drawChunks[layerID][x + (y-1)*self._numChunks[1]]
        currentChunk:Activate()
        love.graphics.clear()
        love.graphics.setColor(1,1,1,1)
        -- render this chunk's allotted tiles
        local yOfs = (y-1) * self._chunkSize + 1
        local xOfs = (x-1) * self._chunkSize + 1

        
        for ty = yOfs, math.min(yOfs + self._chunkSize - 1, self.Size[2]) do
            for tx = xOfs, math.min(xOfs + self._chunkSize - 1, self.Size[1]) do
                local tile = self:GetTile(layerID, tx, ty)
                --print(x,y, tile)
                if tile and tile > 0 then
                    cdrawquad(self.Atlas._drawable, self.Tiles[tile], self.TileSize, self.TileSize, (tx-xOfs)*self.TileSize, (ty-yOfs)*self.TileSize, 0, self.TileSize, self.TileSize)
                end
            end
        end

        currentChunk:Deactivate()
    end
end

function Tilemap:GenerateChunks()
    for layerID = 1, #self.Layers do
        self._drawChunks[layerID] = {}
        for col = 1, self._numChunks.X do
            for row = 1, self._numChunks.Y do
                self._drawChunks[layerID][#self._drawChunks[layerID]+1] = Canvas.new(
                    self._chunkSize * self.TileSize,
                    self._chunkSize * self.TileSize
                                                                    )
            end
        end
    end

    self:DrawChunks()
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
    if self.DrawOverChildren and self:HasChildren() then
        
        self:DrawChildren(tx, ty)
    end

    local sx = self._chunkSize * self.TileSize * self.Scale
    local sy = self._chunkSize * self.TileSize * self.Scale

    local ax, ay = self.Size[1]*self.TileSize*self.AnchorPoint[1]*self.Scale,
                   self.Size[2]*self.TileSize*self.AnchorPoint[2]*self.Scale

    
    local camTilemapDist = self:GetLayer():GetParent().Camera.Position - self:GetPoint(0,0)
    for layerID = 1, #self.Layers do
        love.graphics.setColor(self.Color * (self.LayerColors[layerID] or Constant.COLOR.WHITE))
        local parallaxX = self.LayerParallax[layerID] and self.LayerParallax[layerID][1] or 1
        local parallaxY = self.LayerParallax[layerID] and self.LayerParallax[layerID][2] or 1

        local offsetX = self.LayerOffset[layerID] and self.LayerOffset[layerID][1] or 0
        local offsetY = self.LayerOffset[layerID] and self.LayerOffset[layerID][2] or 0


        -- print(self, layerID)
        for row = 1, self._numChunks[2] do
            for col = 1, self._numChunks[1] do
                --print(row, col)
                local currentChunk = self._drawChunks[layerID][col + (row-1)*self._numChunks[1]]
                local px = self.Position[1] - tx + sx*(col-1) - ax + offsetX
                local py = self.Position[2] - ty + sy*(row-1) - ay + offsetY
                currentChunk:DrawToScreen(
                    floor(px)+ (camTilemapDist.X) * (1 - parallaxX),
                    floor(py)+ (camTilemapDist.Y) * (1 - parallaxY),
                    self.Rotation,-- + Chexcore._clock,
                    sx, sy
                )
            end
        end
    end

    if not self.DrawOverChildren and self:HasChildren() then
        self:DrawChildren(tx, ty)
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
        local hitInfo = {}
        local camTilemapDist = self:GetLayer():GetParent().Camera.Position - self:GetPoint(0,0)
        for layerID, _ in ipairs(self.Layers) do   if self.CollisionLayers[layerID] then
            local parallaxX = self.LayerParallax[layerID] and self.LayerParallax[layerID][1] or 1
            local parallaxY = self.LayerParallax[layerID] and self.LayerParallax[layerID][2] or 1
    
            local offsetX = self.LayerOffset[layerID] and self.LayerOffset[layerID][1] or 0
            local offsetY = self.LayerOffset[layerID] and self.LayerOffset[layerID][2] or 0
            local realLeftEdge = sLeftEdge + (camTilemapDist.X) * (1 - parallaxX) + offsetX
            local realTopEdge = sTopEdge + (camTilemapDist.Y) * (1 - parallaxY) + offsetY

            local sWidth = sRightEdge - sLeftEdge
            local sHeight = sBottomEdge - sTopEdge
            local diffX = oLeftEdge - realLeftEdge
            local diffY = oTopEdge - realTopEdge
            local progX, progY = diffX/sWidth, diffY/sHeight
            
            local xStart = math.max(math.ceil(progX * self.Size[1]),1)
            local yStart = math.max(math.ceil(progY * self.Size[2]),1)
            
            diffX = oRightEdge - realLeftEdge
            diffY = oBottomEdge - realTopEdge
            progX, progY = math.min(diffX/sWidth, 1), math.min(diffY/sHeight, 1)

            local xEnd = math.ceil(progX * self.Size[1]) 
            local yEnd = math.ceil(progY * self.Size[2])

            local realTileX = tilemapSize[1]/self.Size[1]
            local realTileY = tilemapSize[2]/self.Size[2]
            
            local boxLeft, boxRight, boxTop, boxBottom, tileID

            local storeHit, storeHDist, storeVDist

                
                for x = xStart, xEnd do 
                    for y = yStart, yEnd do
                        
                        tileID = self:GetTile(layerID, x, y)
                        if tileID and tileID > 0 then
                            boxLeft = realLeftEdge + realTileX * (x-1)
                            boxRight = realLeftEdge + realTileX * (x)
                            boxTop = realTopEdge + realTileY * (y-1)
                            boxBottom = realTopEdge + realTileY * (y)

                            local hit, hDist, vDist = boxCollide(boxLeft,boxRight,boxTop,boxBottom,oLeftEdge,oRightEdge,oTopEdge,oBottomEdge)


                            if hit then
                                hitInfo[#hitInfo+1] = {hDist, vDist, tileID}
                            end
                        end
                    end
                end
            end;  end
        if #hitInfo > 0 then
            return hitInfo
        end
    end
end


function Tilemap.import(tiledPath, atlasPath, properties)
    
    tiledPath = tiledPath or "game.scenes.testzone.tilemap"
    local tiled_export = require(tiledPath) --.layers[1].data

    local rows = tiled_export.height
    local cols = tiled_export.width

    local tileSize = tiled_export.tilewidth
    
    
    local newTilemap = Tilemap.new(atlasPath, tileSize, cols, rows)

    if properties then newTilemap:Properties(properties) end

    local n = 0
    for i, layer in ipairs(tiled_export.layers) do
        if layer.type == "tilelayer" then
            n = n + 1
            newTilemap.LayerParallax[n] = V{layer.parallaxx or 1, layer.parallaxy or 1}
            newTilemap.LayerOffset[n] = V{layer.offsetx or 0, layer.offsety or 0}

            if layer.properties then
                newTilemap.CollisionLayers[n] = not layer.properties.background_layer
            end

            if layer.tintcolor then
                newTilemap.LayerColors[n] = (V{layer.tintcolor[1], layer.tintcolor[2], layer.tintcolor[3]}/255):AddAxis(layer.opacity)
            else
                newTilemap.LayerColors[n] = V{1, 1, 1, layer.opacity}
            end

            newTilemap.Layers[n] = layer.data

        elseif layer.objects then
            for _, objData in ipairs(layer.objects) do
                local class = objData.type
                if Chexcore._types[class] then
                    local newObj = newTilemap:Adopt(Chexcore._types[class].new():Properties{
                        Position = V{objData.x, objData.y},
                        Size = V{objData.width, objData.height}
                    })

                    newObj.Position.X = newObj.Position.X + newObj.Size.X * newObj.AnchorPoint.X
                    newObj.Position.Y = newObj.Position.Y - newObj.Size.Y * newObj.AnchorPoint.Y

                    if objData.properties and objData.properties.Track then
                        newObj._followingTilemap = true
                        newObj._tilemapOriginPoint = V{newObj.Position.X/(newTilemap.TileSize*newTilemap._dimensions[1]), newObj.Position.Y/(newTilemap.TileSize*newTilemap._dimensions[2])}
                    end
                end
            end
        end
    end
    newTilemap:GenerateChunks()

    

    return newTilemap
end
return Tilemap