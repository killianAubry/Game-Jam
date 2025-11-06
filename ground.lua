-- destructible_ground.lua
ground = {}
require "dough"

local SAMPLE = 10 -- pixel step (smaller = higher detail, slower)

function ground.load(world)
    ground.world = world
    ground.yStart = 200
    ground.width = love.graphics.getWidth()
    ground.height = love.graphics.getHeight()
    ground.canvas = love.graphics.newCanvas(ground.width, ground.height)
    ground.body = love.physics.newBody(world, 0, 0, "static")
    ground.fixtures = {}

    -- Draw initial ground (everything below yStart)
    love.graphics.setCanvas(ground.canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(0.4, 0.3, 0.1)
    love.graphics.rectangle("fill", 0, ground.yStart, ground.width, ground.height - ground.yStart)
    love.graphics.setCanvas()

    ground:rebuildPhysics()
end

function ground.remove(mx, my, radius)
    love.graphics.setCanvas(ground.canvas)
    love.graphics.setBlendMode("replace", "premultiplied")
    love.graphics.setColor(0, 0, 0, 0)
    love.graphics.circle("fill", mx, my, radius)
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()

    ground:rebuildPhysics()
end

function ground:rebuildPhysics()
    for _, f in ipairs(self.fixtures) do
        f:destroy()
    end
    self.fixtures = {}

    local imgData = self.canvas:newImageData()
    local w, h = imgData:getDimensions()

    -- Marching Squares
    -- dont worry about colliders above the dough ball
    for y = dough.tallest, h - SAMPLE - 1, SAMPLE do
        for x = 0, w - SAMPLE - 1, SAMPLE do
            local corners = {}
            for dy = 0, 1 do
                for dx = 0, 1 do
                    local _, _, _, a = imgData:getPixel(x + dx * SAMPLE, y + dy * SAMPLE)
                    table.insert(corners, a > 0.1 and 1 or 0)
                end
            end

            local state = corners[1] * 8 + corners[2] * 4 + corners[4] * 2 + corners[3] * 1
            local lines = ground.marchingSquareSegments(state, x, y, SAMPLE)
            if lines then
                for _, l in ipairs(lines) do
                    local shape = love.physics.newEdgeShape(l[1], l[2], l[3], l[4])
                    local fixture = love.physics.newFixture(self.body, shape)
                    table.insert(self.fixtures, fixture)
                end
            end
        end
    end
end

-- Marching Squares lookup table
function ground.marchingSquareSegments(state, x, y, s)
    local midX, midY = x + s / 2, y + s / 2
    local segments = {
        [1] = {{midX, y + s, x, midY}},
        [2] = {{x + s, midY, midX, y + s}},
        [3] = {{x + s, midY, x, midY}},
        [4] = {{midX, y, x + s, midY}},
        [5] = {{midX, y, x, midY}, {midX, y + s, x + s, midY}},
        [6] = {{midX, y, midX, y + s}},
        [7] = {{midX, y, x, midY}},
        [8] = {{x, midY, midX, y}},
        [9] = {{midX, y + s, midX, y}},
        [10] = {{x, midY, x + s, midY}},
        [11] = {{x + s, midY, midX, y}},
        [12] = {{midX, y + s, x + s, midY}},
        [13] = {{x, midY, midX, y + s}},
        [14] = {{midX, y + s, x, midY}}
    }
    return segments[state]
end

function ground.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ground.canvas)

    -- Optional: visualize physics edges
    
    love.graphics.setColor(0, 1, 0)
    --[[
    for _, f in ipairs(ground.fixtures) do
        local s = f:getShape()
        if s:typeOf("EdgeShape") then
            local x1, y1, x2, y2 = s:getPoints()
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    --]]
end

function ground.reset()
    love.graphics.setCanvas(ground.canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(0.4, 0.3, 0.1)
    love.graphics.rectangle("fill", 0, ground.yStart, ground.width, ground.height - ground.yStart)
    love.graphics.setCanvas()

    ground:rebuildPhysics()
end
