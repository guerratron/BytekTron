if (_G["Seeker"]) then
    return _G["Seeker"]
end

local Shooter      = require "objects.enemies.Shooter"

--local Physics = require "_LIBS_.windfield"
local Vector          = require('_LIBS_.hump.vector')
local Draft           = require('_LIBS_.draft.draft')
local draft           = Draft()
local DeathEffect     = require "objects.effects.DeathEffect"
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local Mina = require "objects.projectils.Mina"
local utils           = require "tools.utils"

local Seeker = Shooter:extend()

-- necesita llamar posteriormente a love.graphics.pop()
function Seeker.pushRotateScale(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r or 0)
    if (sx or sy) then love.graphics.scale(sx or 1, sy or sx or 1) end
    love.graphics.translate(-x, -y)
end

function Seeker:new(game_object, x, y, opts)
    -- game_object, en este caso, es el equivalente al área. 
    -- y self.area se referirá a él.  
    -- Como elemento padre se le pasará el player en las opciones {parent = player}. 
    Seeker.super.new(self, game_object, x, y, opts)
    self.type = "Seeker"

    self.w, self.h = 32, 16
    --self.collider = self.area.world:newPolygonCollider(utils.createIrregularPolygon(5))
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setFixedRotation(false)
    self.r = utils.random(0, 2 * math.pi)
    self.v = utils.random(10, 20)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:applyAngularImpulse(utils.random(-24, 24))
    self.collider:setCollisionClass('Enemy')

    self.points = 5
end

function Seeker:shoot()
    if (not self.area or not self.parent or not self.parent.player) then return false end
    -- EFFECT (punto de disparo)
    --[[self.area:addGameObject(
        'ShootEffect',
        self.x + 1.2 * self.w * math.cos(self.r),
        self.y + 1.2 * self.w * math.sin(self.r)
    )]]
    local d = 0.8 * self.w
    local shoot = ShootEffect(
        self.area,
        self.x + d * math.cos(self.r),
        self.y + d * math.sin(self.r),
        {
            parent = self,
            live = 0.1, -- sirve de efecto de disparo (sg)
            d = d
        }
    )
    local index = self.area:add(shoot)
    shoot.index = index
    --table.insert(self.bulletsIndexes, index)
    local shoot2 = nil
    local index2 = 0

    -- CREAR UNA MINA

    shoot2 = Mina(
        self.area,
        self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
        self.y + 1.4 * self.w * math.sin(self.collider:getAngle()),
        {
            --timer = self.timer,
            --parent = self,
            live = 6.6, -- sirve como alcance del proyectil (sg)
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

-- se mueve ligéramente hacia el player
function Seeker:IA(dt)
    Seeker.super.IA(self, dt)
    local vel  = 1/2
    -- el parent es la room
    local target = self.parent.player --current_room.player
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

function Seeker:draw()
    --local result = Seeker.super.draw(self)
    --if (not result) then return false end
    if self.dead then return false end

    love.graphics.setColor(homing_color)
    Seeker.pushRotateScale(self.x, self.y, self.collider:getAngle(), 1, 1)
        draft:rhombus(self.x, self.y, self.w, self.h, 'line')
        --local points = { self.collider:getWorldPoints(self.collider.shapes.main:getPoints()) }
        --love.graphics.polygon('line', points)
    love.graphics.pop()
    love.graphics.setColor(default_color)
    return true
end

return Seeker