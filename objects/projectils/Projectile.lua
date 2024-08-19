if (_G["Projectile"]) then
    return _G["Projectile"]
end
--local Physics = require "_LIBS_.windfield"
local Bullet = require "objects.projectils.Bullet"

local Projectile = Bullet:extend()

local Vector      = require('_LIBS_.hump.vector')
local DeathEffect     = require "objects.effects.DeathEffect"
local TrailParticle   = require "objects.effects.TrailParticle"
local TrailProjectile   = require "objects.effects.TrailProjectil"
local Rock            = require "objects.enemies.Rock"
local Shooter            = require "objects.enemies.Shooter"
local EnemyProjectile = require "objects.projectils.EnemyProjectile"
local Mina = require "objects.projectils.Mina"

local utils = require "tools.utils"

function Projectile:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    Projectile.super.new(self, game_object, x, y, opts)
    self.type = "Projectile"
    --self.own = enemy or player
    self.own = opts.own

    self.s = opts.s or 2.5 -- el radio del colisionador
    self.v = opts.v or 100
    -- spin
    --self.rv = utils.tableRandom({ utils.random(-2 * math.pi, -math.pi), utils.random(math.pi, 2 * math.pi) })
    self.attack = opts.attack or "Neutral"
    self.color = attacks[self.attack].color

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Projectile') -- se sobrescribe en los hijos
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.handler3 = nil
    --self.collider:setCollisionClass('Projectile')
    if self.timer and self.own and self.own.projectile_ninety_degree_change then
        self.timer:after(0.2, function()
            self.ninety_degree_direction = utils.tableRandom({ -1, 1 })
            self.r = self.r + self.ninety_degree_direction * math.pi / 2
            if(self.timer) then
                self.handler3 = self.timer:every(0.25, function()
                    self.r = self.r - self.ninety_degree_direction * math.pi / 2
                    if(self.timer) then
                        self.timer:after(0.1, function()
                            self.r = self.r - self.ninety_degree_direction * math.pi / 2
                            self.ninety_degree_direction = -1 * self.ninety_degree_direction
                        end, 'ninety_degree_second')
                    end
                end, 'ninety_degree_first')
            end
        end)
    end

    if self.timer and self.own and self.own.fast_slow then
        local initial_v = self.v
        self.timer:tween(0.2, self, { v = 2 * initial_v }, 'in-out-cubic', function()
            if(self.timer) then
                self.timer:tween(0.3, self, { v = initial_v / 2 }, 'linear', 'fast_slow_second')
            end
        end, 'fast_slow_first')
    end
    if self.timer and self.own and self.own.slow_fast then
        local initial_v = self.v
        self.timer:tween(0.2, self, { v = initial_v / 2 }, 'in-out-cubic', function()
            if(self.timer) then
                self.timer:tween(0.3, self, { v = 2 * initial_v }, 'linear', 'slow_fast_second')
            end
        end, 'slow_fast_first')
    end

    -- blast
    if self.attack == 'Blast' then
        --self.damage = 75
        self.color = utils.tableRandom(negative_colors)
        --self.timer:tween(utils.random(0.4, 0.6), self, { v = 0 }, 'linear', function() self:kill() end)
        --print(self.color[1], self.color[2], self.color[3])
    end

    if self.attack == 'Spin' or self.attack == 'Flame' then
        self.rv = utils.tableRandom({ utils.random(-2 * math.pi, -math.pi), utils.random(math.pi, 2 * math.pi) })
        self.timer:after(utils.random(2.4, 3.2), function() self:kill() end)
        self.handler4 = self.timer:every(0.10, function()
            --if(not self.dead and self.collider)then
                local shoot2 = TrailProjectile(
                    self.area,
                    self.x,
                    self.y,
                    {
                        r = Vector(self.collider:getLinearVelocity()):angleTo(),
                        color = self.color,
                        s = self.s
                    }
                )
                shoot2.index = self.area:add(shoot2)
            --end
        end)
    end

    -- proyectiles orbitando
    if self.shield then
        self.orbit_distance = utils.random(32, 64)
        self.orbit_speed = utils.random(-6, 6)
        self.orbit_offset = utils.random(0, 2*math.pi)
    end
    -- almacenamos la posición actual para corregir la dirección de los proyectiles orbitando
    self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:kill()
    if (self.timer) then
        if (self.handler3) then self.timer:cancel(self.handler3) end
        if (self.handler4) then self.timer:cancel(self.handler4) end
    end
    Projectile.super.kill(self)
