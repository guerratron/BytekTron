if (_G["Mina"]) then
    return _G["Mina"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"
--local Rock       = require "objects.enemies.Rock"
--local Projectile= require "objects.projectils.Projectile"

local Mina = GameObject:extend()

local Vector      = require('_LIBS_.hump.vector')
local DeathEffect = require "objects.effects.DeathEffect"
local utils = require "tools.utils"

-- necesita llamar posteriormente a love.graphics.pop()
function Mina.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function Mina:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    Mina.super.new(self, game_object, x, y, opts)
    self.type = "Mina"
    --self.own = game_object -- debería referirse al que lo hace disparar (player or enemy)
    --self.own = enemy or player
    self.own = opts.own

    self.s = opts.s or 2.5 -- el radio del colisionador
    self.v = 0 -- STATIC

    self.hp = opts.hp or 10 --damage

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:setLinearVelocity(0, 0)
    self.collider:setCollisionClass('EnemyProjectile') -- se sobrescribe en los hijos
    self.points = 10
    self.target = nil

    self.direction = utils.tableRandom({-1, 1})
    self.sub_r = utils.random(self.s * 0.3, self.s * 0.7)
    self.max_sub_r = self.s
    self.min_sub_r = 0
end

function Mina:kill()
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

    Mina.super.kill(self)
end

function Mina:hit(damage)
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

function Mina:update(dt)
    Mina.super.update(self, dt)
    if(self.dead)then return end

    self.v = 0
    self.collider:setLinearVelocity(0, 0)

    self.sub_r = self.sub_r + dt * self.direction
    if(self.sub_r > self.max_sub_r)then
        self.sub_r = self.max_sub_r
        self.direction = -self.direction
    end
    if (self.sub_r < self.min_sub_r) then
        self.sub_r = self.min_sub_r
        self.direction = -self.direction
    end

end

function Mina:draw()
    --local result = Mina.super.draw(self)
    --if (not result) then return false end
    if (self.dead) then return end

    if (self.hit_flash) then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(bullet_color)
    end
    love.graphics.circle('line', self.x, self.y, self.s)
    love.graphics.setColor({0.9, 0.7, 0.2})
    love.graphics.circle('line', self.x, self.y, self.sub_r)
    return true
end

return Mina