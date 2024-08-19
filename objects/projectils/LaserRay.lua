if (_G["LaserRay"]) then
    return _G["LaserRay"]
end
--local Physics = require "_LIBS_.windfield"
local Bullet = require "objects.projectils.Bullet"

-- Aparenta un rayo laser desde el gameobject hacia el final de la pantalla abatiendo todos los 
-- enemigos a su paso.  
-- Sirve como efecto simple para gameobjects que disparen, admite que se le pase
-- como parámetros el disparador padre, el enemigo objetivo, el color del efecto, 
-- sus dimensiones, su escala y el tiempo de vida (después del cual se autodestruye).  
-- Por ejemplo:  
--[[
    ```lua
    LaserRay(
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
local LaserRay = Bullet:extend()

local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils           = require "tools.utils"

-- necesita llamar posteriormente a love.graphics.pop()
function LaserRay.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function LaserRay:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    LaserRay.super.new(self, game_object, x, y, opts)

    -- array con las líneas del rayo, con sus {x1, y1, x2, y2}
    self.lines = {}
    self.dif = math.abs(utils.distance(self.x, self.y, self.x2, self.y2))
    --self.collider = self.area.world:newCircleCollider(self.x + dist.x, self.y + dist.y, self.s)
    --local iniX, endX = math.min(self.x1, self.x2), math.max(self.x1, self.x2)
    --self.w, self.h = math.abs(self.x2 - self.x), math.abs(self.y2 - self.y)
    self.w, self.h = math.abs((self.x - self.x2) * math.cos(self.r)), math.abs((self.y - self.y2) * math.sin(self.r))
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h )
    --self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Projectile') -- se sobrescribe en los hijos
    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self:generate()
    self.count = 0
end

-- Generates lines and populates the self.lines table with them
function LaserRay:generate()
    for i = 1, love.math.random(2, 4) do
        local rnd = i * utils.tableRandom({-1, 1})
        --table.insert(self.lines, {x1 = self.x1 + rnd, y1 = self.y1 + rnd, x2 = self.x2 + rnd, y2 = self.y2 + rnd})
        table.insert(self.lines, { x1 = self.x + rnd, y1 = self.y + rnd, x2 = self.x + (self.dif + rnd) * math.cos(self.r), y2 = self.y + (self.dif + rnd) * math.sin(self.r) })
    end
    --[[
    local eff2 = nil
    local index2 = 0
    for i = 1, love.math.random(2, 4) do
        --self.area:addGameObject('ExplodeParticle', x1, y1, { color = utils.tableRandom({ default_color, boost_color }) })
        eff2 = ExplodeParticle(
            self.area,
            self.x1,
            self.y1,
            {
                --timer = self.timer,
                live = -1,  -- sirve de efecto de disparo (sg)
                color = utils.tableRandom({ default_color, boost_color }),
                numEff = 1, -- 1 = desintegración, 2 = fragmentación
                s = 1.1,    -- semi-longitud de los fragmentos
                v = 100,
                d = 0.3,    -- grosor de los gragmentos
                dist = 3    --self.w -- radio de la explosión
            }
        )
        if (self.own.area) then
            index2 = self.own.area:add(eff2)
            eff2.index = index2
            --shoot2.own = self --own == player or enemy
            table.insert(self.own.bulletsIndexes, index2)
        end
    end
    for i = 1, love.math.random(2, 4) do
        --self.area:addGameObject('ExplodeParticle', x2, y2, { color = utils.tableRandom({ default_color, boost_color }) })
        eff2 = ExplodeParticle(
            self.area,
            self.x2,
            self.y2,
            {
                --timer = self.timer,
                live = -1,  -- sirve de efecto de disparo (sg)
                color = utils.tableRandom({ default_color, boost_color }),
                numEff = 2, -- 1 = desintegración, 2 = fragmentación
                s = 1.1,    -- semi-longitud de los fragmentos
                v = 100,
                d = 0.3,    -- grosor de los gragmentos
                dist = 3    --self.w -- radio de la explosión
            }
        )
        if (self.own.area) then
            index2 = self.own.area:add(eff2)
            eff2.index = index2
            --shoot2.own = self --own == player or enemy
            table.insert(self.own.bulletsIndexes, index2)
        end
    end
    ]]
end

function LaserRay:update(dt)
    if(self.dead)then return end
    LaserRay.super.update(self, dt)

    -- NO ES CAPAZ DE DETECTAR LA COLISIÓN, DEBIDO A LA INMEDIATEZ DEL DISPARO
    if self.dead then return end

    if(self.r <= 0)then self:kill() end
end

function LaserRay:draw()
    local result = LaserRay.super.draw(self)
    if (not result) then return false end
    self.count = self.count + 1
    local r, g, b = unpack(ray_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(1.5)
    local dX = 40 * math.cos(self.r)
    local dY = 40 * math.sin(self.r)
    love.graphics.line(self.lines[1].x1, self.lines[1].y1, self.lines[1].x2, self.lines[1].y2)
    love.graphics.line(self.lines[1].x1 + dX, self.lines[1].y1 + dY, self.lines[1].x2 + dX, self.lines[1].y2 + dY)
    --love.graphics.line(self.lines[1].x1, self.lines[1].y1, self.lines[1].x1 + self.w, self.lines[1].y1 + self.h)
    --love.graphics.line(self.lines[1].x1 + dX, self.lines[1].y1 + dY, self.lines[1].x1 + self.w + dX, self.lines[1].y1 + self.h + dY)

    r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(3.0)
    dX = dX /2
    dY = dY /2
    love.graphics.line(self.lines[1].x1 + dX, self.lines[1].y1 + dY, self.lines[1].x2 + dX, self.lines[1].y2 + dY)
    --love.graphics.line(self.lines[1].x1 + dX, self.lines[1].y1 + dY, self.lines[1].x1 + self.w + dX, self.lines[1].y1 + self.h + dY)
    love.graphics.setLineWidth(1)
    -- con 2 pasadas es suficiente para mostrar el rayo
    if(self.count > 4)then
        self:kill()
    end
end

return LaserRay