if (_G["Room"]) then
    return _G["Room"]
end
-- Room: Como una Stage, habitación, sala o pantalla. Se encuentra dividida en áreas.
-- Contiene hijos a través de sus áreas.  
-- Sólo se actualiza y dibuja (y todas sus áreas marcadas como current) cuando está marcada como "current".  
-- Aunque el método .draw() es mejor implementarlo en la subclase derivada (por ej. Stage)
local Room = Object:extend()

local Timer = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local utils = require("tools.utils")

function Room:new(current, opts) --{_index, _id, _type}
    opts = opts or {}
    self.pars = opts
    --self.parent = opts.parent -- aquí parent se refiere al array de ROOMS global
    self.rooms = opts.rooms -- se refiere al array de ROOMS global
    for k, v in ipairs(opts) do self[k] = v end

    self.index = opts._index or 0
    self.id = opts._id or utils.UUID()
    self.type = opts._type or "RoomBasic"
    self.current = current or false -- sinó es current entonces no se dibuja ni actualiza (tampoco sus hijos)

    self.camera = opts.camera
    self.camera.x = gw / 2
    self.camera.y = gh / 2
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.areas = {} -- array de áreas
    self.current_area = nil -- -1 = todos, 0 = ninguno, [area] = un áera
    self.innerTimer = false
    self.timer = opts.timer
    if (not self.timer) then
        self.timer = Timer()
        self.innerTimer = true
    end
    self.dead = false
    self.score = 0
    self.score_max = 99999

    -- control a través de tiempo.
    -- Si se especifica "max_time" se pasa a limitar la partida a un máximo de tiempo
    self.max_time = nil
    self.total_time = 10

    --self.input = Input()
    --input:bind('f8', function() self.rooms:toConsoleRoom(self.camera, { rooms = self.rooms, timer = self.timer }) end)
    --input:bind('f8', function() self:finish() end)
end
-- añade un área al array de áreas
function Room:add(area)
    --print(self.type)
    table.insert(self.areas, area)
end
-- elimina la referencia al área hija en el array de áreas
function Room:remove(index)
    table.remove(self.areas, index)
