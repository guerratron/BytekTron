if (_G["PreAttackEffect"]) then
    return _G["PreAttackEffect"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"

-- Crea un efecto de precarga o preataque en el borde del gameobject como 
-- si se fuese a realizar un disparo, o explosión.  
-- Sirve como efecto simple para gameobjects que disparan, admite que se le pase
-- como parámetros el disparador padre, el color del efecto, sus dimensiones, su 
-- escala, el tiempo de vida (después del cual se autodestruye), ...  
-- Por ejemplo:  
--[[
    ```lua
    PreAttackEffect(
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
local PreAttackEffect = GameObject:extend()

local TargetParticle = require "objects.effects.TargetParticle"
local utils = require "tools.utils"

function PreAttackEffect:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    PreAttackEffect.super.new(self, game_object, x, y, opts)

    self.x, self.y = x, y
    self.w, self.h = 8, 8

    self.color = opts.color or {255, 255, 255, 150}
    self.scaleX = opts.scaleX or 0.5
    self.scaleY = opts.scaleY or 0.5

    -- recibe en las opciones un parámetro "d" que indica el diámetro del padre
    --self.timer:tween(0.1, self, { w = 0 }, 'in-out-cubic', function() self:kill() end)
    if(self.timer)then
        self.handler1 = self.timer:every(0.02, function()
            --[[self.area:addGameObject('TargetParticle',
                self.x + random(-20, 20), self.y + random(-20, 20),
                { target_x = self.x, target_y = self.y, color = self.color })]]
            local eff = TargetParticle(
                self.area,
                self.x + utils.random(-20, 20),
                self.y + utils.random(-20, 20),
                {
                    --parent = self,
                    --live = 0.1, -- sirve de efecto de disparo (sg)
                    target_x = self.x,
                    target_y = self.y,
                    color = self.color, --{ 255, 0, 0, 150 },
                    timer = self.timer
                }
            )
            if (self.area) then self.area:add(eff) end
        end)
        self.timer:after(self.duration - self.duration / 4, function() self:kill() end)
    end
end

function PreAttackEffect:kill()
    if(self.timer and self.handler1)then
        self.timer:cancel(self.handler1)
    end
    PreAttackEffect.super.kill(self)
    --if self.collider then self.collider:destroy() end
    --self.collider = nil
end

function PreAttackEffect:update(dt)
    --if(self.dead)then return end
    PreAttackEffect.super.update(self, dt)
    if self.dead then return end

    if self.shooter and not self.shooter.dead then
        self.x = self.shooter.x + 1.4 * self.shooter.w * math.cos(self.shooter.collider:getAngle())
        self.y = self.shooter.y + 1.4 * self.shooter.w * math.sin(self.shooter.collider:getAngle())
    end
end

function PreAttackEffect:draw()
    local result = PreAttackEffect.super.draw(self)
    if (not result) then return false end
end

return PreAttackEffect