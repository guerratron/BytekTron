if (_G["Director"]) then
    return _G["Director"]
end

--local Timer = require("_LIBS_.chrono.Timer")
local Timer = require("_LIBS_.hump.timer")

-- Director: Es el controlador del juego.  
-- Controla la creación de enemigos y powerups así como el incremento de niveles.  
-- Sólo se actualiza, no se dibuja.
local Director = Object:extend()
local Seeker   = require "objects.enemies.Seeker"
local Rock     = require "objects.enemies.Rock"
local BigRock  = require "objects.enemies.BigRock"
local Shooter  = require "objects.enemies.Shooter"
local Attack   = require "objects.resources.Attack"
local Ammo     = require "objects.resources.Ammo"
local Boost    = require "objects.resources.Boost"
local HP       = require "objects.resources.HP"
local SP       = require "objects.resources.SP"

local utils = require("tools.utils")

function Director:new(room, _pars) --{_index, _id, _type}
    self.room = room               -- referencia a su room padre
    self.stage = room -- igual que room
    self.pars = _pars
    if _pars then for k, v in pairs(_pars) do self[k] = v end end
    self.index = (_pars and _pars._index) or 0
    self.id = (_pars and _pars._id) or utils.UUID()
    self.type = (_pars and _pars._type) or "Director"
    self.innerTimer = false
    self.timer = (_pars and _pars.timer)
    if(not self.timer)then
        self.timer = Timer()
        self.innerTimer = true
    end
    self.finished = false
    self.paused = false
    self.difficulty = 1
    self.round_duration = 22
    self.round_timer = 0

    --[[
Difficulty - Points
1 - 16
2 - 24
3 - 24
4 - 16
5 - 32
6 - 40
7 - 40
8 - 26
9 - 56
10 - 64
11 - 64
12 - 42
13 - 84
..
40 - 400
    ]]
    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16
    for i = 2, 1024, 4 do -- 1024 niveles son demasiados
        self.difficulty_to_points[i] = self.difficulty_to_points[i - 1] + 8
        self.difficulty_to_points[i + 1] = self.difficulty_to_points[i]
        self.difficulty_to_points[i + 2] = math.floor(self.difficulty_to_points[i + 1] / 1.5)
        self.difficulty_to_points[i + 3] = math.floor(self.difficulty_to_points[i + 2] * 2)
    end

    self.enemy_to_points = {
        ['Rock'] = 1,
        ['BigRock'] = 2,
        ['Shooter'] = 3,
        ['Seeker'] = 4,
    }

    --[[events = Utils.chanceList({ 'X', 5 }, { 'Y', 5 }, { 'Z', 10 })
    for i = 1, 40 do
        print(events:next()) --> will print X 10 times, Y 10 times and Z 20 times
    end]]

    self.enemy_spawn_chances = {
        [1] = utils.chanceList({ 'Rock', 1 }),
        [2] = utils.chanceList({ 'Rock', 8 }, { 'Shooter', 4 }),
        [3] = utils.chanceList({ 'Rock', 4 }, { 'BigRock', 2 }),
        [4] = utils.chanceList({ 'Rock', 8 }, { 'Shooter', 8 }),
        [5] = utils.chanceList({ 'Seeker', 4 }),
        [6] = utils.chanceList({ 'Rock', 4 }, { 'Shooter', 8 }),
        [7] = utils.chanceList({ 'BigRock', 4 }, { 'Shooter', 4 }, { 'Seeker', 2 }),
        [8] = utils.chanceList({ 'Rock', 4 }, { 'BigRock', 2 }, { 'Shooter', 2 }, { 'Seeker', 1 })--[[,]]
    }
    --[[ ALEATORIAS:
        for i = 5, 1024 do
            self.enemy_spawn_chances[i] = chanceList(
                {'Rock', love.math.random(2, 12)}, 
                {'Shooter', love.math.random(2, 12)}
            )
        end
    ]]
    self:setEnemySpawnsForThisRound()
    -- HP, SP
    self.resources = 1
    self.resource_duration = 6
    self.resource_timer = 0
    --self.resource_spawn_chances = utils.chanceList({ 'Boost', 28 }, { 'HP', 14 }, { 'SkillPoint', 58 })
    self.resource_spawn_chances = utils.chanceList({ 'Ammo', 3 }, { 'Boost', 4 }, { 'HP', 5 }, { 'Ammo', 3 }, { 'SP', 6 },
        { 'SkillPoint', 7 }) -- SP == SkillPoint
    self:setResourceSpawnsForThisRound()
    --print(self.resource_spawn_chances[self.resources])
    -- N, R, P, 2, Ba, 3, 3B, Si, SR, H, W, F, Sp  (Neutral, Triple, Spin, Blast, Spin, ...)
    self.attacks = 1
    self.attack_duration = 6
    self.attack_timer = 0
    --{ "Neutral", "Rapid", "Projectile", "Double", "DoubleBack", "Triple", "TripleBack", "Side", "Spread", .. }
    self.attack_spawn_chances = utils.chanceList({ 'Rapid', 3 }, { 'Projectile', 4 }, { 'Double', 5 },
        { 'DoubleBack', 6 }, { 'Triple', 7 }, { 'TripleBack', 8 }, { 'Side', 9 }, { 'Spread', 10 }, { 'Blast', 11 },
        { 'Flame', 12 }, { 'Spin', 13 }, { 'Bounce', 14 }, { '2Split', 15 }, { 'LightningRay', 16 },
        { 'LaserRay', 16 }, { 'LaserRay', 16 })
    self:setAttackSpawnsForThisRound()
