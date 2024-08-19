if (_G["Console"]) then
    return _G["Console"]
end

--local Stage = require "objects.rooms.Stage"
--local Console = Stage:extend()
local Room = require "objects.rooms.Room"

local Console = Room:extend()

local Input = require("_LIBS_.boipushy.Input")
--local Typo = require("_LIBS_.Typo.Typo")

local tree = require "objects.basics.Tree"
--local Node = require "objects.basics.Node"
--local Line = require "objects.basics.Line"
local Button = require "objects.basics.Button"
local TxtCommands = require "objects.basics.TxtCommands"
local NumlineModule = require("objects.modules.NumlineModule")
local PromptModule = require("objects.modules.PromptModule")
local InputlineModule = require("objects.modules.InputlineModule")
local TypewriterModule = require("objects.modules.TypewriterModule")
local ResolutionModule = require "objects.modules.ResolutionModule"
local OptionsModule = require "objects.modules.OptionsModule"
local ExecuteModule = require "objects.modules.ExecuteModule"
local utils= require "tools.utils"

function Console:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "Console",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera
    }
    --Console.super.new(self, _camera, pars)--Stage.super.new(self, true, pars)
    Console.super.new(self, true, pars)
    self._type = "Console"
    self.type = "Console"
    self.font = fonts.m5x7_16
    self.tree = opts.tree or utils.tableMerge(tree, {})
    self.color = opts.color or default_color
    self.input = self.input or opts.input or Input()

    --camera:lookAt(gw / 2, gh / 2) -- follow(x, y)
    --camera.x, camera.y = gw/2, gh/2

    self.lines = {} -- cada línea contiene hasta 4 objetos typo
    self.max_lines = 8
    --self.typos = {} -- arrays de textos tipo 'typewriter'
    self.line_y_init = 20
    self.line_y = self.line_y_init
    self.line_y_incr = 12
    self.numLine = 0
    --self.max_typos = 4 * 3
    self.typewriting = false

    self.modules = {}

    --self:addLine(1, { hp_color, '--', boost_color, ' --' })
    --self:addLine('[command]', 1)
    --self:addLine('cls', 1)
    --self:addLine('dir', 1)
    --self:addLine('type', 1)
    self:addLine('cmd', 0.2)
    --self:addLine(nil, 1)
    --self:addLine('', 1)

    --self:addInputLine("En un lugar... ", 100, 100, ammo_color)

    --print(utils.dump({ true, booleano = true, "hola", cadena="adios", 23, numero=32, nil, nulo = nil, boost_color, math }))

    self.buttons = {
        Button(1, gw * 0.33, gh * 0.85, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = {0.2, 0.8, 0.4},
            text = "exit",
            w = 30,
            --shape = "circle",
            --subtype = "positive",
            title = ".. guardar y salir",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text) --, btn.type)
                -- SAVE THE SKILL
                --self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
                if (#self.lines > 0) then
                    local objs = self.lines[#self.lines].objs
                    if (#objs > 0) then
                        objs[#objs].finish = true
                    end
                end
                self:addLine(btn.text, 0.2)
            end
        }),
        Button(2, gw * 0.66, gh * 0.85, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.1, 0.6, 0.9 },
            text = "escape",
            w = 30,
            --shape = "rectangle",
            subtype = "negative",
            title = ".. salir sin guardar",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text)
                -- SAVE THE SKILL
                --self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
                if (#self.lines > 0) then
                    local objs = self.lines[#self.lines].objs
                    if (#objs > 0) then
                        objs[#objs].finish = true
                    end
                end
                self:addLine(btn.text, 0.2)
            end
        })--[[,
        -- no activar, provoca errores groseros inexplicables
        Button(3, gw * 0.05, gh * 0.92, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.9, 0.1, 0.1 },
            text = "del",
            w = 30,
            --shape = "rectangle",
            subtype = "negative",
            title = ".. eliminar logros \n PIERDE LOS PUNTOS GASTADOS!",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text)
                -- SAVE THE SKILL
                --self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
                if (#self.lines > 0) then
                    local objs = self.lines[#self.lines].objs
                    if (#objs > 0) then
                    --if (#objs > 0 and objs[#objs].type ~= "OptionsModule") then
                        objs[#objs].finish = true
                    end
                end
                self:addLine(btn.text, 0.2)
                --_delData()
            end
        })]]
    }

   -- self.lines = {}
    -- for _, node in ipairs(self.nodes) do table.insert(self.lines, node.lines) end

    -- arrastrar la cámara
    self.input:bind('mouse1', 'left_click')
    self.camera:setBounds(-gw / 2, -gh / 2, gw / 2, gh / 2)
    self.lastX, self.lastY = 0, 0
    self.relX, self.relY = 0, 0
    self.min_cam_x, self.min_cam_y = -gw / 2, -gh / 2
    self.max_cam_x, self.max_cam_y = gw / 2, gh / 2
    -- cámara zoom
    self.incr = 0.2
    self.input:bind('+', 'zoom_in')
    self.input:bind('-', 'zoom_out')

    -- FONDO-HELP
    self.txtCmds = TxtCommands(gw * 0.5, gh * 0.1)

    -- controla pulsaciones demasiado rápidas
    self.keyClick = 0
    self.keyClick_time = 0.1 -- contador del tiempo (sg) entre pulsaciones de teclas
    self.keyClick_min = 0.1 -- tiempo (sg) mínimo entre pulsaciones de teclas

    --load({ "slow_amount", "gw", "gh", "sx", "sy", "minZoom", "maxZoom" })
end

function Console:linesSanitize()
    if (#self.lines == 0) then return false end
    local ts = self.lines[#self.lines].objs
    if (#self.lines > self.max_lines) then
        table.remove(self.lines, 1) -- elmina la primera línea
        --self.numLine = self.numLine - 1
        self.line_y = self.line_y - self.line_y_incr
        for i = 1, #self.lines do
            local line = self.lines[i]
            --line.num = i --line.num - 1
            for _, obj in ipairs(line.objs) do
                --if(obj.type == "NumlineModule")then obj.text = line.num .. ""; print(line.num) end
                obj.y = obj.y - self.line_y_incr
            end
        end
        return true
    end
    return false
end
--[[
function Console:makeModule(line, type, text, x, y, opts)
    opts = opts or {}
    opts.font = opts.font or self.font
    local m = nil
    
    if (type == "nl") then
        m = NumlineModule(text, x, y, opts)
    elseif (type == "prompt") then
        m = PromptModule(text, x, y, opts)
    elseif(type == "type")then
        m = TypewriterModule(text, x, y, opts)
    elseif (type == "input") then
        m = InputlineModule(text, x, y, opts)
    elseif (type == "res") then
        m = ResolutionModule(text, x, y, opts)
    end
    if(m)then
        table.insert(line.objs, m)
    end
    return m
end]]

function Console:addCommand(line, name, x, y, opts)
    local delay = opts.delay or 0.1
    local nlPromptInput = function() self:addLine("", 0.2) end
    local commands = {
        cmd = {
            color = side_color,
            txt = "LUA-Console v5.4 <dinertron@gmail.com>",
            action = nlPromptInput
        },
        ver = {
            color = side_color,
            txt = "LUA-Console v5.4",
            action = function()
                --local str = string.format ( "Hola desde %s en %s\n" , _VERSION, os.date ())
                local str = string.format("version: %s", _VERSION)
                self:addLine(nil, 0.2, { text2 = str, action = nlPromptInput })
            end
        },
        vol = {
            color = side_color,
            txt = "Unreal Device 'c:>'", -- Unidad Ficticia
            action = nlPromptInput
        },
        -- BEGIN: HUEVO DE PASCUA
        ["?"] = {
            color = side_color,
            txt = "Juan Jose Guerra Haba + Unai Guerra Godoy [2024] - <dinertron@gmail.com>",
            action = nlPromptInput
        },
        -- FIN: HUEVO DE PASCUA
        hello = {
            color = side_color,
            txt = "by Juanjo Guerra [2024] - <dinertron@gmail.com>",
            action = nlPromptInput
        },
        pause = {
            color = side_color,
            txt = "press any key to continue ..",
            width = 200,
            action = nlPromptInput
        },
        del = {
            color = side_color,
            txt = "... Borrar todos los avances ?? Los puntos gastados SE PERDERAN ..",
            action = function()
                print("deleting ..");
                if (#self.lines > 0) then
                    local objs = self.lines[#self.lines].objs
                    if (#objs > 0)then
                    --if (#objs > 0 and objs[#objs].type ~= "OptionsModule") then
                        objs[#objs].finish = true
                    end
                end
                self:addModule(line, "options", "Data DELETE ?", x, y, utils.tableMerge(opts,
                    {
                        width = 300,
                        color = { 0.9, 0.5, 0.2 },
                        font = self.font,--love.graphics.newFont(16),
                        cursor = false,
                        resalt = true,
                        console = self,
                        options = { "ok", "cancel" },
                        action = function(index, txt)
                            --self:handler_options(index, txt)
                            --print("module options, adios", index, txt)
                            if (txt == "ok") then
                                _delData()
                            else
                                print("del CANCELED!")
                            end
                            self:addLine("", 0.2)
                        end
                    }
                ))
            end
        },
        exit = {
            color = side_color,
            txt = "... exiting of 'LUA-Console' .. Bye, bye ..",
            action = function()
                print("exit .."); save(nil); Sounds.unload() collectgarbage(); love.event.quit()
            end
        },
        escape = {
            color = side_color,
            txt = "... exiting without Save .. Bye, bye ..",
            action = function()
                print("escape->exit .."); Sounds.unload() collectgarbage(); love.event.quit()
            end
        },
        cls = {
            color = side_color,
            txt = "...",
            action = function()
                self.lines = {}
                self.line_y = self.line_y_init
                self.numLine = 0
                self.modules = {}
                nlPromptInput()
            end
        },
        dir = {
            color = side_color,
            txt = "Readme.md, conf.lua, main.lua, credits.txt, ... TYPE 'exec'",
            action = nlPromptInput
        },
        help = {
            color = side_color,
            txt = "cmd, ver, vol, pause, exit, cls, dir, help, exec, so, skill, ach, ship, borders, ...",
            action =
            function ()
                --[[self:addModule(line, "options", "Select options:", x, y, utils.tableMerge(opts,
                    {
                        width = 300,
                        color = { 0.8, 0.9, 0.6 },
                        cursor = false,
                        resalt = true,
                        console = self,
                        delay = 0.02,
                        options = { "cmd", "ver", "vol", "pause", "exit", "cls", "dir", "help", "exec" },
                        action = function(index, txt)
                            --self:handler_options(index, txt)
                            --print("module options, adios", index, txt)
                            self:addLine(txt, 0.2)
                        end
                    }
                ))]]
                print("help")
                self:toRoom("Help")
            end
            --nlPromptInput
        },
        readme = {
            color = side_color,
            txt = " to Reame ...",
            action =
                function()
                    print("readme")
                    self:toRoom("Readme")
                end
            --nlPromptInput
        },
        intro = {
            color = side_color,
            txt = " to Intro ..",
            action = function()
                print("intro")
                --rooms:add(room)
                --self:finish()
                self:toRoom("Intro")
            end
        },
        splash = {
            color = side_color,
            txt = " to Splash ..",
            action = function()
                print("splash")
                --rooms:add(room)
                --self:finish()
                self:toRoom("Splash")
            end
        },
        start = {
            color = side_color,
            txt = "starting ..",
            action = function()
                print("start")
                --rooms:add(room)
                --self:finish()
                --self:toRoom("Room")
                self:toRoom("Start")
            end
        },
        skill = {
            color = side_color,
            txt = "to Skill-Screen ..",
            action = function()
                --print("skill")
                --rooms:add(room)
                self:toRoom("Skill")
            end
        },
        ach = {
            color = side_color,
            txt = "to Achievements-Screen ..",
            action = function()
                --print("skill")
                --rooms:add(room)
                self:toRoom("Achievements")
            end
        },
        ship = {
            color = side_color,
            txt = "to Ship-Screen ..",
            action = function()
                --print("skill")
                --rooms:add(room)
                self:toRoom("Ships")
            end
        },
        borders = {
            color = side_color,
            txt = ".. show borders ? ..",
            action = function()
                if (#self.lines > 0) then
                    local objs = self.lines[#self.lines].objs
                    if (#objs > 0) then
                        objs[#objs].finish = true
                    end
                end
                self:addModule(line, "options", "Select options:", x, y, utils.tableMerge(opts,
                    {
                        width = 300,
                        color = { 0.5, 0.5, 0.9 },
                        cursor = false,
                        resalt = true,
                        console = self,
                        options = { "yes", "no" },
                        action = function(index, txt)
                            --self:handler_options(index, txt)
                            --print("module options, adios", index, txt)
                            if(txt == "yes")then
                                with_borders = true
                            else
                                with_borders = false
                            end
                            self:addLine("", 0.2)
                        end
                    }
                ))
            end
        },
        procss = {
            color = side_color,
            txt = "proccessors count ..",
            action = function ()
                self:addLine(nil, 0.2, { text2 = love.system.getProcessorCount() .. "", action = nlPromptInput })
            end
        },
        exec = {
            color = side_color,
            txt = "type the command over cmd ..",
            action = function(txt) self:addLine(nil, 0.2, { text2 = txt, action = nlPromptInput }) end
            --nlPromptInput --function() self:addLine("exec", 0.2) end
        }
        ,
        pwinfo = {
            color = side_color,
            txt = "power info ..",
            action = function()
                local state, percent, seconds = love.system.getPowerInfo()
                if(not state)then state = "unknown" end
                if(not percent)then percent = 0 end
                if(not seconds)then seconds = 0 end
                local str = string.format("state: %s, percent: %d %%, seconds: %d", state, percent, seconds)
                self:addLine(nil, 0.2, { text2 =  str, action = nlPromptInput })
            end
        },
        date = {
            color = side_color,
            txt = "O.S. Date ..",
            action = function()
                local str = string.format("date: %s", os.date())
                self:addLine(nil, 0.2, { text2 = str, action = nlPromptInput })
            end
        },
        os = {
            color = side_color,
            txt = "'OS.X', 'Windows', 'Linux', 'Android' or 'iOS'",
            action = function()
                self:addLine(nil, 0.2, { text2 = love.system.getOS(), action = nlPromptInput })
            end
        },
        clipb = {
            color = side_color,
            txt = "The text currently held in the system's clipboard ..",
            action = function()
                local str = string.format("%s", love.system.getClipboardText())
                self:addLine(nil, 0.2, { text2 = str, action = nlPromptInput })
            end
        },
        google = {
            color = side_color,
            txt = "... :) ...",
            action = function()
                love.system.openURL("http://google.com/")
                nlPromptInput()
            end
        },
        love = {
            color = side_color,
            txt = "... (: to LOVE 2D :) ...",
            action = function()
                love.system.openURL("http://love2d.org/")
                nlPromptInput()
            end
        },
        --[[options = {
            color = side_color,
            txt = "[up/down] to select",
            action = function ()
                self:addModule(line, "options", "Select options:", x, y, utils.tableMerge(opts,
                    {
                        width = 300,
                        color = { 0.5, 0.5, 0.9 },
                        cursor = false,
                        resalt = true,
                        console = self,
                        options = { "ver", "vol", "dir" },
                        action = function(index, txt)
                            --self:handler_options(index, txt)
                            --print("module options, adios", index, txt)
                            self:addLine(txt, 0.2)
                        end
                    }
                ))
            end
        },]]
        res = {
            color = side_color,
            txt = "[up/down] to select",
            action = function()
                self:addModule(line, "res", "Resolutions:", x, y, utils.tableMerge(opts,
                    {
                        width = 300,
                        color = { 0.5, 0.5, 0.9 },
                        cursor = false,
                        resalt = true,
                        console = self,
                        --options = { "uno", "dos", "tres" },
                        action = function(index, txt)
                            self:handler_options(index, txt)
                            --print("module res, adios", index, txt)
                            --self:addLine(txt, 0.2)
                        end
                    }
                ))
            end
        }
    }
    local m = nil
    local cmd = commands[name]
    if(cmd)then
        -- COMMAND
        m = self:addModule(line, "type", name, x, y, utils.tableMerge(opts, {
            name = "cmd", cursor = true, delay = 0.01
        }))
        if(self.timer)then
            --print("addCommand():", name)
            self.timer:after(delay, function()
                -- RESULT
                m = self:addModule(line, "type", cmd.txt, x + opts.width, y, utils.tableMerge(opts, {
                    name = "result", width = 300, color = cmd.color, cursor = true, delay = 0.01
                }))
                if (self.timer) then
                    self.timer:after(delay * 4, function()
                        if(name == "pause")then
                            -- RESULT
                            m = self:addModule(line, "input", "", x + (cmd.txt:len()*2) + cmd.width, y, {action = cmd.action})
                        elseif (name == "exec") then
                            -- RESULT
                            m = self:addModule(line, "exec", "", x + opts.width, y, { action = cmd.action })
                        else
                            cmd.action()
                        end
                        self.typewriting = false
                    end)
                end
            end)
        end
    end
    return m
end

function Console:addModule(line, type, text, x, y, opts)
    opts = opts or {}
    opts.font = opts.font or self.font
    local m = nil

    --print(type)
    if (type == "nl") then
        m = NumlineModule(text, x, y, opts)
    elseif (type == "prompt") then
        m = PromptModule(text, x, y, opts)
    elseif (type == "type") then
        m = TypewriterModule(text, x, y, opts)
    elseif (type == "input") then
        m = InputlineModule(text, x, y, opts)
    elseif (type == "res") then
        m = ResolutionModule(text, x, y, opts)
    elseif (type == "options") then
        m = OptionsModule(text, x, y, opts)
    elseif (type == "exec") then
        m = ExecuteModule(text, x, y, opts)
    end
    if (m) then
        table.insert(line.objs, m)
    end
    return m
end

function Console:handler_options(index, text)
    --self:addLine(text, 1)
    --print("console.handler_options", index, text)
    self:addLine("")
end
function Console:handler_inputLine(text)
    self:addLine(text, 1)
end

--[[
    addLine(nil, 0.2) -> input but no-head (no number, no prompt)
    addLine('', 0.2)  -> input with head
]]
function Console:addLine(text, delay, opts)
    delay = delay or 0.2
    opts = opts or {}
    --print("addLine()", text, delay, opts.text2, "END")
    --print("addLine():", text)
    if (#self.lines > 0) then
        local objs = self.lines[#self.lines].objs
        --if(#self.inputLines > 0 and not self.inputLines[#self.inputLines].finish)then
        if (#objs > 0 and not objs[#objs].finish) then
            -- Retarda hasta terminar el anterior
            self.timer:after(delay * 3, function()
                self:addLine(text, delay, opts)
            end)
            return
        end
    end
    -- comprobar si la anterior línea ha terminado
    --if(#self.lines > 0)then
    --    if (not self.lines[#self.lines].next) then self:addLine(text, delay, modules) end
    --end
    --self:sanitizeTypos()
    self:linesSanitize()
    self.typewriting = true
    self.line_y = self.line_y + self.line_y_incr
    self.numLine = self.numLine + 1
    local posX1, w1 = 10, gw * 0.04
    local posX2, w2 = posX1 + w1, gw * 0.05
    local posX3, w3 = posX1 + w1 + w2, gw * 0.26
    local posX4, w4 = posX1 + w1 + w2 + w3, gw * 0.65
    local posY = self.line_y
    local pos = {
        nl = { x = posX1, y = posY, w = w1 },
        prompt = { x = posX2, y = posY, w = w2 },
        command = { x = posX3, y = posY, w = w3 },
        res = { x = posX4, y = posY, w = w4 },
    }
    local cmOpts = {
        name = "num_line",
        delay = delay,
        width = 10,
        align = 'left',
        font = self.font,
        color = default_color,
        cursor = false
    }

    local line = { num = self.numLine, objs = {}, alive = true, next = false }
    table.insert(self.lines, line)
    if(text ~= nil and not opts.text2)then
        -- HEAD
        self:addModule(line, "nl", " " .. line.num .. "", pos.nl.x, pos.nl.y, utils.tableMerge(cmOpts,
            { width = pos.nl.w, color = {0.3, 0.3, 0.3}, resalt = true}
        ))
        self:addModule(line, "prompt", "c :>", pos.prompt.x, pos.prompt.y, utils.tableMerge(cmOpts,
            { width = pos.prompt.w, color = {0.3, 0.9, 0.3}}
        ))
    end

    if(not text or text == "")then
            --print("addLine()", opts.text2, "END2")
        if(opts.text2)then
            -- TEXT (WITHOUT PROMPT)
            self:addModule(line, "type", opts.text2, pos.command.x, pos.command.y, utils.tableMerge(cmOpts, {
                name = "text2",
                cursor = true,
                delay = 0.02,
                width = 300,
                color = opts.color,
                action = function(txt)
                    if(opts.action)then opts.action(txt) end
                    --print("TEXT-WITHOUT-PROMPT (END)", txt)
                end
            }))
        else
            -- INPUT
            self:addModule(line, "input", "", pos.command.x, pos.command.y, utils.tableMerge(cmOpts,
                { width = pos.command.w, color = { 0.3, 0.3, 0.9 }, cursor = true, resalt = true,
                action=function (txt)
                    --print("adios", txt)
                    self:addLine(txt, 0.2, opts)
                end
                }
            ))
        end
    else
        --print("COMMAND", text)
        -- COMMAND
        local m = self:addCommand(line, text, pos.command.x, pos.command.y, utils.tableMerge(cmOpts,
            { width = pos.command.w, color = { 0.3, 0.3, 0.9 }, cursor = true, resalt = true, action=opts.action }
        ))
        if(not m)then
            --print("NO COMMAND", text)
            if(opts.command)then
                self:addModule(line, "type", "comando no reconocido", pos.command.x, pos.command.y, utils.tableMerge(cmOpts, {
                    name = "type",
                    cursor = true,
                    delay = 0.02,
                    width = 300,
                    color = hp_color,
                    action = function(txt) end
                }))
                self:addLine("")
            else
                -- TEXT
                m = self:addModule(line, "type", text, pos.command.x, pos.command.y, utils.tableMerge(cmOpts, {
                    name = "cmd", cursor = true, delay = 0.02, width = 300, action = function(txt)
                        --
                        self:addLine(txt, delay, {command = true})
                        --print("finish", txt)
                    end
                }))
            end
        end
    end
end

function Console:toRoom(name)
    --print("finish")
    if (not self.rooms) then return false end
    -- si no se ha completado la "intro" se seguirá visualizando
    if(name == "Start")then
        if (not achievements["IntroScreen [4] Complete"]) then
            name = "Intro"
        end
    end
    self.rooms:toNewRoom(self.type .. ":" .. name, self.camera, { rooms = self.rooms, timer = self.timer })
end
function Console:finish()
    --print("finish")
    if (not self.rooms) then return false end
    self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
end

function Console:destroy()
    --[[for _, node in ipairs(self.nodes) do
        node:destroy()
    end]]
    if self.input then
        self.input:unbind("mouse1")
        self.input:unbind("left_click")
        self.input:unbind("+")
        self.input:unbind("zoom_in")
        self.input:unbind("-")
        self.input:unbind("zoom_out")
        --self.input:unbindAll()
    end
    if(self.lines)then
        for _, line in ipairs(self.lines) do
            for _, obj in ipairs(line.objs) do
                if (obj.destroy) then obj:destroy() end
            end
        end
    end
    if (self.buttons) then
        for _, b in ipairs(self.buttons) do
            if (b.destroy) then b:destroy() end
        end
    end
    if(self.txtCmds and self.txtCmds.destroy)then self.txtCmds:destroy() end
    Console.super.destroy(self)
    --self.typos = nil
    self.lines = nil
    self.buttons = nil
end

function Console:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end

    -- Arrastrar la cámara
    if self.input:pressed('left_click') then
        self.lastX, self.lastY = utils.getMouseXY(self.camera)
    end
    if self.input:released('left_click') then
        --[[local condX1 = self.camera.x > self.min_cam_x
        local condX2 = self.camera.x < self.max_cam_x
        local condY1 = self.camera.y > self.min_cam_y
        local condY2 = self.camera.y < self.max_cam_y
        if(condX1 and condX2 and condY1 and condY2)then]]
        local lim = false
        if (self.camera.x < self.min_cam_x) then
            self.camera.x = self.min_cam_x; lim = true
        end
        if (self.camera.y < self.min_cam_y) then
            self.camera.y = self.min_cam_y; lim = true
        end
        if (self.camera.x > self.max_cam_x) then
            self.camera.x = self.max_cam_x; lim = true
        end
        if (self.camera.y > self.max_cam_y) then
            self.camera.y = self.max_cam_y; lim = true
        end
        if (not lim) then
            local lX, lY = self.lastX, self.lastY --self.camera.x, self.camera.y
            self.lastX, self.lastY = utils.getMouseXY(self.camera)
            self.relX = self.camera.x + (self.lastX - lX) / self.camera.scale
            self.relY = self.camera.y + (self.lastY - lY) / self.camera.scale
            --print(lX, lY, self.lastX, self.lastY)
            --self.camera:move((self.lastX - lX) / self.camera.scale, (self.lastY - lY) / self.camera.scale)
            self.timer:tween(0.2, self.camera,
                {
                    x = self.relX,
                    y = self.relY
                },
                'in-out-cubic', 'move'
            )
        end
    end
    -- zoom de la cámara
    if self.input:pressed('zoom_in') then
        self.timer:tween(0.2, self.camera, { scale = self.camera.scale + self.incr }, 'in-out-cubic', 'zoom')
    end
    if self.input:pressed('zoom_out') then
        self.timer:tween(0.2, self.camera, { scale = self.camera.scale - self.incr }, 'in-out-cubic', 'zoom')
    end

    --[[for _, node in ipairs(self.nodes) do
        node:update(dt)
    end]]

    for i = 1, #self.buttons do
        self.buttons[i]:update(dt)
    end

    --[[for _, module in ipairs(self.modules) do module:update(dt) end]]
    for _, line in ipairs(self.lines) do
        for _, obj in ipairs(line.objs) do
            if(obj.update)then obj:update(dt) end
        end
    end

    -- FONDO-HELP
    self.txtCmds:update(dt)

    -- control de pulsaciones de teclas
    self.keyClick_time = self.keyClick_time + dt
    if(self.keyClick_time > self.keyClick_min)then
        self.keyClick = true
        self.keyClick_time = 0
    end
end

-- dibuja el marco o borde de la pantalla ÚTIL
function Console:drawBorderScreen()
    if (not with_borders) then return false end
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

function Console:drawUIScalable()
    -- BORDER-UTIL
    self:drawBorderScreen()
    love.graphics.setFont(self.font)
    --love.graphics.print("hola", 10, 48, 0, sx, sy)
    --for _, subline in ipairs(self.sublines) do love.graphics.draw(subline.text, subline.x, subline.y) end
    for _, line in ipairs(self.lines) do
        for _, obj in ipairs(line.objs) do
            if(obj.draw)then obj:draw() end
        end
    end
    -- FONDO-HELP
    self.txtCmds:draw()
end

-- dibuja el título de la pantalla
function Console:drawTitle(txt, x, y)
    local font = love.graphics.newFont(24) --self.font
    love.graphics.setFont(font)
    love.graphics.setColor(title_color)
    txt = txt or self.type
    -- PUNTOS
    local w, h = font:getWidth(txt), font:getHeight()
    love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
end

-- dibuja el marco o borde de la pantalla
function Console:drawBorder()
    for _, line in ipairs(utils.borderLinesScreen(4, 4, ammo_color)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
end

function Console:drawUI2()
    --Console.super.drawUI2(self)
    -- BORDER
    self:drawBorder()
    -- TITLE
    self:drawTitle(love.window:getTitle() .. " : " .. self.type, gw * 0.5, gh * 0.05)
    -- BUTTONS
    for i = 1, #self.buttons do
        self.buttons[i]:draw()
    end
end

function Console:draw()
    if (self.dead) then return false end
    --self.camera:attach(0, 0, gw, gh)
    --self.camera:detach()
    --local result = Console.super.draw(self)
    --if (not result) then return false end
    --:toWorldCoords(love.mouse.getPosition())
    if (not self.camera or not self.areas) then return false end
    love.graphics.setCanvas(self.main_canvas)
        love.graphics.clear()
        self.camera:attach(0, 0, gw, gh)
        --self:drawFondoImg()
        self:drawUIScalable()
        self.camera:detach()
        love.graphics.setFont(self.font)
        self:drawUI2()
        love.graphics.setColor(default_color)
    love.graphics.setCanvas()

    -- outer-canvas
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    return true
end

function Console:textinput(t)
    --print('Console.lua', t)
    --[[for _, line in ipairs(self.lines) do
        for _, inputline in ipairs(line.inputLines) do
            if(inputline.textinput)then inputline:textinput(t) end
        end
        for _, typo in ipairs(line.typos) do
            if(typo.textinput)then typo:textinput(t) end
        end
    end
    for _, module in ipairs(self.modules) do
        if (module.textinput) then module:textinput(t) end
    end]]
    if(self.keyClick)then
        -- se salta la escritura en campos "input" de los signos "+" y "-"
        if (t == "+" or t == "-") then return false end

        for _, line in ipairs(self.lines) do
            for _, obj in ipairs(line.objs) do
                if (obj.textinput) then obj:textinput(t) end
            end
        end
        --SALIR SIN GUARDAR "ESCAPE"
        --print("Console:textinput", t)
        if (t == "escape" or t == "scape") then
            if (#self.lines > 0) then
                local objs = self.lines[#self.lines].objs
                if (#objs > 0) then
                    objs[#objs].finish = true
                end
            end
            self:addLine("escape", 0.2)
        end
        -- SALIR GUARDANDO "EXIT"
        if (t == "f5") then
            if (#self.lines > 0) then
                local objs = self.lines[#self.lines].objs
                if (#objs > 0) then
                    objs[#objs].finish = true
                end
            end
            self:addLine("exit", 0.2)
        end
        self.keyClick = false
    end
end

return Console