end

-- se parte en dos proyectiles
function Projectile:toSplit()
    self.own.ammos = self.own.ammos - attacks[self.attack].ammos
    local mods = {
        --timer = self.timer,
        --parent = self,
        own = self.own,
        attack = self.attack,
        shield = self.own.chances.shield_projectile_chance:next(),
        live = 1.6, -- sirve como alcance del proyectil (sg)
        d = self.d,
        r = self.r,
        hp = 15
    }
    -- 1
    local shoot2 = Projectile(
        self.own.area,
        self.x + 1.5 * self.d * math.cos(self.r), -- + angleR),
        self.y + 1.5 * self.d * math.sin(self.r), -- + angleR),
        utils.tableAddTable(mods, { live = 2.2, r = self.r - math.pi/4, d = self.d * math.pi/4, hp = 10 })
    )
    local index2 = self.own.area:add(shoot2)
    shoot2.index = index2
    --shoot2.own = self --own == player or enemy
    table.insert(self.own.bulletsIndexes, index2)
    -- 2
    shoot2 = Projectile(
        self.own.area,
        self.x + 1.5 * self.d * math.cos(self.r), -- + angleR),
        self.y + 1.5 * self.d * math.sin(self.r), -- + angleR),
        utils.tableAddTable(mods, { live = 2.2, r = self.r - 3 * math.pi/4, d = self.d * 3 * math.pi/4, hp = 10 })
    )
    index2 = self.own.area:add(shoot2)
    shoot2.index = index2
    --shoot2.own = self --own == player or enemy
    table.insert(self.own.bulletsIndexes, index2)
end

function Projectile:update(dt)
    --if(self.dead)then return end
    Projectile.super.update(self, dt)
    if self.dead then return end

    if self.collider and self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()
        --if object and (object:is(Rock) or object:is(Shooter)) then
        if object and (
            object.type == "Rock" or
            object.type == "BigRock" or
            object.type == "Shooter" or
            object.type == "Seeker"
        ) then
            if self.own and self.attack == '2Split' and not object.type == "BigRock" then
                self:toSplit()
            end
            --print("projectil->Enemy: ", object.type)
            --self:setAttack(object.type)
            local hp1 = object.hp
            -- añade puntos al player y scene
            local falseObj = {type = object.type, points = object.points}
            object:hit(self.hp)
            if (self.own and self.own.addPointKillEnemy) then
                --self.own:hit(hp1, object)
                --print("Projectile->Enemy: to points kill enemy (", falseObj.type, falseObj.points, ")")
                self.own:addPointKillEnemy(falseObj)
                --self.area.room.score = self.area.room.score + points
            end
            --object.withTexEffect = true -- visualiza el texto "+HP" temporálmente
            --if(object.hp > 0)then
            --self:addHP(-object.hp)
            --end
            --object:kill()
            self:hit(hp1) -- quizás se destruya o no
            self:kill()   -- aunque no se haya destruido antes hay que destruirlo ahora
        end
    end
    if self.dead then return end

    if self.collider:enter('EnemyProjectile') then
        local collision_data = self.collider:getEnterCollisionData('EnemyProjectile')
        local object = collision_data.collider:getObject()
        --if object and object:is(EnemyProjectile) or object:is(Mina) then
        if object and (object.type == "EnemyProjectile" or object.type == "Mina") then
            --print("projectil->EnemyProjectile: ", object.type)
            --self:setAttack(object.type)
            local hp1 = object.hp
            -- añade puntos al player y scene
            local falseObj = { type = object.type, points = object.points }
            object:hit(self.hp)
            if (self.own and self.own.addPointKillProjectile) then
                --self.own:hit(hp1, object)
                --print("Projectile->EnemyProjectile: to points kill enemy (", falseObj.type, falseObj.points, ")")
                self.own:addPointKillProjectile(falseObj)
                --self.area.room.score = self.area.room.score + points
            end

            self:hit(hp1)
        end
    end--[[]]
    if self.dead then return end
    -- Spin
    if self.attack == 'Spin' then
        self.r = self.r + self.rv * dt
    end

    --[[]]
    -- Shield (proyectiles orbitando)
    if self.shield and self.own then
        self.collider:setPosition(
            self.own.x + self.orbit_distance * math.cos(self.orbit_speed * self.time + self.orbit_offset),
            self.own.y + self.orbit_distance * math.sin(self.orbit_speed * self.time + self.orbit_offset))
        -- corrección del ángulo en proyectiles orbitando
        local x, y = self.collider:getPosition()
        local dx, dy = x - self.previous_x, y - self.previous_y
        self.r = Vector(dx, dy):angleTo()
    end

    self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:drawNormal()
    love.graphics.setLineWidth(self.s - self.s / 4)
    if (self.hit_flash) then
        love.graphics.setColor(default_color)
        love.graphics.rectangle("line", self.x - 2 * self.s, self.y - 2 * self.s, 2 * self.s, 2 * self.s)
    else
        love.graphics.setColor(self.color)
    end
    love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y)
    --love.graphics.setColor(hp_color)     -- change half the projectile line to another color
    love.graphics.setColor(default_color)
    love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
    love.graphics.setLineWidth(1)
