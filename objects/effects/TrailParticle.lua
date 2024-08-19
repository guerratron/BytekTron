if (_G["TrailParticle"]) then
    return _G["TrailParticle"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"
local utils      = require "tools.utils"

-- Aparenta un rastro dejado por el gameobject como una cola luminosa.  
-- Sirve como efecto simple para gameobjects que se muevan, admite que se le pase
-- como parámetros el disparador padre, el color del efecto, sus dimensiones, su 
-- escala y el tiempo de vida (después del cual se autodestruye).  
-- Por ejemplo:  
--[[
    ```lua
    TrailParticle(
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
local TrailParticle = GameObject:extend()

function TrailParticle:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    TrailParticle.super.new(self, game_object, x, y, opts)

    self.r = opts.r or utils.random(4, 6)
    self.rMinus = opts.rMinus or utils.random(0.3, 0.5)
    self.color = opts.color or (self.parent and self.parent.trail_color) or {76, 198, 93}
    --[[self.timer:tween(
        opts.d or utils.random(0.3, 0.5),
        self,
        { r = 0 },
        'linear', -- 'in-out-cubic'
        function() self:kill() end
    )]]
end

function TrailParticle:kill()
    TrailParticle.super.kill(self)
end

function TrailParticle:update(dt)
    --if(self.dead)then return end
    --TrailParticle.super.update(self, dt)
    if self.dead then return end
    --self.x = self.parent.x + self.parent.w * math.cos(self.r)
    -- en función de la dirección del padre
    self.x = self.x - math.cos(self.parent.r)
    self.y = self.y - math.sin(self.parent.r)
    self.r = self.r - self.rMinus
    if(self.r <= 0)then self:kill() end
end

function TrailParticle:draw()
    local result = TrailParticle.super.draw(self)
    if (not result) then return false end

    --love.graphics.setColor(self.parent.trail_color)
    love.graphics.setColor(self.color)
    love.graphics.circle('line', self.x, self.y, self.r)
    --[[love.graphics.line(
        self.x + self.parent.w/2,
        self.y + self.parent.w/2,
        self.x + 2 * self.parent.w * math.cos(self.r),
        self.y + 2 * self.parent.w * math.sin(self.r)
    )]]
end

return TrailParticle