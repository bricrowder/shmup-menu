player_class = require("player")
bullet_class = require("bullet")
enemy_class = require("enemy")
laser_class = require("laser")

function love.load()
    -- init
    -- love.graphics.setDefaultFilter("nearest","nearest")

    -- GLOBAL DEFINITIONS
    DEBUG = true
    LEFT = 200
    TOP = 20
    WIDTH = love.graphics.getWidth() - LEFT
    HEIGHT = love.graphics.getHeight() - 20
    LEVEL = 1
    starcount = 250

    -- Objects/lists of objects
    player = player_class.new()
    bullets = {}
    enemies = {}

    -- textures
    enemytex = {}
    enemytex[1] = love.graphics.newImage("assets/ship2.png")
    enemytex[2] = love.graphics.newImage("assets/ship3.png")
    enemytex[3] = love.graphics.newImage("assets/ship4.png")

    -- UI/other graphics
    sidepanel = love.graphics.newImage("assets/sidepanel.png")
    toppanel = love.graphics.newImage("assets/toppanel.png")
    stars = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())

    -- laser positions - critical to keep the xy
    lasers = {}
    -- left panel
    table.insert(lasers, laser_class.new(191, 68, math.pi/2, "laser96"))
    table.insert(lasers, laser_class.new(191, 280, math.pi/2, "laser96"))
    table.insert(lasers, laser_class.new(20, 1, 0, "laser96"))
    table.insert(lasers, laser_class.new(34, 525, 0, "laser96"))

    -- right panel
    table.insert(lasers, laser_class.new(783, 360, math.pi/2, "laser96"))
    table.insert(lasers, laser_class.new(783, 164, math.pi/2, "laser96"))
    table.insert(lasers, laser_class.new(813, 1, 0, "laser96"))
    table.insert(lasers, laser_class.new(829, 525, 0, "laser96"))

    love.graphics.setCanvas(stars)
    --generate random star field
    for i=1, starcount, 1 do
        local x = math.random(stars:getWidth())
        local y = math.random(stars:getHeight())
        local s = math.random(3)
        love.graphics.circle("fill", x, y, s)
    end
    love.graphics.setCanvas()

    -- config variables
    enemyratemin = 1
    enemyratemax = 4
    enemyrate = 1
    enemyspeedmin = 150
    enemyspeedmax = 300
    starspeed = 200

    -- internal variables
    enemytimer = 0
    state = "menu"
    starpos1 = -HEIGHT
    starpos2 = 0
    toppos = 0
    bottompos = 270
    paneldir = -1       -- -1 is to open, 1 is to close
    panelspeed = 300
    paneltrans = false
end

