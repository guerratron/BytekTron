if (_G["Shooter"]) then
    return _G["Shooter"]
end

local Rock      = require "objects.enemies.Rock"

local Shooter = Rock:extend()

--local Physics = require "_LIBS_.windfield"
local Vector          = require('_LIBS_.hump.vector')
local Draft           = require('_LIBS_.draft.draft')
--local draft           = Draft()
local TextEffect      = require('objects.effects.TextEffect')
local EnemyProjectile = require "objects.projectils.EnemyProjectile"
local ShootEffect     = require "objects.effects.ShootEffect"
local DeathEffect     = require "objects.effects.DeathEffect"
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local PreAttackEffect = require "objects.effects.PreAttackEffect"
local utils           = require "tools.utils"

-- no tiene en cuenta ni x ni y (se crean aleatorias)
function Shooter:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. 
    -- y self.area se referirá a él.  
    Shooter.super.new(self, game_object, x, y, opts)
    --if (self.type == "Shooter") then print("2", self.x, self.y) end
    self.w, self.h = 12, 6
    --self.type = opts.type or "Shooter"
    self.type = "Shooter"
    self.collider = self.area.world:newPolygonCollider(
        { self.w, 0, -self.w / 2, self.h, -self.w, 0, -self.w / 2, -self.h }
    )
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setFixedRotation(false)
    self.collider:setAngle((self.direction == 1 and math.pi) or 0)
    self.collider:setFixedRotation(true)
    --self.collider:applyAngularImpulse(0)
    self.collider:setCollisionClass('Enemy')

    self.points = 10
    self.value = 20
    --self.withTexEffect = false
    --self.hp = enemies[self.type].hp
    self.shoot_timer = 0
    self.shoot_cooldown = 2.24
    --self.attack = opts.attacks or "Neutral"
    --self.attack = enemyAttacks[self.attack]
    self.timer:every(utils.random(3, 5), function()
        -- spawn PreAttackEffect object with duration of 1 second
        if(self.timer)then
            --[[self.area:addGameObject('PreAttackEffect',
                self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
                self.y + 1.4 * self.w * math.sin(self.collider:getAngle()),
                { shooter = self, color = hp_color, duration = 1 })]]
            local eff = PreAttackEffect(
                self.area,
                self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
                self.y + 1.4 * self.w * math.sin(self.collider:getAngle()),
                {
                    --parent = self,
                    --live = 0.1, -- sirve de efecto de disparo (sg)
                    shooter = self,
                    color = hp_color,--color = self.color, --{ 255, 0, 0, 150 },
                    duration = 1,
                    timer = self.timer
                }
            )
            if (self.area) then self.area:add(eff) end

            self.timer:after(1, function()
                -- spawn EnemyProjectile
                self:shoot()
            end)
        else
            self:kill()
        end
    end)
end

function Shooter:hit(damage)
    damage = damage or 100
    self.hp = self.hp - damage

    self.hit_flash = true
    if(self.timer)then
        self.timer:after(0.2, function ()
            self.hit_flash = false
            if(self.hp <=0)then
                self.withTexEffect = true -- visualiza el texto "+HP" temporálmente
                self:kill()
            end
        end)
    else
        self:kill()
    end
end

function Shooter:shoot()
    if (not self.area or not self.parent or not self.parent.player) then return false end
    -- EFFECT (punto de disparo)
    --[[self.area:addGameObject(
        'ShootEffect',
        self.x + 1.2 * self.w * math.cos(self.r),
        self.y + 1.2 * self.w * math.sin(self.r)
    )]]
    local d = 1.2 * self.w
    local shoot = ShootEffect(
        self.area,
        self.x + d * math.cos(self.r),
        self.y + d * math.sin(self.r),
        {
            --timer = self.timer, -- el bullet tiene que tener su propio temporizador
            parent = self,
            --color = {255, 0, 255, 200},
            --scaleX = 2,
            --scaleY = 2,
            live = 0.1, -- sirve de efecto de disparo (sg)
            d = d
        }
    )
    local index = self.area:add(shoot)
    shoot.index = index
    --table.insert(self.bulletsIndexes, index)
    local shoot2 = nil
    local index2 = 0
