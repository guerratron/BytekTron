if (_G["Boost"]) then
    return _G["Boost"]
end
local GameObject      = require "objects.basics.GameObject"

local Boost = GameObject:extend()

--local Physics = require "_LIBS_.windfield"
local Vector          = require('_LIBS_.hump.vector')
local Draft           = require('_LIBS_.draft.draft')
local TextEffect      = require('objects.effects.TextEffect')
local draft           = Draft()
local DeathEffect     = require "objects.effects.DeathEffect"
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils           = require "tools.utils"


-- necesita llamar posteriormente a love.graphics.pop()
function Boost.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

-- no tiene en cuenta ni x ni y (se crean aleatorias)
function Boost:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. 
    -- y self.area se referirá a él.  
    -- Como elemento padre se le pasará el player en las opciones {parent = player}. 
    Boost.super.new(self, game_object, x, y, opts)
    self.type = "Boost"
    --if opts then for k, v in pairs(opts) do self[k] = v end end

    local myTable = {-1, 1}
    local direction = myTable[love.math.random(1, #myTable)] --table.random({ -1, 1 })
    --self.x = gw / 2 + direction * (gw / 2 + 48)
    self.x = gw / 2 + direction * (gw / 2 - 48)
    self.y = utils.random(48, gh - 48)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction * utils.random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(utils.random(-24, 24))

    self.points = 12
    self.withTexEffect = false

    --[[
        local all_info_texts = self.area:getAllGameObjectsThat(function(o) 
            if o:is(InfoText) and o.id ~= self.id then 
                return true 
            end 
        end)
    ]]
end

-- se mueve ligéramente hacia el player
function Boost:IA()
    self.collider:setLinearVelocity(self.v, 0)
end

function Boost:kill()
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
            color = boost_color,
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
                color = { 0.4, 0.9, 1, 0.7 },
                numEff = 2, -- 1 = desintegración, 2 = fragmentación
                s = 1.1,    -- semi-longitud de los fragmentos
                v = 100,
                d = 0.3,    -- grosor de los gragmentos
                dist = 5    --self.w -- radio de la explosión
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
                text = "+BOOST",
                color = boost_color
            }
        )
        if (self.area) then self.area:add(eff3) end
    end

    self.dead = true

    Boost.super.kill(self)
end

function Boost:update(dt)
    --if(self.dead)then return end
    --Boost.super.update(self, dt)
    -- límites de pantalla
    if self.x < 0 then self:kill() end
    if self.y < 0 then self:kill() end
    if self.x > gw then self:kill() end
    if self.y > gh then self:kill() end

    if self.dead then return end

    self:IA()
    self.x, self.y = self.collider:getPosition()
end

function Boost:draw()
    local result = Boost.super.draw(self)
    if (not result) then return false end

    love.graphics.setColor(boost_color)
    Boost.pushRotateScale(self.x, self.y, self.collider:getAngle(), 1, 1)
        draft:rhombus(self.x, self.y, 1.5 * self.w, 1.5 * self.h, 'line')
        draft:rhombus(self.x, self.y, 0.5 * self.w, 0.5 * self.h, 'fill')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

return Boost