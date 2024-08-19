if (_G["Bullet"]) then
    return _G["Bullet"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"
--local Rock       = require "objects.enemies.Rock"
--local Projectile= require "objects.projectils.Projectile"

local Bullet = GameObject:extend()

local Vector      = require('_LIBS_.hump.vector')
local DeathEffect = require "objects.effects.DeathEffect"
local utils = require "tools.utils"

-- necesita llamar posteriormente a love.graphics.pop()
function Bullet.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function Bullet:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    Bullet.super.new(self, game_object, x, y, opts)
    self.type = "Bullet"
    --self.own = game_object -- debería referirse al que lo hace disparar (player or enemy)
    --self.own = enemy or player
    self.own = opts.own

    self.s = opts.s or 2.5 -- el radio del colisionador
    self.v = opts.v or 200

    self.hp = opts.hp or 10 --damage

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:setCollisionClass('Projectile') -- se sobrescribe en los hijos
    self.points = 10
    self.target = nil

    if self.shield then
        self.orbit_distance = utils.random(32, 64)
        self.orbit_speed = utils.random(-6, 6)
        self.orbit_offset = utils.random(0, 2 * math.pi)
    end
    self.time = 0
end

function Bullet:kill()
    if self.dead then return end
    --[[self.area:addGameObject('ProjectileDeathEffect', self.x, self.y,
        { color = hp_color, w = 3 * self.s })]]
    local eff = DeathEffect(
        self.area,
        self.x,
        self.y,
        {
            --parent = self,
            --live = 0.1, -- sirve de efecto de disparo (sg)
            color = {255, 0, 0, 150},
            --show = 0.2,
            --unshow = 0.25,
            w = 3 * self.s
        }
    )
    if(self.area)then self.area:add(eff) end
    self.target = nil

    Bullet.super.kill(self)
end

function Bullet:hit(damage)
    damage = damage or 100
    self.hp = self.hp - damage

    self.hit_flash = true
    if(not self.timer)then return end
    self.timer:after(0.2, function()
        self.hit_flash = false
        if (self.hp <= 0) then
            --self.withTexEffect = true -- visualiza el texto "+HP" temporálmente
            self:kill()
        end
    end)
end

function Bullet:update(dt)
    --if(self.dead)then return end
    Bullet.super.update(self, dt)

    -- REBOTES
    -- Collision
    if self.bounce and self.bounce > 0 then
        -- Rebotes
        if self.x < 0 then
            self.r = math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.y < 0 then
            self.r = 2 * math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.x > gw then
            self.r = math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.y > gh then
            self.r = 2 * math.pi - self.r
            self.bounce = self.bounce - 1
        end
    elseif self.attack == "2Split" then
        -- Rebotes
        if self.x < 0 then
            self.r = math.pi/4 - self.r
        end
        if self.y < 0 then
            self.r = 2 * math.pi/4 - self.r
        end
        if self.x > gw then
            self.r = math.pi/4 - self.r
        end
        if self.y > gh then
            self.r = 2 * math.pi/4 - self.r
        end
    else
        -- límites de pantalla
        if self.x < 0 then self:kill() end
        if self.y < 0 then self:kill() end
        if self.x > gw then self:kill() end
        if self.y > gh then self:kill() end
    end

    if self.dead then return end

    --[[
    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()
        if object:is(Rock) then
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp)
            --object.withTexEffect = true -- visualiza el texto "+HP" temporálmente
            --if(object.hp > 0)then
            --self:addHP(-object.hp)
            --end
            --object:kill()
            self:hit(hp1) -- quizás se destruya o no
            self:kill() -- aunque no se haya destruido antes hay que destruirlo ahora
        end
    end
    if self.dead then return end

    if self.collider:enter('EnemyProjectile') then
        local collision_data = self.collider:getEnterCollisionData('EnemyProjectile')
        local object = collision_data.collider:getObject()
        if object:is(Bullet) or object:is(Projectile) then
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp)
            self:hit(hp1)
        end
    end
    if self.dead then return end
    ]]

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    -- Homing
    if self.attack == 'Homing' then
        -- Acquire new target
        if not self.target then
            local targets = self.area:getAllChildrenThat(function(e)
                --if(e.type == "Rock")then print(e.type, enemies["Rock"].abbr) end
                for key, _ in pairs(enemies) do
                    if (e.type == key) and (utils.distance(e.x, e.y, self.x, self.y) < 400) then
                        return true
                    end
                end
            end)
            if(#targets > 0)then
                self.target = table.remove(targets, love.math.random(1, #targets))
            end
        end
        if self.target and self.target.dead then self.target = nil end
        -- Move towards target
        if self.target then
            local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
            local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
            local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
            local final_heading = (projectile_heading + 0.1 * to_target_heading):normalized()
            self.collider:setLinearVelocity(self.v * final_heading.x, self.v * final_heading.y)
        end
    -- Normal movement
    else
        self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    end

    self.time = self.time + dt
    if self.shield and self.own then
        self.collider:setPosition(
            self.own.x + self.orbit_distance * math.cos(self.orbit_speed * self.time + self.orbit_offset),
            self.own.y + self.orbit_distance * math.sin(self.orbit_speed * self.time + self.orbit_offset))
    end
end

function Bullet:draw()
    local result = Bullet.super.draw(self)
    if (not result) then return false end

    if (self.hit_flash) then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(bullet_color)
    end
    love.graphics.circle('line', self.x, self.y, self.s)
    return true
end

return Bullet