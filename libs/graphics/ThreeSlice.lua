ThreeSlice = Class{}

function ThreeSlice:init(texture,isHorizontal, quad1, stretchingQuad, quad3)
    self.x = 0
    self.y = 0
    self.width = 0
    self.precalculatedScaleX = 0
    self.precalculatedScaleY = 0
    self.height = 0
    self.isHorizontal = isHorizontal
    self.texture = texture
    self.quads = 
    {
        quad1 = quad1,
        quad2 = stretchingQuad,
        quad3 = quad3
    }
    self.sizes = {}
    local tempX, tempY, tempW, tempH = quad1:getViewport()
    self.sizes[0] = {width = tempW, height = tempH}
    tempX, tempY, tempW, tempH = stretchingQuad:getViewport()
    self.sizes[1] = {width = tempW, height = tempH}
    tempX, tempY, tempW, tempH = quad3:getViewport()
    self.sizes[2] = {width = tempW, height = tempH}

    self.batch = love.graphics.newSpriteBatch(self.texture, 4)
end

function ThreeSlice:set(x, y, width, height, useMinimum)
    if(useMinimum) then
        if self.isHorizontal then
            height = self.sizes[1].height
        else
            width = self.sizes[1].width
        end
    end

    self.x = x
    self.y = y
    self.width = width
    self.height = height

    local finalWidth = width - self.sizes[0].width - self.sizes[2].width
    local finalHeight  = height - self.sizes[0].height - self.sizes[2].height


    self.precalculatedScaleX = finalWidth / self.sizes[1].width
    self.precalculatedScaleY = finalHeight / self.sizes[1].height
    self:defineBatch()

end

function ThreeSlice:defineBatch()
    self.batch:clear()
    if(self.isHorizontal) then
        --first quad

        local quad1Width = self.sizes[0].width
        local quad3Width = self.sizes[2].width

        local quad1ScaleY = self.height / self.sizes[0].height
        local quad3ScaleY = self.height / self.sizes[2].height
        if(self.precalculatedScaleX > 0) then
            local quad2ScaleY = self.height / self.sizes[1].height
            self.batch:add(self.quads['quad1'], self.x, self.y, 0, 1, quad1ScaleY)
            self.batch:add(self.quads['quad2'], self.x + quad1Width, self.y, 0, self.precalculatedScaleX, quad2ScaleY)
            self.batch:add(self.quads['quad3'], self.x + self.width - quad3Width, self.y, 0, 1, quad3ScaleY)
        else
            local quad1ScaleX = self.width / self.sizes[0].width
            local quad3ScaleX = self.width / self.sizes[2].width
            self.batch:add(self.quads['quad1'], self.x, self.y, 0, quad1ScaleX, quad1ScaleY)
            self.batch:add(self.quads['quad3'], self.x + self.width - quad3Width, self.y, 0, quad3ScaleX, quad3ScaleY)
        end
    else
        --first quad
        local quad1Height = self.sizes[0].height
        local quad3Height = self.sizes[2].height

        local quad1ScaleX = self.width / self.sizes[0].width --Percentage of quad1 scaleX
        local quad3ScaleX = self.width / self.sizes[2].width --Percentage of quad3 scaleX

        if(self.precalculatedScaleY > 0) then
            local quad2ScaleX = self.width / self.sizes[1].width --Percentage of quad2 scaleX

            self.batch:add(self.quads['quad1'], self.x, self.y, 0, quad1ScaleX, 1)
            self.batch:add(self.quads['quad2'], self.x, self.y + quad1Height, 0, quad2ScaleX, self.precalculatedScaleY)

            --last quad
            self.batch:add(self.quads['quad3'], self.x, self.y + self.height - quad3Height, 0, quad3ScaleX, 1)
        else
            local quad1ScaleY = self.height / self.sizes[0].height --Percentage of quad1 scaleY
            local quad2ScaleY = self.height / self.sizes[2].height --Percentage of quad1 scaleY

            self.batch:add(self.quads['quad1'], self.x, self.y, 0, quad1ScaleX, quad1ScaleY)
            self.batch:add(self.quads['quad3'], self.x, self.y + self.height - quad3Height, 0, quad3ScaleX, quad2ScaleY)
        end

    end
    self.batch:flush()
end

function ThreeSlice:render()
    love.graphics.draw(self.batch)
end

function ThreeSlice.generateFromTiles(texture, startX, startY, tileWidth, tileHeight, offset_Per_Tile_X, offset_Per_Tile_Y, isHorizontal)
    local quads = {}

    tileWidth = NineSlice.round(tileWidth)
    tileHeight = NineSlice.round(tileHeight)
    local nextX, nextY
    for i = 0, 2 do
        nextX = startX + offset_Per_Tile_X * i
        nextY = startY + offset_Per_Tile_Y * i
        if(isHorizontal) then
            nextX = nextX + tileWidth * i
        else
            nextY = nextY + tileHeight * i
            print(nextY)
        end
        table.insert(quads, love.graphics.newQuad(nextX, nextY, tileWidth, tileHeight, texture:getDimensions()))
    end
    return ThreeSlice(texture, isHorizontal, unpack(quads))
end

function ThreeSlice.generateFromRect(texture, x, y, width, height)
    local isHorizontal = width > height
    if isHorizontal then
        width = width / 3
    else
        height = height / 3
    end
    return ThreeSlice.generateFromTiles(texture, x, y, width, height, 0, 0, isHorizontal)
end

