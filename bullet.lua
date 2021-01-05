local bullet = {}
bullet.__index = bullet

function bullet.new(x, y, a, s, src, r)
    local b = {}
    setmetatable(b, bullet)

    -- bullet definition
    -- b.texture = love.graphics.newImage()
    b.x = x
    b.y = y
    b.angle = a
    b.speed = s
    b.source = src
    b.radius = r
    b.image = love.graphics.newImage("assets/bullet16green.png")

    return b
end

function bullet:update(dt)
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt
end

function bullet:draw()
    love.graphics.draw(self.image, self.x, self.y, self.a, 1, 1, self.image:getWidth()/2, self.image:getHeight()/2)
    -- love.graphics.circle("fill", self.x, self.y, self.radius)
end

return bullet