local menu = {}
menu.__index = menu

function menu.new()
    local m = {}
    setmetatable(m, menu)

    m.menu = "main"
    m.index = 1

    return m
end

function menu:update(dt)

end

function menu:draw()
    if self.menu == "main" then
        


    elseif self.menu == "options" then

    elseif self.menu == "quit" then
    
    end
end

return menu