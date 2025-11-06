require "ground"
require "dough"
require "timer"
local water = require "water"
local level = require("level")
debug = "false"
cookieImg = nil
function love.load()
    cookieImg = love.graphics.newImage("dough.png")
    love.window.setMode(800, 600)
    love.physics.setMeter(70)
    world = love.physics.newWorld(0, 11.81 * 70, true)
    level.load(world)
    ground.load(world)
    --water.add(200, 400, 100, world)
    dough.load(world, 150, 400, 80, 30)
end

function love.update(dt)
    world:update(dt)
    dough.update(dt)
     if love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        ground.remove(mx, my, 20)
    end
end





function love.draw()
    love.graphics.setBackgroundColor(0.3, 0.3, 0.3)

    -- Draw liquid
    love.graphics.clear(0.3, 0.3, 0.35)
    ground.draw()
    dough.draw()
    --water.draw()
    level.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(debug, 10, 10)
end
