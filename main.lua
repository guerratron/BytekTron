--[[ 
    Example: Game from tuto: https://github.com/a327ex/blog/issues/30
    Partiendo desde: 
    BYTEPATH #6 - Conceptos básicos del jugador #20
    https://github.com/a327ex/blog/issues/20

    -- Variables globales input, timer, color, ataques, enemigos, ... se definen en "conf.lua"

    CONTROLES: 
    -- F1 = Captura instantánea de consumo de recursos en depuración
    -- F2 = Cierra la Room actual y regresa a la Console (sin guardar avances)
    -- F3 = En Rooms con players cierra y regresa a la Console (guardando avances) [en realidad asesina al player]
    -- F4 = ... igual al anterior pero asesina el área del player
    -- F5 = Aceptar-Exit, Regresa a Console o si ya está en Console sale del juego
    -- F8 [~F2] = Finish-Start, Finaliza la Room, regresa a Console (sin guardad avances), pero (a diferencia de F2) 
    -- si ya está en "Console" entonces inicia el juego diréctamente. (dentro de la partida regresa a Console GUARDANDO) 
    -- escape = Cancelar, Regresa al menú principal Console
    -- backspace = borra caracteres en campos de entrada de texto (En Console-InputLineModule)
    -- enter [return] = Acepta texto en campos de entrada (En Console-InputLineModule)
    -- +, - = Zoom (in-out) en Console y Skill
    -- up-down = Controles del Player
    -- ... = Otras posibles teclas se transmiten a través de "love.textinput"
]]

if (_G["Main"]) then
    return _G["Main"]
end

-- CONSTANTS AND DEFINES

-- BEGIN: UTIL-DEBUG-1
if arg[2] == "debug" then
    require("lldebugger").start()
end
local love_errorhandler = love.errorhandler
function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end
-- END: UTIL-DEBUG-1

-- BEGIN: LIBS
-- GLOBAL
Object = require '_LIBS_.classic.classic' -- de rxi/classic

-- LOCAL

local Timer = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local Input = require("_LIBS_.boipushy.Input")
--local Camera = require("_LIBS_.hump.camera")
local Camera = require("_LIBS_.camera.Camera") -- problemas con smooth
-- END: LIBS

Sounds = require("tools.sounds")
local utils = require("tools.utils")
utils.requireLuaFolder("objects") -- añade todos los archivos en la carpeta 'objects' como clases
local Rooms = require("objects.basics.Rooms")
--local Stage = require("objects.rooms.Stage")
--local Level1 = require("objects.rooms.Level1")
--local SkillTree = require("objects.rooms.SkillTree")
--local Console = require("objects.rooms.Console")
local SplashScreen = require("promo.SplashScreen")

local timer = nil

-- f1 = Memoria
-- f2 = Iniciar rooms
-- f3 = Player.killer
-- f4 = Area.destroy
-- f6 = Rooms.destroy


