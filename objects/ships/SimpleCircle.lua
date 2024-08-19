if (_G["SimpleCircle"]) then
    return _G["SimpleCircle"]
end
local SimpleCircle = Object:extend()

local TrailParticle   = require "objects.effects.TrailParticle"
local DeathEffect     = require "objects.effects.DeathEffect"
local utils           = require "tools.utils"

function SimpleCircle:new(parent, x, y, opts)
    self.parent = parent
    self.x, self.y = x, y
    self.w, self.h = parent.w, parent.h
    self.r = self.parent.r
    self.dead = false
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.trail_color = skill_point_color
    self.parent.timer:every(
        0.02,
        function()
            --[[self.area:addGameObject('TrailParticle',
            self.x - self.w * math.cos(self.r), self.y - self.h * math.sin(self.r),
            { parent = self, r = utils.random(2, 4), d = utils.random(0.15, 0.25), color = self.trail_color })]]
            local trail = TrailParticle(
                self.parent.area,
                self.x - self.w * math.cos(self.r),
                self.y - self.h * math.sin(self.r),
                {
                    --timer = self.timer, -- el bullet tiene que tener su propio temporizador
                    parent = self,
                    r = utils.random(2, 4),          -- radio de la bola de fuego
                    rMinus = utils.random(0.3, 0.5), -- disminución progresiva del radio
                    d = utils.random(0.15, 0.25),
                    color = self.trail_color,
                    live = -1 -- sirve de efecto de disparo (sg)
                }
            )
            self.parent.area:add(trail)
        end
    )
end

function SimpleCircle:destroy()
    self.parent = nil
end

function SimpleCircle:kill()
    -- Temblor
    --camera:shake(6, 60, 0.4)
    -- Relampagueo
    flash(12)
    -- Ralentización
    slow(self.parent.timer, 0.15, 1)

    local eff = DeathEffect(
        self.parent.area,
        self.x,
        self.y,
        {
            --timer = self.timer,
            --parent = self,
            --live = 0.1, -- sirve de efecto de disparo (sg)
            color = { 0, 0, 255, 150 },
            w = self.w * 2
        }
    )
    if (self.parent.area) then self.parent.area:add(eff) end

    self.dead = true
    self:destroy()
end

function SimpleCircle:key(key)
    self.trail_color = skill_point_color
    if(key == "up")then
        self.trail_color = boost_up_color
    end
    if (key == "down") then
        self.trail_color = boost_down_color
    end
end

function SimpleCircle:update(dt)
    if(self.dead)then return end
    if(self.parent)then
        self.x, self.y = self.parent.x, self.parent.y
        self.w, self.h = self.parent.w, self.parent.h
        self.r = self.parent.r
    end
end

function SimpleCircle:draw()
    if self.dead then return end
    love.graphics.setColor(0, 0.5, 1, 0.8)
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))
end

return SimpleCircle