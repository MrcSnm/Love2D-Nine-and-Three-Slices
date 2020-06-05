Class = require 'libs.class'
require 'libs.graphics.NineSlice'
require 'libs.graphics.ThreeSlice'

function love.load()
    gTexture = love.graphics.newImage('graphics/ui.png')

    window = NineSlice.generateFromRect(gTexture, 0,0, 196, 196)
    button = ThreeSlice.generateFromRect(gTexture, 0, 196, 64, 24)
    scroll = ThreeSlice.generateFromRect(gTexture, 196, 0, 32, 128)
    scroll:set(600, 200, 999, 300, true)
    button:set(300, 200, 250, 200, true)
end

function love.update(dt)
    window:set(0, 0, love.mouse.getX(), love.mouse.getY(), true, true)
    
end

function love.draw()
    window:render() 
    button:render()
    scroll:render()
end