end

-- pausa o reanuda DEFINITIVAMENTE el director en función del parámetro "yesNo", en caso de segundo parámetro se temporizará 
-- esta acción.  
-- EL PROBLEMA DE ESTO ES QUE TENDRÍA QUE DES-PAUSARSE DESDE UN NIVEL SUPERIOR DEL JUEGO, por ejemplo desde la room padre, 
-- ya que todo la actualizaciónd de la lógica ("update()") se detendrá y ningún hijo avanzará de estado (ni áreas, 
-- ni player, ni efectos, ni ná).
function Director:pause(yesNo, msg)
    if (yesNo == nil) then yesNo = true end
    if (msg) then
        self.timer:after(msg, function()
            self.paused = yesNo
        end)
    else
        self.paused = yesNo
    end
end
-- pausa o reanuda TEMPORÁLMENTE el director en función del parámetro "yesNo", a partir de los milisegundos del segundo 
-- parámetro se reanudará el estado anterior.  
-- NO HAY PROBLEMA, en caso de pausa ningún hijo avanzará de estado (ni áreas, ni player, ni efectos, ni ná) durante 
-- los milisegundos estipulados, luego todo volverá a fluir.
function Director:pauseTemp(yesNo, msg)
    local p = self.paused
    if (yesNo == nil) then yesNo = true end
    if (not msg) then msg = 10 end
    self.paused = yesNo
    self.timer:after(msg, function()
        self.paused = p
    end)
end

