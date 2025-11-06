dough = {}
local level = require("level")
dough.joints = {}
dough.tallest = 100
index = 1
function dough.load(world, size, x, y, radius)
    local bodies = {}
    for i = 1, size do
        local angle = (2 * math.pi * i) / size
        local px = x + math.cos(angle) * radius
        local py = y + math.sin(angle) * radius
        dough.tallest = math.min(dough.tallest, py)
        local p = {}
        p.body = love.physics.newBody(world, px, py, "dynamic")
        p.shape = love.physics.newCircleShape(2)
        p.fixture = love.physics.newFixture(p.body, p.shape, 1)
        p.fixture:setRestitution(0)
        p.fixture:setFriction(0)
        table.insert(bodies, p)
    end
    dough.bodies = bodies

    -- Connect every point with springs to all others
    for i = 1, size do
        for j = i + 1, size do
            local joint = love.physics.newDistanceJoint(
                bodies[i].body,
                bodies[j].body,
                bodies[i].body:getX(),
                bodies[i].body:getY(),
                bodies[j].body:getX(),
                bodies[j].body:getY(),
                false
            )
            joint:setDampingRatio(.3)
            joint:setFrequency(size * 0.002)
            table.insert(dough.joints, joint)
        end
    end
end

function dough.update(dt)
    -- Sort points around the blob’s center
    local cx, cy = 0, 0
    for _, p in ipairs(dough.bodies) do
        cx = cx + p.body:getX()
        cy = cy + p.body:getY()
    end
    cx = cx / #dough.bodies
    cy = cy / #dough.bodies

    table.sort(dough.bodies, function(a, b)
        local ax, ay = a.body:getX() - cx, a.body:getY() - cy
        local bx, by = b.body:getX() - cx, b.body:getY() - cy
        return math.atan2(ay, ax) < math.atan2(by, bx)
    end)

    --------------------------------------------------
    -- build vertex / uv lists for the mesh
    --------------------------------------------------
    local verts = {}          -- x,y,u,v  (4 numbers per vertex)
    local cx, cy = 0,0
    for _,p in ipairs(dough.bodies) do
        cx = cx + p.body:getX()
        cy = cy + p.body:getY()
    end
    cx = cx / #dough.bodies
    cy = cy / #dough.bodies

    -- sort around centre (your old code)
    table.sort(dough.bodies, function(a,b)
        local ax,ay = a.body:getX()-cx, a.body:getY()-cy
        local bx,by = b.body:getX()-cx, b.body:getY()-cy
        return math.atan2(ay,ax) < math.atan2(by,bx)
    end)

    -- fill verts + uvs
    for _,p in ipairs(dough.bodies) do
        local x = p.body:getX()
        local y = p.body:getY()
        if #level.goals > 0 and love.physics.getDistance(p.fixture, level.goals[1].fixture) < 1 then
            level:removeAll()
            ground.reset()
            dough.move(-100, -400)
            level.loadDesign(level.levels[index])
            index = index + 1
        end
        -- simple uv: map distance from centre to 0-1
        local u = (x - cx) / 100 + 0.5
        local v = (y - cy) / 100 + 0.5
        table.insert(verts, {x, y, u, v})
    end

    -- create / refresh the mesh
    if not dough.mesh then
        dough.mesh = love.graphics.newMesh(verts, "fan", "dynamic")
        dough.mesh:setTexture(cookieImg)
    else
        dough.mesh:setVertices(verts)
    end

end

function dough.move(x, y)
    for _, p in ipairs(dough.bodies) do
        p.body:setPosition(p.body:getX() + x, p.body:getY() + y)
        p.body:setLinearVelocity(0, 0)
    end
end


function dough.draw()
    love.graphics.setColor(1, 1, 1)
    if dough.mesh then
        love.graphics.draw(dough.mesh, 0, 0)          -- textured blob
    end

end
