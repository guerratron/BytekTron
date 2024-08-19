if (_G["ShipSelect"]) then
    return _G["ShipSelect"]
end

local ShipSelect = Object:extend()

--local ShapePolygons = require "tools.ShapePolygons"
local utils = require "tools.utils"

function ShipSelect:new(shipKey, x, y, opts)
    self.type = "ShipSelect"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.key = shipKey
    self.title = achievements_description[self.key]
    self.x, self.y = x, y
    self.overX, self.overY = 0, 0 -- se utiliza al pasar el mouse sobre este Nodo
    self.room = opts.room
    self.r = (opts.r or 12)
    --self.w = opts.w or self.r
    --self.h = opts.h or self.w
    self.font = opts.font or fonts.m5x7_16
    self.w, self.h = math.floor(self.font:getWidth(self.key .. '')), self.font:getHeight()
    --self.polygons = Shapes.makeShips(self.w)[self.key]
    self.bought = ships and ships[self.key]
    self.sp = ship_cost

    self.color = self.color or default_color
    self.originalColor = self.color
    self.clicked = false -- clickado
    self.hot = false     -- indica si el ratón se encuentra en los límites del botón
    self.inner = false   -- indica si se entra o sale de los límites del ratón (está relacionada con "hot")
    -- arrastrar la cámara
    self.input = opts.input or self.room.input
    self.input:bind('mouse1', 'left_click2')
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
function ShipSelect:isOver(x, y)
    local result, subX, subY = false, x, y
    local xLU, yLU = camera:toCameraCoords(self.x - self.w, self.y - self.h*4)
    xLU, yLU = xLU - gw / 2, yLU - gh / 2
    local xRD, yRD = camera:toCameraCoords(self.x + self.w, self.y + self.h*4)
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

function ShipSelect:destroy()
    if self.room and self.input then self.input:unbind("left_click2") end
    --self.input:unbindAll()
    --ShipSelect.super.destroy(self)
    --self.polygons = nil
    self.font = nil
    self.room = nil
end

function ShipSelect:update(dt)
    if not self.room or not self.input then return end
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
        if self.input:down("left_click2") then
            if self.bought then
                ship_selected = self.key
                Sounds.play("action3")
            else
                if (loadedData.sp and loadedData.sp >= self.sp) then
                    table.insert(self.room.bought_ships_keys, self.key)
                    loadedData.sp = loadedData.sp - self.sp
                    ship_selected = self.key
                    Sounds.play("action3")
                end
            end
        end
    else
        if (self.inner) then
            Sounds.play("plop")
            self.inner = false
        end
    end

    if (not self.bought) then
        self.bought = utils.tableExists(self.room.bought_ships_keys, self.key)
    end
end

function ShipSelect:draw()
    if not self.room or not self.input then return end
    local r, g, b = unpack(self.color)
    love.graphics.setFont(self.font)
    local x, y, w, h = self.x - self.w, self.y - self.h * 4, self.w * 2, self.h * 8
    -- BACKGROUND
    local bkColor = self.background_color or background_color
    if(ship_selected == self.key)then
        bkColor = {0.6,0.9,0.6, 0.5}
    end
    love.graphics.setColor(bkColor)
    love.graphics.rectangle('fill', x, y, w, h)
    --[[love.graphics.polygon("fill",
        self.x - self.r, self.y - self.r,
        self.x + self.r, self.y - self.r,
        self.x, self.y + self.r
    )]]
    --love.graphics.setColor(self.color)
    -- FRONT
    if self.bought then
        love.graphics.setColor(r, g, b, 1)
    else
        love.graphics.setColor(r, g, b, 0.3)
    end
    love.graphics.print(self.key .. '', self.x, self.y - self.h * 2, 0, sx / 2, sy / 2, self.w / 2, self.h / 2)
    love.graphics.rectangle('line', x, y, w, h)
    --[[love.graphics.polygon("line",
        self.x - self.r, self.y - self.r,
        self.x + self.r, self.y - self.r,
        self.x, self.y + self.r
    )]]
    Shapes.drawPolygons(self.key, self.x, self.y + self.h*2, self.w)
    love.graphics.setColor(r, g, b, 1)

    -- Stats rectangle
    if self.hot then
        -- Draw text description
        love.graphics.setColor(default_color)
        --love.graphics.rectangle('line', self.overX + 2, self.overY + 2, rectW - 4, rectH - 4)
        --love.graphics.print(self.key, math.floor(self.overX + 8),
        --        math.floor(self.overY + self.font:getHeight() / 2 + self.font:getHeight()))
        love.graphics.print(self.key, math.floor(self.overX + 8), math.floor(self.overY + self.font:getHeight() * 1.5))
        love.graphics.setColor(hp_color)
        love.graphics.print(ship_cost .. " $", math.floor(self.overX + 8), math.floor(self.overY + self.font:getHeight() * 2.5))
        --love.graphics.setColor(hp_color)
        self.color = hp_color
    else
        self.color = self.originalColor-- ammo_color
    end
end

return ShipSelect