function Director:setEnemySpawnsForThisRound()
    if (not self.enemy_spawn_chances or not self.difficulty) then return false end
    if (not self.timer or not self.room or not self.room.areas) then return false end
    if (not self.room.areas[1]) then return false end

    local points = self.difficulty_to_points[self.difficulty]

    -- Find enemies
    local enemy_list = {}
    local cont = 0
    while points > 0 do
        if(points == 1)then cont = cont + 1 end
        if (not self.enemy_spawn_chances or
            not self.difficulty or
            not self.enemy_spawn_chances[self.difficulty] or
            cont > 5 -- protección si más de 5 veces no se encuentra ningún enemigo de 1 punto (Roca)
        ) then
                break
        end
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
        if (not enemy) then break end
        --if points - self.enemy_to_points[enemy] >= 0
        points = points - self.enemy_to_points[enemy]
        table.insert(enemy_list, enemy)
    end

    -- Find enemies spawn times
    local enemy_spawn_times = {}
    for i = 1, #enemy_list do
        enemy_spawn_times[i] = utils.random(0, self.round_duration)
    end
    table.sort(enemy_spawn_times, function(a, b) return a < b end)
    -- .enemy_list = {'Rock', 'Shooter', 'Rock'} -> .enemy_spawn_times = {2.5, 8.4, 14.8}
    -- Lo que significa que una Roca se generaría en 2,5 segundos, un Tirador se generaría en 8,4 
    -- segundos y otra Roca se generaría en 14,8 segundos desde el inicio de la ronda.

    -- Set spawn enemy timer
    for i = 1, #enemy_spawn_times do
        if (self.timer) then
            --print(i, #enemy_spawn_times)
            --print(i, #enemy_spawn_times, enemy_spawn_times[i])
            self.timer:after(enemy_spawn_times[i], function()
                if (self.timer and self.room and self.room.areas) then
                    --print(i, #enemy_spawn_times, enemy_spawn_times[i], enemy_list[i])
                    --self.stage.area:addGameObject(enemy_list[i])
                    --self.stage.areas[1]:addGameObject(enemy_list[i])
                    local area = self.room.areas[1] --self.stage.areas[1]
                    if(area)then
                        local enyAtt = { "Neutral", "Rapid", "Projectile", "Double", "DoubleBack", "Triple", "TripleBack", "Side", "Spread" }
                        local enyAtt2 = utils.tableRandom(enyAtt)
                        local ob
                        if (enemy_list[i] == "Rock") then
                            ob = Rock(area, nil, nil, { parent = area, type = "Rock", attack = enyAtt2, timer = self.timer }) --, {timer = self.timer})
                        elseif (enemy_list[i] == "BigRock") then
                            -- aquí el parent es la room, para que el enemigo pueda encontrar la posición del player
                            ob = BigRock(area, nil, nil,
                                { parent = self.room, type = "BigRock", attack = enyAtt2, timer = self.timer })
                        elseif (enemy_list[i] == "Shooter") then
                            -- aquí el parent es la room, para que el enemigo pueda encontrar la posición del player
                            ob = Shooter(area, nil, nil, { parent = self.room, type = "Shooter", attack = enyAtt2, timer = self.timer })
                        elseif (enemy_list[i] == "Seeker") then
                            -- aquí el parent es la room, para que el enemigo pueda encontrar la posición del player
                            ob = Seeker(area, nil, nil,
                                { parent = self.room, type = "Seeker", attack = enyAtt2, timer = self.timer })
                        end
                        local idx = area:add(ob)
                        ob.index = idx
                    end
                end
            end)
        end
    end
    -- FIN DE NIVEL
    if(#enemy_spawn_times == 0)then return false end
    return true
end

function Director:setResourceSpawnsForThisRound()
    if (not self.resource_spawn_chances or not self.resources) then return false end
    if (not self.timer or not self.room or not self.room.areas) then return false end
    if (not self.room.areas[1]) then return false end

    --local points = self.difficulty_to_points[self.difficulty]

    -- Find enemies
    local resource_list = {}
    --while points > 0 do
    --local res = self.resource_spawn_chances[self.resources]:next()
    local res = self.resource_spawn_chances:next()
        --points = points - self.enemy_to_points[enemy]
        table.insert(resource_list, res)
    --end

    -- Find enemies spawn times
    local resource_spawn_times = {}
    for i = 1, #resource_list do
        resource_spawn_times[i] = utils.random(0, self.resource_duration)
    end
    table.sort(resource_spawn_times, function(a, b) return a < b end)
    -- .enemy_list = {'Rock', 'Shooter', 'Rock'} -> .enemy_spawn_times = {2.5, 8.4, 14.8}
    -- Lo que significa que una Roca se generaría en 2,5 segundos, un Tirador se generaría en 8,4
    -- segundos y otra Roca se generaría en 14,8 segundos desde el inicio de la ronda.

    -- Set spawn enemy timer
    for i = 1, #resource_spawn_times do
        if (self.timer) then
            --print(i, #enemy_spawn_times)
            --print(i, #enemy_spawn_times, enemy_spawn_times[i])
            self.timer:after(resource_spawn_times[i], function()
                --print(i, #enemy_spawn_times, enemy_spawn_times[i], enemy_list[i])
                --self.stage.area:addGameObject(enemy_list[i])
                --self.stage.areas[1]:addGameObject(enemy_list[i])
                if (self.room and self.room.areas) then
                    local area = self.room.areas[1] --self.stage.areas[1]
                    if(area)then
                        local ob
                        if (resource_list[i] == "Boost") then
                            --ob = Rock(area, 0, 0, { parent = area, type = "Rock", attack = enyAtt2, timer = self.timer }) --, {timer = self.timer})
                            ob = Boost(area, 0, 0, { parent = self.player }) --, {timer = self.timer})
                        elseif (resource_list[i] == "Ammo") then
                            ob = Ammo(area, gw / 2, gh / 2, { parent = self.player }) --, {timer = self.timer})
                        elseif (resource_list[i] == "HP") then
                            -- aquí el parent es la room, para que el enemigo pueda encontrar la posición del player
                            --ob = Shooter(area, 0, 0, { parent = self.room, type = "Shooter", attack = enyAtt2, timer = self.timer })
                            ob = HP(area, 0, 0, { parent = self.player }) --, {timer = self.timer})
                        elseif (resource_list[i] == "SP") then
                            ob = SP(area, 0, 0, { parent = self.player }) --, {timer = self.timer})
                        elseif (resource_list[i] == "SkillPoint") then
                            ob = SP(area, 0, 0, { parent = self.player }) --, {timer = self.timer})
                        end
                        local idx = area:add(ob)
                        ob.index = idx
                    end
                end
            end)
        end
    end
