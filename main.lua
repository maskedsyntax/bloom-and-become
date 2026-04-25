local Player = require("src.player")
local Collectible = require("src.collectible")
local Particles = require("src.particles")

local player
local collectibles = {}
local vines = {}
local obstacles = {}
local breakables = {}
local goal = {}
local evolutionEnergy = 0
local gameState = "title" -- "title", "playing", "won", "credits"
local camX = 0
local levelWidth = 2500

-- Juice & Background
local shakeTime = 0
local shakeIntensity = 0
local particles
local evolutionPause = 0
local clouds = {}
local hills = {}
local petals = {}

-- Assets
local tilesImg
local charactersImg
local quads = {}
local bgm
local sfx = {}
local fonts = {}

function initGame()
    evolutionEnergy = 0
    collectibles = {}
    vines = {}
    obstacles = {}
    breakables = {}
    camX = 0
    shakeTime = 0
    evolutionPause = 0
    
    particles = Particles.new()
    player = Player.new(50, 450, charactersImg, sfx)
    
    -- --- SECTION 1: SPROUT (0-800) ---
    table.insert(collectibles, Collectible.new(200, 450, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(350, 420, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(500, 450, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(650, 400, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(800, 430, "sunlight", tilesImg))
-- --- SECTION 2: VINE (800-1500) ---
table.insert(obstacles, {x = 1000, y = 320, width = 100, height = 180, color = {0.3, 0.3, 0.3}})
table.insert(vines, {x = 975, y = 150, width = 20, height = 350}) -- Left side vine
table.insert(vines, {x = 1105, y = 150, width = 20, height = 350}) -- Right side vine (New!)

table.insert(collectibles, Collectible.new(975, 100, "sunlight", tilesImg))
table.insert(collectibles, Collectible.new(1105, 100, "sunlight", tilesImg)) -- Extra orb on right vine
table.insert(collectibles, Collectible.new(1150, 250, "sunlight", tilesImg))
table.insert(collectibles, Collectible.new(1200, 450, "sunlight", tilesImg)) -- Extra buffer orb
table.insert(collectibles, Collectible.new(1250, 450, "sunlight", tilesImg))
table.insert(collectibles, Collectible.new(1350, 400, "sunlight", tilesImg))
table.insert(collectibles, Collectible.new(1450, 450, "sunlight", tilesImg))
table.insert(collectibles, Collectible.new(1550, 350, "sunlight", tilesImg))

    -- --- SECTION 3: TREE (1500-2500) ---
    table.insert(breakables, {x = 1700, y = 350, width = 60, height = 150, intact = true})
    table.insert(collectibles, Collectible.new(1850, 450, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(2000, 400, "sunlight", tilesImg))
    table.insert(breakables, {x = 2200, y = 350, width = 40, height = 150, intact = true})
    
    goal = {x = 2400, y = 430, width = 40, height = 70}
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Load Fonts
    fonts.title = love.graphics.newFont("assets/fonts/Fredoka-Bold.ttf", 64)
    fonts.medium = love.graphics.newFont("assets/fonts/Fredoka-Bold.ttf", 24)
    fonts.regular = love.graphics.newFont("assets/fonts/Fredoka-Regular.ttf", 18)
    fonts.small = love.graphics.newFont("assets/fonts/Fredoka-Regular.ttf", 14)
    
    tilesImg = love.graphics.newImage("assets/sprites/environment/tiles_packed.png")
    charactersImg = love.graphics.newImage("assets/sprites/player/characters_packed.png")
    
    local ts = 18
    quads.grass = love.graphics.newQuad(0, 0, ts, ts, tilesImg:getDimensions())
    quads.dirt = love.graphics.newQuad(0, ts, ts, ts, tilesImg:getDimensions())
    quads.vine = love.graphics.newQuad(126, 36, ts, ts, tilesImg:getDimensions())
    quads.rock = love.graphics.newQuad(90, 18, ts, ts, tilesImg:getDimensions())
    quads.shrine = love.graphics.newQuad(198, 90, ts, ts, tilesImg:getDimensions())
    
    bgm = love.audio.newSource("assets/audio/music/spring_ambient.ogg", "stream")
    bgm:setLooping(true)
    bgm:setVolume(0.5)
    
    sfx.jump = love.audio.newSource("assets/audio/sfx/jump.ogg", "static")
    sfx.collect = love.audio.newSource("assets/audio/sfx/collect.ogg", "static")
    sfx.break_obj = love.audio.newSource("assets/audio/sfx/break.ogg", "static")
    sfx.evolve = love.audio.newSource("assets/audio/sfx/evolve.ogg", "static")
    sfx.win = love.audio.newSource("assets/audio/sfx/win.ogg", "static")
    
    -- Init Background Elements
    for i = 1, 8 do
        table.insert(clouds, {
            x = math.random(0, 800),
            y = math.random(20, 200),
            speed = math.random(5, 20),
            w = math.random(60, 120)
        })
    end
    
    for i = 1, 5 do
        table.insert(hills, {
            x = (i-1) * 300,
            h = math.random(100, 250),
            color = {0.2 + (i*0.05), 0.6 + (i*0.05), 0.2 + (i*0.05)}
        })
    end

    for i = 1, 20 do
        table.insert(petals, {
            x = math.random(0, 2500),
            y = math.random(0, 600),
            speedX = math.random(-20, -10),
            speedY = math.random(10, 30),
            angle = math.random() * math.pi * 2,
            rotSpeed = math.random() * 2
        })
    end
    
    initGame()
    bgm:play()
end

function startShake(time, intensity)
    shakeTime = time
    shakeIntensity = intensity
end

function love.update(dt)
    -- Update Background
    for _, c in ipairs(clouds) do
        c.x = c.x + c.speed * dt
        if c.x > 800 then c.x = -c.w end
    end
    for _, p in ipairs(petals) do
        p.x = p.x + p.speedX * dt
        p.y = p.y + p.speedY * dt
        p.angle = p.angle + p.rotSpeed * dt
        if p.y > 600 then p.y = -10 p.x = math.random(0, 2500) end
        if p.x < 0 then p.x = 2500 end
    end

    if gameState ~= "playing" then return end

    if evolutionPause > 0 then
        evolutionPause = evolutionPause - dt
        particles:update(dt)
        return 
    end

    if shakeTime > 0 then
        shakeTime = shakeTime - dt
    end
    particles:update(dt)

    local onVine = false
    for _, vine in ipairs(vines) do
        if player.x < vine.x + vine.width and
           vine.x < player.x + player.width and
           player.y < vine.y + vine.height and
           vine.y < player.y + player.height then
            onVine = true
            break
        end
    end

    player:update(dt, onVine)
    
    if player.y > 600 then
        player.x = 50
        player.y = 450
        player.yVel = 0
    end

    local function checkSolidCollision(obj)
        local dx = (player.x + player.width/2) - (obj.x + obj.width/2)
        local dy = (player.y + player.height/2) - (obj.y + obj.height/2)
        local combinedHalfWidth = (player.width + obj.width) / 2
        local combinedHalfHeight = (player.height + obj.height) / 2

        if math.abs(dx) < combinedHalfWidth and math.abs(dy) < combinedHalfHeight then
            local overlapX = combinedHalfWidth - math.abs(dx)
            local overlapY = combinedHalfHeight - math.abs(dy)
            if overlapX < overlapY then
                if dx > 0 then player.x = obj.x + obj.width else player.x = obj.x - player.width end
                player.xVel = 0
            else
                if dy > 0 then player.y = obj.y + obj.height player.yVel = 0 else
                    player.y = obj.y - player.height
                    player.yVel = 0
                    player.grounded = true
                    player.isClimbing = false
                end
            end
        end
    end

    for _, obs in ipairs(obstacles) do checkSolidCollision(obs) end
    for _, b in ipairs(breakables) do if b.intact then checkSolidCollision(b) end end
    
    for _, item in ipairs(collectibles) do
        if not item.collected and item:checkCollision(player) then
            item.collected = true
            evolutionEnergy = evolutionEnergy + 1
            sfx.collect:stop()
            sfx.collect:play()
            particles:spawn(item.x + item.width/2, item.y + item.height/2, {1, 0.9, 0}, 8)
            if (evolutionEnergy == 5 and player.stage == 1) or (evolutionEnergy == 10 and player.stage == 2) then
                player:evolve()
                sfx.evolve:play()
                evolutionPause = 0.5
                particles:spawn(player.x + player.width/2, player.y + player.height/2, {0.2, 0.8, 0.2}, 30)
                startShake(0.3, 5)
            end
        end
    end

    if player.stage == 3 then
        if player.x < goal.x + goal.width and goal.x < player.x + player.width and
           player.y < goal.y + goal.height and goal.y < player.y + player.height then
            gameState = "won"
            bgm:stop()
            sfx.win:play()
        end
    end

    camX = player.x - 400
    if camX < 0 then camX = 0 end
    if camX > levelWidth - 800 then camX = levelWidth - 800 end
end

function love.keypressed(key)
    if gameState == "title" then
        if key == "return" then gameState = "playing"
        elseif key == "c" then gameState = "credits" end
        return
    end
    if gameState == "credits" then
        if key == "escape" or key == "backspace" or key == "c" then gameState = "title" end
        return
    end
    if key == "r" then
        initGame()
        gameState = "playing"
        bgm:play()
    end
    if gameState == "playing" and evolutionPause <= 0 then
        if key == "space" or key == "w" or key == "up" then player:jump() end
        if key == "e" and player.stage == 3 then
            for _, b in ipairs(breakables) do
                local centerX = player.x + player.width/2
                local dist = math.abs(centerX - (b.x + b.width/2))
                if b.intact and dist < 80 then
                    b.intact = false
                    sfx.break_obj:stop()
                    sfx.break_obj:play()
                    startShake(0.2, 4)
                    particles:spawn(b.x + b.width/2, b.y + b.height/2, {0.5, 0.5, 0.5}, 15)
                end
            end
        end
    end
    if key == "escape" then love.event.quit() end
end

function drawParchmentPanel(x, y, w, h, title)
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", x+4, y+4, w, h, 15)
    -- Main Panel
    love.graphics.setColor(0.98, 0.94, 0.85)
    love.graphics.rectangle("fill", x, y, w, h, 15)
    -- Border
    love.graphics.setColor(0.4, 0.25, 0.1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, w, h, 15)
    
    if title then
        love.graphics.setFont(fonts.medium)
        love.graphics.printf(title, x, y + 10, w, "center")
    end
end

function drawSpringBackground()
    -- Sky
    love.graphics.setColor(0.6, 0.8, 1.0)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Hills
    for i, h in ipairs(hills) do
        love.graphics.setColor(h.color[1], h.color[2], h.color[3])
        love.graphics.ellipse("fill", h.x - (camX * 0.2 % 300), 550, 400, h.h)
        love.graphics.ellipse("fill", h.x + 300 - (camX * 0.2 % 300), 550, 400, h.h)
    end
    
    -- Clouds
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, c in ipairs(clouds) do
        love.graphics.ellipse("fill", c.x, c.y, c.w, c.w*0.4)
    end

    -- Petals
    love.graphics.setColor(1, 0.8, 0.9, 0.6)
    for _, p in ipairs(petals) do
        love.graphics.push()
        love.graphics.translate(p.x - camX, p.y)
        love.graphics.rotate(p.angle)
        love.graphics.rectangle("fill", -4, -2, 8, 4, 2)
        love.graphics.pop()
    end
end

function drawHUD()
    drawParchmentPanel(10, 10, 240, 130)
    
    love.graphics.setColor(0.2, 0.4, 0.1)
    love.graphics.setFont(fonts.medium)
    love.graphics.print("Bloom & Become", 20, 20)
    
    love.graphics.setColor(0.6, 0.5, 0.1)
    love.graphics.setFont(fonts.regular)
    local nextGoal = (player.stage == 1) and 5 or ((player.stage == 2) and 10 or "MAX")
    love.graphics.print("Sunlight: " .. evolutionEnergy .. " / " .. nextGoal, 25, 55)
    
    love.graphics.setColor(0.1, 0.5, 0.1)
    local stageName = (player.stage == 1) and "Sprout" or ((player.stage == 2) and "Vine Sprout" or "Tree Form")
    love.graphics.print("Form: " .. stageName, 25, 75)
    
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.setFont(fonts.small)
    local ability = "None"
    if player.stage == 2 then ability = "Climb (W/S on Vines)" end
    if player.stage == 3 then ability = "Break Rocks (E near rock)" end
    love.graphics.print("Ability: " .. ability, 25, 100)
    love.graphics.print("Press R to Restart", 25, 115)
end

function love.draw()
    drawSpringBackground()

    if gameState == "title" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(0.2, 0.5, 0.1)
        love.graphics.printf("Bloom & Become", 0, 100, 800, "center")
        
        drawParchmentPanel(250, 250, 300, 60, "Enter to Start")
        drawParchmentPanel(250, 320, 300, 60, "C for Credits")
        
        drawParchmentPanel(150, 420, 500, 120)
        love.graphics.setColor(0.4, 0.25, 0.1)
        love.graphics.setFont(fonts.regular)
        love.graphics.printf("Controls:\nMove: A/D | Jump: Space\nVine Form: W/S to Climb\nTree Form: E to Break Rocks", 150, 440, 500, "center")
        return
    end

    if gameState == "credits" then
        drawParchmentPanel(100, 50, 600, 500, "CREDITS")
        love.graphics.setColor(0.4, 0.25, 0.1)
        love.graphics.setFont(fonts.regular)
        local credits = [[
Art Assets:
"Pixel Platformer" by Kenney (CC0)
Via uheartbeast/Pixel-Platformer repository

Audio Assets:
"Starter Kit 3D Platformer" by Kenney (CC0)
"Jingles" by Kenney (CC0)

Tools:
Engine: LÖVE (Love2D)
Language: Lua
Code Assistance: Gemini CLI (Google)

Design & Development:
Created for the "Evolution" Game Jam
]]
        love.graphics.printf(credits, 100, 120, 600, "center")
        love.graphics.setFont(fonts.medium)
        love.graphics.printf("Press Escape to Return", 100, 480, 600, "center")
        return
    end

    love.graphics.push()
    if shakeTime > 0 then
        love.graphics.translate((math.random()-0.5) * shakeIntensity, (math.random()-0.5) * shakeIntensity)
    end
    love.graphics.translate(-camX, 0)

    love.graphics.setColor(1, 1, 1)
    local ts = 18
    for x = 0, levelWidth, ts do
        love.graphics.draw(tilesImg, quads.grass, x, 500)
        for y = 500 + ts, 600, ts do
            love.graphics.draw(tilesImg, quads.dirt, x, y)
        end
    end
    
    for _, obs in ipairs(obstacles) do
        for ox = obs.x, obs.x + obs.width - ts, ts do
            for oy = obs.y, obs.y + obs.height - ts, ts do
                love.graphics.draw(tilesImg, quads.dirt, ox, oy)
            end
        end
    end
    
    for _, vine in ipairs(vines) do
        for y = vine.y, vine.y + vine.height - ts, ts do
            love.graphics.draw(tilesImg, quads.vine, vine.x, y)
        end
    end
    
    for _, item in ipairs(collectibles) do item:draw() end
    for _, b in ipairs(breakables) do
        if b.intact then love.graphics.draw(tilesImg, quads.rock, b.x, b.y, 0, b.width/ts, b.height/ts) end
    end
    love.graphics.draw(tilesImg, quads.shrine, goal.x, goal.y, 0, 2, 4)

    player:draw()
    particles:draw()
    love.graphics.pop()

    drawHUD()

    if gameState == "won" then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        drawParchmentPanel(150, 200, 500, 200, "SPRING HAS BLOOMED!")
        love.graphics.setColor(0.4, 0.25, 0.1)
        love.graphics.setFont(fonts.medium)
        love.graphics.printf("Press R to Play Again", 150, 300, 500, "center")
    end
end
