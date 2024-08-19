if (_G["ExplodeParticle"]) then
    return _G["ExplodeParticle"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"

-- Aparenta una sencilla explosión del gameobject como multitud de líneas en todas direcciones.  
-- Sirve como efecto simple para gameobjects que impactan o se destruyen, admite que se le pase 
-- como parámetros el color del efecto, sus dimensiones y el tiempo (show/unshow) para 
-- cambiar de color.  
-- Por ejemplo: 
--[[
    ```lua
    ExplodeParticle(
        self.area,
        self.x,
        self.y,
        {
            live = -1, -- lo anula, se controla por la función "tween"
            color = { 0, 255, 255, 150 },
            numEff = 2, -- dos tipos distintos de efectos
            s = 2.5, -- semi-longitud de los fragmentos
            v = 100,
            d = 0.4,
            dist = 4 -- radio de la explosión (en función del efecto, entre 0.2 y 4)
        }
    )
    ```
]]
local ExplodeParticle = GameObject:extend()

local Timer = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local utils = require "tools.utils"

-- necesita llamar posteriormente a love.graphics.pop()
function ExplodeParticle.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function ExplodeParticle:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    ExplodeParticle.super.new(self, game_object, x, y, opts)
    --print(self.timer == self.area.timer)

    self.color = opts.color or default_color
    self.r = utils.random(0, 2 * math.pi)
    self.s = opts.s or utils.random(2, 3) -- la mitad del tamaño de la línea
    self.v = opts.v or utils.random(75, 150)
    self.line_width = 2
    self.dist = opts.dist or 1
    self.rango = (self.s * self.dist)
    self.numEff = opts.numEff or 1
    if(self.numEff == 1)then
        self.timer:tween(
            opts.d or utils.random(0.3, 0.5),
            self,
            {
                s = 0,
                v = 0,
                line_width = 0
            },
            'linear',
            function() self:kill() end
        )
    else
        self.timer:tween(
            opts.d or utils.random(0.3, 0.5),
            self,
            {
                x = (utils.random(self.x * 0.98 - self.rango, self.x * 1.02 + self.rango)),
                y = (utils.random(self.y * 0.98 - self.rango, self.y * 1.02 + self.rango)),
                s = 0,
                v = 0,
                line_width = 0
            },
            'linear',
            function() self:kill() end
        )
    end
end

function ExplodeParticle:kill()
    ExplodeParticle.super.kill(self)
    --if self.collider then self.collider:destroy() end
    --self.collider = nil
end

function ExplodeParticle:update(dt)
    --if(self.dead)then return end
    ExplodeParticle.super.update(self, dt)
    if self.dead then return end
    --print(dt, self.timer == self.area.timer)

    --self.x, self.y = self.v * math.cos(self.r), self.v * math.sin(self.r)
    --self.r = (self.r + self.d) * dt
    --self.v = math.min(self.v + self.d * dt, self.v * 2)
    if(self.numEff == 1)then
        self.x = (utils.random(self.x * 0.98 - self.rango, self.x * 1.02 + self.rango))
        self.y = (utils.random(self.y * 0.98 - self.rango, self.y * 1.02 + self.rango))
    end
end

function ExplodeParticle:draw()
    local result = ExplodeParticle.super.draw(self)
    if (not result) then return false end

    ExplodeParticle.pushRotateScale(self.x, self.y, self.r, nil, nil)
        love.graphics.setLineWidth(self.line_width)
        love.graphics.setColor(self.color)
        love.graphics.line(self.x - self.s, self.y, self.x + self.s, self.y)
        love.graphics.setColor(255, 255, 255)
        love.graphics.setLineWidth(1)
    love.graphics.pop()
end

return ExplodeParticle