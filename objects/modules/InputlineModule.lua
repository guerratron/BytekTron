if (_G["InputlineModule"]) then
    return _G["InputlineModule"]
end

local BaseModule = require "objects.modules.BaseModule"

--[[
InputlineModule
====

EXAMPLE
=======
```lua
local InputlineModule = require('InputlineModule')
local m = nil
function love.load()
    {
        name = "il_1",
        cursor_delay = 0.3,
        width = 40,
        align = 'left', -- 'center'
        font = love.graphics.newFont(30),
        color = { 255, 127, 255 },
        cursor = true
    }
    m = InputlineModule(nil, 20, 50, commondOpts)
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
local InputlineModule = BaseModule:extend()

--local Input = require("_LIBS_.boipushy.Input")
--local utils = require "utils"

function InputlineModule:new(text, x, y, opts)
    InputlineModule.super.new(self, text, x, y, opts)
    self.type = "InputlineModule"
    self.text = text or ''
    self.width = opts.width or gw * 0.3
    self.cursor = true
    self.cursor_show = true
end

--[[function InputlineModule:destroy()
    InputlineModule.super.destroy(self)
end

function InputlineModule:update(dt)
    local res = InputlineModule.super.update(self, dt)
    if (not res) then return false end
    -- ...
    return true
end]]

--[[function InputlineModule:drawCursor()
    if(not self.cursor_show)then return false end
    love.graphics.setColor(default_color)
    local char_width = self.font:getWidth('w') * 0.75
    local _x = self.x + (char_width * self.index)
    love.graphics.line(_x, self.y, _x, self.y + self.font:getHeight())
    return true
end

function InputlineModule:draw()
    local res = InputlineModule.super.draw(self)
    if (not res) then return false end
    -- ...
    return true
end]]

function InputlineModule:textinput(t)
    if (self.finish) then return false end
    -- plantilla de caracteres admitidos (no puede incluirse %)
    --[[local str = ' abcdefghijklmnñopqrstuvwxyzABCDEFGHIJKLMNÑOPQRSTUVWYXZ0123456789.:,;/-_*()[]{}"\'$&=?¿!¡ºª€+<>%'
    local i, j = nil, nil
    if (t == "%") then
        i, j = 83, 83
    else
        i, j = utils.split(str, t) --str:find(t) --string.find(str, t) --str:find(t)
    end
    print(self.type, t, j, i)]]
    
    if (t == "escape") or (t == "scape") then
        -- LO IGNORA
    elseif (t == "enter") or (t == "intro") or (t == "return") then
        self.finish = true
        self.cursor = false
    elseif (t == "backspace") then
        if(self.text:len() > 0)then
            self.text = self.text:sub(1, self.text:len() - 1)
        end
    --elseif ((i and j) and (i > 0) and (i == j)) then
    else
        self.text = self.text .. t --tostring(t)
    --else
        --print("??", t)
    end
    return true
end

return InputlineModule