--[[
    if self.attack == 'Neutral' then
        shoot2 = Bullet(
            self.area,
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = self.r,
                hp = 10,
                attack = self.attack
            }
        )
    elseif self.attack == 'Rapid' then
        shoot2 = EnemyProjectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = self.r,
                hp = 10,
                attack = self.attack
            }
        )
    elseif self.attack == 'Projectile' then
        shoot2 = EnemyProjectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = self.r,
                hp = 20,
                attack = self.attack
            }
        )
    elseif self.attack == 'Double' or self.attack == "DoubleBack" then
        local subXA = self.x + 1.5 * d * math.cos(self.r + math.pi / 12)
        local subYA = self.y + 1.5 * d * math.sin(self.r + math.pi / 12)
        local subRA = self.r + math.pi / 12
        local subXB = self.x + 1.5 * d * math.cos(self.r - math.pi / 12)
        local subYB = self.y + 1.5 * d * math.sin(self.r - math.pi / 12)
        local subRB = self.r - math.pi / 12
        if (self.attack == "DoubleBack") then
            subXA = self.x + 1.5 * d * math.cos(self.r)
            subYA = self.y + 1.5 * d * math.sin(self.r)
            subRA = self.r
            subXB = self.x + 1.5 * d * math.cos(self.r - math.pi)
            subYB = self.y + 1.5 * d * math.sin(self.r - math.pi)
            subRB = self.r - math.pi
        end
        -- shoot 1
        shoot2 = EnemyProjectile(
            self.area,
            subXA,
            subYA,
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = subRA,
                hp = 20,
                attack = self.attack
            }
        )
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        --table.insert(self.bulletsIndexes, index2)

        -- shoot 2
        shoot2 = EnemyProjectile(
            self.area,
            subXB,
            subYB,
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = subRB,
                hp = 20,
                attack = self.attack
            }
        )
    elseif self.attack == 'Triple' or self.attack == 'TripleBack' or self.attack == "Side" then
        local subXA = self.x + 1.5 * d * math.cos(self.r + math.pi / 6)
        local subYA = self.y + 1.5 * d * math.sin(self.r + math.pi / 6)
        local subRA = self.r + math.pi / 6
        if (self.attack == "Side") then
            subXA = self.x + 1.5 * d * math.cos(self.r + math.pi / 2)
            subYA = self.y + 1.5 * d * math.sin(self.r + math.pi / 2)
            subRA = self.r + math.pi / 2
        end
        -- shoot 1
        shoot2 = EnemyProjectile(
            self.area,
            subXA,
            subYA,
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = subRA,
                hp = 30,
                attack = self.attack
            }
        )
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        --table.insert(self.bulletsIndexes, index2)

        -- shoot 2 (Triple + TripleBack)
        local subX = self.x + 1.5 * d * math.cos(self.r)
        local subY = self.y + 1.5 * d * math.sin(self.r)
        local subR = self.r
        if (self.attack == "TripleBack") then
            subX = self.x + 1.5 * d * math.cos(self.r - math.pi)
            subY = self.y + 1.5 * d * math.sin(self.r - math.pi)
            subR = self.r - math.pi
        end
        shoot2 = EnemyProjectile(
            self.area,
            subX,
            subY,
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = subR,
                hp = 30,
                attack = self.attack
            }
        )
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        --table.insert(self.bulletsIndexes, index2)

        -- shoot 3
        local subXB = self.x + 1.5 * d * math.cos(self.r - math.pi / 6)
        local subYB = self.y + 1.5 * d * math.sin(self.r - math.pi / 6)
        local subRB = self.r - math.pi / 6
        if (self.attack == "Side") then
            subXB = self.x + 1.5 * d * math.cos(self.r - math.pi / 2)
            subYB = self.y + 1.5 * d * math.sin(self.r - math.pi / 2)
            subRB = self.r - math.pi / 2
        end
        shoot2 = EnemyProjectile(
            self.area,
            subXB,
            subYB,
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = subRB,
                hp = 30,
                attack = self.attack
            }
        )
    elseif self.attack == 'Spread' then
        local angleR = utils.random(-math.pi / 8, math.pi / 8)
        --angleR = angleR * self.r/8
        shoot2 = EnemyProjectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r), -- + angleR),
            self.y + 1.5 * d * math.sin(self.r), -- + angleR),
            {
                --timer = self.timer,
                --parent = self,
                live = 0.6, -- sirve como alcance del proyectil (sg)
                d = d,
                r = self.r + angleR,
                hp = 40,
                attack = self.attack
            }
        )
    end
    ]]

    
    --[[self.area:addGameObject('EnemyProjectile',
        self.x + 1.4*self.w*math.cos(self.collider:getAngle()),
        self.y + 1.4*self.w*math.sin(self.collider:getAngle()),
        {r = math.atan2(current_room.player.y - self.y, current_room.player.x - self.x),
            v = random(80, 100), s = 3.5})]]
    shoot2 = EnemyProjectile(
        self.area,
        self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
        self.y + 1.4 * self.w * math.sin(self.collider:getAngle()),
        {
            --timer = self.timer,
            --parent = self,
            live = 1.6,     -- sirve como alcance del proyectil (sg)
            d = d,
            --r = math.atan2(current_room.player.y - self.y, current_room.player.x - self.x),
            r = math.atan2(self.parent.player.y - self.y, self.parent.player.x - self.x),
            hp = 30,
            v = utils.random(80, 100),
            s = 3.5,
            attack = self.attack
        }
    )

    if (shoot2) then
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        shoot2.own = self
    end
