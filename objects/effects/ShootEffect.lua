if (_G["ShootEffect"]) then
    return _G["ShootEffect"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"

-- Aparenta un cuadrado que aparece y desaparece en el borde del gameobject como 
-- si se hubiese realizado un disparo, o explosión.  
-- Sirve como efecto simple para gameobjects que disparan, admite que se le pase
-- como parámetros el disparador padre, el color del efecto, sus dimensiones, su 
-- escala y el tiempo de vida (después del cual se autodestruye).  
-- Por ejemplo:  
--[[
    ```lua
    ShootEffect(
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
local ShootEffect = GameObject:extend()

-- necesita llamar posteriormente a love.graphics.pop()
function ShootEffect.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function ShootEffect:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    ShootEffect.super.new(self, game_object, x, y, opts)

    self.x, self.y = x, y
    self.w, self.h = 8, 8

    self.color = opts.color or {255, 255, 255, 150}
    self.scaleX = opts.scaleX or 0.5
    self.scaleY = opts.scaleY or 0.5

    -- recibe en las opciones un parámetro "d" que indica el diámetro del padre
    --self.timer:tween(0.1, self, { w = 0 }, 'in-out-cubic', function() self:kill() end)
end

function ShootEffect:kill()
    ShootEffect.super.kill(self)
    --if self.collider then self.collider:destroy() end
    --self.collider = nil
end

function ShootEffect:update(dt)
    --if(self.dead)then return end
    ShootEffect.super.update(self, dt)
    if self.dead then return end

    if self.parent then
        self.x = self.parent.x + self.d * math.cos(self.parent.r)
        self.y = self.parent.y + self.d * math.sin(self.parent.r)
    end

    --self.v = math.min(self.v + self.a * dt, self.max_v)
end

function ShootEffect:draw()
    local result = ShootEffect.super.draw(self)
    if (not result) then return false end

    love.graphics.setColor(self.color)
    --love.graphics.setColor(default_color)
    --love.graphics.circle('line', self.x, self.y, self.w)
    --love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))
    --love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    if(self.parent)then
        ShootEffect.pushRotateScale(self.x, self.y, self.parent.r + math.pi / 4, self.scaleX, self.scaleY)
            love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
        love.graphics.pop()
    else
        love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    end
end

return ShootEffect