end

function Projectile:drawHoming()
    love.graphics.setLineWidth(self.s - self.s / 2)
    if (self.hit_flash) then
        love.graphics.setColor(default_color)
        love.graphics.rectangle("line", self.x - 1 * self.s, self.y - 1 * self.s, 2 * self.s, 2 * self.s)
    else
        love.graphics.setColor(self.color)
    end
    love.graphics.rectangle("line", self.x - 1 * self.s, self.y - 1 * self.s, 2 * self.s, 2 * self.s)
    --love.graphics.setColor(hp_color)     -- change half the projectile line to another color
    love.graphics.setColor(default_color)
    love.graphics.rectangle("fill", self.x - 0.5 * self.s, self.y - 0.5 * self.s, 1 * self.s, 1 * self.s)
    love.graphics.setLineWidth(1)
    local trail = TrailParticle(
        self.own.area,
        -- Una cola en en centro trasero
        --[[self.x - self.w * math.cos(self.r),
                self.y - self.h * math.sin(self.r),]]
        -- Dos colas, una en cada lado trasero
        self.x - 0.9 * self.s * math.cos(self.r) + 0.2 * self.s * math.cos(self.r - math.pi / 2),
        self.y - 0.9 * self.s * math.sin(self.r) + 0.2 * self.s * math.sin(self.r - math.pi / 2),
        {
            parent = self.own,
            --timer = self.timer, -- el trail debe tener su propio temporizador
            timer = self.own.timer,
            r = utils.random(2, 4),              -- radio de la bola de fuego
            rMinus = utils.random(0.3, 0.5),     -- disminución progresiva del radio
            d = utils.random(0.15, 0.25),
            color = self.own.trail_color,
            live = -1     -- sirve de efecto de disparo (sg)
        }
    )
    self.own.area:add(trail)
end

function Projectile:draw()
    --local result = Projectile.super.draw(self)
    --if (not result) then return false end
    if (self.dead) then return false end

    --love.graphics.setColor(default_color)
    if self.attack == 'Bounce' then self.color = utils.tableRandom(default_colors) end

    -- Homing
        Projectile.pushRotateScale(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo(), nil, nil)
    if self.attack == 'Homing' then
        self:drawHoming()
    else
        self:drawNormal()
    end
        love.graphics.pop()
    return true
end

return Projectile