end
--[[ limpia (vacía) el array de todas las áreas
function Room:clear()
    table.clear(self.areas)
    --self.areas = {}
end]]
-- retorna un área por su índice (o nil si no lo encuentra)
function Room:areaByIndex(index)
    local area = nil
    if ((index > 0) and (index < (#self.areas + 1))) then area = self.areas[index] end
    return area
end
-- retorna un área por su id (o nil si no lo encuentra)
function Room:areaById(id)
    local area = nil
    for i, a in ipairs(self.areas) do
        if (a.id == id) then area = a end
    end
    return area
end
-- selecciona sólo un área hija (por índice) como actual (current), el resto no
function Room:gotoArea(index)
    local area = nil
    if (self:areaByIndex(index)) then
        for i, a in ipairs(self.areas) do
            a.current = false
            if (a.index == index) then
                area = a
                area.current = true
                self.current_area = area
                break
            end
        end
    end
    return area
end
-- selecciona todos los hijos como actuales (current)
function Room:selectAll()
    for i, a in ipairs(self.areas) do
        a.current = true
        a.current_child = -1
    end
end
-- deselecciona todos los hijos como no actuales (current = false)
function Room:selectNULL()
    for i, a in ipairs(self.areas) do
        a.current = false
        a.current_child = 0
    end
end

function Room:finish()
    if(not self.rooms)then return false end
    --self.rooms:toNewRoom(self.type, self.camera, { rooms = self.rooms, timer = self.timer })
    --[[self.timer:after(1, function()
        --gotoRoom('Stage')
        self:destroy()
        --self.dead = true
    end)]]
    self.rooms:toConsoleRoom(self.camera, { rooms = self.rooms, timer = self.timer })
end

-- destruye la room y sus recursos, áreas e hijos incluidos
function Room:destroy()
    if (self.camera) then
        --self.camera.detach()
        self.camera = nil
    end
    if (self.main_canvas) then
        love.graphics.setCanvas() -- por si acaso, regresa al canvas principal
        self.main_canvas = nil
    end

    if(self.areas)then
        for i, a in ipairs(self.areas) do
            a.current = false
            a.current_child = 0
        end
        self.current = false
        for i = #self.areas, 1, -1 do
            local area = self.areas[i]
            area:destroy()
            table.remove(self.areas, i)
        end
    end
    self.areas = nil --{}
    self.current_area = nil

    if self.world then
        self.world:destroy()
        self.world = nil
    end
    if(self.innerTimer and self.timer)then
        if self.timer.destroy then self.timer:destroy() end
    end
    self.timer = nil
    self.dead = true
    self.rooms = nil
    -- remate, anula TODO
    --for k, _ in pairs(self) do self[k] = nil end
end

-- retorna la siguiente Area, o NIL si "current_area" es la última
function Room:nextArea()
    local result = false
    local next_area = nil
    for _, area in ipairs(self.areas) do
        if (result) then
            next_area = area
            self.current_area = next_area
            break
        end
        if self.current_area == area then result = true end
    end
    return next_area
end

-- retorna la anterior Area, o NIL si "current_area" es la primera
function Room:prevArea()
    local result = false
    local prev_area = nil
    for i = #self.areas, 1, -1 do
        local area = self.areas[i]
        if (result) then
            prev_area = area
            self.current_area = prev_area
            break
        end
        if self.current_area == area then result = true end
    end
    return prev_area
end

function Room:addScore(score)
    self.score = math.min(self.score + score, self.score_max)
    --[[if not achievements['_10k'] and self.score >= 10000 then
        print("-ACHIEVEMENTS: '_10k', ROOM-SCORE: ", self.score)
        achievements['_10k'] = true
        -- Do whatever else that should be done when an achievement is unlocked
    end
    if not achievements['_30k'] and self.score >= 30000 then
        print("-ACHIEVEMENTS: '_30k', ROOM-SCORE: ", self.score)
        achievements['_30k'] = true
        -- Do whatever else that should be done when an achievement is unlocked
    end
    if not achievements['_50k'] and self.score >= 50000 then
        print("-ACHIEVEMENTS: '_50k', ROOM-SCORE: ", self.score)
        achievements['_50k'] = true
        -- Do whatever else that should be done when an achievement is unlocked
    end]]
    achs("_10k", self.score >= 10000)
    achs("_30k", self.score >= 30000)
    achs("_50k", self.score >= 50000)
end

--------------
-- actualiza esta room (y sus areas marcadas como current) sólo si es 'current'
function Room:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    if self.dead or not self.areas then return false end
    if (not self.camera) then return false end
    if (self.current) then
        for i = #self.areas, 1, -1 do
            local area = self.areas[i]
            area:update(dt)
            if area.dead then
                -- intenta cambiar de area (siguiente o anterior)
                if (self.current_area == area) then
                    self.current_area = self:nextArea()
                    if (not self.current_area) then
                        self.current_area = self:prevArea()
                    end
                end
                table.remove(self.areas, i)
            end
        end
        if (self.max_time) then
            self.total_time = self.total_time + dt
        end

        -- CRONÓMETRO MORTAL
        if(self.max_time)then
            --if (self.total_time > self.max_time) then self.director:destroy() end
            if (self.total_time > self.max_time) then
                if(self.director)then self.director.finished = true end
                self.total_time = 0
            else
                --self.director.finished = false
            end
        end
    end

    return true
end
-- dibuja esta room (y sus areas marcadas como current) sólo si es 'current'
function Room:draw()
    if self.dead then return false end
    if (not self.camera or not self.areas) then return false end
    -- mejor dibujarlo en la subclase, si se dibuja aquí se creará un minimapa
    --[[if (self.current) then
        for _, area in ipairs(self.areas) do
            area:draw()
        end
    end]]
    return true
end

return Room