if (_G["LinkerEdgge"]) then
    return _G["LinkerEdgge"]
end

local LinkerEdgge = Object:extend()

-- load draft
local Draft = require('_LIBS_.draft.draft')
local draft = Draft()

local direction = "up"

function LinkerEdgge:new()
    self.limitUpper = 8
    self.limitLower = 4
    self.numSegments = self.limitLower
    self.direction = 'up'
    self.step = 0.01
end

function LinkerEdgge:destroy()

end

function LinkerEdgge:update(dt)
    if self.numSegments > self.limitUpper and direction == 'up' then
        direction = 'down'
    elseif self.numSegments < self.limitLower and direction == 'down' then
        direction = 'up'
    elseif direction == 'up' then
        self.numSegments = self.numSegments + self.step
    else
        self.numSegments = self.numSegments - self.step
    end
end

function LinkerEdgge:draw(x, y, r)
    --draft:diamond(gw * 0.8, gh * 0.8, gw * 0.01, "line")
    draft:egg(x, y, r, 1, 1, self.numSegments, 'line')
  --[[
    local v = draft:egg(400, 300, 1500, 1, 1, self.numSegments, 'line')
    draft:linkWeb(v)
    ]]
end

return LinkerEdgge