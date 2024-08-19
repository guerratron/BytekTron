if (_G["DeathEffect"]) then
    return _G["DeathEffect"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"

-- Aparenta un cuadrado que aparece y desaparece en las coordenadas del gameobject como
-- si se hubiese realizado una explosión.
-- Sirve como efecto simple para gameobjects que se destruyen, admite que se le pase 
-- como parámetros el color del efecto, sus dimensiones y el tiempo (show/unshow) para 
-- cambiar de color.  
-- Por ejemplo: 
--[[
    ```lua
    DeathEffect(
        self.area,
        self.x,
        self.y,
        {
            --parent = self,
            --live = 0.1, -- sirve de efecto de disparo (sg)
            color = { 0, 0, 255, 150 },
            --show = 0.2,
            --unshow = 0.25,
            w = self.w * 2
        }
    )
    ```
]]
local DeathEffect = GameObject:extend()

--local Timer = require("_LIBS_.hump.timer")
local Timer = require("_LIBS_.chrono.Timer")

function DeathEffect:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    DeathEffect.super.new(self, game_object, x, y, opts)

    self.show = opts.show or 0.1
    self.unshow = opts.unshow or 0.15

    self.first = true
    self.timer:after(self.show, function()
        self.first = false
        self.second = true
        if(self.timer)then
            self.timer:after(self.unshow, function()
                self.second = false
                --self.dead = true
                self:kill()
            end)
        else
            self.second = false
            self:kill()
        end
    end)
end

function DeathEffect:kill()
    DeathEffect.super.kill(self)
    --if self.collider then self.collider:destroy() end
    --self.collider = nil
end

function DeathEffect:update(dt)
    --if(self.dead)then return end
    DeathEffect.super.update(self, dt)
    if self.dead then return end
end

function DeathEffect:draw()
    local result = DeathEffect.super.draw(self)
    if (not result) then return false end

    love.graphics.setColor(255, 255, 255, 150)
    if self.second then
        love.graphics.setColor(self.color)
    end
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
end

return DeathEffect