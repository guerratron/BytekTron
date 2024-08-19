if (_G["TrailProjectil"]) then
    return _G["TrailProjectil"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"
local utils      = require "tools.utils"

-- Aparenta un rastro dejado por el gameobject como una cola que desaparece.  
-- Sirve como efecto simple para gameobjects que se muevan, admite que se le pase
-- como parámetros el disparador padre, el color del efecto, sus dimensiones, su 
-- escala y el tiempo de vida (después del cual se autodestruye).  
-- Por ejemplo:  
--[[
    ```lua
    TrailProjectil(
        self.area,
        self.x + d * math.cos(self.r),
        self.y + d * math.sin(self.r),
        {
            parent = self,
            --color = {255, 0, 255, 200},
            --scaleX = 2,
            --scaleY = 2,
            live = 0.1, -- sirve de efecto de disparo (sg)
            d = d
        }
    )
    ```
]]
local TrailProjectil = GameObject:extend()

-- necesita llamar posteriormente a love.graphics.pop()
function TrailProjectil.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function TrailProjectil:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    TrailProjectil.super.new(self, game_object, x, y, opts)

    self.r = opts.r or utils.random(4, 6)
    self.color = opts.color or (self.parent and self.parent.trail_color) or {76, 198, 93}
    --[[self.timer:tween(
        opts.d or utils.random(0.3, 0.5),
        self,
        { r = 0 },
        'linear', -- 'in-out-cubic'
        function() self:kill() end
    )]]
    self.alpha = 0.5
    self.timer:tween(utils.random(0.1, 0.3), self, { alpha = 0 }, 'in-out-cubic', function()
        self:kill()
    end)
end

function TrailProjectil:kill()
    TrailProjectil.super.kill(self)
end

function TrailProjectil:update(dt)
    --if(self.dead)then return end
    --TrailProjectil.super.update(self, dt)
    if self.dead then return end
    --self.x = self.parent.x + self.parent.w * math.cos(self.r)
    -- en función de la dirección del padre
    --self.x = self.x - math.cos(self.parent.r)
    --self.y = self.y - math.sin(self.parent.r)
    --self.r = self.r - self.rMinus
    if(self.r <= 0)then self:kill() end
end

function TrailProjectil:draw()
    local result = TrailProjectil.super.draw(self)
    if (not result) then return false end

    TrailProjectil.pushRotateScale(self.x, self.y, self.r, 1, 1)
    local r, g, b = unpack(self.color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.x - 2 * self.s, self.y, self.x + 2 * self.s, self.y)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.pop()
end

return TrailProjectil