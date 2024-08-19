if (_G["Node"]) then
    return _G["Node"]
end

local Node = Object:extend()

local tree = require "objects.basics.Tree"
local Line = require "objects.basics.Line"
local utils = require "tools.utils"

function Node:new(id, x, y, opts)
    self.type = "Node"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.id = id
    self.x, self.y = x, y
    self.overX, self.overY = 0, 0 -- se utiliza al pasar el mouse sobre este Nodo
    self.room = opts.room
    self.tree = opts.tree or utils.tableMerge(tree, {})
    local rMultiplier = 1
    if(self.tree[self.id].type == "Small")then
        rMultiplier = 1
    elseif(self.tree[self.id].type == "Medium")then
        rMultiplier = 1.5
    end
    self.r = (opts.r or 12) * rMultiplier
    self.w = opts.w or self.r
    self.h = opts.h or self.w
    self.shape = self.tree[self.id].shape --"square", "triangle", "circle"
    self.font = opts.font or fonts.m5x7_16
    self.color = self.color or default_color
    self.originalColor = self.color
    self.bought = opts.bought or false -- comprado: sólo puede comprarse si enlaza con otro nodo comprado
    self.clicked = false -- clickado
    self.hot = false                   -- indica si el ratón se encuentra en los límites del botón
    self.inner = false                 -- indica si se entra o sale de los límites del ratón (está relacionada con "hot")
    -- arrastrar la cámara
    self.input = opts.input or self.room.input
    self.input:bind('mouse1', 'left_click2')
    self.sp = self.tree[self.id].sp --costo en skill-points de este nodo
    -- crea los links vecinos
    self.neighbors = {}
    for _, link in pairs(self.tree[self.id].links) do
        if link then
            table.insert(self.neighbors, link)
        end
    end
    -- crea los objetos línea
    self.lines = {}
    for n = 1, #self.neighbors do
        if self.neighbors[n] then
            table.insert(self.lines, Line(self.id, self.neighbors[n], {parent = self, tree = self.tree, centred = opts.centred}))
        end
    end
    -- crea los stats, cada stat se compone de tres partes:
    -- Primero está la descripción visual de la estadística, 
    -- luego qué variable cambiará en el objeto Jugador y luego la cantidad de ese efecto
    self.stats = {}
    for _, stat in pairs(self.tree[self.id].stats) do
        if stat then
            table.insert(self.stats, stat)
        end
    end
end

-- Comprueba y retorna si las coordenadas pasadas se corresponden con las de este nodo, 
-- también retorna estas coordenadas traducidas a la cámara.  
-- Tiene en cuenta la escala de la cámara.  
-- Las coordenadas se esperan con respecto a la cámara, por ejemplo a través de:
--[[
    ```lua
    local mx, my =utils.getMouseXY(self.camera)
    mx, my = -mx, -my -- hay que invertirlas
    local over = self:isOver(mx, my)
    self.hot = over[1]
    if(self.hot)then
        self.overX = over[2].x
        self.overY = over[2].y
    end
    ```
]]
function Node:isOver(x, y)
    local result, subX, subY = false, x, y
    local xLU, yLU = camera:toCameraCoords(self.x - self.w / 2, self.y - self.h / 2)
    xLU, yLU = xLU - gw / 2, yLU - gh / 2
    local xRD, yRD = camera:toCameraCoords(self.x + self.w / 2, self.y + self.h / 2)
    xRD, yRD = xRD - gw / 2, yRD - gh / 2
    if x >= xLU and x <= xRD and y >= yLU and y <= yRD then
        --print(self.hot, self.camera.scale)
        subX = x + self.camera.x * self.camera.scale
        subY = y + self.camera.y * self.camera.scale
        result = true
    end
    return {
        result,
        {
            x = subX,
            y = subY
        }
    }
end

function Node:destroy()
    for _, line in ipairs(self.lines) do
        line:destroy()
    end
    if self.room and self.input then self.input:unbind("left_click2") end
    --self.input:unbindAll()
    --Node.super.destroy(self)
    self.font = nil
    self.neighbors = nil
    self.lines = nil
    self.stats = nil
    self.room = nil
end

