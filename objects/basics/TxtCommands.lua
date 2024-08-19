if (_G["TxtCommands"]) then
    return _G["TxtCommands"]
end

--[[
    Se utiliza para crear una especie de imágen de texto con todos los comandos 
    utilizados en Console.
]]
TxtCommands = Object:extend()

local utils = require "tools.utils"

function TxtCommands:new(x, y, opts)
    self.type = "TxtCommands"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.x, self.y = x, y
    self.color = opts.color or negative_colors[1]
    self.rad = opts.rad or 0 -- math.random(1, 2)
    self.font = opts.font or love.graphics.newFont(10)
    self.w, self.h = 10, self.font:getHeight()
    --self.tree = opts.tree or utils.tableMerge(tree, {})
    self.commands = {
        cmd = {
            color = side_color,
            txt = "LUA-Console v5.4 <dinertron@gmail.com>"
        },
        ver = {
            color = side_color,
            txt = "LUA-Console v5.4"
        },
        vol = {
            color = side_color,
            txt = "unidad Ficticia 'c:>'"
        },
        hello = {
            color = side_color,
            txt = "by Juanjo Guerra [2024] - <dinertron@gmail.com>"
        },
        --[[["?"] = {
            color = side_color,
            txt = "Juan José Guerra Haba + Unai Guerra Godoy [2024] - <dinertron@gmail.com>"
        },]]
        pause = {
            color = side_color,
            txt = "press any key to continue .."
        },
        del = {
            color = side_color,
            txt = "Borrar avances ?? Los puntos gastados SE PERDERAN"
        },
        exit = {
            color = side_color,
            txt = "... saliendo de 'LUA-Console' .. Bye, bye .." --
        },
        escape = {
            color = side_color,
            txt = "... saliendo SIN GUARDAR .. Bye, bye .."
        },
        cls = {
            color = side_color,
            txt = "..."
        },
        dir = {
            color = side_color,
            txt = "Readme.md, conf.lua, main.lua, credits.txt, ..."
        },
        help = {
            color = side_color,
            txt = "cmd, ver, vol, pause, exit, cls, dir, help, exec, so, skill, ach, ship, borders, ..."
        },
        readme = {
            color = side_color,
            txt = " to Readme .."
        },
        intro = {
            color = side_color,
            txt = " to Intro .."
        },
        start = {
            color = side_color,
            txt = "starting .."
        },
        skill = {
            color = side_color,
            txt = "to Skill-Screen .."
        },
        ach = {
            color = side_color,
            txt = "to Achievements-Screen .."
        },
        ship = {
            color = side_color,
            txt = "to Ships-Screen .."
        },
        borders = {
            color = side_color,
            txt = ".. show borders ? .."
        },
        procss = {
            color = side_color,
            txt = "proccessors count .."
        },
        exec = {
            color = side_color,
            txt = "type the command over cmd .."
        }
        ,
        pwinfo = {
            color = side_color,
            txt = "power info .."
        },
        date = {
            color = side_color,
            txt = "O.S. Date .."
        },
        os = {
            color = side_color,
            txt = "'OS.X', 'Windows', 'Linux', 'Android' or 'iOS'"
        },
        clipb = {
            color = side_color,
            txt = "The text currently held in the system's clipboard .."
        },
        google = {
            color = side_color,
            txt = "... :) ..."
        },
        love = {
            color = side_color,
            txt = "... (: to LOVE 2D :) ..."
        },
        res = {
            color = side_color,
            txt = "[up/down] to select"
        }
    }
end

function TxtCommands:destroy()
    --TxtCommands.super.destroy(self)
    self.commands = nil
end

function TxtCommands:update(dt)
    love.graphics.setFont(self.font)
    -- font:getWidth(points), font:getHeight()
    local dir = utils.tableRandom({1, -1})
    self.w = self.w + dt*10 * dir
    self.h = self.h + dt*2 * dir
    self.rad = self.rad + dt/5 * dir
    self.color = negative_colors[utils.tableRandom({1, #negative_colors})]
end

function TxtCommands:draw()
    local x, y = self.x + self.w, self.y + self.h
    local r, g, b = unpack(self.color)--{0, 1, 0})--cmd.color)
    for key, cmd in pairs(self.commands) do
        y = y + self.h
        love.graphics.setColor(r, g, b, 0.5)
        --love.graphics.print(key, x, y, self.rad, sx / 4, sy / 4)
        --love.graphics.print(cmd.txt, x + 50, y, self.rad, sx / 4, sy / 4)
        love.graphics.print(key, x, y, self.rad, 1, 1)
        love.graphics.print(cmd.txt, x + 50, y, self.rad, 1, 1)
    end
    love.graphics.setColor(default_color)
end

return TxtCommands