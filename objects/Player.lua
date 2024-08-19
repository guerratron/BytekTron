if (_G["Player"]) then
    return _G["Player"]
end
local GameObject = require "objects.basics.GameObject"

local Player = GameObject:extend()

local Input        = require("_LIBS_.boipushy.Input")
local Timer        = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
--local Physics = require "_LIBS_.windfield"
local Area         = require "objects.basics.Area"
local Fighter      = require "objects.ships.Fighter"
local Master       = require "objects.ships.Master"
local Medium       = require "objects.ships.Medium"
local Tulip        = require "objects.ships.Tulip"
local Crusader     = require "objects.ships.Crusader"
local SimpleCircle = require "objects.ships.SimpleCircle"
local ShootEffect  = require "objects.effects.ShootEffect"
local HasteArea    = require "objects.effects.HasteArea"
local Bullet       = require "objects.projectils.Bullet"
--local Projectile = require "objects.projectils.Projectile"
local LightningRay = require "objects.projectils.LightningRay"
local LaserRay = require "objects.projectils.LaserRay"
local Ammo         = require "objects.resources.Ammo"
local Boost        = require "objects.resources.Boost"
local HP         = require "objects.resources.HP"
local SP         = require "objects.resources.SP"
local Attack     = require "objects.resources.Attack"
--local Rock       = require "objects.enemies.Rock"
--local Shooter       = require "objects.enemies.Shooter"
--local TrailParticle   = require "objects.TrailParticle"
--local DeathEffect = require "objects.effects.DeathEffect"
local TextEffect = require "objects.effects.TextEffect"
--local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils = require "tools.utils"

--[[
local function toShake(self, cam, shake, _cont)
    _cont = _cont or 0
    --print(shake.ini)
    if(not self.timer)then return false end
    self.timer:after(
        shake.ini,
        function()
            --print(true, shake.ini)
            cam:move(shake.dx, shake.dy)
            _cont = _cont + 1
            if (_cont < shake.rep) then
                toShake(self, cam, shake, _cont)
            end
        end
    )
end
]]

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)
    self.type = "Player"

    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    --self.collider:setType('static')
    --self.collider:setRestitution(0.8)
    --self.collider:applyAngularImpulse(5000)
    self.collider:setCollisionClass('Player')

    self.r = -math.pi / 2
    --self.rv = 1.66 * math.pi


    --[[self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2]]

    self.bulletsIndexes = {}

    self.input = Input()
    self.input:bind('left', 'left')
    self.input:bind('right', 'right')
    self.input:bind('up', 'up')
    self.input:bind('down', 'down')

    --ship_selected = "Tulip"

    if ship_selected == "Fighter" then
        self.ship = Fighter(self, self.x, self.y, { color = { 0.1, 0.9, 0.6, 1 } })
    elseif ship_selected == "Master" then
        self.ship = Master(self, self.x, self.y, { color = { 0.1, 0.6, 0.9, 1 } })
    elseif ship_selected == "Medium" then
        self.ship = Medium(self, self.x, self.y, { color = { 0.6, 0.9, 0.1, 1 } })
    elseif ship_selected == "Tulip" then
        self.ship = Tulip(self, self.x, self.y, { color = { 0.9, 0.1, 0.6, 1 } })
    elseif ship_selected == "Crusader" then
        self.ship = Crusader(self, self.x, self.y, { color = { 0.6, 0.9, 0.6, 1 } })
    end
    --self.ship = SimpleCircle(self, self.x, self.y, { color = { 1, 0.3, 0.6, 1 } })

    self.rv = self.ship.rv -- velocidad de impulso o de giro
    self.v = self.ship.v               -- velocidad
    --self.max_v = 10 --100
    self.base_max_v = self.ship.base_max_v
    self.max_v = self.base_max_v
    self.a = self.ship.a --100 -- aceleración

    self.shoot_timer = 0
    self.shoot_cooldown = self.ship.shoot_cooldown -- lo trae el ataque no el tipo de nave
    self.max_points = self.ship.max_points
    self.points = self.ship.points
    self.points_multiplier = 1
    self.max_ammo = self.ship.max_ammo
    self.ammos = self.ship.ammos
    self.attack_count = 0
    self.attack_count_multiplier = 1
    self:setAttack('Neutral')
    --self:setAttack('Homing')
    self.max_hp = self.ship.max_hp
    self.hp = self.ship.hp
    self.max_sp = self.ship.max_sp
    self.sp = self.ship.sp
    self.sp_multiplier = 1
    self.sp_adding = 0
    self.invincible = self.ship.invincible
    self.invincible_time = 5

    -- Cycle
    self.cycle_timer = 0
    self.cycle_cooldown = self.ship.cycle_cooldown
    self.cycles = {}
    self.cycleIndex = 0

    --print("loadedData.sp", loadedData.sp)
    --[[local data = loadedData --load()
    if(data)then
        for key, value in pairs(data) do
            --print("player", key, value)
            if(key ~= "points")then
                if(self[key])then
                    self[key] = value
                    --print("player", key, value)
                end
                if (self.ship[key]) then
                    self.ship[key] = value
                    --print("ship", key, value)
                end
            end
        end
    end]]

    -- Multipliers
    -- tree[2] = {'HP', {'6% Increased HP', 'hp_multiplier', 0.06}}
    self.hp_multiplier = 1
    self.ammo_multiplier = 1
    self.boost_multiplier = 1
    -- Flats
    -- tree[15] = {'Flat HP', {'+10 Max HP', 'flat_hp', 10}}
    self.flat_hp = 0
    self.flat_ammo = 0
    self.flat_boost = 0
    -- Extras
    self.ammo_gain = 0

    -- Chances
    self.chances = {} -- listado de probabilidades de variables terminadas en "_chance"
    --self.launch_homing_projectile_on_ammo_pickup_chance = 5 -- 5% probabilidad (5 true y 95 false en chances)
    self.launch_homing_projectile_on_ammo_pickup_chance = 75
    self.additional_homing_projectiles_chance = 50
    self.regain_hp_on_ammo_pickup_chance = 50
    self.regain_hp_on_sp_pickup_chance = 50
    self.spawn_sp_on_cycle_chance = 25
    self.shield_projectile_chance = 5
    self:generateChances()
    -- Multipliers
    -- .. shoot-velocity
    self.aspd_multiplier = 1
    self.pre_haste_aspd_multiplier = self.aspd_multiplier
    self.inside_haste_area = false
    -- self.gain_aspd_boost_on_kill_chance = 0
    -- ..hp
    self.inside_haste_area_hp = false

    -- Booleans
    self.projectile_ninety_degree_change = false
    self.projectile_ninety_degree_time = 5
    self.fast_slow = false
    self.slow_fast = false --not self.fast_slow

    -- Ralentiza los tiempos entre dos círculos de HP seguidos
    self.hasteHP_timedown = 0
    self.hasteHP_max_time = 2
    -- toShake()

    local data = loadedData --load()
    if (data) then
        for key, value in pairs(data) do
            --print("player", key, value)
            if (key ~= "points") then
                if (self[key]) then
                    self[key] = value
                    --print("player", key, value)
                end
                if (self.ship[key]) then
                    self.ship[key] = value
                    --print("ship", key, value)
                end
            end
        end
    end

    self.tree = opts.tree or tree
    if (loadedData.bought_node_indexes) then
        treeToPlayer(self.tree, self, loadedData.bought_node_indexes)
    end
    --print(self.aspd_multiplier)
    self:setStats()
