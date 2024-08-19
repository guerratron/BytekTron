if (_G["BaseModule"]) then
    return _G["BaseModule"]
end
--[[
    Módulo Base para otros Módulos (modificado por GuerraTron24 <dinertron@gmail.com>)
    ======================================
    Sirve de base para otros módulos sencillos que no requieran demasiada lógica.  
    Muestra un simple texto con posibilidad de cursor.  
    Como particularidad el texto se imprime a través de 'love.graphics.printf(..)', lo 
    cual permite opciones como ancho, alineación, ..
    
BaseModule
====
Compatible with LÖVE 11.5  

LICENSE
====
License is GNU GPL v3

EXAMPLE
=======
```lua
local BaseModule = require('BaseModule')
local m = nil
function love.load()
    {
        name = "base_1",
        cursor_delay = 0.3,
        width = 20,
        align = 'left', -- 'center'
        font = love.graphics.newFont(30),
        color = { 255, 127, 255 },
        cursor = true
    }
    m = BaseModule("Hello, World", 20, 50, commondOpts)
end
function love.update(dt)
    if(m)then m:update(dt) end
end
function love.draw()
    if(m)then m:draw() end
end
function love.textinput(t)
    if(m and m.textinput)then m:textinput(t) end
end
```
]]
local BaseModule = Object:extend()

function BaseModule:new(text, x, y, opts)
    --text, cursor_delay, width, align, x, y, font, colour, cursor
    self.type = "BaseModule"
    self.text = text or "" -- retiene el valor completo de texto original
    self.x = x
    self.y = y
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    --[[]]
    self.name = opts.name or "normal"
    self.width = opts.width or gw * 0.5
    self.align = opts.align or "left" -- center
    self.font = opts.font or love.graphics.newFont(16)
    self.color = opts.color or default_color
    self.cursor = opts.cursor -- booleano
    self.cursor_delay = opts.cursor_delay or 0.5 -- para el parpadeo del cursor
    self.cursor_timer = 0
    self.cursor_show = true
    self.resalt = opts.resalt
    self.handler = opts.action

    self.char_width = self.font:getWidth('w') * 0.75
    self.txt_w = (self.char_width * self.text:len())

    --self.timer = 0
    self.start = false
    self.finish = false
end

function BaseModule:destroy()
    self.start = false
    self.finish = true
    self.text = nil
end

function BaseModule:update(dt)
    --print("BaseModule", dt)
    if(not dt)then
        return false
    end
    self.start = true
    if (self.finish) then
        if (self.handler) then
            self.handler(self.text)
            --self.handler(self, self.text)
            --self:handler(self.text)
        end
        self.handler = nil
        return false
    end
    --self.timer = self.timer + dt
    self.cursor_timer = self.cursor_timer + dt
    --[[if self.timer >= self.cursor_delay then
        self.timer = 0
        self.cursor_show = not self.cursor_show
    end]]
    if self.cursor_timer >= self.cursor_delay then
        self.cursor_timer = 0
        self.cursor_show = not self.cursor_show
    end
    return true
end

function BaseModule:drawCursor()
    if(not self.cursor_show)then return false end
    love.graphics.setColor(default_color)
    --local char_width = self.font:getWidth('w') * 0.75
    local _x = self.x + (self.char_width * self.text:len())
    love.graphics.line(_x, self.y, _x, self.y + self.font:getHeight())
end

function BaseModule:draw()
    --if(self.start and not self.finish)then
    if(self.start)then
        if(self.resalt and not self.finish)then
            --local char_width = self.font:getWidth('w') * 0.75
            local w = (self.char_width * self.text:len())
            local bk_color = {0.05, 0.05, 0.05}
            love.graphics.setColor(bk_color)
            love.graphics.rectangle("fill", self.x, self.y, w, self.font:getHeight())
        end
        if(self.cursor and not self.finish)then self:drawCursor() end
        love.graphics.setColor(self.color)
        love.graphics.setFont(self.font)
        love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
        --print(self.type, self.x, self.y, self.width)
    end
    return true
end

function BaseModule:textinput(t)
    if (self.finish) then return false end
    return true
end

return BaseModule
