if (_G["ExecuteModule"]) then
    return _G["ExecuteModule"]
end

local BaseModule = require "objects.modules.BaseModule"

--[[
    Módulo para ejecutar comandos del SO
    ======================================
  
EXAMPLE
=======
```lua
local ExecuteModule = require('ExecuteModule')
local m = nil
function love.load()
    {
        name = "exec_1",
        cursor_delay = 0.3,
        width = 20,
        align = 'left', -- 'center'
        font = love.graphics.newFont(30),
        color = { 255, 127, 255 },
        cursor = true
    }
    m = ExecuteModule("Hello, World", 20, 50, commondOpts)
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
local ExecuteModule = BaseModule:extend()

function ExecuteModule:new(text, x, y, opts)
    ExecuteModule.super.new(self, text, x, y, opts)
    self.type = "ExecuteModule"
    self.suc, self.exitcode, self.code = os.execute("cmd " .. self.text) -- exitcode = "exit"|"signal"
    self.result = "[" .. self.text .. "] -> suc: " .. tostring(self.suc) .. ", exitcode: " .. tostring(self.exitcode) .. ", code: " .. tostring(self.code)
    --self.text = self.result
    self.finish = true
end

function ExecuteModule:update(dt)
    if (not dt) then
        return false
    end
    self.start = true
    if (self.finish) then
        if (self.handler) then
            self.handler(self.result)
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

return ExecuteModule
