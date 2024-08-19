if (_G["Stage"]) then
    return _G["Stage"]
end

local Room = require "objects.rooms.Room"

local Stage = Room:extend()

local Timer = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local Input = require("_LIBS_.boipushy.Input")
local Camera = require("_LIBS_.hump.camera")
--local Camera = require("_LIBS_.camera.Camera") -- problemas con smooth
local Director   = require "objects.basics.Director"
local Area = require "objects.basics.Area"
local Player = require "objects.Player"
local Ammo = require "objects.resources.Ammo"
local Boost = require "objects.resources.Boost"
local HP   = require "objects.resources.HP"
local SP   = require "objects.resources.SP"
local Attack = require "objects.resources.Attack"
local Rock   = require "objects.enemies.Rock"
local utils= require "tools.utils"

local LinkerEdgge = require "tools.LinkerEdgge"

function Stage:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "Stage",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        imgFondoPath = opts.imgFondoPath
    }
    Stage.super.new(self, true, pars)
    self._type = "Stage"
    self.type = "Stage"
    self.camera = _camera
    self.camera.x = gw / 2
    self.camera.y = gh / 2
    self.imgFondoPath = opts.imgFondoPath -- aqui no se utiliza pero en otras rooms si
    self.leCycles = LinkerEdgge() -- el orbe indicativo del cycle
    --self.timer = opts.timer or Timer()
    --self.timer = opts.timer
    --self.current_room = nil
    -- se reutiliza pars para el siguiente elemento
    pars._id = utils.UUID()
    pars._type = "Area"
    pars.timer = self.timer          --nil --Timer()-- su propio timer ??
    -- AREA
    self:add(Area(self, true, pars)) --:addPhysicsWorld())
    local area = self.areas[1]
    area:addPhysicsWorld()
    area.world:addCollisionClass('Player')
    --area.world:addCollisionClass('Projectile')
    --area.world:addCollisionClass('Collectable')
    area.world:addCollisionClass('Projectile', { ignores = { 'Projectile', 'Player' } })
    area.world:addCollisionClass('Collectable', { ignores = { 'Projectile' } }) --'Collectable'
    area.world:addCollisionClass('Enemy', { ignores = { 'Collectable' } })
    area.world:addCollisionClass('EnemyProjectile', { ignores = { 'EnemyProjectile', 'Enemy' } })--, 'Projectile'
    -- PLAYER (cada player con un nuevo timer) 
    self.player = Player(area, gw / 2, gh / 2, {timer = self.timer}) --, {timer = Timer()}) -- su propio timer ??
    --self.area:add('Player', gw / 2, gh / 2)
    local index = area:add(self.player)
    self.player.index = index
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    --local input = Input()
    --print(self:is(Room) and self:is(Stage))
    self.director = Director(self, {player = self.player, timer = self.timer})
    self.font = fonts.m5x7_16
    self.fondo_img_chances = utils.chanceList(
        { 'none', 2 },
        { 'assets/fondo1.png', 3 },
        { 'assets/universe.png', 4 },
        { 'assets/universe2.png', 5 }
    )
    local imgPath = self.fondo_img_chances:next()
    self.imgFondo = nil
    if(imgPath == "none")then
    else
        self.imgFondo = love.graphics.newImage(imgPath)
    end
    self.zoom = minZoom
    self.fondoZoom = 0     -- -1 = zoom-out, 0 = zoom-none, +1 = zoom-in
    self.paused = false
    self.visible = true

    -- control a través de tiempo.
    -- Si se especifica "max_time" se pasa a limitar la partida a un máximo de tiempo
    self.max_time = nil --30

    input:bind('p', function()
        --area:addGameObject('Ammo', random(0, gw), random(0, gh))
        --[[local amm = Ammo(area, gw / 2, gh / 2, {parent = self.player}) --, {timer = self.timer})
        local idx = area:add(amm)
        amm.index = idx]]
        if(self.director)then self.director.paused = not self.director.paused end
    end)
    -- f3 elimina player
    input:bind('f3', function()
        if(self.player)then
            self.player:kill()
            --self.player.dead = true
            self.player = nil
        end
    end)
    -- f4 elimina area completa
    input:bind('f4', function()
        if(self.areas)then
            for i = #self.areas, 1, -1 do
                local ar = self.areas[i]
                ar:destroy()
                table.remove(self.areas, i)
            end
        end
        self.areas = nil
    end)
    --input:bind('f8', function() self.camera:shake(4, 60, 1) end)
    -- f4 elimina esta room e inicia una nueva
    --[[input:bind('f7', function()
        self:finish()
    end)]]
