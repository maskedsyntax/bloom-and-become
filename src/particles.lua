local Particles = {}
Particles.__index = Particles

function Particles.new()
    local self = setmetatable({}, Particles)
    self.pool = {}
    return self
end

function Particles:spawn(x, y, color, count)
    for i = 1, count or 10 do
        local p = {
            x = x,
            y = y,
            dx = (math.random() - 0.5) * 200,
            dy = (math.random() - 0.5) * 200,
            life = 0.5 + math.random() * 0.5,
            maxLife = 1,
            color = color or {1, 1, 1},
            size = 2 + math.random() * 3
        }
        p.maxLife = p.life
        table.insert(self.pool, p)
    end
end

function Particles:update(dt)
    for i = #self.pool, 1, -1 do
        local p = self.pool[i]
        p.x = p.x + p.dx * dt
        p.y = p.y + p.dy * dt
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(self.pool, i)
        end
    end
end

function Particles:draw()
    for _, p in ipairs(self.pool) do
        local alpha = p.life / p.maxLife
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Particles
