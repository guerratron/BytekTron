if (_G["Button"]) then
    return _G["Button"]
end

Button = Object:extend()

local tree = require "objects.basics.Tree"
local utils = require "tools.utils"

local function _innerHandlerClick(_self)
    _self:toHandlerClick()
    if (_self.subtype == "positive") then
        Sounds.play("action9")
    else
        Sounds.play("action2")
    end
end

function Button:new(id, x, y, opts)
    self.type = "Button"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.subtype = opts.subtype or "positive"
    self.shape = opts.shape or "circle"
    self.title = opts.title
    --print(self.title, opts.title)

    self.timer = opts.timer --or Timer()
    --print("New Button")
    self.id = id
    self.x, self.y = x, y
    self.overX, self.overY = 0, 0 -- se utiliza al pasar el mouse sobre este Nodo
    self.room = opts.room
    self.text = opts.text or "?"
    self.w = opts.w or 12 -- de w puede extraerse r = w/2
    self.h = opts.h or self.w
    self.font = opts.font or fonts.m5x7_16
    self.color = self.color or default_color
    self.originalColor = self.color
    self.clicked = false -- clickado, sólo se permite clickar una vez
    self.hot = false -- indica si el ratón se encuentra en los límites del botón
    self.inner = false -- indica si se entra o sale de los límites del ratón (está relacionada con "hot")
    self.toHandlerClick = opts.toHandlerClick or function() end
    -- arrastrar la cámara
    -- hay que diferir los click del ratón para que no se superpongan con otros
    self.timer:after(0.5,
        function()
            self.room.input:bind('mouse1', 'left_click_button') -- + id
        end
    )
end

function Button:destroy()
    if self.room and self.room.input then self.room.input:unbind("left_click_button") end
    --self.input:unbindAll()
    --Button.super.destroy(self)
end

function Button:update(dt)
    if not self.room or not self.room.input then return end
    local mx, my = love.mouse.getPosition()
    --mx, my = -mx, -my
    mx, my = mx / sx, my / sy

    self.hot = false
    if(self.shape == "circle")then
        if mx > self.x - self.w/2 and mx < self.x + self.w/2 and my > self.y - self.h/2 and my < self.y + self.h/2 then
            self.hot = true
        end
    else
        if mx > self.x and mx < self.x + self.w and my > self.y and my < self.y + self.h then
            self.hot = true
        end
    end
    if (self.hot) then
        -- retiene las coordenadas
        self.overX = mx
        self.overY = my
        -- clickado
        if not self.clicked and self.room.input:down("left_click_button") then
            --print("button", self.clicked)
            self.clicked = true
            _innerHandlerClick(self)
        end
        if (not self.inner) then
            Sounds.play("action5")
        end
        self.inner = true
    else
        if(self.inner)then
            Sounds.play("plop")
            self.inner = false
        end
    end
end

function Button:draw()
    if self.hot then
        self.color = hp_color
    else
        self.color = self.originalColor -- ammo_color
    end
    local r, g, b = unpack(self.color)
    --love.graphics.setColor(r, g, b, 1)
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.background_color or background_color)
    if(self.shape == "circle")then
        -- Draw circle
        love.graphics.circle('fill', self.x, self.y, self.w / 2)
        love.graphics.setColor(self.color)
        --[[love.graphics.print(self.text, self.x, self.y, 0, sx / 2, sy / 2,
            math.floor(self.font:getWidth(self.text) / 2),
            self.font:getHeight() / 2
        )]]
        love.graphics.print(self.text, self.x, self.y, 0, 1, 1,
            math.floor(self.font:getWidth(self.text) / 2),
            self.font:getHeight() / 2
        )
        love.graphics.circle('line', self.x, self.y, self.w/2)
    else
        -- Draw rectangle
        local rectW = 32 + self.font:getWidth(self.text)
        local rectH = 24 + self.font:getHeight()
        -- Draw text
        love.graphics.setColor(default_color)
        --[[love.graphics.rectangle('line', self.overX + 2, self.overY + 2, rectW - 4, rectH - 4)
        love.graphics.print(
            self.text,
            math.floor(self.overX + 8),
            math.floor(self.overY + self.font:getHeight() / 2)
        )]]
        love.graphics.rectangle('line', self.x-self.w/2, self.y-self.w/2, rectW - 4, rectH - 4)
        love.graphics.print(
            self.text,
            math.floor(self.x + 8),
            math.floor(self.y + self.font:getHeight() / 2)
        )
    end
    if(self.hot and self.title)then
        love.graphics.print(
            self.title,
            math.floor(self.overX + 8),
            math.floor(self.overY + self.font:getHeight() / 2)
        )
    end
end

return Button