end

function Player:enterHasteAreaVelocity()
    self.inside_haste_area = true
    self.pre_haste_aspd_multiplier = self.aspd_multiplier
    self.aspd_multiplier = self.aspd_multiplier / 2
end
function Player:exitHasteAreaVelocity()
    self.inside_haste_area = false
    self.aspd_multiplier = self.pre_haste_aspd_multiplier
    self.pre_haste_aspd_multiplier = 1
end

function Player:enterHasteAreaHP()
    self.inside_haste_area_hp = true
    self:addHP(1)
end

function Player:exitHasteAreaHP()
    self.inside_haste_area_hp = false
end

function Player:setStats()
    self.max_hp = (self.max_hp + self.flat_hp) * self.hp_multiplier
    self.hp = self.max_hp
    self.max_ammo = (self.max_ammo + self.flat_ammo) * self.ammo_multiplier
    self.ammos = self.max_ammo
    self.ship.max_boost = (self.ship.max_boost + self.flat_boost) * self.boost_multiplier
    self.ship.boost = self.ship.max_boost
end

function Player:generateChances()
    self.chances = {}
    for k, v in pairs(self) do
        -- variables numéricas terminadas en "_chance"
        if k:find('_chance') and type(v) == 'number' then
            self.chances[k] = utils.chanceList({ true, math.ceil(v) }, { false, 100 - math.ceil(v) })
        end
    end
end

function Player:onCycle()
    if self.chances.spawn_sp_on_cycle_chance:next() then
        --self.area:addGameObject('SkillPoint')
        local ob = SP(self.area, 0, 0, { parent = self.player, color = default_color }) --, {timer = self.timer})
        ob.index = self.area:add(ob)
        --self.area:addGameObject('InfoText', self.x, self.y, { text = 'SP Spawn!', color = skill_point_color })
        local txtEff = TextEffect(self, self.x, self.y, { text = "SP Spawn !", color = skill_point_color })
        if (self.area) then self.area:add(txtEff) end
    end