end
--[[
function Stage:mark(x, y)
    if(self.player and self.player.dead)then
        self.player = nil
    end
    if(self.player)then
        --self.score = self.player.sp
        love.graphics.print(
        string.format("Player: points:%d, ammos:%d, hp:%d, sp:%d", self.player.points, self.player.ammos, self.player.hp, self.player.sp),
            x, y)
        if(self.player.ship)then
            love.graphics.print(
            string.format("Fighter: boost:%d, boosting:%s, can_boost:%s, boost_timer:%d", self.player.ship.boost, tostring(self.player.ship.boosting), tostring(self.player.ship.can_boost), self.player.ship.boost_timer), x, y + 12)
        end
    end
end]]

-- pausa o reanuda definitivamente la room en función del parámetro "yesNo", en caso de 
-- segundo parámetro se temporizará esta acción.  
-- EL PROBLEMA DE ESTO ES QUE TENDRÍA QUE DES-PAUSARSE DESDE UN NIVEL SUPERIOR DEL JUEGO, ya que tanto el 
-- "update()" como el "draw()" se detendrán y ningún hijo avanzará de estado (ni áreas, ni player, ni director, ni ná).
function Stage:pause(yesNo, msg)
    if(yesNo == nil)then yesNo = true end
    if(msg)then
        self.timer:after(msg, function()
            self.paused = yesNo
        end)
    else
        self.paused = yesNo
    end
end
-- pausa o reanuda TEMPORÁLMENTE la room en función del parámetro "yesNo", a partir de los milisegundos del segundo
-- parámetro se reanudará el estado anterior.
-- NO HAY PROBLEMA, en caso de pausa ningún hijo avanzará de estado (ni áreas, ni player, ni efectos, ni ná) durante
-- los milisegundos estipulados, luego todo volverá a fluir.
function Stage:pauseTemp(yesNo, msg)
    local p = self.paused
    if (yesNo == nil) then yesNo = true end
    if (not msg) then msg = 10 end
    self.paused = yesNo
    self.timer:after(msg, function()
        self.paused = p
    end)
end

--[=[function Stage:finish()
    Stage.super.finish(self)

    --if(not self.rooms)then return false end
    --self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
    --[[self.timer:after(1, function()
        --gotoRoom('Stage')
        self:destroy()
        --self.dead = true
    end)]]
end]=]

function Stage:destroy()
    if (self.camera) then
        --self.camera.detach()
        self.camera = nil
    end
    if(self.main_canvas)then
        love.graphics.setCanvas() -- por si acaso, regresa al canvas principal
        self.main_canvas = nil
    end
    -- no es necesario, ya lo destruye su área madre ??
    --if(self.player)then self.player:kill() end
    if (self.director) then
        self.director:destroy()
        self.director = nil
    end
    if (self.font) then
        self.font = nil
    end
    if (self.leCycles) then
        self.leCycles:destroy()
        self.leCycles = nil
    end
    if (self.imgFondo) then
        self.imgFondo = nil
    end
    self.fondo_img_chances = nil
    Stage.super.destroy(self)
end

