-- water.lua   (LÖVE 11.x+)
local water = {}

-- user tweakables -----------------------------------------------------------
local PARTICLE_RADIUS = 2.5          -- Box2D radius (meters)
local CANVAS_SCALE    = 0.25         -- 1/4 res for the mask -> huge fill-rate win
local SURFACE_TENSION = 1.55         -- 0…1  (shader: higher → rounder drops)
-----------------------------------------------------------------------------

-- private -------------------------------------------------------------------
local shader          -- the surface shader
local worldCanvas     -- tiny off-screen target that holds the particle mask
local particles       -- list of {body, ...} for cleanup/respawn
local world2canvas    -- quick matrix: world→canvas pixels

local vertexCode = [[
#pragma language glsl3
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    return transform_projection * vertex_position;
}]]

local fragmentCode = [[
#pragma language glsl3
uniform sampler2D mask;
//uniform vec2      canvasSize;
uniform float     surfaceTension;   // kept for compatibility


vec4 effect(vec4 color, Image tex, vec2 uvs, vec2 screen_coords)
{
    float c = texture(mask, uvs).r;          // single tap – perfectly sharp
    float edge = 0.5;                        // mid-point
    float width = 0.08 - surfaceTension*0.04;// tighten for sharper transition
    float alpha = smoothstep(edge - width, edge + width, c);

    vec3 rgb = vec3(0.12, 0.50, 0.90);       // flat water colour
    return vec4(rgb, alpha);
}]]

local function ensureShader()
    if shader then return end
    shader = love.graphics.newShader(vertexCode, fragmentCode)
    shader:send("surfaceTension", SURFACE_TENSION)
end

local function ensureCanvas()
    if worldCanvas then return end
    local w, h = love.graphics.getDimensions()
    worldCanvas = love.graphics.newCanvas(w*CANVAS_SCALE, h*CANVAS_SCALE)
    worldCanvas:setFilter("linear","linear")
    world2canvas = love.math.newTransform(
        0,0, 0,  CANVAS_SCALE,CANVAS_SCALE,  0,0 )
end

-- public API ----------------------------------------------------------------
function water.add(n, x, y, world)
    ensureShader(); ensureCanvas()
    particles = particles or {}

    for i = 1, n do
        local body = love.physics.newBody(world, x + love.math.random()*4-2,
                                                    y + love.math.random()*4-2, "dynamic")
        local shape = love.physics.newCircleShape(PARTICLE_RADIUS)
        local fixture = love.physics.newFixture(body, shape, 1.0)
        fixture:setRestitution(0.1)
        fixture:setFriction(0.05)
        fixture:setUserData({isWater=true})  -- tag for other game logic
        table.insert(particles, {body=body, fixture=fixture, shape=shape})
    end
end

-- call this once per frame --------------------------------------------------
function water.draw()
    if not particles or #particles==0 then return end
    local w, h = love.graphics.getDimensions()

    -- 1) draw particles into tiny mask
    love.graphics.push("all")
    love.graphics.setCanvas(worldCanvas)
    love.graphics.clear(0,0,0,0)
    love.graphics.applyTransform(world2canvas)
    love.graphics.setColor(1,1,1,1)
    for _,p in ipairs(particles) do
        local x,y = p.body:getPosition()
        love.graphics.circle("fill", x, y, PARTICLE_RADIUS*1.2)
    end
    love.graphics.setCanvas()

    -- 2) composite fullscreen water layer
    love.graphics.pop()
    love.graphics.setShader(shader)
    shader:send("mask", worldCanvas)
    --shader:send("canvasSize", {worldCanvas:getDimensions()})
    --shader:send("time", love.timer.getTime())
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(worldCanvas, 0,0, 0, 1/CANVAS_SCALE, 1/CANVAS_SCALE)
    love.graphics.setShader()
end

-- optional: destroy bodies when you leave the state -------------------------
function water.clear()
    for _,p in ipairs(particles or {}) do
        p.body:destroy()
    end
    particles = {}
end

return water