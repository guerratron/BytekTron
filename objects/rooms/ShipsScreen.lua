if (_G["ShipsScreen"]) then
    return _G["ShipsScreen"]
end

--local Stage = require "objects.rooms.Stage"
--local ShipsScreen = Stage:extend()
local Room = require "objects.rooms.Room"

local ShipsScreen = Room:extend()

local Input = require("_LIBS_.boipushy.Input")

local ShipSelect = require "objects.basics.ShipSelect"
--local Line = require "objects.basics.Line"
local Button = require "objects.basics.Button"
local utils= require "tools.utils"

function ShipsScreen:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "ShipsScreen",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        --input = Input()
    }
    --ShipsScreen.super.new(self, _camera, pars)
    ShipsScreen.super.new(self, true, pars)

    self._type = "ShipsScreen"
    self.type = "ShipsScreen"
    self.font = fonts.m5x7_16
    self.input = self.input or opts.input or Input()

    self.ships = {} -- shapes, ships
    self.bought_ships_keys = {"Fighter"}
    if(ships)then
        for key, _ in pairs(ships) do
            if(ships[key] and not utils.tableExists(self.bought_ships_keys, key))then
                table.insert(self.bought_ships_keys, key)
            end
        end
    end
    --self.bought_ships_keys_original = utils.tableMerge(self.bought_ships_keys, {})
    self.sp_original = loadedData.sp
    self.ship_selected_original = ship_selected

    local x, y = 10, 100
    local xOR = x
    local w, h = 50, self.font:getHeight()
    local lastW = w
    local sepH, sepV = 20, 40
    -- Determina el sitio de cada recuadro para ubicar las naves
    for key, _ in pairs(Shapes.ships) do
        w = math.floor(self.font:getWidth(key .. '')) * 2
        x = x + (lastW + w)/2 + sepH
        if (x > (gw - (lastW + w) / 2 + sepH)) then
            x = xOR + (lastW + w) / 2 + sepH
            y = y + h * 2 + sepV
        end
        lastW = w
        --print(key)
        table.insert(self.ships, ShipSelect(key, x, y, {room = self, input = self.input, camera = self.camera, font = self.font}))
    end

    self.buttons = {
        Button(1, gw * 0.33, gh * 0.85, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.2, 0.8, 0.4 },
            text = "yes",
            w = 30,
            --shape = "circle",
            --subtype = "positive",
            title = "guardar y volver a la consola",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text)
                --print(utils.dump(loadedData))
                -- SAVE THE SHIPS-BOUGHTs
                for _, key in ipairs(self.bought_ships_keys) do
                    ships[key] = true
                end
                local data2 = {
                    ships = ships, --utils.tableMerge(self.bought_ships_keys, {}),
                    sp = loadedData.sp -- guarda los puntos gastados
                }
                saveData(data2)
                -- REGRESA
                self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
            end
        }),
        Button(2, gw * 0.66, gh * 0.85, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = { 0.9, 0.6, 0.1 },
            text = "no",
            w = 30,
            --shape = "circle",
            subtype = "negative",
            title = "cancelar y volver a la consola",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text)
                -- restaura los puntos virtualmente gastados
                --self.bought_ships_keys = self.bought_ships_keys_original
                loadedData.sp = self.sp_original
                ship_selected = self.ship_selected_original
                -- REGRESA
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

--[[function ShipsScreen:modifyTemporal_BoughtNodeIndexes(id)
    table.insert(self.bought_node_indexes, id)
end]]

function ShipsScreen:destroy()
    for _, ship in ipairs(self.ships) do
        ship:destroy()
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
    ShipsScreen.super.destroy(self)
    self.ships = nil
    self.buttons = nil
end

function ShipsScreen:update(dt)
    if (self.dead) then return false end
    for _, ship in ipairs(self.ships) do
        ship:update(dt)
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

-- dibuja el rectángulo informativo de Skill actual
function ShipsScreen:drawSkillTag(x, y)
    local font = love.graphics.newFont(12) --self.font
    love.graphics.setFont(font)
    --last = self.tree[2]
    local points = "SKILL pts: 0"
    --if (loadedData.points) then points = "POINTS: " .. loadedData.points end
    if (loadedData.sp) then points = "SKILL: " .. loadedData.sp .. " pts" end
    -- PUNTOS
    local w, h = font:getWidth(points), font:getHeight()
    local radius, sep = w / 5, w
    love.graphics.print(points,
        x, y,
        0, 1, 1,
        math.floor(font:getWidth(points) / 2),
        math.floor(font:getHeight() / 2)
    )
    -- SKILL
    font = love.graphics.newFont(10) --self.font
    love.graphics.setFont(font)
    love.graphics.setLineWidth(0.5)
    local r, g, b = unpack(default_color)
    --love.graphics.setColor(r, g, b)
    love.graphics.setColor(r - 0.2, g - 0.2, b - 0.2)

    x = x + sep
    love.graphics.circle('line', x, y, radius)
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
    _txt(ship_selected, x, y)
    --_txt("32", x, y)

    love.graphics.setLineWidth(1)
end

-- dibuja el título de la pantalla
function ShipsScreen:drawTitle(txt, x, y)
    local font = love.graphics.newFont(24) --self.font
    love.graphics.setFont(font)
    love.graphics.setColor(title_color)
    txt = txt or self.type
    -- PUNTOS
    local w, h = font:getWidth(txt), font:getHeight()
    --local radius, sep = w/5, w
    love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
end
-- dibuja el marco o borde de la pantalla
function ShipsScreen:drawBorder()
    for _, line in ipairs(utils.borderLinesScreen(nil, nil, hp_color)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
end

-- dibuja el marco o borde de la pantalla ÚTIL
function ShipsScreen:drawBorderScreen()
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

function ShipsScreen:drawUI2()
    --ShipsScreen.super.drawUI2(self)
    -- BORDER
    self:drawBorder()
    -- TITLE
    self:drawTitle(nil, gw * 0.5, gh * 0.05)
    -- BUTTONS
    for i = 1, #self.buttons do
        self.buttons[i]:draw()
    end
    self:drawSkillTag(gw * 0.75, gh * 0.1)

    -- COST
    love.graphics.print("$: " .. ship_cost, gw * 0.1, gh * 0.95, 0, 1, 1, 20, 20)
end

function ShipsScreen:draw()
    if (self.dead) then return false end
    --self.camera:attach(0, 0, gw, gh)
    --self.camera:detach()
    --local result = ShipsScreen.super.draw(self)
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
        for _, ship in ipairs(self.ships) do
            ship:draw()
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

function ShipsScreen:textinput(t)
    -- SALIR GUARDANDO "EXIT"
    if (t == "f5" or t == "return") then
        if (#self.buttons > 1) then
            self.buttons[1]:toHandlerClick()
        end
    end
    --SALIR SIN GUARDAR, RETROCEDER DE ROOM "ESCAPE"
    --print("Console:textinput", t)
    if (t == "escape" or t == "scape") then
        if (#self.buttons > 0) then
            self.buttons[2]:toHandlerClick()
        end
    end
end

return ShipsScreen