-- dibuja el rectángulo informativo de Ataque actual
function Stage:drawAttackTag(x, y)
    local font = self.font
    local invert = false
    local at = attacks[self.player.attack]
    local att = self.player.attack .. " [" .. at.abbr .. "]"
    local rnd = utils.random(1, #negative_colors)
    -- rectángulo
    --love.graphics.setColor(negative_colors[rnd])
    -- recuadro FICHA
    love.graphics.setLineWidth(0.5)
    local r, g, b = unpack(at.color)
    love.graphics.setColor(r, g, b)
    local w, h = 1.5 * font:getWidth(att), 2 * font:getHeight()
    --love.graphics.rectangle('fill', x, y, w, h)
    --love.graphics.setColor(r - 32, g - 32, b - 32)
    love.graphics.setColor(r - 0.2, g - 0.2, b - 0.2)
    --love.graphics.rectangle('line', x - 4, y - 4, w + 8, h + 8)
    love.graphics.line(x - 4, y - 4, x + w, y - 4) -- sup
    love.graphics.line(x - 4, y + h + 8, x + w + 8, y + h + 8) -- inf
    love.graphics.line(x - 4, y - 4, x - 4, y + h + 8) -- izda
    love.graphics.line(x + w + 8, y + 4, x + w + 8, y + h + 8) -- drcha
    love.graphics.line(x + w, y - 4, x + w + 8, y + 4)         -- drcha
    -- texts
    love.graphics.setColor(r, g, b)
    local function _txt(txt, _x, _y)
        love.graphics.print(txt,
            _x, _y,
            0, 1, 1,
            math.floor(font:getWidth(txt) / 2),
            math.floor(font:getHeight() / 2)
        )
    end

    -- text Sup.
    _txt(att, (x + w) / 2, y)
    -- text Inf.
    _txt("A: " .. at.ammos .. ", C: " .. at.cooldown, x + 24, y + font:getHeight())

    love.graphics.setLineWidth(1)
end

-- sirve tanto para actualizar el cycle como para dibujarlo, en función del parámetro pasado
function Stage:updateDrawCycle(dt)
    if (not self.leCycles) then return false end
    if(dt)then
        self.leCycles:update(dt)
    else
        local x = gw * 0.95 --utils.random(gw * 0.8, gw * 0.9)
        local y = gh * 0.95
        local r = 30 --utils.random(20, 30)
        self.leCycles:draw(x, y, r)
        love.graphics.setColor(sp_color)
        local cycle = "0"
        if(self.player and self.player.cycles)then
            cycle = #self.player.cycles .. ""
        end
        love.graphics.print(
            cycle,
            x, y,
            0,
            2, 2,
            math.floor(self.font:getWidth(cycle) / 2),
            self.font:getHeight() / 2
        )
    end
    return true
end

-- NO PUEDE LLAMARSE drawUI() porque provoca PROBLEMAS con alguna librería "AI Lib" extraños.
function Stage:drawUI2()
    -- Score
    -- POINTS
    love.graphics.setColor(default_color)
    love.graphics.print(
        self.score,
        gw - 20, 10, 0, 1, 1,
        math.floor(self.font:getWidth(self.score) / 2),
        self.font:getHeight() / 2
    )
    if(not self.player)then return false end
    -- SKILL-POINTS (Habilidad)
    love.graphics.setColor(sp_color)
    love.graphics.print(
        self.player.sp,
        20, 10,
        0,
        1, 1,
        math.floor(self.font:getWidth(self.player.sp) / 2),
        self.font:getHeight() / 2
    )
    -- STAGE-NAME
    love.graphics.setColor(hp_color)
    love.graphics.print(
        self.type,
        100 + self.font:getWidth(self.player.sp),
        10 + self.font:getHeight(),
        0,
        2, 2,
        math.floor(self.font:getWidth(self.type) / 2),
        self.font:getHeight()
    )
    -- POWER-UPS (ATTACK)
    self:drawAttackTag(10, gh - 40)
    -- BARS
    -- HP
    utils.textBar(self.font, "HP", gw / 2 - 52, gh - 16, self.player.hp, self.player.max_hp, hp_color)
    -- Ammo
    utils.textBar(self.font, "Ammo", gw / 2 - 52, 16, self.player.ammos, self.player.max_ammo, ammo_color, true)
    -- Cycle
    utils.textBar(self.font, "Cycle", gw / 2 + 4, gh - 16, self.player.points, self.player.max_points, skill_point_color)
    if (not self.player.ship) then return false end
    -- Boost
    local num = string.format("%.2d", self.player.ship.boost)
    utils.textBar(self.font, "Boost", gw / 2 + 4, 16, num, self.player.ship.max_boost, boost_color, true)
    --Players
    --[[local w = self.player.ship.w
    local points = {
        100, 100, 200, 100, 150, 200
    }
    love.graphics.polygon('line', points)]]
    --love.graphics.setColor(255, 255, 255)
    self:updateDrawCycle()
end

function Stage:drawFondoImg()
    self.zoom = self.zoom + self.fondoZoom / 10
    self.fondoZoom = 0 -- restaura el zoom
    if (self.zoom > maxZoom) then self.zoom = maxZoom end
    if (self.zoom < minZoom) then self.zoom = minZoom end
    if (self.imgFondo) then
        --love.graphics.draw(self.imgFondo, 0, 0, 0, sx * self.zoom, sy * self.zoom)
        love.graphics.draw(self.imgFondo, 0, 0, 0, self.zoom, self.zoom)
    end
end

function Stage:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    --if (self.director.finished) then return false end
    -- al actualizar AQUÍ la clase padre, se DOBLA LA VELOCIDAD DE JUEGO
    -- PUEDE OMITIRSE COMENTANDO LAS SIGUIENTES DOS LÍNEAS:
    local result = Stage.super.update(self, dt)
    if not result then return false end

    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    if self.dead or not self.areas then return false end
    --if (not self.camera) then return false end
    --self.camera.smoother = Camera.smooth.damped(5)
    --self.camera:lockPosition(gw / 2, gh / 2)

    self.director:update(dt)

    --[[
    -- CRONÓMETRO MORTAL
    if(self.max_time)then
        --if (self.total_time > self.max_time) then self.director:destroy() end
        if (self.total_time > self.max_time) then
            self.director.finished = true
            self.total_time = 0
        else
            --self.director.finished = false
        end
    end]]

    for _, area in ipairs(self.areas) do
        area:update(dt)
    end
    self:updateDrawCycle(dt)

    if (self.director and self.director.finished) then
        --self.director.finished = false
        --self.director:destroy()
        if (self.timer and not self.director.paused) then
            self.timer:after(0.2, function()
                --if (self.director) then
                    --self.director.finished = false
                    achs("1 Stage Complete", true)
                    Sounds.play("power_ups1")
                    if (self.timer) then
                        self.timer:after(4, function()
                            --self:finish()
                            --if (self.ship) then self.ship:kill() end
                            self:destroy()
                        end)
                    else
                        self:destroy()
                    end
                --end
            end)
        end
        self.director.paused = true
        return false
    end
    return true
end

-- dibuja el marco o borde de la pantalla ÚTIL
function Stage:drawBorderScreen()
    if(not with_borders)then return false end
    -- BORDER-UTIL
    local x, y, width, height = 4, 3, gw * 0.98, gh * 0.97
    local opts = {
        maxLinesX = nil,
        maxLinesY = nil,
        line_width = width * 0.05,
        line_height = height * 0.05,
        paddX = width * 0.05,
        paddY = height * 0.05,
        scaleX = sx,
        scaleY = sy,
        color = { 0.6, 0.6, 0.6, 0.6 }
    }
    for _, line in ipairs(utils.borderLinesRect(x, y, width, height, opts)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
end

--[[function Stage:drawUI()
    love.graphics.draw(self.imgFondo, 0, 0)
    love.graphics.circle('line', gw / 2, gh / 2, 50)
end]]

function Stage:draw()
    --if (self.paused or not self.visible) then return false end
    if (not self.visible) then return false end
    local result = Stage.super.draw(self)
    if (not result) then return false end
    if (not self.camera or not self.areas) then return false end
    -- inner-canvas
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        self.camera:attach(0, 0, gw, gh)
        self:drawFondoImg()
        --self:drawUI()
        self:drawBorderScreen()
        for _, area in ipairs(self.areas) do
            area:draw()
        end
        self.camera:detach()
        love.graphics.setFont(self.font)
        self:drawUI2()
    if (not self.director or self.director.finished) then
        love.graphics.setColor(hp_color)
        love.graphics.print(
            self.type .. " END",
            gw * 0.2,
            gh * 0.3,
            0,
            6, 6,
            1,
            1
        )
        --return false
    end
    love.graphics.setCanvas()

    -- outer-canvas
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    -- mark
    --self:mark(50, 50)
    return true
end

return Stage