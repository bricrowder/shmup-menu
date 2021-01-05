local player = {}
player.__index = player

function player.new()
    local p = {}
    setmetatable(p, player)

    -- player definition
    p.texture = love.graphics.newImage("assets/ship.png")
    p.hits = 100
    p.power = 100
    p.shield = 100
    p.speed = 400
    p.x = 400
    p.y = 600
    p.firerate = 0.1
    p.shieldrecharge = 1
    p.powerrecharge = 1
    p.radius = 32

    -- internal variables
    p.firetimer = 0
    p.canfire = false
    p.shieldrechargetimer = 0
    p.powerrechargetimer = 0
    return p
end

function player:update(dt)
    -- process keyboard input
    if love.keyboard.isDown("a") then
        self.x = self.x - self.speed * dt 
    elseif love.keyboard.isDown("d") then
        self.x = self.x + self.speed * dt 
    end
    if love.keyboard.isDown("w") then
        self.y = self.y - self.speed * dt 
    elseif love.keyboard.isDown("s") then
        self.y = self.y + self.speed * dt 
    end
    if love.keyboard.isDown("space") and self.canfire and self.power > 0 then
        NEWBULLET(bullet_class.new(self.x, self.y, math.pi*3/2, 400, "player", 8))
        self.canfire = false
        self.power = self.power - 1
    end

    -- clamp movement to game bounds
    if self.x < LEFT + self.texture:getWidth()/2 then 
        self.x = LEFT + self.texture:getWidth()/2
    elseif self.x > WIDTH - self.texture:getWidth()/2 then
        self.x = WIDTH - self.texture:getWidth()/2
    end
    if self.y < TOP + self.texture:getHeight()/2 then
        self.y = TOP + self.texture:getHeight()/2
    elseif self.y > HEIGHT - self.texture:getHeight()/2 then
        self.y = HEIGHT- self.texture:getHeight()/2
    end

    -- increment shot timer
    if not(self.canfire) then
        self.firetimer = self.firetimer + dt
        if self.firetimer >= self.firerate then
            self.canfire = true
            self.firetimer = self.firetimer - self.firerate
        end
    end

    -- increment recharge timers
    if self.power < 100 then
        self.powerrechargetimer = self.powerrechargetimer + dt
        if self.powerrechargetimer >= self.powerrecharge then
            self.powerrechargetimer = self.powerrechargetimer - self.powerrecharge
            self.power = self.power + 1
        end
    end
    if self.shield < 100 then
        self.shieldrechargetimer = self.shieldrechargetimer + dt
        if self.shieldrechargetimer >= self.shieldrecharge then
            self.shieldrechargetimer = self.shieldrechargetimer - self.shieldrecharge
            self.shield = self.shield + 1
        end
    end
end

function player:draw()
    love.graphics.draw(self.texture, self.x, self.y, 0, 1, 1, self.texture:getWidth()/2, self.texture:getHeight()/2)
end

function player:hit()
    if self.shield > 0 then
        self.shield = self.shield - 1
    else
        self.hits = self.hits - 1
    end
end

return player