function love.update(dt)
    if state == "game" and not(paneltrans) then
        -- scroll background
        starpos1 = starpos1 + dt * starspeed
        starpos2 = starpos2 + dt * starspeed
        if starpos1 >= 0 then
            starpos1 = -HEIGHT
            starpos2 = 0
        end
        
        -- lasers
        for i, v in ipairs(lasers) do
            v:update(dt)
        end

        -- update player
        player:update(dt)

        -- tables to hold what bullets/enemies to remove during collisions 
        local bulletremove = {}
        local enemyremove = {}

        -- add enemies
        enemytimer = enemytimer + dt
        if enemytimer >= enemyrate then
            table.insert(enemies, enemy_class.new(nil, math.random(LEFT, WIDTH), -32, math.pi/2, math.random(enemyspeedmin, enemyspeedmax), 16))
            enemytimer = enemytimer - enemyrate
            enemyrate = math.random(enemyratemin, enemyratemax)
        end

        -- update enemies
        for i, v in ipairs(enemies) do
            v:update(dt)

            -- removal check
            if v.x < LEFT-32 or v.x > WIDTH or v.y < -32 or v.y > HEIGHT then
                table.insert(enemyremove, i)
            end
        end

        -- remove any enemies
        if #enemyremove > 0 then
            for i = #enemyremove, 1, -1 do
                table.remove(enemies, enemyremove[i])
            end
        end
        
        -- update bullets
        for i, v in ipairs(bullets) do
            local alreadyremoved = false

            v:update(dt)
        
            -- collision check
            if v.source == "player" then
                -- reset for bullet checks
                enemyremove = {}                

                for j, e in ipairs(enemies) do
                    -- calculate the distance between the player bullet and enemy
                    local dx = v.x - e.x
                    local dy = v.y - e.y
                    local d = math.sqrt(dx*dx+dy*dy)
                    if d < v.radius + e.radius then
                        -- mark both bullet and enemy for removal - set that flag for the bullet so it doesn't conflict with a bounds check removals - probably an edge case but still something
                        alreadyremoved = true
                        table.insert(bulletremove, i)
                        table.insert(enemyremove, j)
                    end
                end

                -- remove any enemies -- is this the most optimised?
                if #enemyremove > 0 then
                    for i = #enemyremove, 1, -1 do
                        table.remove(enemies, enemyremove[i])
                    end
                end

            elseif v.source == "enemy" then
                -- calculate the distance between the player bullet and enemy
                local dx = v.x - player.x
                local dy = v.y - player.y
                local d = math.sqrt(dx*dx+dy*dy)
                -- are they colliding?
                if d < v.radius + player.radius then
                    -- mark for removal - set that flag so it doesn't conflict with a bounds check removals - probably an edge case but still something
                    alreadyremoved = true
                    table.insert(bulletremove, i)
                    player:hit()
                end
            end

            -- bounds removal check
            if not(alreadyremoved) and (v.x < LEFT or v.x > WIDTH or v.y < TOP or v.y > HEIGHT) then
                table.insert(bulletremove, i)
            end
        end

        -- remove any bullets
        if #bulletremove > 0 then
            for i = #bulletremove, 1, -1 do
                table.remove(bullets, bulletremove[i])
            end
        end
    elseif state == "menu" then
        -- will have animated trasition here
    end

    -- panel transition animation
    if paneltrans then
        -- draw positions
        toppos = toppos + dt * panelspeed * paneldir
        bottompos = bottompos + dt * panelspeed * paneldir * -1

        -- check if we should stop
        if toppos <= -260 then
            toppos = -260
            bottompos = 530
            paneltrans = false
        elseif toppos >= 0 then
            toppos = 0
            bottompos = 270
            paneltrans = false            
        end
    end
end

function love.draw()
    -- background and UI
    love.graphics.draw(stars, 0, starpos1)
    love.graphics.draw(stars, 0, starpos2)

    if state == "game" or state == "menu" then
        -- -- lasers
        -- for i, v in ipairs(lasers) do
        --     v:draw()
        -- end

        -- draw bullets
        for i, v in ipairs(bullets) do
            v:draw() 
        end

        -- draw enemies
        for i, v in ipairs(enemies) do
            v:draw() 
        end

        -- draw player
        player:draw()

        -- draw text
        if DEBUG then
            love.graphics.setColor(0,0,0,1)
            -- love.graphics.print("Enemies: " .. #enemies, 10, 10)
            -- love.graphics.print("Bullets: " .. #bullets, 10, 25)
            -- love.graphics.print("Hitpoints: " .. player.hits, 10, 40)
            -- love.graphics.print("Power: " .. player.power, 10, 55)
            -- love.graphics.print("Shield: " .. player.shield, 10, 70)
            love.graphics.print("FPS: " .. love.timer.getFPS(), love.graphics.getWidth() - 60, 10)
            love.graphics.print("top: " .. toppos, love.graphics.getWidth() - 60, 25)
            love.graphics.print("bottom: " .. bottompos, love.graphics.getWidth() - 60, 40)
            love.graphics.setColor(1,1,1,1)
        end
    elseif state == "menu" then
        -- draw menu items that player will scroll through here

    end

    -- draw the panels
    love.graphics.draw(sidepanel, 0, 0)
    love.graphics.draw(sidepanel, love.graphics.getWidth(), love.graphics.getHeight(), 0, -1, -1)
    love.graphics.draw(toppanel, 200, toppos)
    love.graphics.draw(toppanel, 200, bottompos + 270, 0, 1, -1)    -- + to Y because of the rotation/origin
end

function love.keypressed(key)
    -- temp stuff
    if key == "m" then
        if state == "game" then
            state = "menu"
            -- close the gates
            paneltrans = true
            paneldir = 1
        elseif state == "menu" then
            state = "game"
            -- open the gates
            paneltrans = true
            paneldir = -1
        end
    elseif key == "escape" then
        love.event.quit()
    elseif key == "`" then
        DEBUG = not(DEBUG)
    end
end

-- adds a bullet to the list
function NEWBULLET(b)
    table.insert(bullets, b)
end