end

-- se mueve en línea recta
function Shooter:IA(dt)
    Shooter.super.IA(self, dt)
    --shoot
    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown then
        self.shoot_timer = 0
        --self:shoot()
    end
end

function Shooter:kill()
    Shooter.super.kill(self)
end

function Shooter:update(dt)
    --if(self.dead)then return end
    --Shooter.super.update(self, dt)
    -- límites de pantalla
    --[[if self.x < 0 then self:kill() end
    if self.y < 0 then self:kill() end
    if self.x > gw then self:kill() end
    if self.y > gh then self:kill() end
]]
    if self.x < -100 or
       self.y < -100 or
       self.x > gw+100 or
       self.y > gh+100 then
        --self.visible = false
        self:kill()
    end
    if self.dead then return end
    --EnemyProjectile.super.update(self, dt)

    -- NO HACE FALTA, YA LO HACEN PLAYER Y PROJECTILE
    --[[if self.collider:enter('Player') then
        local collision_data = self.collider:getEnterCollisionData('Player')
        local object = collision_data.collider:getObject()
        if object and object:is(Player) then
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp)
            self:hit(hp1) -- quizás se destruya o no
            self:kill()   -- aunque no se haya destruido antes hay que destruirlo ahora
        end
    end
    if self.dead then return end
    if self.collider:enter('Projectile') then
        local collision_data = self.collider:getEnterCollisionData('Projectile')
        local object = collision_data.collider:getObject()
        if object and object:is(Projectile) then
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp)
            self:hit(hp1)
        end
    end
    ]]

    self:IA(dt)
    self.x, self.y = self.collider:getPosition()
end

function Shooter:draw()
    local result = Shooter.super.draw(self)
    if (not result) then return false end

    if(self.hit_flash)then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(hp_color)
    end
    local points = { self.collider:getWorldPoints(self.collider.shapes.main:getPoints()) }
    love.graphics.polygon('line', points)
    love.graphics.setColor(default_color)
    return true
end

return Shooter