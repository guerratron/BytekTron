if (_G["SkillTree"]) then
    return _G["SkillTree"]
end

--local Stage = require "objects.rooms.Stage"
--local SkillTree = Stage:extend()
local Room = require "objects.rooms.Room"

local SkillTree = Room:extend()

local Input = require("_LIBS_.boipushy.Input")

local tree = require "objects.basics.Tree"
local Node = require "objects.basics.Node"
--local Line = require "objects.basics.Line"
local Button = require "objects.basics.Button"
local utils= require "tools.utils"

function SkillTree:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "SkillTree",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        --input = Input()
    }
    --SkillTree.super.new(self, _camera, pars)
    SkillTree.super.new(self, true, pars)

    self._type = "SkillTree"
    self.type = "SkillTree"
    self.font = fonts.m5x7_16
    self.bought_node_indexes = { 1 }
    self.bought_node_indexes_original = utils.tableMerge(self.bought_node_indexes, {})
    self.sp_original = 0
    --self.tree = opts.tree or utils.tableMerge(tree, {})
    -- IMPORTANTE: no igualar las referencias diréctamente,
    -- mejor a través de copia para evitar efectos colaterales
    self.tree = utils.tableMerge(tree, {}, true) -- crea una copia local del árbol
    self.input = self.input or opts.input or Input()

    local data = loadedData --load()
    if (data) then
        --[[for key, value in pairs(data) do
            --print("player", key, value)
            if (key == "bought_node_indexes") then
                if (self[key]) then
                    --self[key] = value
                    self[key] = utils.tableMerge(value, {})
                    --print("skill", key, value)
                    print("SkillTree:LOAD()->dump('bought_node_indexes')")
                    print(utils.dump(self[key]))
                end
            end
        end]]
        if (data.bought_node_indexes) then
            -- IMPORTANTE: no igualar las referencias diréctamente,
            -- mejor a través de copia para evitar efectos colaterales
            self.bought_node_indexes = utils.tableMerge(data.bought_node_indexes, {})
            --print("skill", key, value)
            --print("SkillTree:LOAD()->dump('bought_node_indexes')")
            --print(utils.dump(self.bought_node_indexes))
        end
        if(data.sp)then
            self.sp_original = data.sp
        end
    end
    --print("sp_original", self.sp_original)
    --[[self.tree = {}
    self.tree[10] = {
        name = 'HP',
        stats = {
            {'4% Increased HP', 'hp_multiplier = 0.04'}
        },
        x = 150, y = 150,
        links = {4, 6, 8},
        type = 'Small',
    }]]
    local centred = opts.centred or true
    local paddX, paddY = 0, 0
    if(centred)then
        paddX, paddY = gw/2, gh/2
    end
    self.nodes = {}
    for id, node in pairs(self.tree) do
        if node then
            node.x = node.x + paddX
            node.y = node.y + paddY
            table.insert(self.nodes, Node(id, node.x, node.y, {camera = self.camera, font = self.font, room = self, tree = self.tree, centred = opts.centred}))--, input = Input()}))
        end
    end

    self.buttons = {
        Button(1, gw * 0.33, gh * 0.85, {
            camera = self.camera,
            timer = self.timer,
            font = self.font,
            room = self,
            color = {0.2, 0.8, 0.4},
            text = "yes",
            w = 30,
            --shape = "circle",
            --subtype = "positive",
            title = "guardar y volver a la consola",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text)
                --print(utils.dump(loadedData))
                -- SAVE THE SKILL
                local data2 = {
                    bought_node_indexes = utils.tableMerge(self.bought_node_indexes, {}),
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
            color = {0.9, 0.6, 0.1},
            text = "no",
            w = 30,
            --shape = "circle",
            subtype = "negative",
            title = "cancelar y volver a la consola",
            toHandlerClick = function(btn)
                if (not self.rooms) then return false end
                print(self.type, " -> click " .. btn.text)
                -- restaura los puntos virtualmente gastados
                self.bought_node_indexes = self.bought_node_indexes_original
                loadedData.sp = self.sp_original
                -- REGRESA
                self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
            end
        })
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
end

--[[function SkillTree:modifyTemporal_BoughtNodeIndexes(id)
    table.insert(self.bought_node_indexes, id)
end]]

function SkillTree:destroy()
    for _, node in ipairs(self.nodes) do
        node:destroy()
    end
    for i = #self.buttons, 1, -1 do
        local btn = self.buttons[i]
        btn:destroy()
        table.remove(self.buttons, i)
    end
    if self.input then
        self.input:unbind("mouse1")
        self.input:unbind("left_click")
        self.input:unbind("+")
        self.input:unbind("zoom_in")
        self.input:unbind("-")
        self.input:unbind("zoom_out")
        --self.input:unbindAll()
    end
    SkillTree.super.destroy(self)
    self.tree = nil
    self.nodes = nil
    self.buttons = nil
end

function SkillTree:update(dt)
    if (self.dead) then return false end
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

    for _, node in ipairs(self.nodes) do
        node:update(dt)
    end

    if(self.buttons)then
        for i = 1, #self.buttons do
            if(self.buttons[i])then
                self.buttons[i]:update(dt)
            end
        end
    end
end

-- dibuja el rectángulo informativo de Skill actual
function SkillTree:drawSkillTag(x, y)
    local font = love.graphics.newFont(12) --self.font
    love.graphics.setFont(font)
    local last = self.tree[self.bought_node_indexes[#self.bought_node_indexes]]
    --last = self.tree[2]
    local n, t, s, c = last.name, last.type, last.shape, last.color
    local points = "SKILL pts: 0"
    --if (loadedData.points) then points = "POINTS: " .. loadedData.points end
    if (loadedData.sp) then points = "SKILL: " .. loadedData.sp .. " pts" end
    -- PUNTOS
    local w, h = font:getWidth(points), font:getHeight()
    local radius, sep = w/5, w
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
    local r, g, b = unpack(c)
    love.graphics.setColor(r, g, b)
    love.graphics.setColor(r - 0.2, g - 0.2, b - 0.2)
    --[[love.graphics.polygon("line",
        x - 4, y - 4, x + w, y - 4,             -- sup
        x - 4, y + h + 8, x + w + 8, y + h + 8, -- inf
        x - 4, y - 4, x - 4, y + h + 8,         -- izda
        x + w + 8, y + 4, x + w + 8, y + h + 8, -- drcha
        x + w, y - 4, x + w + 8, y + 4          -- drcha
    )
    love.graphics.line(x - 4, y - 4, x + w, y - 4)             -- sup
    love.graphics.line(x - 4, y + h + 8, x + w + 8, y + h + 8) -- inf
    love.graphics.line(x - 4, y - 4, x - 4, y + h + 8)         -- izda
    love.graphics.line(x + w + 8, y + 4, x + w + 8, y + h + 8) -- drcha
    love.graphics.line(x + w, y - 4, x + w + 8, y + 4)         -- drcha
    ]]
    --local w, h = radius * 2, radius * 2
    if (t == "Small") then
        w, h = w / 2, h / 2
        sep = w * 1.5
        radius = w/4
        --print("small", radius)
    end
    x = x + sep
    if (s == "circle") then
        love.graphics.circle('line', x, y, radius)
    elseif (s == "square") then
        love.graphics.rectangle('line', x - w/4, y - w/4, w/2, w/2)
    elseif (s == "triangle") then
        love.graphics.polygon("line",
            x - w/4, y - w/8,
            x + w/4, y - w/8,
            x, y + w/4
        )
    end
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
    _txt(self.bought_node_indexes[#self.bought_node_indexes] .. "", x, y)
    --_txt("32", x, y)

    love.graphics.setLineWidth(1)
end

-- dibuja el título de la pantalla
function SkillTree:drawTitle(txt, x, y)
    local font = love.graphics.newFont(24) --self.font
    love.graphics.setFont(font)
    love.graphics.setColor(title_color)
    txt = txt or self.type
    -- PUNTOS
    local w, h = font:getWidth(txt), font:getHeight()
    love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
end

-- dibuja el marco o borde de la pantalla
function SkillTree:drawBorder()
    for _, line in ipairs(utils.borderLinesScreen(nil, nil, ammo_color)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
end

-- dibuja el marco o borde de la pantalla ÚTIL
function SkillTree:drawBorderScreen()
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

function SkillTree:drawUI2()
    --SkillTree.super.drawUI2(self)
    -- BORDER
    self:drawBorder()
    -- TITLE
    self:drawTitle(nil, gw * 0.5, gh * 0.05)
    -- BUTTONS
    for i = 1, #self.buttons do
        self.buttons[i]:draw()
    end

    self:drawSkillTag(gw * 0.75, gh * 0.1)
end

function SkillTree:draw()
    if (self.dead) then return false end
    --self.camera:attach(0, 0, gw, gh)
    --self.camera:detach()
    --local result = SkillTree.super.draw(self)
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
        for _, node in ipairs(self.nodes) do
            node:draw()
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

function SkillTree:textinput(t)
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

return SkillTree