end
function Player:cycle()
    local color = utils.tableRandom({{0.2, 1, 0.2}, {1, 0.2, 0.2}, {0.2, 0.2, 1}})
    local txtEff = TextEffect(self, gw/3, 2*gh/3, { text = "NEW CYCLE !", color = color, scale = 4 })
    if (self.area) then
        self.area:add(txtEff)
        print("to new Cycle [" .. #self.cycles .. "], points = " .. self.points)
    end
    table.insert(self.cycles, {points = self.points})
    Sounds.play("action3")
    if (self.ship and self.ship.type == "Fighter") then
        --achs("2 Cycles Fighter", utils.tablePairsCount(self.cycles) >= 1)
        achs("2 Cycles Fighter", #self.cycles == 2)
    end
    collectgarbage()
    self.area.room:pauseTemp(true, 4)
    --self.points = 0
    -- SHAKE
    self:onCycle()
end

function Player:shoot()
    if (not self.bulletsIndexes) then return end
    local soundPlaying = false
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
    table.insert(self.bulletsIndexes, index)

    --BULLET
    --[[self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r),
        self.y + 1.5 * d * math.sin(self.r), { r = self.r })
    local shoot2 = Projectile(-- Bullet(
        self.area,
        self.x + 1.5 * d * math.cos(self.r),
        self.y + 1.5 * d * math.sin(self.r),
        {
            --timer = self.timer,
            --parent = self,
            live = 0.6, -- sirve como alcance del proyectil (sg)
            d = d,
            r = self.r
        }
    )]]
    local shoot2 = nil
    local index2 = 0
    local mods = {
        --timer = self.timer,
        --parent = self,
        own = self,
        attack = self.attack,
        shield = self.chances.shield_projectile_chance:next(),
        live = 0.6,         -- sirve como alcance del proyectil (sg)
        d = d,
        r = self.r,
        hp = 10
    }
    if self.attack == 'Neutral' then
        --[[print("rad=" .. self.r,
            "grad=" .. utils.toGrad(self.r),
            "norm=" .. utils.toGradNormalized(self.r),
            "atan=" .. math.atan(self.r)
            --"atan2=" .. math.atan2(self.x, self.y),
            --"sin=" .. math.sin(self.r),
            --"cos=" .. math.cos(self.r),
            --"90º:" .. (math.pi / 2),
            --"270º:" .. (3 * math.pi / 2)
        )]]
        shoot2 = Bullet(
            self.area,
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            utils.tableAddTable(mods, {live = 0.6, hp = 10})
        )
        Sounds.play("ship_shoot2")
        soundPlaying = true
    elseif self.attack == 'Rapid' then
        shoot2 = Projectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            utils.tableAddTable(mods, {live = 0.6, hp = 10})
        )
    elseif self.attack == 'Projectile' then
        shoot2 = Projectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            utils.tableAddTable(mods, {live = 0.6, hp = 20})
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
        shoot2 = Projectile(
            self.area,
            subXA,
            subYA,
            utils.tableAddTable(mods, { live = 0.6, r = subRA, hp = 20 })
        )
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        table.insert(self.bulletsIndexes, index2)

        -- shoot 2
        shoot2 = Projectile(
            self.area,
            subXB,
            subYB,
            utils.tableAddTable(mods, { live = 0.6, r = subRB, hp = 20 })
        )
        Sounds.play("ship_shoot3")
        soundPlaying = true
    elseif self.attack == 'Triple' or self.attack == 'TripleBack' or self.attack == "Side" then
        local subXA = self.x + 1.5 * d * math.cos(self.r + math.pi / 6)
        local subYA = self.y + 1.5 * d * math.sin(self.r + math.pi / 6)
        local subRA = self.r + math.pi / 6
        if (self.attack == "Side") then
            subXA = self.x + 1.5 * d * math.cos(self.r + math.pi/2)
            subYA = self.y + 1.5 * d * math.sin(self.r + math.pi/2)
            subRA = self.r + math.pi/2
        end
        -- shoot 1
        shoot2 = Projectile(
            self.area,
            subXA,
            subYA,
            utils.tableAddTable(mods, { live = 0.6, r = subRA, hp = 30 })
        )
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        table.insert(self.bulletsIndexes, index2)

        -- shoot 2 (Triple + TripleBack)
        local subX = self.x + 1.5 * d * math.cos(self.r)
        local subY = self.y + 1.5 * d * math.sin(self.r)
        local subR = self.r
        if(self.attack == "TripleBack")then
            subX = self.x + 1.5 * d * math.cos(self.r - math.pi)
            subY = self.y + 1.5 * d * math.sin(self.r - math.pi)
            subR = self.r - math.pi
        end
        shoot2 = Projectile(
            self.area,
            subX,
            subY,
            utils.tableAddTable(mods, { live = 0.6, r = subR, hp = 30 })
        )
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        table.insert(self.bulletsIndexes, index2)

        -- shoot 3
        local subXB = self.x + 1.5 * d * math.cos(self.r - math.pi / 6)
        local subYB = self.y + 1.5 * d * math.sin(self.r - math.pi / 6)
        local subRB = self.r - math.pi / 6
        if (self.attack == "Side") then
            subXB = self.x + 1.5 * d * math.cos(self.r - math.pi / 2)
            subYB = self.y + 1.5 * d * math.sin(self.r - math.pi / 2)
            subRB = self.r - math.pi / 2
        end
        shoot2 = Projectile(
            self.area,
            subXB,
            subYB,
            utils.tableAddTable(mods, { live = 0.6, r = subRB, hp = 30 })
        )
        Sounds.play("ship_shoot4")
        soundPlaying = true
    elseif self.attack == 'Spread' then
        local angleR = utils.random(-math.pi / 8, math.pi / 8)
        --angleR = angleR * self.r/8
        shoot2 = Projectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r), -- + angleR),
            self.y + 1.5 * d * math.sin(self.r), -- + angleR),
            utils.tableAddTable(mods, { live = 1.2, r = self.r + angleR, hp = 40 })
        )
        Sounds.play("ship_shoot5")
        soundPlaying = true
    elseif self.attack == 'Homing' then
        local angleR = utils.random(-math.pi / 8, math.pi / 8)
        --angleR = angleR * self.r/8
        shoot2 = Projectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r + angleR),
            self.y + 1.5 * d * math.sin(self.r + angleR),
            utils.tableAddTable(mods, { live = 3.2, r = self.r + angleR, hp = 80 })
        )
    elseif self.attack == 'Blast' then
        self.ammos = self.ammos - attacks[self.attack].ammos -- quita el doble de ammos
        for i = 1, 6 do
            local random_angle = utils.random(-math.pi / 6, math.pi / 6)
            shoot2 = Projectile(
                self.area,
                self.x + 1.5 * d * math.cos(self.r + random_angle),
                self.y + 1.5 * d * math.sin(self.r + random_angle),
                utils.tableAddTable(mods, { live = 0.3, r = self.r + random_angle, s = 1.5, v = utils.random(200, 300), hp = 6 })
            )
            -- el último se añade al final de la función "shoot()"
            if(i < 6)then
                index2 = self.area:add(shoot2)
                shoot2.index = index2
                --shoot2.own = self --own == player or enemy
                table.insert(self.bulletsIndexes, index2)
            end
        end
        if(self.ammos % 11 == 0)then camera:shake(4, 60, 0.4) end
        Sounds.play("ship_shoot6")
        soundPlaying = true
    elseif self.attack == 'Flame' then
        self.ammos = self.ammos - attacks[self.attack].ammos -- quita el doble de ammos
        for i = 1, 6 do
            local random_angle = utils.random(-math.pi / 6, math.pi / 6)
            shoot2 = Projectile(
                self.area,
                self.x + 1.5 * d * math.cos(self.r + random_angle),
                self.y + 1.5 * d * math.sin(self.r + random_angle),
                utils.tableAddTable(mods,
                    { live = 0.4, r = self.r + random_angle/2, s = 1.5, v = utils.random(150, 250), hp = 6 })
            )
            -- el último se añade al final de la función "shoot()"
            if(i < 6)then
                index2 = self.area:add(shoot2)
                shoot2.index = index2
                --shoot2.own = self --own == player or enemy
                table.insert(self.bulletsIndexes, index2)
            end
        end
        if (self.ammos % 11 == 0) then camera:shake(4, 60, 0.4) end
        Sounds.play("ship_shoot6")
        soundPlaying = true
    elseif self.attack == 'Spin' then
        local angleR = utils.random(-math.pi / 8, math.pi / 8)
        --angleR = angleR * self.r/8
        shoot2 = Projectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r), -- + angleR),
            self.y + 1.5 * d * math.sin(self.r), -- + angleR),
            utils.tableAddTable(mods, { live = 2.2, r = self.r + angleR, hp = 25 })
        )
    elseif self.attack == 'Bounce' then
        self.ammos = self.ammos - attacks[self.attack].ammos -- quita el doble de ammos
        shoot2 = Projectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r), -- + angleR),
            self.y + 1.5 * d * math.sin(self.r), -- + angleR),
            utils.tableAddTable(mods, { live = 2.2, r = self.r, hp = 25, bounce = 4 })
        )
    elseif self.attack == '2Split' then
        self.ammos = self.ammos - attacks[self.attack].ammos -- quita el doble de ammos
        shoot2 = Projectile(
            self.area,
            self.x + 1.5 * d * math.cos(self.r), -- + angleR),
            self.y + 1.5 * d * math.sin(self.r), -- + angleR),
            utils.tableAddTable(mods, { live = 2.2, r = self.r, hp = 25, bounce = 4 })
        )
    elseif self.attack == 'LightningRay' then
        local x1, y1 = self.x + d * math.cos(self.r), self.y + d * math.sin(self.r)
        local cx, cy = x1 + 24 * math.cos(self.r), y1 + 24 * math.sin(self.r)
        -- Find nearby enemy
        local nearby_enemies = self.area:getAllChildrenThat(function(e)
            for key, _ in pairs(enemies) do
                if (e.type == key) and (utils.distance(e.x, e.y, cx, cy) < 64) then
                    return true
                end
            end
        end)
        local closest_enemy = nil
        if (#nearby_enemies > 0) then
            closest_enemy = table.remove(nearby_enemies, love.math.random(1, #nearby_enemies))
        end
        -- Attack closest enemy
        if closest_enemy then
            self.ammos = self.ammos - attacks[self.attack].ammos
            local angleR = utils.random(-math.pi / 8, math.pi / 8)
            --closest_enemy:hit()
            local x2, y2 = closest_enemy.x, closest_enemy.y
            --self.area:addGameObject('LightningLine', 0, 0, { x1 = x1, y1 = y1, x2 = x2, y2 = y2 })
            shoot2 = LightningRay(
                self.area,
                self.x + 1.5 * d * math.cos(self.r + angleR),
                self.y + 1.5 * d * math.sin(self.r + angleR),
                utils.tableAddTable(mods,
                    { live = 1.2, hp = 30, x1 = x1, y1 = y1, x2 = x2, y2 = y2, s=6, alpha = 0.9 })
            )
            -- Este disparo es tan rápido (como el rayo) que impacta en el enemigo antes de lanzarlo
            -- por eso se le resta la "hp" desde aquí
            local hp1 = closest_enemy.hp
            closest_enemy:hit(shoot2.hp)
        end
    elseif self.attack == 'LaserRay' then
            self.ammos = self.ammos - attacks[self.attack].ammos
        local x1, y1 = self.x + d * math.cos(self.r), self.y + d * math.sin(self.r)
        local x2, y2
        -- x2 : positivo hacia la derecha, negativo hacia la izquierda
        --if (self.r < math.pi / 2 or self.r > 3 * math.pi / 2) then x2 = gw - x1 else x2 = 0 end
        --if (math.abs(self.r) < math.pi / 2) then x2 = gw - x1 else x2 = 0 end
        -- y2 : positivo hacia la derecha, negativo hacia la izquierda
        --if (self.r > math.pi) then y2 = gh - y1 else y2 = 0 end
        local grad = utils.toGradNormalized(self.r)
        if (grad < 90 or grad > 270) then x2 = gw * math.cos(self.r) else x2 = 0 end
        if (grad > 180) then y2 = gh * math.sin(self.r) else y2 = 0 end
        -- Find nearby enemy
        local nearby_enemies = self.area:getAllChildrenThat(function(e)
            for key, _ in pairs(enemies) do
                if (e.type == key) and utils.inSquare(
                    --{ x = e.x, y = e.y, w = e.s or e.d or d, h = e.s or e.d or d },
                    { x = e.x, y = e.y, w = 5, h = 5 },
                    {x1 = x1, y1 = y1, x2 = x2, y2 = y2}) then
                        --print(true)
                    return true
                end
            end
        end)
        -- Fight
        shoot2 = LaserRay(
            self.area,
            x1,
            y1,
            utils.tableAddTable(mods,
                { live = 1.6, hp = 400, x2 = x2, y2 = y2, s = 6, alpha = 0.9 })
        )
        -- Kill all nearby enemies
        for _, enemy in pairs(nearby_enemies) do enemy:kill() end
    end

    if(shoot2)then
        index2 = self.area:add(shoot2)
        shoot2.index = index2
        --shoot2.own = self --own == player or enemy
        table.insert(self.bulletsIndexes, index2)

        self.ammos = self.ammos - attacks[self.attack].ammos
        if self.ammos <= 0 then
            self:setAttack('Neutral')
            --self.ammo = self.max_ammo
        end
        --[[if(not shoot_sound:isPlaying())then
            shoot_sound:play()
        end]]
        if(not soundPlaying)then Sounds.play("ship_shoot") end
    end
end

function Player:setAttack(attack)
    if not attacks[attack] then
        return false
    end
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammos = self.max_ammo
    if(self.attack ~= "Neutral")then
        Sounds.play("action4")
        self.attack_count = self.attack_count * self.attack_count_multiplier + 1
        achs("10 Attacks", self.attack_count >= 5)
    end
    return true
end

function Player:killBullet(index)
    local bullet = self.area.children[self.bulletsIndexes[index]]
    if (bullet) then
        --self.area:remove(index)
        bullet:kill()
    end
    table.remove(self.bulletsIndexes, index)
end

function Player:kill()
    Sounds.play("explosion")
    local data = {
        points = self.points,
        ammos = self.ammos,
        hp = self.hp,
        sp = self.sp
    }
    local data2 = {}
    if(self.ship)then
        data2 = {
            boost = self.ship.boost
        }
    end
    saveData(utils.tableMerge(data, data2))

    --print("-Player(KILL) - sp:", self.sp, loadedData.sp)

    if(self.bulletsIndexes)then
        for i = #self.bulletsIndexes, 1, -1 do
            self:killBullet(i)
        end
        self.bulletsIndexes = nil
    end

    if(self.ship and self.ship.kill)then
        self.ship:kill()
    end

    if (self.area and self.area.room) then
        self.area.room:finish()
    end
    Player.super.kill(self)
    --if self.collider then self.collider:destroy() end
    --self.collider = nil
    self.input = nil
    self.ship = nil
    self.chances = nil
    self.cycles = nil
    --if self.timer and self.timer.destroy then self.timer:destroy() end
    --self.timer = nil
end

function Player:addPoints(points)
    self.points = self.points * 4 * self.points_multiplier -- parecían pocos points
    self.points = math.min(self.points + points, self.max_points)
    self.area.room:addScore(points)
    --if(self.points >= 1000)then
    if(self.points % 67 == 0)then
        self:cycle()
    end
    if(self.points % 11 == 0)then
        self.projectile_ninety_degree_change = true
        if not self.timer then return end
        self.timer:after(self.projectile_ninety_degree_time, function()
            self.projectile_ninety_degree_change = false
        end)
    end
    if (self.ship and self.ship.type == "Fighter") then
        --print("--10K Fighter", self.points, self.points >= 10000)
        --[[if not achievements['10K Fighter'] and self.points >= 10000 then
            print("-ACHIEVEMENTS: '10K Fighter', PLAYER-POINTS: ", self.points)
            achievements['10K Fighter'] = true
            -- Do whatever else that should be done when an achievement is unlocked
            Sounds.play("action3")
        end]]
        achs("10K Fighter", self.points >= 10000)
    end
end
function Player:addAmmo(ammo)
    if (not self.area or not self.area.room) then return false end
    --print("ammo", ammo.type)
    self:addPoints(ammo.points * 2)
    self.ammos = math.min(self.ammos + self.ammo_gain + ammo.points, self.max_ammo)
    self.area.room.score = self.area.room.score + 50
end
function Player:addBoost(boost)
    if (not self.area or not self.area.room) then return false end
    --print("boost", boost.type)
    self:addPoints(boost.points * 2)
    self.ship.boost = math.min(self.ship.boost + boost.points, self.ship.max_boost)
    self.area.room.score = self.area.room.score + 150
end
function Player:addHP(hp)
    if (not self.area or not self.area.room) then return false end
    --print("hp", hp)
    self:addPoints(hp / 2)
    --self.ship.boost = math.min(self.ship.boost + boost.points, self.ship.max_boost)
    self.hp = math.min(self.hp + hp, self.max_hp)
    self.area.room.score = self.area.room.score + 50
    if(self.hp <= 0)then
        self:kill()
    end
end
function Player:addSP(sp) -- Skill Point
    if (not self.area or not self.area.room) then return false end
    --print("sp", sp.type)
    self:addPoints(sp.points / 2)
    self.sp = math.min(self.sp + (sp.points * self.sp_multiplier) + self.sp_adding, self.max_sp)
    self.area.room.score = self.area.room.score + 250
    self:makeHasteArea(
        "Velocity Area !",
        sp_color,
        function(_self)
            --_self == HasteArea, self == Player
            if not self then return end                                 --current_room.player
            local d = utils.distance(_self.x, _self.y, self.x, self.y)
            if d < _self.r and not self.inside_haste_area then          -- Enter event
                self:enterHasteAreaVelocity()
            elseif d >= _self.r and self.inside_haste_area then         -- Leave event
                self:exitHasteAreaVelocity()
            end
        end,
        function (_self)
            if (self) then
                self:exitHasteAreaVelocity()
            end
        end
    )
end
-- Crea un círculo de velocidad, hp, u otros powerups
function Player:makeHasteArea(text, color, _outerUpdate, _outerKill)
    local dX = self.x + utils.random(-100, 100)
    local dY = self.y + utils.random(-100, 100)
    local haste = HasteArea(
        self.area,
        dX, -- * math.cos(self.r),     -- + angleR),
        dY, -- * math.sin(self.r),     -- + angleR),
        {
            --timer = self.timer,
            parent = nil, -- OBLIGATORIO el parent = nil
            player = self,
            --live = 0.6,     -- sirve como alcance del proyectil (sg)
            --r = self.r,
            color = color,
            outerUpdate = _outerUpdate,
            outerKill = _outerKill
        }
    )
    local index = self.area:add(haste)
    haste.index = index

    local txtEff = TextEffect(
        self,
        haste.x,
        haste.y,
        {
            --parent = self,
            --live = 0.1, -- sirve de efecto de disparo (sg)
            text = text,
            color = color
        }
    )
    if (self.area) then self.area:add(txtEff) end
end

function Player:addPointKillEnemy(enemy) -- Skill Point
    if(not self.area or not self.area.room)then return false end
    self:addPoints(enemy.points)
    local points = 0
    --print(enemy.type)
    if(enemy.type == "Rock")then
        points = 50
    elseif(enemy.type == "BigRock")then
        points = 150
    elseif (enemy.type == "Shooter") then
        points = 175
    elseif (enemy.type == "EnemyProjectile") then
        points = 125
    end
    self.area.room.score = self.area.room.score + points
end

function Player:addPointKillAttack(attack) -- Skill Point
    if (not self.area or not self.area.room) then return false end
    --print(attack.type)
    self:addPoints(attack.points)
    self.area.room.score = self.area.room.score + 500
end
function Player:addPointKillProjectile(projectil) -- Skill Point
    if (not self.area or not self.area.room) then return false end
    --print(projectil.type)
    self:addPoints(projectil.points)
    self.area.room.score = self.area.room.score + 80
    if(self.hasteHP_timedown > self.hasteHP_max_time)then
        self:makeHasteArea(
            "HP Area !",
            hp_color,
            function(_self)
                --_self == HasteArea, self == Player
                if not self then return end                         --current_room.player
                local d = utils.distance(_self.x, _self.y, self.x, self.y)
                if d < _self.r and not self.inside_haste_area_hp then  -- Enter event
                    self:enterHasteAreaHP()
                elseif d >= _self.r and self.inside_haste_area_hp then -- Leave event
                    self:exitHasteAreaHP()
                end
            end,
            function(_self)
                if (self) then
                    self:exitHasteAreaHP()
                end
            end
        )
        self.hasteHP_timedown = 0
    end
end

function Player:hit(damage, obj)
    -- Rock, Shooter or EnemyProjectile
    --print(self.invincible, damage)
    if(self.invincible)then return false end

    damage = damage or 50
    --self.hp = self.hp - damage
    self:addHP(-damage)

    --print(damage, obj.type)
    self:addPointKillEnemy(obj)

    self.hit_flash = true
    if(self.timer)then
        self.timer:after(0.2, function()
            self.hit_flash = false
            if (self.hp <= 0) then
                --self.withTexEffect = true -- visualiza el texto "+HP" temporálmente
                self:kill()
            end
        end)
    else
        self:kill()
    end
    if(damage >= 30)then
        --[[TODO: Si el daño recibido es inferior a 30, entonces la cámara debería temblar con una intensidad 
        de 6 durante 0,1 segundos, la pantalla debería parpadear durante 2 fotogramas y el juego debería 
        ralentizarse a 0,75 durante 0,25 segundos.]]
        self.invincible = true
        if(self.timer)then
            self.timer:after(self.invincible_time, function()
                self.invincible = false
            end)
        else
            self:kill()
        end
    end
    Sounds.play("power_ups2")
end

function Player:onAmmoPickup()
    if self.chances.launch_homing_projectile_on_ammo_pickup_chance:next() then
        local d = 1.2 * self.w
        --[[self.area:addGameObject('Projectile',
            self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
            { r = self.r, attack = 'Homing' })]]
        local additional_homing_projectiles = 1
        if(self.chances.additional_homing_projectiles_chance:next())then
            additional_homing_projectiles = utils.random(2, 4)
        end
        for i = 1, 1 + additional_homing_projectiles do
            local shoot2 = Projectile(
                self.area,
                self.x + d * math.cos(self.r),       -- + angleR),
                self.y + d * math.sin(self.r), -- + angleR),
                {
                    --timer = self.timer,
                    --parent = self,
                    live = 0.6, -- sirve como alcance del proyectil (sg)
                    d = d,
                    r = self.r,
                    hp = 40,
                    attack = 'Homing'
                }
            )
            local index2 = self.area:add(shoot2)
            shoot2.index = index2
            shoot2.own = self --own == player or enemy
            table.insert(self.bulletsIndexes, index2)
        end

        --self.area:addGameObject('InfoText', self.x, self.y, { text = 'Homing Projectile!' })
        local eff3 = TextEffect(
            self,
            self.x,
            self.y,
            {
                --parent = self,
                --live = 0.1, -- sirve de efecto de disparo (sg)
                text = "Homing Projectile!",
                color = self.color
            }
        )
        if (self.area) then self.area:add(eff3) end
    elseif self.chances.regain_hp_on_ammo_pickup_chance:next() then
        self:addHP(25)
        --self.area:addGameObject('InfoText', self.x, self.y, { text = 'Homing Projectile!' })
        local eff3 = TextEffect(
            self,
            self.x,
            self.y,
            {
                --parent = self,
                --live = 0.1, -- sirve de efecto de disparo (sg)
                text = "HP Regain!",
                color = hp_color
            }
        )
        if (self.area) then self.area:add(eff3) end
    end
