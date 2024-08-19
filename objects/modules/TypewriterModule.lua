if (_G["TypewriterModule"]) then
    return _G["TypewriterModule"]
end

local BaseModule = require "objects.modules.BaseModule"

--[[
    EFECTO MÁQUINA DE ESCRIBIR 'TYPEWRITER' (modificado por GuerraTron24 <dinertron@gmail.com>)
    ======================================
    
TypewriterModule
====
Compatible with LÖVE 11.5  

Basado en https://github.com/sonic2kk/Typo by Eamonn Rea

LICENSE
====

License is GNU GPL v3

EXAMPLE
=======
```lua
local TypewriterModule = require('TypewriterModule')
local m = nil
function love.load()
    {
        name = "il_1",
        cursor_delay = 0.3,
        delay = 0.02,
        width = 100,
        align = 'left', -- 'center'
        font = love.graphics.newFont(24),
        color = { 255, 127, 255 },
        cursor = true
    }
    m = TypewriterModule("En un lugar de la Mancha ...", 20, 50, commondOpts)
end
function love.update(dt)
    if(m)then m:update(dt) end
end
function love.draw()
    if(m)then m:draw() end
end
```
]]
local TypewriterModule = BaseModule:extend()

local utils = require "tools.utils"

function TypewriterModule:new(text, x, y, opts)
    TypewriterModule.super.new(self, text, x, y, opts)
    self.type = "TypewriterModule"
    self.txt = text -- retiene el valor completo de texto original
    self.text = ""

    self.delay = opts.delay or 0.01 -- espera entre escritura de caracteres
    self.width = opts.width or gw * 40

    self.timer = 0
    self.str = {}
    self.index = 1
    self.start = false
    self.finish = false
    self.paused = opts.paused or false
    self.sound = opts.sound or false

    local i = 1
    if(text)then
        for c in text:gmatch('.') do
            self.str[i] = c
            i = i + 1
        end
    end
    --[[self.str = utils.split(self.txt, ".")
    for index, value in ipairs(self.str) do
        print("type", index, value)
    end]]
end

function TypewriterModule:setText(txt)
    self.txt = txt -- retiene el valor completo de texto original
    self.text = ""
    self.str = {}
    self.index = 1
    self.start = false
    self.finish = false

    local i = 1
    if (txt) then
        for c in txt:gmatch('.') do
            self.str[i] = c
            i = i + 1
        end
    end
end

function TypewriterModule:setPosition(pos)
    self.x, self.y = pos.x, pos.y
end

function TypewriterModule:destroy()
    TypewriterModule.super.destroy(self)
    self.txt = nil
    self.str = nil
end

function TypewriterModule:update(dt)
    if (self.paused) then return false end
    local res = TypewriterModule.super.update(self, dt)
    if (not res) then return false end
    self.start = true
    if (self.finish) then
        if (self.handler) then
            self.handler(self.text)
            --self:handler(self.text)
        end
        self.handler = nil
        return false
    end
    --[[]]
    self.timer = self.timer + dt
    if self.timer >= self.delay and self.index <= #self.str then
        self.text = self.text .. tostring(self.str[self.index])
        self.index = self.index + 1
        self.timer = 0
        --self.cursor_show = not self.cursor_show
        if(self.sound)then
            Sounds.play("key_down")--plop
        end
    end
    --[[self.cursor_timer = self.cursor_timer + dt
    if self.cursor_timer >= self.cursor_delay then
        self.text = self.text .. tostring(self.str[self.index])
        self.index = self.index + 1
        self.cursor_timer = 0
        self.cursor_show = not self.cursor_show
    end]]
    if self.index > #self.str then self.finish = true end
end

--[[function TypewriterModule:drawCursor()
    if(not self.cursor_show)then return false end
    love.graphics.setColor(default_color)
    local char_width = self.font:getWidth('w') * 0.75
    local _x = self.x + (char_width * self.index)
    love.graphics.line(_x, self.y, _x, self.y + self.font:getHeight())
end

function TypewriterModule:draw()
    --if(self.start and not self.finish)then
    if(self.start)then
        if(self.cursor)then self:drawCursor() end
        love.graphics.setColor(self.color)
        love.graphics.setFont(self.font)
        love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
    end
end]]

return TypewriterModule
