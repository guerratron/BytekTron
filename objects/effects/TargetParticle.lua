if (_G["TargetParticle"]) then
    return _G["TargetParticle"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"

-- Aparenta unas partículas que van hacia el gameobject como un efecto de energización o carga.  
-- Sirve como efecto simple para gameobjects que disparan, admite que se le pase
-- como parámetros el disparador padre, el color del efecto, sus dimensiones, su 
-- escala, el tiempo de vida (después del cual se autodestruye), ...  
-- Por ejemplo:  
--[[
    ```lua
    TargetParticle(
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
local TargetParticle = GameObject:extend()

local utils = require "tools.utils"

function TargetParticle:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    TargetParticle.super.new(self, game_object, x, y, opts)

    --self.r = opts.r or utils.random(4, 6)
    --self.rMinus = opts.rMinus or utils.random(0.3, 0.5)
    self.color = opts.color or (self.parent and self.parent.trail_color) or {76, 198, 93}
    --[[self.timer:tween(
        opts.d or utils.random(0.3, 0.5),
        self,
        { r = 0 },
        'linear', -- 'in-out-cubic'
        function() self:kill() end
    )]]
    self.r = opts.r or utils.random(2, 3)
    self.timer:tween(
        opts.d or utils.random(0.1, 0.3),
        self,
        { r = 0, x = self.target_x, y = self.target_y },
        'out-cubic',
        function() self:kill() end
    )
end

function TargetParticle:kill()
    TargetParticle.super.kill(self)
end

function TargetParticle:update(dt)
    --if(self.dead)then return end
    --TargetParticle.super.update(self, dt)
    if self.dead then return end
end

function TargetParticle:draw()
    local result = TargetParticle.super.draw(self)
    if (not result) then return false end

    --love.graphics.setColor(self.parent.trail_color)
    love.graphics.setColor(self.color)
    --draft:rhombus(self.x, self.y, 2 * self.r, 2 * self.r, 'fill')
    love.graphics.line(
        self.x, self.y, self.x + 2 * self.r, self.y + 2 * self.r
    )
    love.graphics.setColor(default_color)
end

return TargetParticle