if (_G["Line"]) then
    return _G["Line"]
end

Line = Object:extend()

local tree = require "objects.basics.Tree"
local utils = require "tools.utils"

function Line:new(node_1_id, node_2_id, opts)
    self.type = "Line"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.tree = opts.tree or utils.tableMerge(tree, {})
    self.node_1_id, self.node_2_id = node_1_id, node_2_id
    self.node_1, self.node_2 = self.tree[node_1_id], self.tree[node_2_id]
    self.color = self.color or default_color
    self.originalColor = self.color
    self.active = false
end

function Line:destroy()
    --if self.room and self.room.input then self.room.input:unbind("left_click2") end
    --self.input:unbindAll()
    --Line.super.destroy(self)
    self.node_1, self.node_2 = nil, nil
    self.tree = nil
end

function Line:update(dt)

end

function Line:draw()
    local r, g, b = unpack(self.color)
    if self.active then
        love.graphics.setColor(r, g, b, 1)
    else
        love.graphics.setColor(r, g, b, 0.3)
    end
    love.graphics.line(self.node_1.x, self.node_1.y, self.node_2.x, self.node_2.y)
    love.graphics.setColor(r, g, b, 1)
end

return Line