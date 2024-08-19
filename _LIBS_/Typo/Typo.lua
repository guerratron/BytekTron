if (_G["Typo"]) then
    return _G["Typo"]
end
--[[
    EFECTO MÁQUINA DE ESCRIBIR 'TYPEWRITER' (modificado por GuerraTron24 <dinertron@gmail.com>)
    ======================================
    
Typo
====

FROM: https://github.com/sonic2kk/Typo  

Typo - Typewriter effect for LÖVE  
Compatible with LÖVE 11.5 (Mysterious Mysteries).  
Created by Eamonn Rea

LICENSE
====

License is GNU GPL v3, and it can be found at COPYING.txt

EXAMPLE
=======
```lua
require('Typo')
function love.load()
    typo_new("Hello, World", 0.5, 500, 'center', 0, 0, love.graphics.newFont(30), { 255, 255, 255 })
end
function love.update(dt)
    typo_update(dt)
end
function love.draw()
    typo_draw()
end
```
]]
local Typo = Object:extend()

function Typo:new(text, x, y, opts)
    --text, delay, width, align, x, y, font, colour, cursor
    self.txt = text -- retiene el valor completo de texto original
    self.x = x
    self.y = y
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    --[[]]
    self.type = opts.type or "normal"
    self.delay = opts.delay or 0.2 -- espera entre escritura de caracteres
    self.width = opts.width or gw - 40
    self.align = opts.align or "left"
    self.font = opts.font
    self.color = opts.color or default_color

    self.str = {}
    self.index = 1
    self.timer = 0
    self.text = ''
    self.start = false
    self.finish = false
    self.cursor = opts.cursor
    self.cursor_show = true

    local i = 1
    if(text)then
        for c in text:gmatch('.') do
            self.str[i] = c
            i = i + 1
        end
    end
end

function Typo:destroy()
    self.start = false
    self.finish = true
    self.str = nil
    self.text = nil
end

function Typo:update(dt)
    if(self.finish)then return false end
    self.start = true
    self.timer = self.timer + dt
    if self.timer >= self.delay and self.index <= #self.str then
        self.text = self.text .. tostring(self.str[self.index])
        self.index = self.index + 1
        self.timer = 0
        self.cursor_show = not self.cursor_show
    end
    if self.index > #self.str then self.finish = true end
end

function Typo:drawCursor()
    if(not self.cursor_show)then return false end
    love.graphics.setColor(default_color)
    local char_width = self.font:getWidth('w') * 0.75
    local _x = self.x + (char_width * self.index)
    love.graphics.line(_x, self.y, _x, self.y + self.font:getHeight())
end

function Typo:draw()
    --if(self.start and not self.finish)then
    if(self.start)then
        if(self.cursor)then self:drawCursor() end
        love.graphics.setColor(self.color)
        love.graphics.setFont(self.font)
        love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
    end
end

return Typo
