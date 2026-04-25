local Player = {}
Player.__index = Player

function Player.new(x, y, img, sfx)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = 16
    self.height = 24
    self.xVel = 0
    self.yVel = 0
    self.grounded = false
    self.stage = 1
    self.isClimbing = false
    self.facing = 1 -- 1 for right, -1 for left

    -- Constants
    self.speed = 120
    self.accel = 900
    self.friction = 800
    self.gravity = 700
    self.jumpVelocity = -400
    self.climbSpeed = 80

    -- Graphics
    self.img = img
    self.sfx = sfx
    self.quads = {}
    local cs = 24 -- Character size
    self.quads[1] = love.graphics.newQuad(0, 0, cs, cs, img:getDimensions())
    self.quads[2] = love.graphics.newQuad(24, 0, cs, cs, img:getDimensions())
    self.quads[3] = love.graphics.newQuad(48, 0, cs, cs, img:getDimensions())

    return self
end

function Player:evolve()
    if self.stage == 1 then
        self.stage = 2
        self.jumpVelocity = -450
        self.height = 32
    elseif self.stage == 2 then
        self.stage = 3
        self.width = 24
        self.height = 40
        self.jumpVelocity = -420
    end
end

function Player:update(dt, onVine)
    self.grounded = false -- Assume not grounded until proven otherwise
    local canClimb = self.stage >= 2 and onVine
    
    if canClimb and (love.keyboard.isDown("w", "up", "s", "down")) then
        self.isClimbing = true
    end
    
    if not onVine then
        self.isClimbing = false
    end

    -- Horizontal movement (Now enabled even while climbing to allow exiting vines)
    local moveDir = 0
    if love.keyboard.isDown("a", "left") then
        moveDir = moveDir - 1
        self.facing = -1
    end
    if love.keyboard.isDown("d", "right") then
        moveDir = moveDir + 1
        self.facing = 1
    end

    if moveDir ~= 0 then
        self.xVel = self.xVel + moveDir * self.accel * dt
        if math.abs(self.xVel) > self.speed then
            self.xVel = (self.xVel / math.abs(self.xVel)) * self.speed
        end
    else
        local friction = self.friction * dt
        if math.abs(self.xVel) <= friction then
            self.xVel = 0
        else
            self.xVel = self.xVel - (self.xVel / math.abs(self.xVel)) * friction
        end
    end

    if self.isClimbing then
        self.yVel = 0
        if love.keyboard.isDown("w", "up") then
            self.yVel = -self.climbSpeed
        elseif love.keyboard.isDown("s", "down") then
            self.yVel = self.climbSpeed
        end
        -- If climbing and moving away from vine, don't lock X to 0 anymore
    else
        self.yVel = self.yVel + self.gravity * dt
    end

    -- Apply velocity
    self.x = self.x + self.xVel * dt
    self.y = self.y + self.yVel * dt

    local groundY = 500
    if self.y + self.height > groundY then
        self.y = groundY - self.height
        self.yVel = 0
        self.grounded = true
        self.isClimbing = false
    end
end

function Player:jump()
    if self.grounded or self.isClimbing then
        self.yVel = self.jumpVelocity
        self.grounded = false
        self.isClimbing = false
        if self.sfx and self.sfx.jump then
            self.sfx.jump:stop()
            self.sfx.jump:play()
        end
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    local q = self.quads[self.stage]
    local cs = 24
    
    local sx = (self.width / cs) * self.facing
    local sy = (self.height / cs)
    
    local ox = cs / 2
    local oy = 0
    
    love.graphics.draw(self.img, q, self.x + self.width/2, self.y, 0, sx, sy, ox, oy)
end

return Player
