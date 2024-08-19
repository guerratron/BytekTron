if (_G["IntroScreen"]) then
    return _G["IntroScreen"]
end

local Room = require "objects.rooms.Room"

local IntroScreen = Room:extend()

local Timer       = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local Input       = require("_LIBS_.boipushy.Input")
local Camera      = require("_LIBS_.hump.camera")
--local Camera = require("_LIBS_.camera.Camera") -- problemas con smooth
local Director    = require "objects.basics.Director"
local Area        = require "objects.basics.Area"
--[[local Player      = require "objects.Player"
local Ammo        = require "objects.resources.Ammo"
local Boost       = require "objects.resources.Boost"
local HP          = require "objects.resources.HP"
local SP          = require "objects.resources.SP"
local Attack      = require "objects.resources.Attack"
local Rock         = require "objects.enemies.Rock"]]
local TypewriterModule = require "objects.modules.TypewriterModule"
local utils       = require "tools.utils"

local intro_stages = require "promo.intro_stages"

local LinkerEdgge = require "tools.LinkerEdgge"

function IntroScreen:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "IntroScreen",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        imgFondoPath = opts.imgFondoPath
    }
    IntroScreen.super.new(self, true, pars)
    self._type = "IntroScreen"
    self.type = "IntroScreen"
    self.camera = _camera
    self.camera.x = gw / 2
    self.camera.y = gh / 2
    self.imgFondoPath = opts.imgFondoPath -- aqui no se utiliza pero en otras rooms si
    self.leCycles = LinkerEdgge()         -- el orbe indicativo del cycle
    --self.timer = opts.timer or Timer()
    --self.timer = opts.timer
    --self.current_room = nil
    -- se reutiliza pars para el siguiente elemento
    pars._id = utils.UUID()
    pars._type = "Area"
    pars.timer = self.timer          --nil --Timer()-- su propio timer ??
    -- AREA
    self:add(Area(self, true, pars)) --:addPhysicsWorld())
    self.current_area = self.areas[1]
    self.current_area:addPhysicsWorld()
    self.current_area.world:addCollisionClass('Player')
    --self.current_area.world:addCollisionClass('Projectile')
    --self.current_area.world:addCollisionClass('Collectable')
    self.current_area.world:addCollisionClass('Projectile', { ignores = { 'Projectile', 'Player' } })
    self.current_area.world:addCollisionClass('Collectable', { ignores = { 'Projectile' } })                   --'Collectable'
    self.current_area.world:addCollisionClass('Enemy', { ignores = { 'Collectable' } })
    self.current_area.world:addCollisionClass('EnemyProjectile', { ignores = { 'EnemyProjectile', 'Enemy' } }) --, 'Projectile'
    -- PLAYER (cada player con un nuevo timer)
--self.player = Player(self.current_area, gw / 2, gh / 2, { timer = self.timer })                            --, {timer = Timer()}) -- su propio timer ??
--local index = self.current_area:add(self.player)
--self.player.index = index
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    --local input = Input()
    --print(self:is(Room) and self:is(Stage))
    self.director = Director(self, { player = self.player, timer = self.timer })
    self.font = fonts.m5x7_16

    -- control a través de tiempo.
    -- Si se especifica "max_time" se pasa a limitar la partida a un máximo de tiempo
    self.max_time = nil
    self.total_time = 0
    -- stages
    self.stage = nil
    self.stageNextId = 1 -- indica el siguiente id de stage válido
    self.typewriter = {}
    self:nextStage(1) -- al regresar aumenta stageNextId

    self.zoom = minZoom
    self.fondoZoom = 0 -- -1 = zoom-out, 0 = zoom-none, +1 = zoom-in
    self.paused = false
    self.visible = true
    self.intro_end = false

    
    --[[local tOpts = {
        name = "result", width = 300, color = hp_color, cursor = true, delay = 0.01
    }
    self.typewriter = TypewriterModule("hola que tal", self.x, self.y, opts)]]


    input:bind('p', function()
        --area:addGameObject('Ammo', random(0, gw), random(0, gh))
        --[[local amm = Ammo(self.current_area, gw / 2, gh / 2, {parent = self.player}) --, {timer = self.timer})
        local idx = self.current_area:add(amm)
        amm.index = idx]]
        if (self.director) then self.director.paused = not self.director.paused end
    end)
    -- f3 elimina player
    input:bind('f3', function()
        if (self.player) then
            self.player:kill()
            --self.player.dead = true
            self.player = nil
        end
    end)
    -- f4 elimina area completa
    input:bind('f4', function()
        if (self.areas) then
            for i = #self.areas, 1, -1 do
                local ar = self.areas[i]
                ar:destroy()
                table.remove(self.areas, i)
            end
        end
        self.areas = nil
    end)
end

