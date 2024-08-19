if (_G["Level1"]) then
    return _G["Level1"]
end

local Stage = require "objects.rooms.Stage"
local Level1 = Stage:extend()
--local Room = require "objects.basics.Room"

--local Level1 = Room:extend()

local utils= require "tools.utils"

function Level1:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "Level1",
        timer = opts.timer,
        rooms = opts.rooms,
        --camera = _camera
    }
    Level1.super.new(self, _camera, pars)
    --Level1.super.new(self, true, pars)
    self._type = "Level1"
    self.type = "Level1"
end

function Level1:drawUI3()
    if(self.dead or not self.imgFondo)then return false end
    -- love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.circle('line', gw / 2, gh / 2, 50, sx*self.zoom)--, sy*self.zoom)
    --Level1.super.drawUI2(self)
end

function Level1:draw()
    --self.camera:attach(0, 0, gw, gh)
    --self.camera:detach()
    local result = Level1.super.draw(self)
    if (not result) then return false end
    if (not self.camera or not self.areas) then return false end
    -- mark
    --self:mark(50, 50)
    self:drawUI3()
end

return Level1