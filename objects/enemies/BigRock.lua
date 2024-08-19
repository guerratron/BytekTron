if (_G["BigRock"]) then
    return _G["BigRock"]
end

local Rock      = require "objects.enemies.Rock"

local BigRock = Rock:extend()

--local Physics = require "_LIBS_.windfield"
local Vector          = require('_LIBS_.hump.vector')

local EnemyProjectile = require "objects.projectils.EnemyProjectile"
local Draft           = require('_LIBS_.draft.draft')
local TextEffect      = require('objects.effects.TextEffect')
--local draft           = Draft()
local ShootEffect     = require "objects.effects.ShootEffect"
local DeathEffect     = require "objects.effects.DeathEffect"
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils           = require "tools.utils"

-- no tiene en cuenta ni x ni y (se crean aleatorias)
function BigRock:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. 
    -- y self.area se referirá a él.  
    BigRock.super.new(self, game_object, x, y, opts)
    --if opts then for k, v in pairs(opts) do self[k] = v end end

    self.w, self.h = 16, 16
    self.r = -math.pi / 2
    self.type = opts.type or "BigRock"
    --self.type = "BigRock"
    self.collider = self.area.world:newPolygonCollider(utils.createIrregularPolygon(16))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')

    self.points = 10
    self.value = 20
    self.withTexEffect = false
    self.hp = enemies[self.type].hp
end

function BigRock:hit(damage)
    damage = damage or 100
    self.hp = self.hp - damage

    self.hit_flash = true
    if(self.timer)then
        local area = self.area -- se guarda la referencia porque puede desaparecer tras el timer
        self.timer:after(0.2, function ()
            self.hit_flash = false
            if(self.hp <=0)then
                self.withTexEffect = true -- visualiza el texto "+HP" temporálmente
                local ob = Rock(area, self.x, self.y, { parent = area, type = "Rock", attack = self.attack, timer = self.timer or area.timer })
                local idx = area:add(ob)
                ob.index = idx
                self:kill()
            end
        end)
    else
        self:kill()
    end
end

return BigRock