if (_G["EnemyProjectile"]) then
    return _G["EnemyProjectile"]
end

local Bullet = require "objects.projectils.Bullet"

local EnemyProjectile = Bullet:extend()

local Vector      = require('_LIBS_.hump.vector')
--local Physics = require "_LIBS_.windfield"
--local Rock   = require "objects.enemies.Rock"
--local Projectile = require "objects.projectils.Projectile"
local Player     = require "objects.Player"
local DeathEffect = require "objects.effects.DeathEffect"

function EnemyProjectile:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    EnemyProjectile.super.new(self, game_object, x, y, opts)
    self.type = "EnemyProjectile"
    --self.own = enemy

    --self.s = opts.s or 2.5 -- el radio del colisionador
    self.v = opts.v or 100
    self.attack = opts.attack or "Neutral"
    self.color = enemyAttacks[self.attack].color
    self.hp = opts.hp or 5

    --self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    --self.collider:setObject(self)
    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:setCollisionClass('EnemyProjectile')
end

function EnemyProjectile:kill()
    EnemyProjectile.super.kill(self)
end

function EnemyProjectile:update(dt)
    --if(self.dead)then return end
    EnemyProjectile.super.update(self, dt)
    if self.dead then return end

    if self.collider:enter('Player') then
        local collision_data = self.collider:getEnterCollisionData('Player')
        local object = collision_data.collider:getObject()
        if object and object:is(Player) then
            --print("EnemyProjectile->player: ", object.type)
            --object:addPointKillEnemy(self)
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp, self)
            self:hit(hp1) -- quizás se destruya o no
            self:kill()   -- aunque no se haya destruido antes hay que destruirlo ahora
        end
    end
    if self.dead then return end
    -- NO HACE FALTA, YA LO HACE PROJECTILE
--[[
    if self.collider:enter('Projectile') then
        local collision_data = self.collider:getEnterCollisionData('Projectile')
        local object = collision_data.collider:getObject()
        if object and object:is(Projectile) then
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp)
            self:hit(hp1)
        end
    end]]
    --[[]]
end

function EnemyProjectile:draw()
    --local result = EnemyProjectile.super.draw(self)
    --if (not result) then return false end
    if (self.dead) then return false end

    --love.graphics.setColor(default_color)

    EnemyProjectile.pushRotateScale(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo(), nil, nil)
        love.graphics.setLineWidth(self.s - self.s / 4)
        if (self.hit_flash) then
            love.graphics.setColor(default_color)
            love.graphics.rectangle("line", self.x - 2 * self.s, self.y - 2 * self.s, 2 * self.s, 2 * self.s)
        else
            love.graphics.setColor(self.color)
        end
        love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y)
        --love.graphics.setColor(hp_color)     -- change half the projectile line to another color
        --love.graphics.setColor(default_color)
        love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
        love.graphics.setLineWidth(1)
    love.graphics.pop()
    love.graphics.setColor(default_color)
    return true
end

return EnemyProjectile