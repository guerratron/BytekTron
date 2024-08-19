if (_G["Achievements"]) then
    return _G["Achievements"]
end

--local Stage = require "objects.rooms.Stage"
--local Achievements = Stage:extend()
local Room = require "objects.rooms.Room"

local Achievements = Room:extend()

local Input = require("_LIBS_.boipushy.Input")

local Achievement = require "objects.basics.Achievement"
--local Line = require "objects.basics.Line"
local Button = require "objects.basics.Button"
local utils= require "tools.utils"

function Achievements:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "Achievements",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        --input = Input()
    }
    --Achievements.super.new(self, _camera, pars)
    Achievements.super.new(self, true, pars)

    self._type = "Achievements"
    self.type = "Achievements"
    self.font = fonts.m5x7_16
    self.input = self.input or opts.input or Input()

    self.achs = {}
    local x, y = 10, 50
    local xOR = x
    local w, h = 50, self.font:getHeight()
    local lastW = w
    local sepH, sepV = 10, 10
    --print(self.type, "Achievements->dump(achievements)")
    --print(utils.dump(achievements))
    for key, _ in pairs(achievements) do
        w = math.floor(self.font:getWidth(key .. '')) * 2
        x = x + (lastW + w)/2 + sepH
        if (x > (gw - (lastW + w) / 2 + sepH)) then
            x = xOR + (lastW + w) / 2 + sepH
            y = y + h * 2 + sepV
        end
        lastW = w
        --print(key)
        table.insert(self.achs, Achievement(key, x, y, {room = self, input = self.input, camera = self.camera, font = self.font}))
    end

    self.buttons = {
        Button(1, gw * 0.5, gh * 0.85, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = {0.8, 0.2, 0.2},
            text = "back",
            w = 30,
            --shape = "circle",
            subtype = "negative",
            title = "volver a la consola",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text)
                self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
            end
        })
    }

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
end

--[[function Achievements:modifyTemporal_BoughtNodeIndexes(id)
    table.insert(self.bought_node_indexes, id)
end]]

function Achievements:destroy()
    for _, ach in ipairs(self.achs) do
        ach:destroy()
    end
    if self.input then
        --self.input:unbind("mouse1")
        self.input:unbind("left_click")
        --self.input:unbind("+")
        self.input:unbind("zoom_in")
        --self.input:unbind("-")
        self.input:unbind("zoom_out")
        --self.input:unbindAll()
    end
    Achievements.super.destroy(self)
    self.achs = nil
    self.buttons = nil
end

function Achievements:update(dt)
    if (self.dead) then return false end
    for _, ach in ipairs(self.achs) do
        ach:update(dt)
    end
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
        if (self.camera.x < self.min_cam_x) then self.camera.x = self.min_cam_x; lim = true end
        if (self.camera.y < self.min_cam_y) then self.camera.y = self.min_cam_y; lim = true end
        if (self.camera.x > self.max_cam_x) then self.camera.x = self.max_cam_x; lim = true end
        if (self.camera.y > self.max_cam_y) then self.camera.y = self.max_cam_y; lim = true end
        if(not lim)then
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
    for i = 1, #self.buttons do
        self.buttons[i]:update(dt)
    end
end

-- dibuja el título de la pantalla
function Achievements:drawTitle(txt, x, y)
    local font = love.graphics.newFont(24) --self.font
    love.graphics.setFont(font)
    love.graphics.setColor(title_color)
    txt = txt or self.type
    -- PUNTOS
    local w, h = font:getWidth(txt), font:getHeight()
    local radius, sep = w/5, w
    love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
end
-- dibuja el marco o borde de la pantalla
function Achievements:drawBorder()
    local x, y, width, height = 0, 0, gw, gh
    local opts = {
        maxLinesX = nil,
        maxLinesY = nil,
        line_width = width * 0.05,
        line_height = height * 0.05,
        paddX = width * 0.05,
        paddY = height * 0.05,
        scaleX = sx,
        scaleY = sy,
        color = hp_color
    }
    --for _, line in ipairs(utils.borderLinesRect(x, y, width, height, opts)) do
    for _, line in ipairs(utils.borderLinesScreen(nil, nil, hp_color)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
end

-- dibuja el marco o borde de la pantalla ÚTIL
function Achievements:drawBorderScreen()
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

function Achievements:drawUI2()
    --Achievements.super.drawUI2(self)
    -- BORDER
    self:drawBorder()
    -- TITLE
    self:drawTitle(nil, gw * 0.5, gh * 0.05)
    -- BUTTONS
    for i = 1, #self.buttons do
        self.buttons[i]:draw()
    end

end

function Achievements:draw()
    if (self.dead) then return false end
    --self.camera:attach(0, 0, gw, gh)
    --self.camera:detach()
    --local result = Achievements.super.draw(self)
    --if (not result) then return false end
    --:toWorldCoords(love.mouse.getPosition())
    if (not self.camera or not self.areas) then return false end
    love.graphics.setCanvas(self.main_canvas)
        love.graphics.clear()
        --self.camera:attach(0, 0, gw, gh)
        self.camera:attach(0, 0, gw, gh)
        --self:drawFondoImg()
        --self:drawUI()
        self:drawBorderScreen()
        for _, ach in ipairs(self.achs) do
            ach:draw()
        end
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

function Achievements:textinput(t)
    -- ["ENTER"] SALIR "NADA QUE GUARDAR" == ["ESCAPE"] RETROCEDER DE ROOM 
    --print("Console:textinput", t)
    if (t == "escape" or t == "scape" or t == "return" or t == "F5") then
        if (#self.buttons > 0) then
            self.buttons[1]:toHandlerClick()
        end
    end
    -- SALIR GUARDANDO 
end

return Achievements