end

function Director:setAttackSpawnsForThisRound()
    if (not self.attack_spawn_chances or not self.attacks) then return false end
    if (not self.timer or not self.room or not self.room.areas) then return false end
    if (not self.room.areas[1]) then return false end

    --local points = self.difficulty_to_points[self.difficulty]

    -- Find enemies
    local attack_list = {}
    local res = self.attack_spawn_chances:next()
    table.insert(attack_list, res)

    -- Find enemies spawn times
    local attack_spawn_times = {}
    for i = 1, #attack_list do
        attack_spawn_times[i] = utils.random(0, self.attack_duration)
    end
    table.sort(attack_spawn_times, function(a, b) return a < b end)
    -- .enemy_list = {'Rock', 'Shooter', 'Rock'} -> .enemy_spawn_times = {2.5, 8.4, 14.8}
    -- Lo que significa que una Roca se generaría en 2,5 segundos, un Tirador se generaría en 8,4
    -- segundos y otra Roca se generaría en 14,8 segundos desde el inicio de la ronda.

    -- Set spawn enemy timer
    for i = 1, #attack_spawn_times do
        if (self.timer) then
            --print(i, #enemy_spawn_times)
            --print(i, #enemy_spawn_times, enemy_spawn_times[i])
            self.timer:after(attack_spawn_times[i], function()
                if (self.room and self.room.areas) then
                    --print(i, #enemy_spawn_times, enemy_spawn_times[i], enemy_list[i])
                    --self.stage.area:addGameObject(enemy_list[i])
                    --self.stage.areas[1]:addGameObject(enemy_list[i])
                    local area = self.room.areas[1] --self.stage.areas[1]
                    if(area)then
                        local ob = Attack(area, 0, 0, { parent = self.player, type = attack_list[i] }) --, {timer = self.timer})
                        if(ob)then
                            local idx = area:add(ob)
                            ob.index = idx
                        end
                    end
                end
            end)
        end
    end
end

function Director:destroy()
    self.paused = true
    self.finished = true
    self.room = nil
    self.stage = nil
    self.pars = nil
    if (self.innerTimer and self.timer) then
        if self.timer.destroy then self.timer:destroy() end
    end
    self.timer = nil
    -- no es necesario, ya lo destruye su área madre
    if (self.player) then self.player:kill() end
    self.difficulty_to_points = nil
    self.enemy_to_points = nil
    self.resource_spawn_chances = nil
    self.attack_spawn_chances = nil
end

--------------
function Director:update(dt)
    if(self.innerTimer)then
        self.timer:update(dt)
    end
    if self.paused then return end
    if (not self.room or not self.room.areas[1]) then return false end

    self.round_timer = self.round_timer + dt
    if self.round_timer > self.round_duration then
        self.round_timer = 0
        self.difficulty = self.difficulty + 1
        if(not self:setEnemySpawnsForThisRound())then
            if (self.timer) then
                self.timer:after(2, function()
                    self.finished = true
                    if (self.room and self.room.areas) then
                        self.room:pauseTemp(true, 5)
                    end
                end)
            end
        end
    end
    self.resource_timer = self.resource_timer + dt
    if self.resource_timer > self.resource_duration then
        self.resource_timer = 0
        self.resources = self.resources + 1
        self:setResourceSpawnsForThisRound()
    end
    self.attack_timer = self.attack_timer + dt
    if self.attack_timer > self.attack_duration then
        self.attack_timer = 0
        self.attacks = self.attacks + 1
        self:setAttackSpawnsForThisRound()
    end
end
--[[ dibuja esta área (y sus hijos marcados como current) sólo si es 'current'
function Director:draw()
    if self.paused then return end
end]]

return Director