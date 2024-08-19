--[[
    EFECTO MÁQUINA DE ESCRIBIR 'TYPEWRITER'
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
require('typo_OLD')
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
local typo_OLD = {}

function typo_OLD.new(text, delay, width, align, x, y, font, colour)
  local t = {
    t = text,
    delay = delay,
    width = width,
    align = align,
    x = x,
    y = y,
    font = font,
    colour = colour,

    string = {},
    index = 1,
    timer = 0,

    text = ''
  }

  local i = 1

  for c in text:gmatch('.') do
    t.string[i] = c

    i = i + 1
  end

  table.insert(typo_OLD, t)
end

function typo_OLD.update(dt)
  for i,v in ipairs(typo_OLD) do
    v.timer = v.timer + dt

    if v.timer >= v.delay and v.index <= #v.string then
      v.text = v.text .. tostring(v.string[v.index])

      v.index = v.index + 1

      v.timer = 0
    end
  end
end

function typo_OLD.draw()
  for i,v in ipairs(typo_OLD) do
    love.graphics.setColor(v.colour)
    love.graphics.setFont(v.font)
    love.graphics.printf(v.text, v.x, v.y, v.width, v.align)
  end
end

return typo_OLD
