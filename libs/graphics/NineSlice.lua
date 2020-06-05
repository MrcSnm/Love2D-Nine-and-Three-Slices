NineSlice = Class{}

function NineSlice:init(texture, topLeft, topMid, topRight, midLeft, mid, midRight, botLeft, botMid, botRight)

    self.texture = texture
    self.quads = {}
    self.quads[0] = topLeft
    self.quads[1] = topMid
    self.quads[2] = topRight
    self.quads[3] = midLeft
    self.quads[4] = mid
    self.quads[5] = midRight
    self.quads[6] = botLeft
    self.quads[7] = botMid
    self.quads[8] = botRight

    self.sizes = {}

    --This part could be simplified, but, using this form will let it have greater flexibility
    local tempX, tempY, tempW, tempH = self.quads[0]:getViewport()
    self.sizes[0] ={width = tempW, height = tempH}

    tempX, tempY, tempW, tempH = self.quads[1]:getViewport()
    self.sizes[1] ={width = tempW, height = tempH}
    
    tempX, tempY, tempW, tempH = self.quads[2]:getViewport()
    self.sizes[2] ={width = tempW, height = tempH}

    tempX, tempY, tempW, tempH = self.quads[3]:getViewport()
    self.sizes[3] ={width = tempW, height = tempH}

    tempX, tempY, tempW, tempH = self.quads[4]:getViewport()
    self.sizes[4] ={width = tempW, height = tempH}

    tempX, tempY, tempW, tempH = self.quads[5]:getViewport()
    self.sizes[5] ={width = tempW, height = tempH}
    tempX, tempY, tempW, tempH = self.quads[6]:getViewport()
    self.sizes[6] ={width = tempW, height = tempH}
    tempX, tempY, tempW, tempH = self.quads[7]:getViewport()
    self.sizes[7] ={width = tempW, height = tempH}
    tempX, tempY, tempW, tempH = self.quads[8]:getViewport()
    self.sizes[8] ={width = tempW, height = tempH}


    self.width = 0
    self.height = 0

    self.precalculatedScaleXTop = 0 --Used in top and bottom
    self.precalculatedScaleXMid = 0 --Used in top and bottom
    self.precalculatedScaleXBot = 0 --Used in top and bottom

    self.precalculatedScaleYLeft = 0 --Used in left and right
    self.precalculatedScaleYMid = 0 --Used in left and right
    self.precalculatedScaleYRight = 0 --Used in left and right

    self.batch = love.graphics.newSpriteBatch(self.texture, 16)
end

function NineSlice:set(x, y, width, height, useMinimumWidth, useMinimumHeight)
    self.x = NineSlice.round(x)
    self.y = NineSlice.round(y)
    if(useMinimumWidth) then
        width = (math.max(width, self.sizes[0].width + self.sizes[2].width))
    end
    if(useMinimumHeight) then
        height = (math.max(height, self.sizes[0].height + self.sizes[6].height))
    end
    self.width = NineSlice.round(width) --The minimum value is the sum of left and right edge
    self.height = NineSlice.round(height) --The minimum value is the sum of top and bottom-left corners

    self.precalculatedScaleXTop = (width - self.sizes[0].width - self.sizes[2].width) / self.sizes[1].width
    self.precalculatedScaleXMid = (width - self.sizes[3].width - self.sizes[5].width) / self.sizes[4].width
    self.precalculatedScaleXBot = (width - self.sizes[6].width - self.sizes[8].width) / self.sizes[7].width

    self.precalculatedScaleYLeft  = (height - self.sizes[0].height - self.sizes[6].height) / self.sizes[3].height
    self.precalculatedScaleYMid   = (height - self.sizes[1].height - self.sizes[7].height) / self.sizes[4].height
    self.precalculatedScaleYRight = (height - self.sizes[2].height - self.sizes[8].height) / self.sizes[5].height

    --Normalize for not having decimal pixes
    self.precalculatedScaleXTop =  NineSlice.round(self.precalculatedScaleXTop * self.sizes[1].width) / self.sizes[1].width
    self.precalculatedScaleXMid =  NineSlice.round(self.precalculatedScaleXMid * self.sizes[4].width) / self.sizes[4].width
    self.precalculatedScaleXBot =  NineSlice.round(self.precalculatedScaleXBot * self.sizes[7].width) / self.sizes[7].width
    self.precalculatedScaleYLeft  =  NineSlice.round(self.precalculatedScaleYLeft  * self.sizes[3].height) / self.sizes[3].height
    self.precalculatedScaleYMid   =  NineSlice.round(self.precalculatedScaleYMid   * self.sizes[4].height) / self.sizes[4].height
    self.precalculatedScaleYRight =  NineSlice.round(self.precalculatedScaleYRight * self.sizes[5].height) / self.sizes[5].height


    self:defineBatch()
