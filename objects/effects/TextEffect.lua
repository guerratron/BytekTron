if (_G["TextEffect"]) then
    return _G["TextEffect"]
end
local TextEffect = Object:extend()

local Mos             = require("_LIBS_.Moses.moses_min")
require("_LIBS_.utf8")
local ExplodeParticle = require "objects.effects.ExplodeParticle"
local utils           = require "tools.utils"

-- Texto con efecto que desaparece gradualmente. Admite parámetros como las coordenadas y la escala.  
-- La escala también afecta al tiempo de visualización.
-- Por ejemplo:
--[[```lua
    TextEffect(self, self.x, self.y, { text = "SP Spawn !", color = skill_point_color })

    TextEffect(self, gw/2, gh/2, { text = "NEW CYCLE !", color = color, scale = 4 })
    ```
]]
function TextEffect:new(parent, x, y, opts)
    self.parent = parent
    if(self.parent.area)then
        self.area = self.parent.area
    else
        self.area = self.parent
    end
    self.x, self.y = x, y
    self.w, self.h = parent.w, parent.h
    self.scale = 1
    self.font = fonts.m5x7_16
    self.text = nil --"?"
    self.depth = 80
    --[[local default_colors = { default_color, hp_color, ammo_color, boost_color, skill_point_color }
    local negative_colors = {
        { 255 - default_color[1],   255 - default_color[2],   255 - default_color[3] },
        { 255 - hp_color[1],        255 - hp_color[2],        255 - hp_color[3] },
        { 255 - ammo_color[1],      255 - ammo_color[2],      255 - ammo_color[3] },
        { 255 - boost_color[1],     255 - boost_color[2],     255 - boost_color[3] },
        { 255 - skill_point_color[1], 255 - skill_point_color[2], 255 - skill_point_color[3] }
    }]]
    self.all_colors = Mos.append(default_colors, negative_colors)
    self.background_colors = {}
    self.foreground_colors = {}
    if opts then for k, v in pairs(opts) do self[k] = v end end

    self.characters = {}
    for i = 1, #self.text do table.insert(self.characters, self.text:utf8sub(i, i)) end

    self.max_cont = 20 -- elimina residuos en la pantalla
    self.count_effect = 0 -- elimina residuos en la pantalla
    self.visible = true
    if(self.parent and self.parent.timer)then
        self.parent.timer:after(0.70 * self.scale, function()
            if(self.parent and self.parent.timer)then
                local _handler2 = self.parent.timer:every(0.05, function() self.visible = not self.visible end, 6)
                self.parent.timer:after(0.35, function()
                    self.visible = true
                    if(self.parent and self.parent.timer)then
                        self.parent.timer:cancel(_handler2)
                    else
                        self:kill()
                    end
                end)
                self.handler1 = self.parent.timer:every(0.035, function()
                    self.count_effect = self.count_effect + 1
                    --if(self.max_cont > 10)then return false end
                    local random_characters =
                    '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
                    for i, character in ipairs(self.characters) do
                        --chars
                        if love.math.random(1, 20) <= 1 then
                            local r = love.math.random(1, #random_characters)
                            self.characters[i] = random_characters:utf8sub(r, r)
                        else
                            self.characters[i] = character
                        end
                        if(self.background_colors)then
                            --colors
                            if love.math.random(1, 10) <= 1 then
                                self.background_colors[i] = utils.tableRandom(self.all_colors)
                            else
                                self.background_colors[i] = nil
                            end
                            if love.math.random(1, 10) <= 2 then
                                self.foreground_colors[i] = utils.tableRandom(self.all_colors)
                            else
                                self.background_colors[i] = nil
                            end
                        end
                    end
                end)
            else
                self:kill()
            end
        end)

        self.area.timer:after(1.10 * self.scale, function()
            self:kill()
        end, "borrar_txt")
    else
        self:kill()
    end
end

function TextEffect:destroy()
    self.text = nil
    self.background_colors = nil
    self.foreground_colors = nil
    self.parent = nil
end

--[[
    Simula un Temblor (Shake). Espera como parámetros la cámara, la dureza y las repeticiones: 
    toShake(camera, rough, rep)  
    CUIDADO: esta función NO es recursiva, pero es repetitiva.
local function toShake(cam, rough, rep)
    local function _rep()
        --cam:zoom(2, 2)
        --cam:lookAt(rough, rough)
        cam:move(rough, rough)
        --cam:move(-shake.dx, -shake.dy)
        rep = rep - 1
        if (rep > 0) then
            _rep()
        end
    end
    if (rep > 0) then
        _rep()
    end
    --cam:zoomTo(1, 1)
end
]]

function TextEffect:kill()
    if self.dead or not self.parent then
        self.dead = true
        return
    end
    if(self.handler1 and self.parent.timer)then self.parent.timer:cancel(self.handler1) end
    -- Temblor -- la cámara es global y ya viene definida de "main.lua"
    --camera:shake(6, 60, 0.4)
    --toShake(camera, 3, 2)
    -- Relampagueo
    --flash(6)
    -- Ralentización
    -- slow(0.15, 1)
    local numFragments = 10
    for i = 1, utils.random(numFragments * 0.6, numFragments * 1) do -- número de fragmentos
        --self.area:addGameObject('ExplodeParticle', self.x, self.y)
        local eff2 = ExplodeParticle(
            self.area,
            self.x,
            self.y,
            {
                --timer = self.timer,
                live = -1, -- sirve de efecto de disparo (sg)
                color = { 0.6, 0.3, 0.8, 0.7 },
                numEff = 2, -- 1 = desintegración, 2 = fragmentación
                s = 1.5, -- semi-longitud de los fragmentos
                v = 120,
                d = 0.3, -- grosor de los gragmentos
                dist = 6 --self.w -- radio de la explosión
            }
        )
        if (self.area and self.area.add) then self.area:add(eff2) end
    end

    self.dead = true
    self:destroy()
end


function TextEffect:update(dt)
    if self.dead or not self.visible then return end
end

function TextEffect:draw()
    if (self.count_effect > self.max_cont) then
        self.dead = true
    end
    if self.dead or not self.visible then return false end
    love.graphics.setFont(self.font)
    for i = 1, #self.characters do
        local width = 0
        if i > 1 then
            for j = 1, i - 1 do
                width = width + self.font:getWidth(self.characters[j]) * self.scale
            end
        end
        --love.graphics.setColor(self.color)
        --love.graphics.print(self.characters[i], self.x + width, self.y, 0, 1, 1, 0, self.font:getHeight() / 2)

        if self.background_colors[i] then
            love.graphics.setColor(self.background_colors[i])
            love.graphics.rectangle('fill', self.x + width, self.y - self.font:getHeight() / 2,
                self.font:getWidth(self.characters[i]) * self.scale, self.font:getHeight() * self.scale)
        end
        love.graphics.setColor(self.foreground_colors[i] or self.color or default_color)
        love.graphics.print(self.characters[i], self.x + width, self.y,
            0, self.scale, self.scale, 0, self.font:getHeight() / 2 * self.scale)

    end
    love.graphics.setColor(default_color)
    return true
end

return TextEffect