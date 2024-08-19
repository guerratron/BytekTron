if (_G["LightningRay"]) then
    return _G["LightningRay"]
end
--local Physics = require "_LIBS_.windfield"
local Bullet = require "objects.projectils.Bullet"

-- Aparenta un rayo luminoso desde el gameobject hacia el enemigo.  
-- Sirve como efecto simple para gameobjects que disparen, admite que se le pase
-- como parámetros el disparador padre, el enemigo objetivo, el color del efecto, 
-- sus dimensiones, su escala y el tiempo de vida (después del cual se autodestruye).  
-- Por ejemplo:  
--[[
    ```lua
    LightningRay(
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
local LightningRay = Bullet:extend()

local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils           = require "tools.utils"

-- necesita llamar posteriormente a love.graphics.pop()
function LightningRay.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function LightningRay:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    LightningRay.super.new(self, game_object, x, y, opts)

    -- array con las líneas del rayo, con sus {x1, y1, x2, y2}
    self.lines = {}
    local dist = {x = self.x1 - self.x2, y = self.y1 - self.y2}
    local quad = math.sqrt(dist.x * dist.x + dist.y * dist.y)
    --self.collider = self.area.world:newCircleCollider(self.x + dist.x, self.y + dist.y, self.s)
    self.collider = self.area.world:newCircleCollider(self.x2, self.y2, self.s )
    self.collider:setObject(self)
    self.collider:setCollisionClass('Projectile') -- se sobrescribe en los hijos
    self:generate()
    self.count = 0
end

-- Generates lines and populates the self.lines table with them
function LightningRay:generate()
    for i = 1, love.math.random(2, 4) do
        local rnd = i * utils.tableRandom({-1, 1})
        table.insert(self.lines, {x1 = self.x1 + rnd, y1 = self.y1 + rnd, x2 = self.x2 + rnd, y2 = self.y2 + rnd})
    end
    --[[
    ]]
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
end

function LightningRay:update(dt)
    if(self.dead)then return end
    LightningRay.super.update(self, dt)

    -- NO ES CAPAZ DE DETECTAR LA COLISIÓN, DEBIDO A LA INMEDIATEZ DEL DISPARO
    --[[if self.collider and self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()
        if object and (object:is(Rock) or object:is(Shooter)) then
            print(self.hp)
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp)
            --object.withTexEffect = true -- visualiza el texto "+HP" temporálmente
            --if(object.hp > 0)then
            --self:addHP(-object.hp)
            --end
            --object:kill()
            self:hit(hp1) -- quizás se destruya o no
            --self:kill()   -- aunque no se haya destruido antes hay que destruirlo ahora
        end
    end]]
    if self.dead then return end

    if(self.r <= 0)then self:kill() end
end

function LightningRay:draw()
    local result = LightningRay.super.draw(self)
    if (not result) then return false end

    self.count = self.count + 1
    --LightningRay.pushRotateScale(self.x, self.y, self.r, 1, 1)
    for i, line in ipairs(self.lines) do
        local r, g, b = unpack(boost_color)
        love.graphics.setColor(r, g, b, self.alpha)
        love.graphics.setLineWidth(3.5)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2)

        r, g, b = unpack(default_color)
        love.graphics.setColor(r, g, b, self.alpha)
        love.graphics.setLineWidth(2.0)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2)
    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(255, 255, 255, 255)
    --love.graphics.pop()
    -- con 2 pasadas es suficiente para mostrar el rayo
    if(self.count > 4)then
        self:kill()
    end
end

return LightningRay