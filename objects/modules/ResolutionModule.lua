if (_G["ResolutionModule"]) then
    return _G["ResolutionModule"]
end

local OptionsModule = require "objects.modules.OptionsModule"

--[[
ResolutionModule
====

EXAMPLE
=======
```lua
local ResolutionModule = require('ResolutionModule')
local m = nil
function love.load()
    {
        name = "res_1",
        delay = 0.02,
        width = 100,
        line_height = 16,
        options = {"uno", "dos", "tres"}
        align = 'left', -- 'center'
        font = love.graphics.newFont(24),
        color = { 255, 127, 255 },
        cursor = true,
        action = function(txt) print(txt) end
    }
    m = ResolutionModule("Resoluciones admitidas: ", 20, 50, commondOpts)
end
function love.update(dt)
    if(m)then m:update(dt) end
end
function love.draw()
    if(m)then m:draw() end
end
```
]]
local ResolutionModule = OptionsModule:extend()

--local Input = require("_LIBS_.boipushy.Input")

function ResolutionModule:new(text, x, y, opts)
    opts.options = {}
    ResolutionModule.super.new(self, text, x, y, opts)
    self.type = "ResolutionModule"

    self.selection_index = sx
    self.selection_options = { gw .. "x" .. gh, (gw * 2) .. "x" .. (gh * 2), (gw * 3) .. "x" .. (gh * 3), (gw * 4) ..
    "x" .. (gh * 4) }
    local d = self.delay
    for _, opt in ipairs(self.selection_options) do
        d = d + 0.02
        --self.console:addLine("- " .. opt, d)
        self.console:addLine(nil, d, { text2 = "" .. opt, color = self.color })
        --table.insert(self.selection_options, opt)
    end
end

--[[
function ResolutionModule:destroy()
    ResolutionModule.super.destroy(self)
    --self.active = false
end
function ResolutionModule:update(dt)
    print("ResolutionModule", dt)
    local res = ResolutionModule.super.update(self, dt)
    if (not res or not self.active) then return false end

    return true
end

function ResolutionModule:drawCursor()
    if (not self.cursor_show) then return false end
    local width = self.selection_options[self.selection_index]
    local r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, 0.4)
    local x_offset = self.console.font:getWidth('    ')
    love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.selection_index * self.line_height,
        width + 4, self.console.font:getHeight())
    love.graphics.setColor(r, g, b, 1)
    return true
end

function ResolutionModule:draw()
    local res = ResolutionModule.super.update(self)
    if (not res) then return false end
    --if (not res or not self.active) then return false end
    --love.graphics.setColor(self.color)
    --love.graphics.setFont(self.font)
    --love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
    return true
end]]

function ResolutionModule:textinput(t)
    if (self.finish) then return false end
    --if not self.active then return end
    --print('ResolutionModule.lua', t)
    if (t == "enter") or (t == "intro") or (t == "return") then
        --print("enter")
        self.finish = true
        self.cursor = false
        --self.active = false
        resize(self.selection_index)
        --self.console:addLine('', 0.02)
    elseif (t == "up") then
        self.selection_index = self.selection_index - 1
        if self.selection_index < 1 then self.selection_index = #self.selection_options end
    elseif (t == "down") then
        self.selection_index = self.selection_index + 1
        if self.selection_index > #self.selection_options then self.selection_index = 1 end
        if #self.selection_options == 0 then self.selection_index = 0 end
    else
        --print("??", t)
    end
    return true
end

return ResolutionModule
