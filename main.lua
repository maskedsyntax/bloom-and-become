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

-- Juice
local shakeTime = 0
local shakeIntensity = 0
local particles
local evolutionPause = 0

-- Assets
local tilesImg
local charactersImg
local quads = {}
local bgm
local sfx = {}

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
    table.insert(collectibles, Collectible.new(350, 400, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(500, 450, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(650, 350, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(800, 450, "sunlight", tilesImg))
    
    -- --- SECTION 2: VINE (800-1500) ---
    table.insert(obstacles, {x = 1000, y = 320, width = 100, height = 180, color = {0.3, 0.3, 0.3}})
    table.insert(vines, {x = 1040, y = 150, width = 20, height = 350})
    
    table.insert(collectibles, Collectible.new(1040, 100, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(1150, 250, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(1250, 450, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(1350, 400, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(1450, 450, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(1550, 350, "sunlight", tilesImg))
    
    -- --- SECTION 3: TREE (1500-2500) ---
    table.insert(breakables, {x = 1700, y = 440, width = 60, height = 60, intact = true})
    table.insert(collectibles, Collectible.new(1850, 450, "sunlight", tilesImg))
    table.insert(collectibles, Collectible.new(2000, 400, "sunlight", tilesImg))
    table.insert(breakables, {x = 2200, y = 400, width = 40, height = 100, intact = true})
    
    goal = {x = 2400, y = 430, width = 40, height = 70}
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.5, 0.8, 1.0)
    
    tilesImg = love.graphics.newImage("assets/sprites/environment/tiles_packed.png")
    charactersImg = love.graphics.newImage("assets/sprites/player/characters_packed.png")
    
    local ts = 18
    quads.grass = love.graphics.newQuad(0, 0, ts, ts, tilesImg:getDimensions())
    quads.dirt = love.graphics.newQuad(0, ts, ts, ts, tilesImg:getDimensions())
    quads.vine = love.graphics.newQuad(198, 144, ts, ts, tilesImg:getDimensions())
    quads.rock = love.graphics.newQuad(36, 18, ts, ts, tilesImg:getDimensions())
    quads.shrine = love.graphics.newQuad(162, 144, ts, ts, tilesImg:getDimensions())
    
    bgm = love.audio.newSource("assets/audio/music/spring_ambient.ogg", "stream")
    bgm:setLooping(true)
    bgm:setVolume(0.5)
    
    sfx.jump = love.audio.newSource("assets/audio/sfx/jump.ogg", "static")
    sfx.collect = love.audio.newSource("assets/audio/sfx/collect.ogg", "static")
    sfx.break_obj = love.audio.newSource("assets/audio/sfx/break.ogg", "static")
    sfx.evolve = love.audio.newSource("assets/audio/sfx/evolve.ogg", "static")
    sfx.win = love.audio.newSource("assets/audio/sfx/win.ogg", "static")
    
    initGame()
    bgm:play()
end

function startShake(time, intensity)
    shakeTime = time
    shakeIntensity = intensity
end

function love.update(dt)
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

    local oldX, oldY = player.x, player.y
    player:update(dt, onVine)
    
    if player.y > 600 then
        player.x = 50
        player.y = 450
        player.yVel = 0
    end

    local function checkSolidCollision(obj)
        if player.x < obj.x + obj.width and
           obj.x < player.x + player.width and
           player.y < obj.y + obj.height and
           obj.y < player.y + player.height then
            player.x = oldX
            player.xVel = 0
        end
    end

    for _, obs in ipairs(obstacles) do checkSolidCollision(obs) end
    for _, b in ipairs(breakables) do
        if b.intact then checkSolidCollision(b) end
    end
    
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
        if player.x < goal.x + goal.width and
           goal.x < player.x + player.width and
           player.y < goal.y + goal.height and
           goal.y < player.y + player.height then
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
        if key == "return" then
            gameState = "playing"
        elseif key == "c" then
            gameState = "credits"
        end
        return
    end

    if gameState == "credits" then
        if key == "escape" or key == "backspace" or key == "c" then
            gameState = "title"
        end
        return
    end

    if key == "r" then
        initGame()
        gameState = "playing"
        bgm:play()
    end

    if gameState == "playing" and evolutionPause <= 0 then
        if key == "space" or key == "w" or key == "up" then
            player:jump()
        end
        
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
    
    if key == "escape" then
        love.event.quit()
    end
end

function drawHUD()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 5, 5, 260, 110)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Bloom & Become", 10, 10)
    
    love.graphics.setColor(1, 0.9, 0)
    local nextGoal = (player.stage == 1) and 5 or ((player.stage == 2) and 10 or "MAX")
    love.graphics.print("Sunlight: " .. evolutionEnergy .. " / " .. nextGoal, 10, 35)
    
    local stageName = (player.stage == 1) and "Sprout" or ((player.stage == 2) and "Vine Sprout" or "Tree Form")
    love.graphics.setColor(0.2, 0.8, 0.2)
    if player.stage == 3 then love.graphics.setColor(0.5, 0.3, 0.1) end
    love.graphics.print("Form: " .. stageName, 10, 55)
    
    love.graphics.setColor(1, 1, 1)
    local ability = "None"
    if player.stage == 2 then ability = "Climb (Up/Down on Vines)" end
    if player.stage == 3 then ability = "Break Rocks (E near rock)" end
    love.graphics.print("Ability: " .. ability, 10, 75)
    love.graphics.print("Press R to Restart", 10, 95)
end

function love.draw()
    if gameState == "title" then
        love.graphics.printf("Bloom & Become", 0, 150, 800, "center", 0, 2, 2)
        love.graphics.printf("Press Enter to Start", 0, 300, 800, "center")
        love.graphics.printf("Press C for Credits", 0, 330, 800, "center")
        love.graphics.printf("Controls:\nMove: A/D | Jump: Space\nVine Form: Up/Down to Climb\nTree Form: E to Break Rocks", 0, 420, 800, "center")
        return
    end

    if gameState == "credits" then
        love.graphics.printf("CREDITS", 0, 50, 800, "center", 0, 1.5, 1.5)
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
        love.graphics.printf(credits, 0, 120, 800, "center")
        love.graphics.printf("Press Escape to Return", 0, 530, 800, "center")
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
        if b.intact then
            love.graphics.draw(tilesImg, quads.rock, b.x, b.y, 0, b.width/ts, b.height/ts)
        end
    end
    
    love.graphics.draw(tilesImg, quads.shrine, goal.x, goal.y, 0, 2, 4)

    player:draw()
    particles:draw()
    
    love.graphics.pop()

    drawHUD()

    if gameState == "won" then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("SPRING HAS BLOOMED!", 0, 250, 800, "center", 0, 2, 2)
        love.graphics.printf("Press R to Play Again", 0, 350, 800, "center")
    end
end
