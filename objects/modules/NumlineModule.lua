if (_G["NumlineModule"]) then
    return _G["NumlineModule"]
end

local BaseModule = require "objects.modules.BaseModule"

--[[
NumlineModule
====
Muestra un simple prompt del sistema indicando por ejemplo una letra de unidad a modo cmd, por 
defecto mostrará 'c :>'

EXAMPLE
=======
```lua
local NumlineModule = require('NumlineModule')
local m = nil
function love.load()
    {
        name = "nl_1",
        width = 10,
        align = 'left', -- 'center'
        font = love.graphics.newFont(24),
        color = { 255, 127, 255 },
        cursor = false
    }
    m = NumlineModule("# 1", 20, 50, commondOpts)
end
function love.update(dt)
    if(m)then m:update(dt) end
end
function love.draw()
    if(m)then m:draw() end
end
```
]]
local NumlineModule = BaseModule:extend()

--local Input = require("_LIBS_.boipushy.Input")
--local utils = require "utils"

function NumlineModule:new(text, x, y, opts) --, delay, width, align, x, y, font, colour, cursor)
    NumlineModule.super.new(self, text, x, y, opts)
    self.type = "NumlineModule"
    self.text = self.text or "# 1"
end

--[[function NumlineModule:destroy()
    NumlineModule.super.destroy(self)
end]]

function NumlineModule:update(dt)
    local res = NumlineModule.super.update(self, dt)
    if(not res)then return false end
    -- ...
    --self.finish = true
    return true
end

--[[function NumlineModule:draw()
    local res = NumlineModule.super.draw(self)
    if (not res) then return false end
    -- ...
    return true
end

function NumlineModule:textinput(t)
    self.remove = false
    if (self.finish) then return false end
    -- ...
    return true
end]]

return NumlineModule
