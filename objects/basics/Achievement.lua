if (_G["Achievement"]) then
    return _G["Achievement"]
end

local Achievement = Object:extend()

local utils = require "tools.utils"

function Achievement:new(achKey, x, y, opts)
    self.type = "Achievement"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.key = achKey
    self.ach = achievements[self.key]
    self.title = achievements_description[self.key]
    self.x, self.y = x, y
    self.overX, self.overY = 0, 0 -- se utiliza al pasar el mouse sobre este Nodo
    self.room = opts.room
    self.r = (opts.r or 12)
    --self.w = opts.w or self.r
    --self.h = opts.h or self.w
    self.font = opts.font or fonts.m5x7_16
    self.w, self.h = math.floor(self.font:getWidth(self.key .. '')), self.font:getHeight()
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
function Achievement:isOver(x, y)
    local result, subX, subY = false, x, y
    local xLU, yLU = camera:toCameraCoords(self.x - self.w, self.y - self.h)
    xLU, yLU = xLU - gw / 2, yLU - gh / 2
    local xRD, yRD = camera:toCameraCoords(self.x + self.w, self.y + self.h)
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

function Achievement:destroy()
    if self.room and self.input then self.input:unbind("left_click2") end
    --self.input:unbindAll()
    --Achievement.super.destroy(self)
    self.ach = nil
    self.font = nil
    self.room = nil
end

function Achievement:update(dt)
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
        --[[if not self.ach and self.input:down("left_click2") then
        end]]
    else
        if (self.inner) then
            Sounds.play("plop")
            self.inner = false
        end
    end

    if(not self.ach)then
    end
end

function Achievement:draw()
    if not self.room or not self.input then return end
    local r, g, b = unpack(self.color)
    love.graphics.setFont(self.font)
    -- BACKGROUND
    love.graphics.setColor(self.background_color or background_color)
    love.graphics.rectangle('fill', self.x - self.w, self.y - self.h, self.w * 2, self.h * 2)
    --[[love.graphics.polygon("fill",
        self.x - self.r, self.y - self.r,
        self.x + self.r, self.y - self.r,
        self.x, self.y + self.r
    )]]
    --love.graphics.setColor(self.color)
    -- FRONT
    if self.ach then
        love.graphics.setColor(r, g, b, 1)
    else
        love.graphics.setColor(r, g, b, 0.3)
    end
    love.graphics.print(self.key .. '', self.x, self.y, 0, sx / 2, sy / 2, self.w / 2, self.h / 2)
    --love.graphics.print(self.key .. '', self.x, self.y, 0, 1, 1, self.w / 2, self.h / 2)
    love.graphics.rectangle('line', self.x - self.w, self.y - self.h, self.w * 2, self.h * 2)
    --[[love.graphics.polygon("line",
        self.x - self.r, self.y - self.r,
        self.x + self.r, self.y - self.r,
        self.x, self.y + self.r
    )]]
    love.graphics.setColor(r, g, b, 1)

    -- Stats rectangle
    if self.hot then
        -- Draw text description
        love.graphics.setColor(default_color)
        --love.graphics.rectangle('line', self.overX + 2, self.overY + 2, rectW - 4, rectH - 4)
        --love.graphics.print(self.key, math.floor(self.overX + 8),
        --        math.floor(self.overY + self.font:getHeight() / 2 + self.font:getHeight()))
        if(self.title)then
            love.graphics.print(self.title, math.floor(self.overX + 8), math.floor(self.overY + self.font:getHeight() * 1.5))
        end
        --love.graphics.setColor(hp_color)
        self.color = hp_color
    else
        self.color = self.originalColor-- ammo_color
    end
end

return Achievement