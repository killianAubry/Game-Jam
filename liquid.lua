-- liquid.lua
local liquid = {}

------------------------------------------------------
-- CONFIG
------------------------------------------------------
local CLUSTER_DISTANCE = 10 -- distance threshold between clusters

------------------------------------------------------
-- Utility functions
------------------------------------------------------
local function distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx*dx + dy*dy)
end

local function cross(o, a, b)
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
end

local function convexHull(points)
    table.sort(points, function(a, b)
        return a.x < b.x or (a.x == b.x and a.y < b.y)
    end)

    local lower = {}
    for _, p in ipairs(points) do
        while #lower >= 2 and cross(lower[#lower-1], lower[#lower], p) <= 0 do
            table.remove(lower)
        end
        table.insert(lower, p)
    end

    local upper = {}
    for i = #points, 1, -1 do
        local p = points[i]
        while #upper >= 2 and cross(upper[#upper-1], upper[#upper], p) <= 0 do
            table.remove(upper)
        end
        table.insert(upper, p)
    end

    table.remove(upper, 1)
    table.remove(upper, #upper)
    for _, p in ipairs(upper) do
        table.insert(lower, p)
    end

    return lower
end

------------------------------------------------------
-- Cluster detection
------------------------------------------------------
local function clusterPoints(points, threshold)
    local clusters = {}
    local visited = {}

    for i, p in ipairs(points) do
        if not visited[i] then
            local cluster = {p}
            visited[i] = true

            -- Breadth-first neighbor collection
            local stack = {p}
            while #stack > 0 do
                local current = table.remove(stack)
                for j, other in ipairs(points) do
                    if not visited[j] and distance(current, other) < threshold then
                        visited[j] = true
                        table.insert(cluster, other)
                        table.insert(stack, other)
                    end
                end
            end

            table.insert(clusters, cluster)
        end
    end

    return clusters
end


------------------------------------------------------
-- Liquid system
------------------------------------------------------
local particles = {}

function liquid.load(count, world)
    particles = {}

    for i = 1, count do
        local particle = {}
        particle.body = love.physics.newBody(world, math.random(200, 600), math.random(100, 300), "dynamic")
        particle.shape = love.physics.newCircleShape(4)
        particle.fixture = love.physics.newFixture(particle.body, particle.shape, 1)
        particle.fixture:setRestitution(0.1)
        particle.body:setLinearDamping(0)
        particle.body:setAngularDamping(0)
        particle.fixture:setFriction(0)
        particle.fixture:setDensity(0)
        table.insert(particles, particle)
    end
end

------------------------------------------------------
-- Update particles
------------------------------------------------------
function liquid.update(dt)
    for _, particle in ipairs(particles) do
        -- if one particle has a velocity greater than a threshold, apply the same force in the same direction to nearby particles
        local vx, vy = particle.body:getLinearVelocity()
        local speed = math.sqrt(vx * vx + vy * vy)
        if speed > 1 then
            for _, other in ipairs(particles) do
                if other ~= particle then
                    local ox, oy = other.body:getPosition()
                    local px, py = particle.body:getPosition()
                    local dist = distance({x = ox, y = oy}, {x = px, y = py})
                    if dist < 50 then
                        local force = (50 - dist) * 10
                        local angle = math.atan2(vy, vx)
                        other.body:applyForce(math.cos(angle) * force, math.sin(angle) * force)
                    end
                end
            end
        end
    end
end

------------------------------------------------------
-- Draw multiple polygons
------------------------------------------------------
function liquid.draw()
    -- Collect positions
    local points = {}
    for _, particle in ipairs(particles) do
        local x, y = particle.body:getPosition()
        table.insert(points, {x = x, y = y})
    end

    if #points < 3 then return end

    -- Find clusters of nearby particles
    local clusters = clusterPoints(points, CLUSTER_DISTANCE)

    --Draw each blob polygon separately
    love.graphics.setColor(0.3, 0.5, 1, 0.5)
    for _, cluster in ipairs(clusters) do
        if #cluster >= 3 then
            local hull = convexHull(cluster)
            local poly = {}
            for _, p in ipairs(hull) do
                table.insert(poly, p.x)
                table.insert(poly, p.y)
            end
            love.graphics.polygon("fill", poly)
        end
    end


    --Draw the particles on top (for a soft look)
    love.graphics.setColor(0.2, 0.4, 0.8)
    for _, particle in ipairs(particles) do
        local x, y = particle.body:getPosition()
        love.graphics.circle("fill", x, y, particle.shape:getRadius())
    end
end

return liquid
