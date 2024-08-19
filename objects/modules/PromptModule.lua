if (_G["PromptModule"]) then
    return _G["PromptModule"]
end

local BaseModule = require "objects.modules.BaseModule"

--[[
PromptModule
====
Muestra un simple prompt del sistema indicando por ejemplo una letra de unidad a modo cmd, por 
defecto mostrará 'c :>'

EXAMPLE
=======
```lua
local PromptModule = require('PromptModule')
local m = nil
function love.load()
    {
        name = "prompt_1",
        width = 20,
        align = 'left', -- 'center'
        font = love.graphics.newFont(30),
        color = { 255, 127, 255 },
        cursor = false
    }
    m = PromptModule("root ~", 20, 50, commondOpts)
end
function love.update(dt)
    if(m)then m:update(dt) end
end
function love.draw()
    if(m)then m:draw() end
end
```
]]
local PromptModule = BaseModule:extend()

--local Input = require("_LIBS_.boipushy.Input")
--local utils = require "utils"

function PromptModule:new(text, x, y, opts) --, delay, width, align, x, y, font, colour, cursor)
    PromptModule.super.new(self, text, x, y, opts)
    self.type = "PromptModule"
    self.text = self.text or "c :>"
end

--[[function PromptModule:destroy()
    PromptModule.super.destroy(self)
end]]

function PromptModule:update(dt)
    local res = PromptModule.super.update(self, dt)
    if(not res)then return false end
    -- ...
    self.finish = true
    return true
end


--[[function PromptModule:draw()
    local res = PromptModule.super.draw(self)
    if (not res) then return false end
    -- ...
    return true
end
function PromptModule:textinput(t)
    self.remove = false
    if (self.finish) then return false end
    -- ...
    return true
end]]

return PromptModule
