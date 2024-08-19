if (_G["Rock"]) then
    return _G["Rock"]
end

local GameObject      = require "objects.basics.GameObject"
local EnemyProjectile = require "objects.projectils.EnemyProjectile"

local Rock = GameObject:extend()

--local Physics = require "_LIBS_.windfield"
local Vector          = require('_LIBS_.hump.vector')
local Draft           = require('_LIBS_.draft.draft')
local TextEffect      = require('objects.effects.TextEffect')
--local draft           = Draft()
local ShootEffect     = require "objects.effects.ShootEffect"
local DeathEffect     = require "objects.effects.DeathEffect"
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils           = require "tools.utils"

-- no tiene en cuenta ni x ni y (se crean aleatorias)
function Rock:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. 
    -- y self.area se referirá a él.  
    Rock.super.new(self, game_object, x, y, opts)
    --if opts then for k, v in pairs(opts) do self[k] = v end end

    self.direction = utils.tableRandom({ -1, 1 })
    self.x = x or (gw / 2 + self.direction * (gw / 2 + 48))
    self.y = y or utils.random(16, gh - 16)
    --if(self.type == "Shooter")then print("1", self.x, self.y) end
    self.w, self.h = 8, 8
    self.r = -math.pi / 2
    --self.type = opts.type or "Rock"
    self.type = "Rock"
    self.collider = self.area.world:newPolygonCollider(utils.createIrregularPolygon(8))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFixedRotation(false)
    self.v = -self.direction * utils.random(10, 30)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(utils.random(-10, 10))

    self.points = 5
    self.value = 10
    self.withTexEffect = false
    self.hp = enemies[self.type].hp
end

function Rock:hit(damage)
    damage = damage or 100
    self.hp = self.hp - damage

    self.hit_flash = true
    self.timer:after(0.2, function ()
        self.hit_flash = false
        if(self.hp <=0)then
            self.withTexEffect = true -- visualiza el texto "+HP" temporálmente
            self:kill()
        end
    end)
end

-- se mueve en línea recta
function Rock:IA(dt)
    self.collider:setLinearVelocity(self.v, 0)
end

function Rock:kill()
    if not self.parent then
        self.dead = true
        return
    end
    --[[self.area:addGameObject('ProjectileDeathEffect', self.x, self.y,
        { color = hp_color, w = 3 * self.s })]]
    local eff = DeathEffect(
        self.area,
        self.x,
        self.y,
        {
            --parent = self,
            --live = 0.1, -- sirve de efecto de disparo (sg)
            color = enemies[self.type].color, --sp_color,
            --show = 0.2,
            --unshow = 0.25,
            w = 3 * self.v
        }
    )
    if(self.area)then self.area:add(eff) end

    local numFragments = 8
    for i = 1, utils.random(numFragments * 0.5, numFragments * 1) do -- número de fragmentos
        --self.area:addGameObject('ExplodeParticle', self.x, self.y)
        local eff2 = ExplodeParticle(
            self.area,
            self.x,
            self.y,
            {
                --timer = self.timer,
                live = -1,  -- sirve de efecto de disparo (sg)
                color = { 0.5, 0.9, 0.5, 0.7 },
                numEff = 1, -- 1 = desintegración, 2 = fragmentación
                s = 1.3,    -- semi-longitud de los fragmentos
                v = 80,
                d = 0.4,    -- grosor de los gragmentos
                dist = 4    --self.w -- radio de la explosión
            }
        )
        if (self.area) then self.area:add(eff2) end
    end

    if(self.withTexEffect)then
        --self.area:addGameObject('InfoText', self.x, self.y, { text = '+BOOST', color = boost_color })
        local eff3 = TextEffect(
            self.parent,
            self.x,
            self.y,
            {
                --parent = self,
                --live = 0.1, -- sirve de efecto de disparo (sg)
                text = self.points .. "+" .. self.type,
                color = sp_color
            }
        )
        if (self.area) then self.area:add(eff3) end
    end

    self.dead = true

    Rock.super.kill(self)
end

function Rock:update(dt)
    --if(self.dead)then return end
    --Rock.super.update(self, dt)
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

    self:IA(dt)
    self.x, self.y = self.collider:getPosition()
    self.r = self.collider:getAngle()
end

function Rock:draw()
    local result = Rock.super.draw(self)
    if (not result) then return false end

    if(self.hit_flash)then
        love.graphics.setColor(default_color)
    else
        love.graphics.setColor(hp_color)
    end
    local points = { self.collider:getWorldPoints(self.collider.shapes.main:getPoints()) }
    love.graphics.polygon('line', points)
    love.graphics.setColor(default_color)
end

return Rock