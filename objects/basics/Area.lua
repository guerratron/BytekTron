if (_G["Area"]) then
    return _G["Area"]
end

local Physics = require "_LIBS_.windfield"
--local Timer = require("_LIBS_.chrono.Timer")
local Timer = require("_LIBS_.hump.timer")

-- Area: Es una subparte (subsala) de una Room.  
-- Contiene todos sus hijos en un array.  
-- Sólo se actualiza y dibuja (y todos sus hijos marcados como current) cuando está marcada como "current".
local Area = Object:extend()

local Utils = require("tools.utils")

function Area:new(room, current, _pars) --{_index, _id, _type}
    if _pars then for k, v in pairs(_pars) do self[k] = v end end
    self.room = room -- referencia a su room padre
    self.pars = _pars
    self.index = (_pars and _pars._index) or 0
    self.id = (_pars and _pars._id) or Utils.UUID()
    self.type = (_pars and _pars._type) or "AreaBasic"
    self.innerTimer = false
    self.timer = (_pars and _pars.timer)
    if(not self.timer)then
        self.timer = Timer()
        self.innerTimer = true
    end
    self.current = current or false -- sinó es current entonces no se dibuja ni actualiza (tampoco sus hijos)
    self.children = {} -- array de cualesquiera tipo de hijos (GameObjects)
    self.current_child = nil -- -1 = todos, 0 = ninguno, [child] = un hijo
    self.world = nil
    self.dead = false
    self.visible = true
end
-- añade un hijo cualquiera al array de hijos y retorna su índice
function Area:add(child)
    table.insert(self.children, child)
    return #self.children
end
-- elimina la referencia al hijo en el array de hijos y retorna la cantidad que quedan
function Area:remove(index)
    table.remove(self.children, index)
    return #self.children
end
--[[ limpia (vacía) el array de todos los hijos
function Area:clear()
    table.clear(self.children)
    --self.children = {}
end]]
-- retorna un hijo por su índice (o nil si no lo encuentra)
function Area:childByIndex(index)
    local child = nil
    if ((index > 0) and (index < (#self.children + 1))) then child = self.children[index] end
    return child
end
-- retorna un hijo por su id (o nil si no lo encuentra)
function Area:childById(id)
    local child = nil
    for i, c in ipairs(self.children) do
        if (c.id == id) then child = c end
    end
    return child
end
-- selecciona sólo un hijo (por índice) como actual (current), el resto no
function Area:gotoChild(index)
    local child = nil
    if (self:childByIndex(index)) then
        for i, c in ipairs(self.children) do
            c.current = false
            if (c.index == index) then
                child = c
                child.current = true
                self.current_child = child
                break
            end
        end
    end
    return child
end

-- se entrega una función (que retorne booleano) y retorna todos los hijos que cumplan esa función
function Area:getAllChildrenThat(filter)
    local out = {}
    for _, child in pairs(self.children) do
        if filter(child) then
            table.insert(out, child)
        end
    end
    return out
end
-- selecciona todos los hijos como actuales (current)
function Area:selectAll()
    for i, c in ipairs(self.children) do
        c.current = true
        c.current_child = -1
    end
end
-- deselecciona todos los hijos como no actuales (current = false)
function Area:selectNULL()
    for i, c in ipairs(self.children) do
        c.current = false
        c.current_child = 0
    end
end

function Area:addPhysicsWorld()
    self.world = Physics.newWorld(0, 0, true)
    self.world:setGravity(0, 4)
    return self
end

function Area:destroy()
    self.current = false
    for i = #self.children, 1, -1 do
        local game_object = self.children[i]
        if(game_object)then game_object:kill() end
        table.remove(self.children, i)
    end
    self.children = nil
    self.current_child = nil
    self.room = nil

    if self.world then
        self.world:destroy()
        self.world = nil
    end
    if (self.innerTimer and self.timer) then
        if self.timer.destroy then self.timer:destroy() end
    end
    self.timer = nil
end

--[[
    what = {
        who = self,
        type = self._type,
        what = what
    }
function Area:receive(what)

end
function Area:notify(what)
    self.parent:receive({
        who = self,
        type = self._type,
        what = what
    })
end
]]

--------------
-- actualiza esta área (y sus hijos marcados como current) sólo si es 'current'
function Area:update(dt)
    if self.dead then return end
    if (self.current) then
        if self.world then self.world:update(dt) end
        --[[for i, child in ipairs(self.children) do
            child:update(dt)
            if child.dead then table.remove(self.children, i) end
        end]]
        for i = #self.children, 1, -1 do
            local game_object = self.children[i]
            game_object:update(dt)
            if game_object.dead then
                game_object:kill()
                table.remove(self.children, i)
            end
        end
        --[[ para el orden de dibujado (quizás mejor en .draw() ??)
        -- NO UTILIZAR, si se utilizan los índices para otra ordenación
        table.sort(self.children, function(a, b)
            return a.depth < b.depth
        end)
        -- o en caso de profundidades iguales:
        table.sort(self.children, function(a, b)
            if a.depth == b.depth then
                return a.creation_time < b.creation_time
            else
                return a.depth < b.depth
            end
        end)]]
    end
end
-- dibuja esta área (y sus hijos marcados como current) sólo si es 'current'
function Area:draw()
    if self.dead or not self.visible then return end
    if (self.current) then
        --if self.world then self.world:draw() end
        for _, child in ipairs(self.children) do
            child:draw()
        end
    end
end

return Area