end

function NineSlice.round(num)
    local decimals = num % 1
    if decimals < 0.499 then
        num = num - decimals
    else
        num = (num - decimals) + 1
    end
    return num
end

function NineSlice:defineBatch()
    self.batch:clear()
    if(self.precalculatedScaleXTop <= 0) then --Keep it simple by adding simple case for when scaling only corners

        local topLeftScaleX = NineSlice.round(self.width / self.sizes[0].width * 0.5)
        local topRightScaleX = NineSlice.round(self.width / self.sizes[2].width * 0.5)

        local midLeftScaleX = NineSlice.round(self.width / self.sizes[3].width * 0.5)
        local midRightScaleX = NineSlice.round(self.width / self.sizes[5].width * 0.5)

        local botLeftScaleX = NineSlice.round(self.width / self.sizes[6].width * 0.5)
        local botRightScaleX = NineSlice.round(self.width / self.sizes[8].width * 0.5)

        if(self.precalculatedScaleYLeft < 0) then
            local topLeftScaleY = NineSlice.round(self.height / self.sizes[0].height * 0.5)
            local topRightScaleY = NineSlice.round(self.height / self.sizes[2].height * 0.5 )

            local botLeftScaleY = NineSlice.round(self.height / self.sizes[6].height * 0.5)
            local botRightScaleY = NineSlice.round(self.height / self.sizes[8].height * 0.5)


            self.batch:add(self.quads[0], self.x, self.y, 0, topLeftScaleX, topLeftScaleY) --Top Lef
            self.batch:add(self.quads[2], self.x + self.width - NineSlice.round(self.sizes[2].width * topLeftScaleX), self.y, 0, topRightScaleX, topRightScaleY) --Top Right
            self.batch:add(self.quads[6], self.x, self.y + self.height - NineSlice.round(self.sizes[6].height * botLeftScaleY), 0, botLeftScaleX, botLeftScaleY) --Bot Left
            self.batch:add(self.quads[8], self.x + self.width - NineSlice.round(self.sizes[8].width * botRightScaleX), self.y + self.height - NineSlice.round(self.sizes[8].height * botRightScaleY), 0, botRightScaleX, botRightScaleY) --Bot Right
        else

            self.batch:add(self.quads[0], self.x, self.y, 0, topLeftScaleX, 1) --Top Lef
            self.batch:add(self.quads[2], self.x + self.width - NineSlice.round(self.sizes[2].width * topLeftScaleX), self.y, 0, topRightScaleX, 1) --Top Right
            self.batch:add(self.quads[3], self.x, self.y + self.sizes[0].height, 0, midLeftScaleX, self.precalculatedScaleYLeft) --Mid Left
            self.batch:add(self.quads[5], self.x + self.width - NineSlice.round(self.sizes[5].width * midRightScaleX), self.y + self.sizes[2].height, 0, midRightScaleX, self.precalculatedScaleYRight) --Mid Right
            self.batch:add(self.quads[6], self.x, self.y + self.height - self.sizes[6].height, 0, botLeftScaleX, 1) --Bot Left
            self.batch:add(self.quads[8], self.x + self.width - NineSlice.round(self.sizes[8].width * botRightScaleX), self.y + self.height - self.sizes[8].height, 0, botRightScaleX, 1) --Bot Right

        end

    elseif(self.precalculatedScaleYLeft < 0) then

        local topLeftScaleY = NineSlice.round(self.height / self.sizes[0].height * 0.5)
        local botLeftScaleY = NineSlice.round(self.height / self.sizes[6].height * 0.5)

        local topMidScaleY = NineSlice.round(self.height / self.sizes[1].height * 0.5)
        local botMidScaleY = NineSlice.round(self.height / self.sizes[7].height * 0.5)

        local topRightScaleY = NineSlice.round(self.height / self.sizes[2].height * 0.5)
        local botRightScaleY = NineSlice.round(self.height / self.sizes[8].height * 0.5)

        self.batch:add(self.quads[0], self.x, self.y, 0, 1, topLeftScaleY) --Top Left
        self.batch:add(self.quads[6], self.x, self.y + self.height - NineSlice.round(self.sizes[6].height * botLeftScaleY), 0, 1, botLeftScaleY) --Bot Left

        self.batch:add(self.quads[1], self.x + self.sizes[0].width, self.y, 0, self.precalculatedScaleXTop, topMidScaleY) --Top Mid
        self.batch:add(self.quads[7], self.x + self.sizes[6].width, self.y + self.height - NineSlice.round(self.sizes[7].height * botMidScaleY), 0, self.precalculatedScaleXBot, botMidScaleY) --Bot Mid

        self.batch:add(self.quads[2], self.x + self.width - self.sizes[2].width, self.y, 0, 1, topRightScaleY) --Top Right
        self.batch:add(self.quads[8], self.x + self.width - self.sizes[8].width, self.y + self.height - NineSlice.round(self.sizes[8].height * botRightScaleY), 0, 1, botRightScaleY) --Bot Right

    else
        self.batch:add(self.quads[0], self.x, self.y) --Top Left
        self.batch:add(self.quads[1], self.x + self.sizes[0].width, self.y, 0, self.precalculatedScaleXTop, 1) --Top Mid
        self.batch:add(self.quads[2], self.x + self.width - self.sizes[2].width, self.y) --Top Right

        self.batch:add(self.quads[3], self.x, self.y + self.sizes[0].height, 0, 1, self.precalculatedScaleYLeft) --Mid Left
        self.batch:add(self.quads[4], self.x + self.sizes[3].width, self.y + self.sizes[1].height, 0, self.precalculatedScaleXMid, self.precalculatedScaleYMid) --Mid
        self.batch:add(self.quads[5], self.x + self.width - self.sizes[5].width, self.y + self.sizes[2].height, 0, 1, self.precalculatedScaleYRight) --Mid Right

        self.batch:add(self.quads[6], self.x, self.y + self.height - self.sizes[6].height) --Bot Left
        self.batch:add(self.quads[7], self.x + self.sizes[6].width, self.y + self.height - self.sizes[7].height, 0, self.precalculatedScaleXBot, 1) --Bot Mid
        self.batch:add(self.quads[8], self.x + self.width - self.sizes[8].width, self.y + self.height - self.sizes[8].height) --Bot Right
    end
    self.batch:flush()
    
end


function NineSlice:render()
    love.graphics.draw(self.batch)
end

function NineSlice.generateFromTiles(texture, startX, startY, tileWidth, tileHeight, offset_Per_Tile_X, offset_Per_Tile_Y)
    local quads = {}

    tileWidth = NineSlice.round(tileWidth)
    tileHeight = NineSlice.round(tileHeight)
    local i = 0
    for y = 0, 2 do
        for x = 0, 2 do
            table.insert(quads, love.graphics.newQuad(startX + (tileWidth + offset_Per_Tile_X) * x, startY + (tileHeight + offset_Per_Tile_Y) * y, tileWidth, tileHeight, texture:getDimensions()))
            i = i + 1
        end
    end
    return NineSlice(texture, unpack(quads))
end


function NineSlice.generateFromRect(texture, quadX, quadY, rectWidth, rectHeight)
    return NineSlice.generateFromTiles(texture, quadX, quadY, rectWidth / 3, rectHeight / 3, 0,0)
end