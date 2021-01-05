local laser = {}
laser.__index = laser

function laser.new(x, y, a, f)
    local l = {}
    setmetatable(l, laser)

    l.x = x
    l.y = y
    l.rotation = a

    l.images = {}
    for i=1, 3 do
        table.insert(l.images, love.graphics.newImage("assets/" .. f .. "_" .. i .. ".png"))
    end

    l.anispeed = 0.15
    l.anitimer = 0
    l.anindex = 1

    return l
end

function laser:update(dt)
    self.anitimer = self.anitimer + dt
    if self.anitimer >= self.anispeed then
        self.anitimer = self.anitimer - self.anispeed
        self.anindex = self.anindex + 1
        if self.anindex > #self.images then
            self.anindex = 1
        end
    end
end

function laser:draw()
    love.graphics.draw(self.images[self.anindex], self.x, self.y, self.rotation)
end

return laser