end

function Player:onSPPickup()
    if self.chances.regain_hp_on_sp_pickup_chance:next() then
        self:addHP(25)
        --self.area:addGameObject('InfoText', self.x, self.y, { text = 'Homing Projectile!' })
        local eff3 = TextEffect(
            self,
            self.x,
            self.y,
            {
                --parent = self,
                --live = 0.1, -- sirve de efecto de disparo (sg)
                text = "HP-SP Regain!",
                color = hp_color
            }
        )
        if (self.area) then self.area:add(eff3) end
    end
end

function Player:update(dt)
    --if(self.dead)then return end
    Player.super.update(self, dt)
    if (self.dead) then return end
    if(self.bulletsIndexes)then
        for i = #self.bulletsIndexes, 1, -1 do
            local bullet = self.area.children[self.bulletsIndexes[i]]
            if(bullet and bullet.dead)then
                table.remove(self.bulletsIndexes, i)
            end
        end
    end

    -- límites de pantalla
    if self.x < 0 then self:kill() end
    if self.y < 0 then self:kill() end
    if self.x > gw then self:kill() end
    if self.y > gh then self:kill() end

    if self.dead then return end

    --shoot
    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown * self.aspd_multiplier then
        self.shoot_timer = 0
        self:shoot()
    end

    -- Dirección + Impulso
    if self.input:down('left') then
        self.r = self.r - self.rv * dt
    end
    if self.input:down('right') then self.r = self.r + self.rv * dt end
    self.max_v = self.base_max_v
    local key = "none"
    if self.input:down('up') then
        key = "up"
        --self.max_v = 1.5 * self.base_max_v
        self.area.room.fondoZoom = 1 -- zoom-in
    end
    if self.input:down('down') then
        --self.boosting = true
        key = "down"
        --self.max_v = 0.5 * self.base_max_v
        self.area.room.fondoZoom = -1 -- zoom-out
    end
    if (self.ship) then
        self.ship:key(key, dt) --se le informa a la nave que tecla se ha pulsado
    end

    if self.collider:enter('Collectable') then
        local collision_data = self.collider:getEnterCollisionData('Collectable')
        local object = collision_data.collider:getObject()
        if(object)then
            if object:is(Ammo) then
                self:addAmmo(object)
                self:onAmmoPickup()
                object:kill()
            elseif object:is(Boost) then
                self:addBoost(object)
                object.withTexEffect = true -- visualiza el texto "+BOOST" temporálmente
                object:kill()
            elseif object:is(HP) then
                self:addHP(object.points)
                object.withTexEffect = true -- visualiza el texto "+HP" temporálmente
                object:kill()
            elseif object:is(SP) then
                self:addSP(object)
                self:onSPPickup()
                object.withTexEffect = true -- visualiza el texto "+SP" temporálmente
                object:kill()
            elseif object:is(Attack) then
                self:setAttack(object.type)
                object.withTexEffect = true -- visualiza el texto "+..Atack" temporálmente
                self:addPointKillAttack(object)
                object:kill()
            end
        end
    end

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()
        --if object and (object:is(Rock) or object:is(Shooter)) then
        if object and (
            object.type == "Rock" or
            object.type == "BigRock" or
            object.type == "Shooter" or
            object.type == "Seeker"
        ) then
            --print("player->Enemy: ", object.type)
            --local falseObj = {type = object.type, points = -object.points}
            --self:addPointKillEnemy(falseObj)
            --self:setAttack(object.type)
            local hp1 = object.hp
            object:hit(self.hp)
            --object.withTexEffect = true -- visualiza el texto "+HP" temporálmente
            --if(object.hp > 0)then
                --self:addHP(-object.hp)
            --end
            --if(not object or object.dead)then
            --    print("Rock or Shooter", "dead", object)
            --end
            self:hit(hp1/2, object)
            --object:kill()
            --self:kill()
            --print("enemy")
        end
    end
    if self.dead then return end

    -- no sale nunca
    if self.collider:enter('EnemyProjectile') then
        local collision_data = self.collider:getEnterCollisionData('EnemyProjectile')
        local object = collision_data.collider:getObject()
        --if object and object:is(EnemyProjectile) then
        if object and (
            object.type == "EnemyProjectile" or
            object.type == "Mina"
        ) then
            --print("player->EnemyProjectile: ", object.type)
            self:addPointKillProjectile(object)
            local hp1 = object.hp
            object:hit(self.hp)
            self:hit(hp1, object)
            --print("enemy-proj")
        end
    end
    if self.dead then return end
    --[[]]

    self.hasteHP_timedown = self.hasteHP_timedown + dt

    self.v = math.min(self.v + self.a * dt, self.max_v)
    --[[self.v = self.v + self.a * dt
    if self.v >= self.max_v then
        self.v = self.max_v
    end]]
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if (self.ship) then
        self.ship:update(dt)
    end
end

function Player:draw()
    local result = Player.super.draw(self)
    if (not result) then return false end
    if (self.ship) then
        self.ship:draw()
    end
    if (self.invincible) then
        love.graphics.setColor(invincible_color)
        love.graphics.circle("line", self.x, self.y, 1.6 * self.w)
        love.graphics.setColor(default_color)
    end
end

return Player