if (_G["Ammo"]) then
    return _G["Ammo"]
end

local GameObject      = require "objects.basics.GameObject"

--local Physics = require "_LIBS_.windfield"
local Vector          = require('_LIBS_.hump.vector')
local Draft           = require('_LIBS_.draft.draft')
local draft           = Draft()
local DeathEffect     = require "objects.effects.DeathEffect"
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils           = require "tools.utils"

local Ammo = GameObject:extend()

-- necesita llamar posteriormente a love.graphics.pop()
function Ammo.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function Ammo:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. 
    -- y self.area se referirá a él.  
    -- Como elemento padre se le pasará el player en las opciones {parent = player}. 
    Ammo.super.new(self, game_object, x, y, opts)
    self.type = "Ammo"

    self.w, self.h = 8, 8
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setFixedRotation(false)
    self.r = utils.random(0, 2 * math.pi)
    self.v = utils.random(10, 20)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:applyAngularImpulse(utils.random(-24, 24))
    self.collider:setCollisionClass('Collectable')

    self.points = 5
end

-- se mueve ligéramente hacia el player
function Ammo:IA()
    local vel  = 1/2
    -- el parent es el player
    local target = self.parent --current_room.player
    if target then
        local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
        local angle = math.atan2(target.y - self.y, target.x - self.x)
        local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
        local final_heading = (projectile_heading + 0.1 * to_target_heading):normalized()
        self.collider:setLinearVelocity(self.v * final_heading.x * vel, self.v * final_heading.y * vel)
    else
        self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    end
end

function Ammo:kill()
    --[[self.area:addGameObject('ProjectileDeathEffect', self.x, self.y,
        { color = hp_color, w = 3 * self.s })]]
    local eff = DeathEffect(
        self.area,
        self.x,
        self.y,
        {
            --parent = self,
            --live = 0.1, -- sirve de efecto de disparo (sg)
            color = ammo_color,
            --show = 0.2,
            --unshow = 0.25,
            w = 3 * self.r
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
                color = { 0.5, 0.7, 0.8, 0.7 },
                numEff = 1, -- 1 = desintegración, 2 = fragmentación
                s = 1.1,    -- semi-longitud de los fragmentos
                v = 100,
                d = 0.3,    -- grosor de los gragmentos
                dist = 3    --self.w -- radio de la explosión
            }
        )
        if (self.area) then self.area:add(eff2) end
    end

    self.dead = true

    Ammo.super.kill(self)
end

function Ammo:update(dt)
    --if(self.dead)then return end
    --Ammo.super.update(self, dt)
    -- límites de pantalla
    if self.x < 0 then self:kill() end
    if self.y < 0 then self:kill() end
    if self.x > gw then self:kill() end
    if self.y > gh then self:kill() end

    if self.dead then return end

    --self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self:IA()
    self.x, self.y = self.collider:getPosition()
end

function Ammo:draw()
    local result = Ammo.super.draw(self)
    if (not result) then return false end

    love.graphics.setColor(ammo_color)
    Ammo.pushRotateScale(self.x, self.y, self.collider:getAngle(), 1, 1)
        draft:rhombus(self.x, self.y, self.w, self.h, 'line')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

return Ammo