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
local currentLevel = 1
local gameState = "title" -- "title", "playing", "won", "credits", "transition"
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
local evolutionText = ""
local evolutionTextTimer = 0
local windForce = 0

-- Assets
local tilesImg
local charactersImg
local quads = {}
local bgm
local sfx = {}
local fonts = {}

function initGame(level)
    currentLevel = level or 1
    collectibles = {}
    vines = {}
    obstacles = {}
    breakables = {}
    camX = 0
    shakeTime = 0
    evolutionPause = 0
    evolutionText = ""
    evolutionTextTimer = 0
    windForce = 0
    
    particles = Particles.new()
    
    if currentLevel == 1 then
        evolutionEnergy = 0
        player = Player.new(50, 450, charactersImg, sfx)
        levelWidth = 2500
        -- SECTION 1: SPROUT
        table.insert(collectibles, Collectible.new(200, 450, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(350, 420, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(500, 450, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(650, 400, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(800, 430, "sunlight", tilesImg))
        -- SECTION 2: VINE
        table.insert(obstacles, {x = 1000, y = 320, width = 100, height = 180})
        table.insert(vines, {x = 975, y = 150, width = 20, height = 350})
        table.insert(vines, {x = 1105, y = 150, width = 20, height = 350})
        table.insert(collectibles, Collectible.new(975, 100, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(1105, 100, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(1150, 250, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(1200, 450, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(1250, 450, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(1350, 400, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(1450, 450, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(1550, 350, "sunlight", tilesImg))
        -- SECTION 3: TREE
        table.insert(breakables, {x = 1700, y = 350, width = 60, height = 150, intact = true})
        table.insert(collectibles, Collectible.new(1850, 450, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(2000, 400, "sunlight", tilesImg))
        table.insert(breakables, {x = 2200, y = 350, width = 40, height = 150, intact = true})
        goal = {x = 2400, y = 430, width = 40, height = 70}
    elseif currentLevel == 2 then
        levelWidth = 3000
        windForce = -60 -- Gentle leftward push
        player.x = 50
        player.y = 450
        player.yVel = 0
        
        -- Section 1: Low-gravity feel jumping (orbs as guides)
        table.insert(collectibles, Collectible.new(300, 450, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(500, 400, "sunlight", tilesImg))
        table.insert(collectibles, Collectible.new(700, 450, "sunlight", tilesImg))
        
        -- Section 2: Precise Climbing (No redundant breakables)
        table.insert(obstacles, {x = 1000, y = 250, width = 150, height = 250})
        table.insert(vines, {x = 980, y = 100, width = 20, height = 400})
        table.insert(vines, {x = 1150, y = 100, width = 20, height = 400})
        table.insert(collectibles, Collectible.new(1065, 200, "sunlight", tilesImg)) -- Between vines
        
        -- Section 3: The Ridge (Combined Breaking + Jumping)
        -- Lowered the high orb from screenshot and removed the trap
        table.insert(obstacles, {x = 1500, y = 400, width = 200, height = 100})
        table.insert(collectibles, Collectible.new(1600, 300, "sunlight", tilesImg)) -- Reached from platform
        
        table.insert(breakables, {x = 1900, y = 350, width = 60, height = 150, intact = true})
        table.insert(collectibles, Collectible.new(2000, 450, "sunlight", tilesImg))
        
        table.insert(obstacles, {x = 2200, y = 350, width = 200, height = 150})
        table.insert(vines, {x = 2180, y = 150, width = 20, height = 350})
        table.insert(collectibles, Collectible.new(2300, 250, "sunlight", tilesImg)) -- Top of large ridge
        
        goal = {x = 2850, y = 430, width = 40, height = 70}
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    fonts.title = love.graphics.newFont("assets/fonts/Fredoka-Bold.ttf", 64)
    fonts.medium = love.graphics.newFont("assets/fonts/Fredoka-Bold.ttf", 24)
    fonts.regular = love.graphics.newFont("assets/fonts/Fredoka-Regular.ttf", 18)
    fonts.small = love.graphics.newFont("assets/fonts/Fredoka-Regular.ttf", 14)
    
    tilesImg = love.graphics.newImage("assets/sprites/environment/tiles_packed.png")
    charactersImg = love.graphics.newImage("assets/sprites/player/characters_packed.png")
    logoImg = love.graphics.newImage("assets/sprites/logo.png")
    love.window.setIcon(love.image.newImageData("assets/sprites/logo.png"))
    
    local ts = 18
    quads.grass = love.graphics.newQuad(0, 0, ts, ts, tilesImg:getDimensions())
    quads.dirt = love.graphics.newQuad(0, ts, ts, ts, tilesImg:getDimensions())
    quads.vine = love.graphics.newQuad(126, 36, ts, ts, tilesImg:getDimensions())
    quads.rock = love.graphics.newQuad(90, 18, ts, ts, tilesImg:getDimensions())
    quads.shrine = love.graphics.newQuad(198, 90, ts, ts, tilesImg:getDimensions())
    
    -- Load Audio (with safety checks)
    local success, music = pcall(love.audio.newSource, "assets/audio/music/spring_ambient.ogg", "stream")
    if success then
        bgm = music
        bgm:setLooping(true)
        bgm:setVolume(0.3)
    else
        -- Second attempt with static source
        local success2, music2 = pcall(love.audio.newSource, "assets/audio/sfx/win.ogg", "static")
        if success2 then
            bgm = music2
            bgm:setLooping(true)
            bgm:setVolume(0.1)
        end
    end
    
    sfx.jump = love.audio.newSource("assets/audio/sfx/jump.ogg", "static")
    sfx.collect = love.audio.newSource("assets/audio/sfx/collect.ogg", "static")
    sfx.break_obj = love.audio.newSource("assets/audio/sfx/break.ogg", "static")
    sfx.evolve = love.audio.newSource("assets/audio/sfx/evolve.ogg", "static")
    sfx.win = love.audio.newSource("assets/audio/sfx/win.ogg", "static")
    
    for i = 1, 8 do
        table.insert(clouds, {x = math.random(0, 800), y = math.random(20, 200), speed = math.random(5, 15), w = math.random(60, 100)})
    end
    for i = 1, 5 do
        table.insert(hills, {x = (i-1) * 300, h = math.random(100, 250), color = {0.2+(i*0.05), 0.5+(i*0.05), 0.2+(i*0.05)}})
    end
    for i = 1, 20 do
        table.insert(petals, {x = math.random(0, 2500), y = math.random(0, 600), speedX = math.random(-20, -10), speedY = math.random(20, 40), angle = math.random()*math.pi*2, rotSpeed = math.random()*2, color = {1, 0.8, 0.9}})
    end
    
    initGame()
    if bgm then bgm:play() end
end

function startShake(time, intensity)
    shakeTime = time
    shakeIntensity = intensity
end

function love.update(dt)
    for _, c in ipairs(clouds) do c.x = c.x + c.speed * dt if c.x > 800 then c.x = -c.w end end
    for _, p in ipairs(petals) do
        p.x = p.x + p.speedX * dt p.y = p.y + p.speedY * dt p.angle = p.angle + p.rotSpeed * dt
        if p.y > 600 then p.y = -10 p.x = math.random(0, 2500) end
    end
    if evolutionTextTimer > 0 then evolutionTextTimer = evolutionTextTimer - dt end
    if gameState ~= "playing" then return end
    if evolutionPause > 0 then evolutionPause = evolutionPause - dt particles:update(dt) return end
    if shakeTime > 0 then shakeTime = shakeTime - dt end
    particles:update(dt)
    
    local onVine = false
    for _, vine in ipairs(vines) do
        if player.x < vine.x + vine.width and vine.x < player.x + player.width and
           player.y < vine.y + vine.height and vine.y < player.y + player.height then
            onVine = true break
        end
    end
    if windForce ~= 0 and not player.isClimbing then player.xVel = player.xVel + windForce * dt end
    player:update(dt, onVine)
    if player.y > 600 then player.x = 50 player.y = 450 player.yVel = 0 end

    local function checkSolidCollision(obj)
        local dx = (player.x + player.width/2) - (obj.x + obj.width/2)
        local dy = (player.y + player.height/2) - (obj.y + obj.height/2)
        local combinedHalfWidth = (player.width + obj.width) / 2
        local combinedHalfHeight = (player.height + obj.height) / 2
        if math.abs(dx) < combinedHalfWidth and math.abs(dy) < combinedHalfHeight then
            local overlapX, overlapY = combinedHalfWidth - math.abs(dx), combinedHalfHeight - math.abs(dy)
            if overlapX < overlapY then
                if dx > 0 then player.x = obj.x + obj.width else player.x = obj.x - player.width end
                player.xVel = 0
            else
                if dy > 0 then player.y = obj.y + obj.height player.yVel = 0 else
                    player.y = obj.y - player.height player.yVel = 0 player.grounded = true player.isClimbing = false
                end
            end
        end
    end
    for _, obs in ipairs(obstacles) do checkSolidCollision(obs) end
    for _, b in ipairs(breakables) do if b.intact then checkSolidCollision(b) end end
    
    for _, item in ipairs(collectibles) do
        if not item.collected and item:checkCollision(player) then
            item.collected = true evolutionEnergy = evolutionEnergy + 1 sfx.collect:stop() sfx.collect:play()
            particles:spawn(item.x + item.width/2, item.y + item.height/2, {1, 0.9, 0}, 12)
            local evolved = false
            if evolutionEnergy == 5 and player.stage == 1 then player:evolve() evolutionText = "EVOLVED: VINE SPROUT\nCLIMB UNLOCKED!" evolved = true
            elseif evolutionEnergy == 10 and player.stage == 2 then player:evolve() evolutionText = "EVOLVED: TREE FORM\nBREAK UNLOCKED!" evolved = true end
            if evolved then sfx.evolve:play() evolutionPause = 0.7 evolutionTextTimer = 3.0 particles:spawn(player.x + player.width/2, player.y + player.height/2, {0.3, 1, 0.3}, 50) startShake(0.4, 8) end
        end
    end
    if player.stage == 3 and player.x < goal.x + goal.width and goal.x < player.x + player.width and
       player.y < goal.y + goal.height and goal.y < player.y + player.height then
        if currentLevel == 1 then 
            gameState = "transition" 
            if bgm then bgm:stop() end
        else 
            gameState = "won" 
            if bgm then bgm:stop() end
            sfx.win:play() 
        end
        for i=1, 100 do particles:spawn(goal.x + 20, goal.y + 35, {1, 0.5, 0.8}, 1) end
    end
    camX = player.x - 400
    if camX < 0 then camX = 0 elseif camX > levelWidth - 800 then camX = levelWidth - 800 end
end

function love.keypressed(key)
    if gameState == "title" then if key == "return" then gameState = "playing" elseif key == "c" then gameState = "credits" end return end
    if gameState == "credits" then if key == "escape" or key == "backspace" or key == "c" then gameState = "title" end return end
    if gameState == "transition" then if key == "return" then initGame(2) gameState = "playing" if bgm then bgm:play() end end return end
    if key == "r" then initGame(currentLevel) gameState = "playing" if bgm then bgm:play() end end
    if gameState == "playing" and evolutionPause <= 0 then
        if key == "space" or key == "w" or key == "up" then player:jump() end
        if key == "e" and player.stage == 3 then
            for _, b in ipairs(breakables) do
                local centerX = player.x + player.width/2
                if b.intact and math.abs(centerX - (b.x + b.width/2)) < 80 then
                    b.intact = false sfx.break_obj:stop() sfx.break_obj:play() startShake(0.25, 6)
                    particles:spawn(b.x + b.width/2, b.y + b.height/2, {0.6, 0.6, 0.6}, 25)
                end
            end
        end
    end
    if key == "escape" then love.event.quit() end
end

function drawParchmentPanel(x, y, w, h, title)
    love.graphics.setColor(0, 0, 0, 0.2) love.graphics.rectangle("fill", x+4, y+4, w, h, 15)
    love.graphics.setColor(0.98, 0.94, 0.85) love.graphics.rectangle("fill", x, y, w, h, 15)
    love.graphics.setColor(0.4, 0.25, 0.1) love.graphics.setLineWidth(3) love.graphics.rectangle("line", x, y, w, h, 15)
    if title then love.graphics.setFont(fonts.medium) love.graphics.printf(title, x, y + 10, w, "center") end
end

function drawSpringBackground()
    love.graphics.setColor(0.6, 0.8, 1.0) love.graphics.rectangle("fill", 0, 0, 800, 600)
    for i, h in ipairs(hills) do
        love.graphics.setColor(h.color[1], h.color[2], h.color[3])
        love.graphics.ellipse("fill", h.x - (camX * 0.2 % 300), 550, 400, h.h)
        love.graphics.ellipse("fill", h.x + 300 - (camX * 0.2 % 300), 550, 400, h.h)
    end
    love.graphics.setColor(1, 1, 1, 0.8)
    for _, c in ipairs(clouds) do love.graphics.ellipse("fill", c.x, c.y, c.w, c.w*0.4) end
    for _, p in ipairs(petals) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], 0.6)
        love.graphics.push() love.graphics.translate(p.x - camX, p.y) love.graphics.rotate(p.angle)
        love.graphics.rectangle("fill", -4, -2, 8, 4, 2) love.graphics.pop()
    end
end

function drawHUD()
    drawParchmentPanel(10, 10, 240, 140)
    love.graphics.setColor(0.2, 0.4, 0.1) love.graphics.setFont(fonts.medium) love.graphics.print("Bloom & Become", 20, 20)
    local nextGoal = (player.stage == 1) and 5 or 10
    local progress = math.min(evolutionEnergy / nextGoal, 1)
    if player.stage == 3 then progress = 1 end
    love.graphics.setColor(0.4, 0.25, 0.1) love.graphics.rectangle("line", 25, 55, 200, 12, 5)
    love.graphics.setColor(0.4, 0.8, 0.2) love.graphics.rectangle("fill", 25, 55, 200 * progress, 12, 5)
    love.graphics.setColor(0.6, 0.5, 0.1) love.graphics.setFont(fonts.regular)
    love.graphics.print("Sunlight: " .. evolutionEnergy .. " / " .. ((player.stage == 3) and "MAX" or nextGoal), 25, 70)
    love.graphics.setColor(0.1, 0.5, 0.1)
    local stageName = (player.stage == 1) and "Sprout" or ((player.stage == 2) and "Vine Sprout" or "Tree Form")
    love.graphics.print("Form: " .. stageName, 25, 90)
    love.graphics.setColor(0.3, 0.3, 0.3) love.graphics.setFont(fonts.small)
    local ability = "None"
    if player.stage == 2 then ability = "Climb (W/S on Vines)" elseif player.stage == 3 then ability = "Break Rocks (E near rock)" end
    love.graphics.print("Ability: " .. ability, 25, 112)
    love.graphics.print("Press R to Restart", 25, 125)
end

function love.draw()
    drawSpringBackground()
    if gameState == "title" then
        love.graphics.setColor(1, 1, 1)
        local lw, lh = logoImg:getDimensions()
        local scale = 300 / lh
        love.graphics.draw(logoImg, 400, 150, 0, scale, scale, lw/2, lh/2)
        
        drawParchmentPanel(250, 280, 300, 60, "Enter to Start")
        drawParchmentPanel(250, 350, 300, 60, "C for Credits")
        
        drawParchmentPanel(150, 440, 500, 120)
        love.graphics.setColor(0.4, 0.25, 0.1)
        love.graphics.setFont(fonts.regular)
        love.graphics.printf("Controls:\nMove: A/D | Jump: Space\nVine Form: W/S to Climb\nTree Form: E to Break Rocks", 150, 460, 500, "center")
        return
    end
    if gameState == "credits" then
        drawParchmentPanel(100, 50, 600, 500, "CREDITS")
        love.graphics.setColor(0.4, 0.25, 0.1) love.graphics.setFont(fonts.regular)
        local credits = [[Art Assets: "Pixel Platformer" by Kenney (CC0) | Audio Assets: "Starter Kit 3D Platformer" by Kenney (CC0) | Tools: Engine: LÖVE (Love2D) | Code Assistance: Gemini CLI (Google) | Design: Evolution Jam]]
        love.graphics.printf(credits, 100, 120, 600, "center")
        love.graphics.setFont(fonts.medium) love.graphics.printf("Press Escape to Return", 100, 480, 600, "center")
        return
    end
    if gameState == "transition" then
        love.graphics.setColor(0, 0, 0, 0.6) love.graphics.rectangle("fill", 0, 0, 800, 600)
        drawParchmentPanel(150, 150, 500, 300, "Level 1 Complete!")
        love.graphics.setColor(0.4, 0.25, 0.1) love.graphics.setFont(fonts.regular)
        love.graphics.printf("You are growing stronger, but the path ahead is rugged and windy...\n\nCan you reach the mountain top?", 170, 230, 460, "center")
        love.graphics.setFont(fonts.medium) love.graphics.setColor(0.2, 0.4, 0.1) love.graphics.printf("Press Enter to Continue", 150, 380, 500, "center")
        return
    end
    love.graphics.push()
    if shakeTime > 0 then love.graphics.translate((math.random()-0.5) * shakeIntensity, (math.random()-0.5) * shakeIntensity) end
    love.graphics.translate(-camX, 0)
    love.graphics.setColor(1, 1, 1)
    local ts = 18
    for x = 0, levelWidth, ts do
        love.graphics.draw(tilesImg, quads.grass, x, 500)
        for y = 500+ts, 600, ts do love.graphics.draw(tilesImg, quads.dirt, x, y) end
    end
    for _, obs in ipairs(obstacles) do
        for ox = obs.x, obs.x + obs.width - ts, ts do
            for oy = obs.y, obs.y + obs.height - ts, ts do love.graphics.draw(tilesImg, quads.dirt, ox, oy) end
        end
    end
    for _, vine in ipairs(vines) do
        for y = vine.y, vine.y + vine.height - ts, ts do love.graphics.draw(tilesImg, quads.vine, vine.x, y) end
    end
    for _, item in ipairs(collectibles) do item:draw() end
    for _, b in ipairs(breakables) do if b.intact then love.graphics.draw(tilesImg, quads.rock, b.x, b.y, 0, b.width/ts, b.height/ts) end end
    love.graphics.draw(tilesImg, quads.shrine, goal.x, goal.y, 0, 2, 4)
    player:draw() particles:draw()
    love.graphics.pop()
    drawHUD()
    if evolutionTextTimer > 0 then
        love.graphics.setColor(0,0,0,0.4*math.min(evolutionTextTimer,1)) love.graphics.rectangle("fill", 0, 250, 800, 100)
        love.graphics.setColor(1,1,1,math.min(evolutionTextTimer,1)) love.graphics.setFont(fonts.medium) love.graphics.printf(evolutionText, 0, 265, 800, "center")
    end
    if gameState == "won" then
        love.graphics.setColor(0, 0, 0, 0.7) love.graphics.rectangle("fill", 0, 0, 800, 600)
        drawParchmentPanel(150, 200, 500, 200, "SPRING HAS BLOOMED!")
        love.graphics.setColor(0.4, 0.25, 0.1) love.graphics.setFont(fonts.medium) love.graphics.printf("Press R to Play Again", 150, 300, 500, "center")
    end
end
