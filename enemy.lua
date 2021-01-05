local enemy = {}
enemy.__index = enemy

function enemy.new(t, x, y, a, s, r)
    local e = {}
    setmetatable(e, enemy)

    -- enemy definition
    -- determine the enemy type

    e.x = x
    e.y = y
    e.angle = a or 0
    e.speed = s
    e.radius = r
    e.firerate = 0.75
    -- internal variables
    e.firetimer = 0
    e.canfire = false
    e.texture = enemytex[1]

    -- Enemy type, randomly selected based on the global LEVEL, it controls the type of behaviour in the update call
    local types = {
        {1,2,3,4},
        {1},
        {1},
        {1},
        {1}
    }

    -- randomly select an enemy
    e.type = t or types[LEVEL][math.random(#types[LEVEL])]
    print(e.type)

    -- init the enemy
    if e.type == 1 then
        -- linear going down
        e.angle = math.pi/2
        e.speed = 100
        e.radius = 16
        e.firerate = 0.75
        e.texture = enemytex[1]
    elseif e.type == 2 then
        -- linear going down
        e.angle = math.pi/2
        e.speed = 100
        e.radius = 16
        e.firerate = 1
        e.texture = enemytex[2]
    elseif e.type == 3 then
        -- sine wave going down
        e.angle = math.pi/2
        e.speed = 100
        e.radius = 16
        e.firerate = 0.5
        e.sinrate = 2
        e.sintimer = 0
        e.texture = enemytex[2]
    elseif e.type == 4 then
        -- random horizontal
        e.x = LEFT
        e.y = math.random(32, 256)
        e.angle = 0
        e.direction = "left"
        if math.random() > 0.5 then
            e.direction = "right"
            e.x = WIDTH
            e.angle = math.pi
        end
        e.speed = 200
        e.radius = 16
        e.firerate = 1
        e.texture = enemytex[3]
    elseif e.type == 101 then
        -- boss

    end

    return e
end

function enemy:update(dt)
    -- Setup by type
    if self.type == 1 then
        -- 1 - linear with two shots 
        -- process movement
        self.y = self.y + math.sin(self.angle) * self.speed * dt
        self.x = self.x + math.cos(self.angle) * self.speed * dt

        -- process shooting
        self.firetimer = self.firetimer + dt
        if self.firetimer >= self.firerate then
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4, 400, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*3, 400, "enemy", 8))
            self.firetimer = self.firetimer - self.firerate
        end
        
    elseif self.type == 2 then
        -- 2 - linear with 8 shots
        -- process movement
        self.y = self.y + math.sin(self.angle) * self.speed * dt
        self.x = self.x + math.cos(self.angle) * self.speed * dt

        -- process shooting
        self.firetimer = self.firetimer + dt
        if self.firetimer >= self.firerate then
            NEWBULLET(bullet_class.new(self.x, self.y, 0, 200, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4, 200, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*2, 200, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*3, 200, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi, 200, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*5, 200, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*6, 200, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*7, 200, "enemy", 8))
            self.firetimer = self.firetimer - self.firerate
        end
    elseif self.type == 3 then
        -- 3 - sine with 2 shot a little apart
        -- process sin timer
        self.sintimer = self.sintimer + dt * self.sinrate

        -- process movement
        self.y = self.y + math.sin(self.angle) * self.speed * dt
        self.x = self.x + math.cos(self.angle) * self.speed * dt + math.cos(self.sintimer)

        -- process shooting
        self.firetimer = self.firetimer + dt
        if self.firetimer >= self.firerate then
            NEWBULLET(bullet_class.new(self.x-32, self.y, math.pi/2, 400, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x+32, self.y, math.pi/2, 400, "enemy", 8))
            self.firetimer = self.firetimer - self.firerate
        end
        
        
    elseif self.type == 4 then
        -- 4 - horizontal movement with 4 45 deg shots
        -- process movement
        local dir = 1
        if self.direction == "right" then
            dir = -1
        end
        self.x = self.x + self.speed * dt * dir
        -- process shooting
        self.firetimer = self.firetimer + dt
        if self.firetimer >= self.firerate then
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4, 400, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*3, 400, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*5, 400, "enemy", 8))
            NEWBULLET(bullet_class.new(self.x, self.y, math.pi/4*7, 400, "enemy", 8))
            self.firetimer = self.firetimer - self.firerate
        end
        
    elseif self.type == 101 then
        -- 101 - boss 1
        
    end

end

function enemy:draw()
    love.graphics.draw(self.texture, self.x, self.y, self.angle, 1, 1, self.texture:getWidth()/2, self.texture:getHeight()/2)
    -- love.graphics.circle("fill", self.x, self.y, self.radius)
end

return enemy