-- level.lua
local level = {}
level.levels = {"level1", "level2"}  -- list of level names
local index = 1
level.designs = {
    -- Level 1
    level1 = {
        walls = {
            {x = 0, y = 0, w = 800, h = 50},          -- top
            {x = 0, y = 550, w = 800, h = 50},        -- bottom
            {x = 0, y = 0, w = 50, h = 600},          -- left
            {x = 750, y = 0, w = 50, h = 600},        -- right
        },
        obstacles = {
            {x = 300, y = 400, w = 200, h = 20, rotation = 0},
            {x = 150, y = 500, w = 150, h = 20, rotation = math.pi / 8},
        },
        goals = {
            {x = 600, y = 550, w = 150, h = 20, rotation = 0},
        },
    },
    level2 = {
        walls = {
            {x = 0, y = 0, w = 800, h = 50},          -- top
            {x = 0, y = 550, w = 800, h = 50},        -- bottom
            {x = 0, y = 0, w = 50, h = 600},          -- left
            {x = 750, y = 0, w = 50, h = 600},        -- right
        },
        obstacles = {
            {x = 200, y = 300, w = 100, h = 20, rotation = -math.pi / 6},
            {x = 400, y = 350, w = 150, h = 20, rotation = math.pi / 4},
            {x = 600, y = 250, w = 100, h = 20, rotation = -math.pi / 8},
        },
        goals = {
            {x = 700, y = 550, w = 150, h = 20, rotation = 0},
        },
    },
    -- Additional levels can be added here
}



function level.load(world)
    level.world = world
    level.walls = {}
    level.obstacles = {}
    level.goals = {}

    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    local thickness = 50  -- how thick the borders are

    -- Create static perimeter walls (indestructible)
    level:addWall(0, 0, width, thickness)                   -- top
    level:addWall(0, height - thickness, width, thickness)   -- bottom
    level:addWall(0, 0, thickness, height)                   -- left
    level:addWall(width - thickness, 0, thickness, height)   -- right
    level.loadDesign(level.levels[index])
    index = index + 1
end

function level.loadDesign(designName)
    local design = level.designs[designName]
    if not design then
        print("Level design not found: " .. designName)
        return
    end

    -- Clear existing level elements
    level:removeAll()

    -- Add walls
    for _, wall in ipairs(design.walls) do
        level:addWall(wall.x, wall.y, wall.w, wall.h)
    end

    -- Add obstacles
    for _, obstacle in ipairs(design.obstacles) do
        level:addObstacle(obstacle.x, obstacle.y, obstacle.w, obstacle.h, obstacle.rotation)
    end

    -- Add goals
    for _, goal in ipairs(design.goals) do
        level:addGoal(goal.x, goal.y, goal.w, goal.h, goal.rotation)
    end
end

function level:addWall(x, y, w, h)
    local body = love.physics.newBody(self.world, 0, 0, "static")
    local shape = love.physics.newRectangleShape(x + w / 2, y + h / 2, w, h)
    local fixture = love.physics.newFixture(body, shape)
    table.insert(self.walls, {body = body, shape = shape, fixture = fixture})
end

function level:addObstacle(x, y, w, h, rotation)

    local body = love.physics.newBody(self.world, 0, 0, "static")
    local shape = love.physics.newRectangleShape(x + w / 2, y + h / 2, w, h, rotation)
    local fixture = love.physics.newFixture(body, shape)
    table.insert(self.obstacles, {body = body, shape = shape, fixture = fixture})
end

function level:addGoal(x, y, w, h, rotation)
    local body = love.physics.newBody(self.world, 0, 0, "static")
    local shape = love.physics.newRectangleShape(x + w / 2, y + h / 2, w, h, rotation)
    local fixture = love.physics.newFixture(body, shape)
    table.insert(self.goals, {body = body, shape = shape, fixture = fixture})
end

function level:removeAll()
    for _, o in ipairs(self.obstacles) do
        o.body:destroy()
    end

    for _, g in ipairs(self.goals) do
        g.body:destroy()
    end
    self.goals = {}

    self.obstacles = {}
end


function level.draw()
    love.graphics.setColor(0.2, 0.2, 0.2)
    for _, w in ipairs(level.walls) do
        local x, y, w_, h_ = w.shape:getPoints()
        love.graphics.polygon("fill", w.shape:getPoints())
    end

    love.graphics.setColor(1,1,1)
    for _, o in ipairs(level.obstacles) do
        love.graphics.polygon("fill", o.shape:getPoints())
    end

    love.graphics.setColor(0, 1, 0)
    for _, g in ipairs(level.goals) do
        love.graphics.polygon("fill", g.shape:getPoints())
    end
end

return level
