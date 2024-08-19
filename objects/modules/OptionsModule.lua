if (_G["OptionsModule"]) then
    return _G["OptionsModule"]
end

local BaseModule = require "objects.modules.BaseModule"

--[[
OptionsModule
====

EXAMPLE
=======
```lua
local OptionsModule = require('OptionsModule')
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
    m = OptionsModule("Resoluciones admitidas: ", 20, 50, commondOpts)
end
function love.update(dt)
    if(m)then m:update(dt) end
end
function love.draw()
    if(m)then m:draw() end
end
```
]]
local OptionsModule = BaseModule:extend()

--local Input = require("_LIBS_.boipushy.Input")

function OptionsModule:new(text, x, y, opts)
    OptionsModule.super.new(self, text, x, y, opts)
    self.type = "OptionsModule"
    self.cursor = true
    --[[]]
    self.console = opts.console
    self.line_height = opts.line_height or 12

    --self.console:addLine('Available resolutions: ', 0.02)
    self.selection_index = 1
    self.selection_options = {}
    local d = self.delay
    for _, opt in ipairs(opts.options) do
        d = d + 0.02
        --self.console:addLine("- " .. opt, d, { withoutPrompt = true, text2 = "- " .. opt })
        --self.console:addLine(nil, d, { text2 = "" .. opt, color = self.color })
        --print("toOption: ", opt, self.console.addLine)
        self.console:addLine(nil, d, { text2 = "" .. opt, color = self.color })
        table.insert(self.selection_options, opt)
        --print(opt)
    end
    self.selection_index = opts.selected or #self.selection_options
    if(#self.selection_options == 0)then
        self.selection_index = 0
    end
--print(self.color[1], self.color[2], self.color[3])
end

function OptionsModule:destroy()
    OptionsModule.super.destroy(self)
    --self.active = false
    self.selection_options = nil
end
--[[]]
function OptionsModule:update(dt)
    --print("OptionsModule", dt)
    if (self.finish) then
        if (self.handler) then
            if(self.selection_index > 0)then
                self.handler(self.selection_index, self.selection_options[self.selection_index])
            else
                self.handler(self.selection_index)
            end
            --self.handler(self, self.text)
            --self:handler(self.text)
        end
        self.handler = nil
        return false
    end
    local res = OptionsModule.super.update(self, dt)
    if (not res or not self.active) then return false end

    return true
end

function OptionsModule:drawCursor()
    --print("options.drawCursor()")
    if (not self.cursor_show) then return false end
    if (self.selection_index == 0) then return false end
    local r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, 0.4)
    --local x_offset = self.font:getWidth('    ')
    --love.graphics.rectangle('fill', 8 + x_offset - 2, self.y + self.selection_index * self.line_height,
    --    width:len() + 4, self.font:getHeight())
    local width = "- " .. self.selection_options[self.selection_index]
    --local char_width = self.font:getWidth('w') * 0.75
    local w = (self.char_width * width:len())
    love.graphics.rectangle('fill', self.x, self.y + self.selection_index * self.line_height, w, self.font:getHeight())
    --love.graphics.setColor(r, g, b, 1)
    love.graphics.setColor(self.color)
    return true
end

--[[]]
function OptionsModule:draw()
    if (self.finish) then return false end
    if (self.start) then
        local bk_color = {0, 0, 0}
        if (self.resalt and not self.finish) then
            bk_color = { 0.05, 0.05, 0.05 }
        end
        love.graphics.setColor(bk_color)
        love.graphics.rectangle("fill", self.x, self.y, self.txt_w, self.font:getHeight())
        if (self.cursor and not self.finish) then self:drawCursor() end
        love.graphics.setColor(self.color)
        --print(self.text)
        love.graphics.setFont(self.font)
        love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
        --print(self.type, self.x, self.y, self.width)
    end
    return true
end

function OptionsModule:textinput(t)
    if (self.finish) then return false end
    --if not self.active then return end
    --print('OptionsModule.lua', t)
    if (t == "enter") or (t == "intro") or (t == "return") then
        --print(self.type, "enter")
        self.finish = true
        self.cursor = false
        --self.active = false
        --self.handler(self.console, self.selection_index)
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

return OptionsModule