function love.load()
    fonts["m5x7_16"] = love.graphics.newFont("objects/resources/m5x7.ttf")
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.LineStyle = "rough"
    -- AUDIOS
    Sounds.load()
    --shoot_sound = love.audio.newSource("assets/ship_shoot.ogg", "static")
    --print(shoot_sound)
    --love.window.setMode(3*gw, 3*gh)
    camera = Camera(0, 0)
    --camera = Camera(0, 0, gw, gh, 1, 0)
    resize(3)

    rooms = Rooms({timer = timer})

    --st1 = Stage(camera)
    --table.insert(rooms, Stage(camera))

    timer = Timer() --Timer.new()
    input = Input()
    -- memory
    input:bind('f1', function()
        if (rooms and (#rooms._rooms > 0)) then
            print("WITH ROOMS [" .. #rooms._rooms .. "]")
        else
            print("NO ROOMS")
        end
        utils.showMEM()
    end)
    -- add room (y sale de la partida a la concola sin guardar)
    input:bind('f2', function()
        if (not rooms) then return end
        --table.insert(rooms, Stage(camera))
        --local room = Stage(camera, { rooms = rooms, timer = timer })
        --local room = Level1(camera, { rooms = rooms, timer = timer, input = input })
        --local room = SkillTree(camera, { rooms = rooms, timer = timer, input = input })
        --local room = Console(camera, { rooms = rooms, timer = timer, input = input })
        local room = SplashScreen(camera, { rooms = rooms, timer = timer, input = input })
        rooms:add(room)--, {timer = timer})
    end)
    -- SALIR GUARDANDO "EXIT"
    input:bind('f5', function()
        --print("main:: f5")
        if (rooms) then
            rooms:textinput("f5")
        end
    end)
    -- remove rooms
    --[=[input:bind('f6', function()
        if(not rooms)then return end
        --[[for i = #rooms, 1, -1 do
            local rs = rooms[i]
            rs:destroy()
            table.remove(rooms, i)
        end]]
        rooms:destroy()
        rooms._rooms = {}
        --rooms = nil
    end)]=]
    --[[input:bind('f8', function()
        --print("f8: shake: ", Camera.shake, camera.shake)
        --camera:shake(4, 60, 1)
        print("f8: flash: ", Camera.flash, camera.flash)
        --camera:flash(2, {1,1,0.2})
    end)]]
    input:bind('f8', function()
        if (rooms and rooms.current_room) then
            if(rooms.current_room.director)then
                rooms.current_room.director.finished = true
            --rooms.current_room:finish()
            --[[if (timer) then
                timer:after(4, function()
                    --self:finish()
                    --if (self.ship) then self.ship:kill() end
                    rooms.current_room:destroy()
                end)]]
            else
                rooms.current_room:destroy()
                Sounds.play("power_ups1")
            end
        end
    end)
    input:bind('backspace', function()
        --print("backspace")
        if (rooms) then
            rooms:textinput("backspace")
        end
    end)
    --SALIR SIN GUARDAR, RETROCEDER DE ROOM "ESCAPE"
    input:bind('escape', function()
        --print("main:: escape")
        if (rooms) then
            rooms:textinput("escape")
        end
    end)
    input:bind('return', function()
        --print("backspace")
        if (rooms) then
            rooms:textinput("return")
        end
    end)
    input:bind('up', function()
        --print("backspace")
        if (rooms) then
            rooms:textinput("up")
        end
    end)
    input:bind('down', function()
        --print("backspace")
        if (rooms) then
            rooms:textinput("down")
        end
    end)

    -- igual que F2
    --local room = Console(camera, { rooms = rooms, timer = timer, input = input })
    local room = SplashScreen(camera, { rooms = rooms, timer = timer, input = input })
    rooms:add(room)

    -- F1 = Captura instantánea de consumo de recursos en depuración
    -- F2 = Cierra la Room actual y regresa a la Console (sin guardar avances)
    -- F3 = En Rooms con players cierra y regresa a la Console (guardando avances) [en realidad asesina al player]
    -- F4 = ... igual al anterior pero asesina el área del player
    -- F5 = Aceptar-Exit, Regresa a Console o si ya está en Console sale del juego
    -- F8 [~F2] = Finish-Start, Finaliza la Room, regresa a Console (sin guardad avances), pero (a diferencia de F2) 
    -- si ya está en "Console" entonces inicia el juego diréctamente 
    -- escape = Cancelar, Regresa al menú principal Console
    -- backspace = borra caracteres en campos de entrada de texto (En Console-InputLineModule)
    -- enter [return] = Acepta texto en campos de entrada (En Console-InputLineModule)
    -- +, - = Zoom (in-out) en Console y Skill
    -- up-down = Controles del Player
    -- ... = Otras posibles teclas se transmiten a través de "love.textinput"
end

function love.update(dt)
    --st1:update(dt)
    timer:update(dt * slow_amount)
    if(rooms)then
        --[[for _, room in ipairs(rooms) do
            room:update(dt)
        end]]
        rooms:update(dt * slow_amount)
        camera:update(dt * slow_amount)
    end
end

function love.draw()
    --st1:draw()
    if(rooms)then
        --[[for _, room in ipairs(rooms) do
            room:draw()
        end]]
        rooms:draw()
        camera:draw()
    end

    -- Relampagueo
    if flash_frames then
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
        --print(flash_frames)
    end
    if flash_frames then
        love.graphics.setColor(impact_color) --background_color)
        love.graphics.rectangle('fill', 0, 0, sx * gw, sy * gh)
        love.graphics.setColor(1, 1, 0.5, 1)
        --print(love.graphics.getBackgroundColor(), love.graphics.getColor())
    end
end

-- Events
function love.textinput(t)
    --print('main.lua', t)
    if (rooms) then
        rooms:textinput(t)
    end
end
--[[
function love.keypressed(key, code, rep) -- tecla presionada, su código de escaneo y si repetición
end
function love.keyreleased(key)
    print(key)
end
function love.mousepressed(x, y, button)
    print(x, y, button)
end
function love.mousereleased(x, y, button)
    print(x, y, button)
end
]]
