if (_G["Fighter"]) then
    return _G["Fighter"]
end
local Fighter = Object:extend()
local Timer           = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local Mos             = require("_LIBS_.Moses.moses_min")
local TrailParticle   = require "objects.effects.TrailParticle"
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local Shapes   = require "tools.ShapePolygons"
local utils           = require "tools.utils"

-- necesita llamar posteriormente a love.graphics.pop()
function Fighter.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end
--[[
function Fighter:makePolygons()
    return {
        {
            self.w, 0, -- 1
            self.w/2, -self.w/2, -- 2
            -self.w/2, -self.w/2, -- 3
            -self.w, 0, -- 4
            -self.w/2, self.w/2, -- 5
            self.w/2, self.w/2, -- 6
        },
        {
            self.w/2, -self.w/2, -- 7
            0, -self.w, -- 8
            -self.w - self.w/2, -self.w, -- 9
            -3*self.w/4, -self.w/4, -- 10
            -self.w/2, -self.w/2, -- 11
        },
        {
            self.w/2, self.w/2, -- 12
            -self.w/2, self.w/2, -- 13
            -3*self.w/4, self.w/4, -- 14
            -self.w - self.w/2, self.w, -- 15
            0, self.w, -- 16
        }
    }
end]]

function Fighter:new(parent, x, y, opts)
    self.parent = parent -- el parent debe tener un timer y un area (como por ejemplo un player)
    self.x, self.y = x, y
    self.w, self.h = parent.w, parent.h
    self.r = self.parent.r
    self.dead = false
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.type = "Fighter"

    self.rv = 0.83 * math.pi -- velocidad de impulso o de giro
    self.v = 0               -- velocidad
    --self.max_v = 10 --100
    self.base_max_v = 25
    self.a = 10 --100 -- aceleración

    self.shoot_timer = 0
    self.shoot_cooldown = 0.24 -- lo trae el ataque no el tipo de nave
    self.max_points = 99999
    self.points = 0

    self.max_ammo = 100
    self.ammos = self.max_ammo * 0.8
    --self:setAttack('Homing')
    self.max_hp = 100
    self.hp = self.max_hp * 0.8

    self.max_sp = 100
    self.sp = 25
    self.invincible = false

    -- Cycle
    self.cycle_cooldown = 5

    self.max_boost = 100
    self.boost = self.max_boost * 0.8
    self.boosting = false
    self.can_boost = true   -- puede ocurrir un impulso?
    self.boost_timer = 0    -- cuánto tiempo ha pasado desde que boost llegó a 0
    self.boost_cooldown = 2 -- sg después de llegar a boost = 100 se permitirá de nuevo el can_boost

    --self.polygons = self:makePolygons()

    self.trail_color = skill_point_color
    self.handler1 = self.parent.timer:every(
        0.02,
        function()
            if(not self.parent)then
                (Timer()):cancel(self.handler1)
                return
            end
            --[[self.area:addGameObject('TrailParticle',
            self.x - self.w * math.cos(self.r), self.y - self.h * math.sin(self.r),
            { parent = self, r = utils.random(2, 4), d = utils.random(0.15, 0.25), color = self.trail_color })]]
            local trail = TrailParticle(
                self.parent.area,
                -- Una cola en en centro trasero
                --[[self.x - self.w * math.cos(self.r),
                self.y - self.h * math.sin(self.r),]]
                -- Dos colas, una en cada lado trasero
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r - math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r - math.pi / 2),
                {
                    parent = self,
                    --timer = self.timer, -- el trail debe tener su propio temporizador
                    timer = self.parent.timer,
                    r = utils.random(2, 4),          -- radio de la bola de fuego
                    rMinus = utils.random(0.3, 0.5), -- disminución progresiva del radio
                    d = utils.random(0.15, 0.25),
                    color = self.trail_color,
                    live = -1 -- sirve de efecto de disparo (sg)
                }
            )
            self.parent.area:add(trail)

            local trail2 = TrailParticle(
                self.parent.area,
                -- Dos colas, una en cada lado trasero
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r + math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r + math.pi / 2),
                {
                    parent = self,
                    --timer = self.timer, -- el trail debe tener su propio temporizador
                    timer = self.parent.timer,
                    r = utils.random(2, 4),          -- radio de la bola de fuego
                    rMinus = utils.random(0.3, 0.5), -- disminución progresiva del radio
                    d = utils.random(0.15, 0.25),
                    color = self.trail_color,
                    live = -1 -- sirve de efecto de disparo (sg)
                }
            )
            self.parent.area:add(trail2)
        end
    )
end

