local Collectible = {}
Collectible.__index = Collectible

function Collectible.new(x, y, type, img)
    local self = setmetatable({}, Collectible)
    self.x = x
    self.y = y
    self.width = 18
    self.height = 18
    self.type = type or "sunlight"
    self.collected = false
    
    -- Graphics
    self.img = img
    local ts = 18
    if self.type == "sunlight" then
        self.quad = love.graphics.newQuad(198, 126, ts, ts, img:getDimensions())
    else
        self.quad = love.graphics.newQuad(198, 144, ts, ts, img:getDimensions())
    end
    
    return self
end

function Collectible:draw()
    if not self.collected then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.img, self.quad, self.x, self.y)
    end
end

function Collectible:checkCollision(player)
    if self.collected then return false end
    
    return player.x < self.x + self.width and
           self.x < player.x + player.width and
           player.y < self.y + self.height and
           self.y < player.y + player.height
end

return Collectible
