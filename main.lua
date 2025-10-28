require "ground"
local liquid = require("liquid")

function love.load()
    love.window.setMode(800, 600)
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)

    -- Load liquid particles
    liquid.load(300, world)
    ground.load()
end

function love.update(dt)
    world:update(dt)

     if love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        ground.removeGround(mx, my, 20)
    end
end





function love.draw()
    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)

    -- Draw liquid
    love.graphics.clear(0.3, 0.3, 0.35)

    liquid.draw()
    ground.draw()

end
