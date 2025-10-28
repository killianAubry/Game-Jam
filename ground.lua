ground = {}

function ground.load()
    ground.x = 400
    ground.y = 475
    ground.width = 800
    ground.height = 100
    ground.segments = 10000
    ground.bodies = {}

    -- Compute how many circles per row and column
    local totalArea = ground.width * ground.height
    local circleArea = totalArea / ground.segments
    local circleDiameter = math.sqrt(circleArea) -- approximate size of each particle
    local circleRadius = circleDiameter / 2

    -- Compute how many fit per row/column based on the particle size
    local cols = math.floor(ground.width / circleDiameter)
    local rows = math.floor(ground.height / circleDiameter)

    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local x = ground.x - ground.width / 2 + (col + 0.5) * circleDiameter
            local y = ground.y - ground.height / 2 + (row + 0.5) * circleDiameter

            local body = love.physics.newBody(world, x, y, "static")
            local shape = love.physics.newCircleShape(circleRadius)
            local fixture = love.physics.newFixture(body, shape)
            fixture:setRestitution(0)
            fixture:setFriction(0)

            table.insert(ground.bodies, {body = body, shape = shape, fixture = fixture})
        end
    end
end

function ground.removeGround(mx, my, radius)
    for i = #ground.bodies, 1, -1 do
        local bx, by = ground.bodies[i].body:getPosition()
        local dist = math.sqrt((bx - mx)^2 + (by - my)^2)
        if dist < radius then
            ground.bodies[i].body:destroy()
            table.remove(ground.bodies, i)
        end
    end
end

function ground.draw()
    love.graphics.setColor(1, 1, 1)
    for _, particle in ipairs(ground.bodies) do
        love.graphics.circle("fill", particle.body:getX(), particle.body:getY(), particle.shape:getRadius())
    end
end