function Fighter:destroy()
    self.parent.timer:cancel(self.handler1)
    self.handler1 = nil
    self.parent = nil
end

--[[
    Simula un Temblor (Shake). Espera como parámetros la cámara, la dureza y las repeticiones: 
    toShake(camera, rough, rep)  
    CUIDADO: esta función NO es recursiva, pero es repetitiva.
]]
local function toShake(cam, rough, rep)
    local function _rep()
        --cam:zoom(2, 2)
        --cam:lookAt(rough, rough)
        cam:move(rough, rough)
        --cam:move(-shake.dx, -shake.dy)
        rep = rep - 1
        if (rep > 0) then
            _rep()
        end
    end
    if (rep > 0) then
        _rep()
    end
    --cam:zoomTo(1, 1)
end

function Fighter:kill()
    -- Temblor -- la cámara es global y ya viene definida de "main.lua"
    --camera:shake(6, 60, 0.4)
    toShake(camera, 3, 1)
    -- Relampagueo
    flash(12)
    -- Ralentización
    slow(self.parent.timer, 0.15, 1)

    local numFragments = 10
    for i = 1, utils.random(numFragments * 0.6, numFragments * 1) do -- número de fragmentos
        --self.area:addGameObject('ExplodeParticle', self.x, self.y)
        local eff2 = ExplodeParticle(
            self.parent.area,
            self.x,
            self.y,
            {
                parent = self,
                --timer = self.parent.area.timer,
                --timer = self.timer, -- ExplodeParticle con su propio timer
                live = -1, -- sirve de efecto de disparo (sg)
                color = { 0.6, 0.3, 0.8, 0.7 },
                numEff = 2, -- 1 = desintegración, 2 = fragmentación
                s = 1.5, -- semi-longitud de los fragmentos
                v = 120,
                d = 0.3, -- grosor de los gragmentos
                dist = 6 --self.w -- radio de la explosión
            }
        )
        if (self.parent.area) then self.parent.area:add(eff2) end
    end

    self.dead = true
    self:destroy()
end


function Fighter:canBoost(dt)
    if self.boost_timer > self.boost_cooldown then
        self.can_boost = self.boost > 1
    end
    --self.can_boost = self.boost > 1
    return self.can_boost
end
function Fighter:toBoostUp(dt)
    if self:canBoost() then
        Sounds.play("action7")
        self.parent.max_v = 1.5 * self.parent.base_max_v
        self.trail_color = boost_up_color
        self.boost = self.boost - 50 * dt
        self.boosting = true
        --self.boost_timer = self.boost_timer + 1
    else
        self.trail_color = skill_point_color
        self.boosting = false
        self.boost_timer = 0
    end
end
function Fighter:toBoostDown(dt)
    if self:canBoost() then
        self.parent.max_v = 0.5 * self.parent.base_max_v
        self.trail_color = boost_down_color
        self.boost = self.boost + 50 * dt
        self.boosting = true
        --self.boost_timer = self.boost_timer + 1
    else
        self.trail_color = skill_point_color
        self.boosting = false
        self.boost_timer = 0
    end
end

function Fighter:key(key, dt)
    if (key == "up") then
        self:toBoostUp(dt)
    elseif (key == "down") then
        self:toBoostDown(dt)
    else
        self.trail_color = skill_point_color
        self.boosting = false
    end
end

function Fighter:update(dt)
    if(self.dead)then return end
    if(self.parent)then
        self.x, self.y = self.parent.x, self.parent.y
        self.w, self.h = self.parent.w, self.parent.h
        self.r = self.parent.r
    end
    self.boost = math.min(self.boost + 10 * dt, self.max_boost)
    self.boost_timer = self.boost_timer + dt
    --if self.boost_timer > self.boost_cooldown then self.can_boost = true end
    --print(self.boost, self.boosting, self.parent.can_boost, self.parent.boost_timer)
end

function Fighter:draw()
    if self.dead then return end
    Fighter.pushRotateScale(self.x, self.y, self.r, 1, 1)
        love.graphics.setColor(self.color or default_color)
        --love.graphics.setColor(0, 0.5, 1, 0.8)
        --[[for _, polygon in ipairs(self.polygons) do
            -- draw each polygon here
            local points = Mos.map(polygon, function(v, k)
                if k % 2 == 1 then
                    return self.x + v + utils.random(-1, 1)
                else
                    return self.y + v + utils.random(-1, 1)
                end
            end)
            love.graphics.polygon('line', points)
        end]]
    -- shipName = "Fighter, Master, Medium, Tulip, Crusader"
    Shapes.drawPolygons("Fighter", self.x, self.y, self.w)
    love.graphics.pop()
end

return Fighter