function Node:update(dt)
    if not self.room or not self.input then return end
    for _, link in ipairs(self.lines) do
        link.active = self.bought
        link:update(dt)
    end
    --mx, my = mx / sx, my / sy
    local mx, my =utils.getMouseXY(self.camera)
    mx, my = -mx, -my

    local over = self:isOver(mx, my)
    self.hot = over[1]
    if(self.hot)then
        -- retiene las coordenadas
        self.overX = over[2].x
        self.overY = over[2].y
        if (not self.inner) then
            Sounds.play("action5")
        end
        self.inner = true
        -- clickado
        if not self.bought and self.input:down("left_click2") then
            if(loadedData.sp >= self.sp)then
                for n = 1, #self.neighbors do
                    -- comprueba si tiene algún vecino ya comprado
                    if utils.tableExists(self.room.bought_node_indexes, self.neighbors[n]) then
                        --self.room:modifyTemporal_BoughtNodeIndexes(self.id)
                        table.insert(self.room.bought_node_indexes, self.id)
                        loadedData.sp = loadedData.sp - self.sp
                        Sounds.play("action3")
                        break
                    end
                end
            end
        end
    else
        if (self.inner) then
            Sounds.play("plop")
            self.inner = false
        end
    end

    if(not self.bought)then
        self.bought = utils.tableExists(self.room.bought_node_indexes, self.id)
    end
end

function Node:draw()
    if not self.room or not self.input then return end
    for _, link in ipairs(self.lines) do
        link:draw()
    end
    local r, g, b = unpack(self.color)
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.background_color or background_color)
    if(self.shape == "circle")then
        love.graphics.circle('fill', self.x, self.y, self.r)
    elseif(self.shape == "square")then
        love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
    elseif (self.shape == "triangle") then
        love.graphics.polygon("fill",
            self.x - self.r, self.y - self.r,
            self.x + self.r, self.y - self.r,
            self.x, self.y + self.r
        )
    end
    --love.graphics.setColor(self.color)
    if self.bought then
        love.graphics.setColor(r, g, b, 1)
    else
        love.graphics.setColor(r, g, b, 0.3)
    end
    love.graphics.print(self.id .. '', self.x, self.y, 0, sx / 2, sy / 2,
        math.floor(self.font:getWidth(self.id .. '') / 2),
        self.font:getHeight() / 2
    )
    --[[love.graphics.print(self.id .. '', self.x, self.y, 0, 1, 1,
        math.floor(self.font:getWidth(self.id .. '') / 2),
        self.font:getHeight() / 2
    )]]
    if (self.shape == "circle") then
        love.graphics.circle('line', self.x, self.y, self.r)
    elseif (self.shape == "square") then
        love.graphics.rectangle('line', self.x-self.w/2, self.y-self.h/2, self.w, self.h)
    elseif (self.shape == "triangle") then
        love.graphics.polygon("line",
            self.x - self.r, self.y - self.r,
            self.x + self.r, self.y - self.r,
            self.x, self.y + self.r
        )
    end
    love.graphics.setColor(r, g, b, 1)

    -- Stats rectangle
    if self.hot then
        local stats = self.stats         --tree[node.id].stats
        -- Figure out max_text_width to be able to set the proper rectangle width
        local max_text_width = 0
        for i = 1, #stats, 3 do
            if self.font:getWidth(stats[i]) > max_text_width then
                max_text_width = self.font:getWidth(stats[i])
            end
        end
        -- Draw rectangle
        local rectW = 32 + max_text_width
        local rectH = self.font:getHeight() + (#stats / 3) * self.font:getHeight() + 24
        --local rectH = #stats * self.font:getHeight()
        --love.graphics.setColor(0, 0, 0, 222)
        --[[love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        love.graphics.rectangle('fill', self.overX, self.overY, rectW, rectH)
        --print(#self.stats, max_text_width)
        love.graphics.setColor(0.9, 0.9, 0.9, 1)
        love.graphics.rectangle('line', self.overX + 2, self.overY + 2, rectW - 4, rectH - 4)
        local txt = stats[1] .. "\n" .. stats[2] .. "\n" .. stats[3]
        love.graphics.print(
            txt,--stats[1],
            self.overX + rectW/2, --self.font:getWidth(stats[1])/2,
            self.overY + rectH/2,
            0,
            self.camera.scale, self.camera.scale,
            --math.floor(self.font:getWidth(stats[1]) / 2),
            math.floor(self.font:getWidth(txt) / 2),
            self.font:getHeight()
        )]]
        -- Draw text
        love.graphics.setColor(default_color)
        love.graphics.rectangle('line', self.overX + 2, self.overY + 2, rectW - 4, rectH - 4)
        for i = 1, #stats, 3 do
            love.graphics.print("[" .. self.id .. "] " .. stats[i], math.floor(self.overX + 8),
                math.floor(self.overY + self.font:getHeight() / 2 + math.floor(i / 3) * self.font:getHeight()))
        end
        love.graphics.setColor(hp_color)
        love.graphics.print("SP: " .. self.sp, math.floor(self.overX + 8*3),
            math.floor(self.overY + self.font:getHeight() / 2 + math.floor(3 / 3)*2 * self.font:getHeight()))
        self.color = hp_color
    else
        self.color = self.originalColor-- ammo_color
    end
end

return Node