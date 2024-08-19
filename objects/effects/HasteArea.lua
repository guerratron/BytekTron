if (_G["HasteArea"]) then
    return _G["HasteArea"]
end
--local Physics = require "_LIBS_.windfield"
local GameObject = require "objects.basics.GameObject"

-- área circular que se utiliza para realizar la tarea encargada al callback de actualización "outerUpdate", por 
-- ejemplo puede disminuir "aspd_multiplier" en cierta medida mientras el jugador esté dentro de ella, aumentando 
-- así temporalmente la velocidad de disparo.
-- Por ejemplo: 
--[[
    ```lua
    HasteArea(
        self.area,
        self.x,
        self.y,
        {
            parent = nil,
            player = self.player,
            --live = 0.1, -- sirve de efecto de disparo (sg)
            color = color,
            outerUpdate = function (_self) print(_self, self) end,  -- callback de update
            outerKill   = function(_self) self:kill() end           -- callback de kill
        }
    )
    ```
]]
local HasteArea = GameObject:extend()

--local Timer = require("_LIBS_.hump.timer")
local utils = require("tools.utils")

function HasteArea:new(game_object, x, y, opts)
    -- prototipo por defecto de la función "outerUpdate", aunque se espera en los 
    -- parámetros, donde: _self == HasteArea, self == Player
    self.outerUpdate = function (_self) return end
    -- prototipo por defecto de la función "outerKill", aunque se espera en los
    -- parámetros, donde: _self == HasteArea, self == Player
    self.outerKill = function(_self) return end
    -- game_object, en este caso, es el equivalente al área. Como un elemento padre.  
    -- y self.area se referirá a él
    HasteArea.super.new(self, game_object, x, y, opts)
    -- a partir de aquí ya estará definida la función "outerUpdate" y "outerKill"

    self.player = opts.player -- necesita el player para el timer
    self.r = utils.random(64, 96)
    self.timer:after(4, function()
        if(self.timer)then
            self.timer:tween(0.25, self, { r = 0 }, 'in-out-cubic', function() self:kill() end)
        else
            self:kill()
        end
    end)
end

function HasteArea:kill()
    HasteArea.super.kill(self)
    self.player = nil
    --[[
        if (self.player) then
            self.player:exitHasteArea()
        end
    ]]
    self:outerKill()
end

function HasteArea:update(dt)
    --if(self.dead)then return end
    HasteArea.super.update(self, dt)
    if self.dead then return end
    --[[if not self.player then return end            --current_room.player
        local d = utils.distance(self.x, self.y, self.player.x, self.player.y)
        if d < self.r and not self.player.inside_haste_area then -- Enter event
            self.player:enterHasteArea()
        elseif d >= self.r and self.player.inside_haste_area then -- Leave event
            self.player:exitHasteArea()
        end]]
    self:outerUpdate()
end

function HasteArea:draw()
    local result = HasteArea.super.draw(self)
    if (not result) then return false end

    love.graphics.setColor(self.color) -- ammo_color
    love.graphics.circle('line', self.x, self.y, self.r + utils.random(-2, 2))
    love.graphics.setColor(default_color)
end

return HasteArea