-- pausa o reanuda definitivamente la room en función del parámetro "yesNo", en caso de 
-- segundo parámetro se temporizará esta acción.  
-- EL PROBLEMA DE ESTO ES QUE TENDRÍA QUE DES-PAUSARSE DESDE UN NIVEL SUPERIOR DEL JUEGO, ya que tanto el 
-- "update()" como el "draw()" se detendrán y ningún hijo avanzará de estado (ni áreas, ni player, ni director, ni ná).
function IntroScreen:pause(yesNo, msg)
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
function IntroScreen:pauseTemp(yesNo, msg)
    local p = self.paused
    if (yesNo == nil) then yesNo = true end
    if (not msg) then msg = 10 end
    self.paused = yesNo
    self.timer:after(msg, function()
        self.paused = p
    end)
end

--[=[function IntroScreen:finish()
    IntroScreen.super.finish(self)

    --if(not self.rooms)then return false end
    --self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
    --[[self.timer:after(1, function()
        --gotoRoom('IntroScreen')
        self:destroy()
        --self.dead = true
    end)]]
end]=]

function IntroScreen:destroy()
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
    self.stage = nil
    IntroScreen.super.destroy(self)
end

function IntroScreen:nextStage(index)
    index = index or self.stageNextId
    if (index < 1) or (index > #intro_stages) then
        self.intro_end = true
        self.timer:after(1.5, function()
            --self:finish()
            --self.rooms:toConsoleRoom(self.camera, { rooms = self.rooms, timer = self.timer })
            self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
        end)
        return false
    end
    self.stage = intro_stages[index]
    self.stageNextId = index + 1
    -- control a través de tiempo.
    -- Si se especifica "max_time" se pasa a limitar la partida a un máximo de tiempo
    self.max_time = self.stage.until_time
    self.total_time = 0
    self.director.finished = not self.stage.director
    self.current_area.visible = self.stage.area
    -- TEXTOS (escritura carácter a carácter y línea a línea)
    -- primero se eliminan los existentes
    for _, tw in ipairs(self.typewriter) do
        tw:destroy()
    end
    self.typewriter = {}
    -- ahora se crean los nuevos pausados
    local x, y, w, h = gw * 0.1, gh * 0.1, gw / 3, gh / 2
    for i, value in ipairs(self.stage.lines) do
        local m = nil
        m = TypewriterModule(
            value, (x + w) * 0.25, (y + h) * 0.4,
            { width = 300, color = { 0.1, 0.1, 0.1 }, delay = 0.02, font = self.font,
            cursor = true, resalt = false, paused = true, sound = true,
            action = function(txt)
                if(i < #self.typewriter)then
                    self.typewriter[i + 1].paused = false
                end
                --m.paused = false
            end }
        )
        table.insert(self.typewriter, m)
        y = y + self.font:getHeight() * 2
    end
    -- inicia la primera línea
    if(#self.typewriter > 0)then self.typewriter[1].paused = false end
    --MUSIC
    -- TEMPO
    achs("IntroScreen [" .. self.stage.id .. "] Complete", true)
    Sounds.play("power_ups3")
    if (self.timer and self.stage.until_time) then
        if(self.next_stage_timer)then self.timer:cancel(self.next_stage_timer) end
        self.next_stage_timer = self.timer:after(self.stage.until_time, function()
            self:nextStage()
        end)
    end
    return true
end

function IntroScreen:drawLogo(x, y)
    love.graphics.setColor(negative_colors[5])
    local txt = "BytekTron"
    love.graphics.print(
        txt,
        x, y,
        0,
        2, 2,
        math.floor(self.font:getWidth(txt) / 2),
        self.font:getHeight() / 2
    )
end
function IntroScreen:drawTextZone(x, y, w, h)
    --local font = self.font
    --local rnd = utils.random(1, #negative_colors)
    -- rectángulo
    --love.graphics.setColor(negative_colors[rnd])
    -- recuadro FICHA
    love.graphics.setLineWidth(0.5)
    --love.graphics.rectangle('fill', x, y, w, h)
    --love.graphics.setColor(r - 32, g - 32, b - 32)
    love.graphics.setColor({0.9, 0.9, 0.9, 0.8})
    love.graphics.rectangle('fill', x - 4, y - 4, w + 8, h + 8)
    self:drawLogo(x + w * 0.5, y + h * 0.1)
    -- texts
    love.graphics.setColor({0.1, 0.1, 0.1, 1})
    local function _txt(txt, _x, _y)
        love.graphics.print(txt,
            _x, _y,
            0, 1, 1,
            math.floor(self.font:getWidth(txt) / 2),
            math.floor(self.font:getHeight() / 2)
        )
    end

    -- lineas de texto
    --[[for _, value in ipairs(self.stage.lines) do
        --self.typewriter:setText(value)
        --self.typewriter:setPosition({ x = (x + w) * 0.6, y = (y + h) * 0.4 })
        local tOpts = {
            name = "result", width = 300, color = hp_color, cursor = true, delay = 0.01
        }
        table.insert(self.typewriter, TypewriterModule(value, (x + w) * 0.6, (y + h) * 0.4, tOpts))
        self.typewriter[#self.typewriter]:draw()
        --_txt(value, (x + w) * 0.6, (y + h) * 0.4)
        y = y + self.font:getHeight() * 2
    end
    --self.typewriter:draw()]]
    for _, tw in ipairs(self.typewriter) do
        tw:draw()
    end

    love.graphics.setLineWidth(1)
end

-- NO PUEDE LLAMARSE drawUI() porque provoca PROBLEMAS con alguna librería "AI Lib" extraños.
function IntroScreen:drawUI2()
    --if(not self.player)then return false end
    -- POWER-UPS (ATTACK)
    self:drawTextZone(gw * 0.1, gh * 0.1, gw/3, gh/2)
    --Players
    --[[local w = self.player.ship.w
    local points = {
        100, 100, 200, 100, 150, 200
    }
    love.graphics.polygon('line', points)]]
end

function IntroScreen:drawFondoImg()
    --[[self.zoom = self.zoom + self.fondoZoom / 10
    self.fondoZoom = 0 -- restaura el zoom
    if (self.zoom > maxZoom) then self.zoom = maxZoom end
    if (self.zoom < minZoom) then self.zoom = minZoom end]]
    if (self.stage.img) then
        --love.graphics.draw(self.stage.img, 0, 0, 0, sx * self.zoom, sy * self.zoom)
        --local y = gh / 2
        --if(self.stage.id == 4)then y = 0 end
        local y = 0
        love.graphics.draw(self.stage.img, 0, y, 0, 1, 1)
    end
end

function IntroScreen:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    --if (self.director.finished) then return false end
    -- al actualizar AQUÍ la clase padre, se DOBLA LA VELOCIDAD DE JUEGO
    -- PUEDE OMITIRSE COMENTANDO LAS SIGUIENTES DOS LÍNEAS:
    local result = IntroScreen.super.update(self, dt)
    if not result then return false end

    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    if not self.areas then return false end
    --if (not self.camera) then return false end
    --self.camera.smoother = Camera.smooth.damped(5)
    --self.camera:lockPosition(gw / 2, gh / 2)

    if (self.director and not self.director.finished) then
        self.director:update(dt)
    end

    -- CRONÓMETRO MORTAL
    --[[if(self.max_time)then
        --if (self.total_time > self.max_time) then self.director:destroy() end
        if (self.total_time > self.max_time) then
            self:nextStage()
        else
            --self.director.finished = false
        end
    end]]

    for _, area in ipairs(self.areas) do
        area:update(dt)
    end

    --[[if (self.director and self.director.finished) then
        --self.director.finished = false
        --self.director:destroy()
        if (self.timer and not self.director.paused) then
            self.timer:after(0.2, function()
                --if (self.director) then
                    --self.director.finished = false
                    achs("IntroScreen [" .. self.stage.id .. "] Complete", true)
                    Sounds.play("power_ups1")
                    if (self.timer) then
                        self.timer:after(4, function()
                            --self:finish()
                            --if (self.ship) then self.ship:kill() end
                            --self:destroy()
                            --self:finish()
                        end)
                    else
                        self:destroy()
                    end
                --end
            end)
        end
        self.director.paused = true
        return false
    end]]
    -- lineas de texto
    --[[local x, y, w, h = gw * 0.1, gh * 0.1, gw / 3, gh / 2
    for _, value in ipairs(self.stage.lines) do
        --self.typewriter:setText(value)
        --self.typewriter:setPosition({ x = (x + w) * 0.6, y = (y + h) * 0.4 })
        --_txt(value, (x + w) * 0.6, (y + h) * 0.4)
        y = y + self.font:getHeight() * 2
    end]]
    for _, tw in ipairs(self.typewriter) do
        tw:update(dt)
    end
    return true
end

-- dibuja el marco o borde de la pantalla ÚTIL
function IntroScreen:drawBorderScreen()
    --if(not with_borders)then return false end
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

--[[function IntroScreen:drawUI()
    love.graphics.draw(self.imgFondo, 0, 0)
    love.graphics.circle('line', gw / 2, gh / 2, 50)
end]]

function IntroScreen:draw()
    --if (self.paused or not self.visible) then return false end
    --if (not self.visible) then return false end
    local result = IntroScreen.super.draw(self)
    if (not result) then return false end
    if (not self.camera or not self.areas) then return false end
    -- inner-canvas
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        self.camera:attach(0, 0, gw, gh)
            for _, area in ipairs(self.areas) do
                area:draw()
            end
            self:drawFondoImg()
            --self:drawUI()
            self:drawBorderScreen()
        self.camera:detach()
        love.graphics.setFont(self.font)
        self:drawUI2()
    if (self.intro_end) then
        love.graphics.setColor(hp_color)
        love.graphics.print(
            self.type .. " END",
            gw * 0.5,
            gh * 0.3,
            0,
            3, 3,
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

function IntroScreen:textinput(t)
    -- SALTAR LA INTRO
    if (t == "f5" or t == "escape" or t == "scape") then
        if (self.next_stage_timer) then self.timer:cancel(self.next_stage_timer) end
        self:nextStage(1000) -- hace que termine la intro
    elseif (t == "return" or t == "space" or t == " ") then
        if (self.next_stage_timer) then self.timer:cancel(self.next_stage_timer) end
        self:nextStage() -- pasa a la página siguiente
    end
end

return IntroScreen