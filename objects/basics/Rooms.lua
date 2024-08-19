if (_G["Rooms"]) then
    return _G["Rooms"]
end
-- Rooms: Un array de rooms [Room], que contienen áreas [Area] y estas hijos [any].  
-- Contiene hijos a través de las áreas de sus rooms.
-- Sólo se actualizan y dibujan todas sus rooms si se encuentran marcadas como current.
local Rooms = Object:extend()

local Timer = require("_LIBS_.chrono.Timer")
local Console = require("objects.rooms.Console")
local Stage = require("objects.rooms.Stage")
local Level1 = require("objects.rooms.Level1")
local HelpScreen = require("objects.rooms.HelpScreen")
local ReadmeScreen = require("objects.rooms.ReadmeScreen")
local SkillTree = require("objects.rooms.SkillTree")
local Achievements = require("objects.rooms.Achievements")
local ShipsScreen = require("objects.rooms.ShipsScreen")
local IntroScreen = require("promo.IntroScreen")
local SplashScreen = require("promo.SplashScreen")

local utils = require("tools.utils")

function Rooms:new(opts)
    self._rooms = {}
    self.current_room = nil
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end
    self.score = 0
    --self.shift = nil
    self.innerTimer = false
    self.timer = opts.timer
    if (not self.timer) then
        self.timer = Timer()
        self.innerTimer = true
    end
end
-- añade una room al array de rooms
function Rooms:add(room)
    for i, r in ipairs(self._rooms) do
        --room:destroy()
        room.current = false
    end
    self._rooms = {}
    table.insert(self._rooms, room)
    room.current = true
    room.index = #self._rooms
    self.current_room = room
end
-- elimina la referencia a la room hija en el array de rooms
function Rooms:remove(index)
    table.remove(self._rooms, index)
end
-- limpia (vacía) el array de todas las rooms
function Rooms:clear()
    --table.clear(self._rooms)
    --self._rooms = {}
end

function Rooms:toConsoleRoom(_camera, ...)
    --print("toConsoleRoom")
    --[[local cr = self.current_room
    self.timer:after(0.2, function()
        if (cr and cr.destroy) then
            cr:destroy()
            --self:remove(cr.index)
        end
        collectgarbage()
    end, "hey_" .. (cr.index + 1))]]
    --[[if (cr and cr.destroy) then cr:destroy() end
    collectgarbage()]]

    print(".. to Console ..")
    --local current_room = self.current_room
    --self._rooms = {}
    self:add(Console(_camera or camera, ...)) -- opts))
    --print("toConsoleRoom()", current_room, current_room.ship)
    --if(current_room)then
        --current_room:destroy()
        --if(current_room.ship)then current_room.ship:kill() end
    --end
    collectgarbage()
end
function Rooms:toNewRoom(type, camera, ...)
    --print("toNewRoom")
    if(not self.timer)then return false end
    --[[local cr = self.current_room
    self.timer:after(0.2, function()
        if (cr and cr.destroy) then
            cr:destroy()
            --self:remove(cr.index)
        end
        collectgarbage()
    end, "hey_" .. (cr.index + 1))]]
    --[[if (cr and cr.destroy) then cr:destroy() end
    collectgarbage()]]

    --[[local opts = ...
        opts.imgFondoPath = cr.imgFondoPath
        print("'Level1': new Room 'Stage'", opts.imgFondoPath)]]
    --self._rooms = {}
    local CLS = Stage
    if (type == "Stage") then
        CLS = Level1
    elseif (type == "Level1") then
        CLS = Stage
    elseif (type == "HelpScreen") then
        CLS = Console
    elseif (type == "ReadmeScreen") then
        CLS = Console
    elseif (type == "SkillTree") then
        CLS = Console
    elseif (type == "Achievements") then
        CLS = Console
    elseif (type == "ShipsScreen") then
        CLS = Console
    elseif (type == "IntroScreen") then
        CLS = Stage
    elseif (type == "SplashScreen") then
        CLS = Console
    elseif (type == "Console:Help") then
        CLS = HelpScreen
    elseif (type == "Console:Readme") then
        CLS = ReadmeScreen
    elseif (type == "Console:Skill") then
        CLS = SkillTree
    elseif (type == "Console:Achievements") then
        CLS = Achievements
    elseif (type == "Console:Ships") then
        CLS = ShipsScreen
    elseif (type == "Console:Intro" or type == "Splash:Intro") then
        CLS = IntroScreen
    elseif (type == "Console:Splash") then
        CLS = SplashScreen
    elseif (type == "Console:Room" or type == "Console:Start") then
        CLS = utils.tableRandom({Stage, Level1})
    end
    local c = CLS(camera, ...)
    print(".. " .. c.type .. " ..")
    --self.current_room:destroy()
    --self._rooms = {}
    self:add(c)     -- opts))
    collectgarbage()
end
-- retorna una room por su índice (o nil si no lo encuentra)
function Rooms:roomByIndex(index)
    local room = nil
    if ((index > 0) and (index < (#self._rooms + 1))) then room = self._rooms[index] end
    return room
end
-- retorna una room por su id (o nil si no lo encuentra)
function Rooms:roomById(id)
    local room = nil
    for i, r in ipairs(self._rooms) do
        if (r.id == id) then room = r end
    end
    return room
end
-- selecciona sólo una room (por índice) como actual (current), el resto no
function Rooms:gotoRoom(index)
    local room = nil
    if (self:roomByIndex(index)) then
        for _, r in ipairs(self._rooms) do
            r.current = false
            if (r.index == index) then
                room = r
                room.current = true
                self.current_room = room
                break
            end
        end
        if(self.current_room)then self.current_room.current = true end
    end
    return room
end

--[[function Rooms:gotoRoom(room_type, ...)
    --self.current_room = _G[room_type](...)
    for i, room in ipairs(self._rooms) do
        if (i == index) then current_room:update(dt) end
    end
end

function addRoom(room_type, room_name, ...)
    local room = _G[room_type](room_name, ...)
    rooms[room_name] = room
    return room
end
function Area:addGameObject(game_object_type, x, y, opts)
    local opts = opts or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
    table.insert(self.game_objects, game_object)
    return game_object
end

function gotoRoom(room_type, room_name, ...)
    if current_room and rooms[room_name] then
        if current_room.deactivate then current_room:deactivate() end
        current_room = rooms[room_name]
        if current_room.activate then current_room:activate() end
    else current_room = addRoom(room_type, room_name, ...) end
end]]

function Rooms:destroy()
    if (self.innerTimer and self.timer) then
        if self.timer.destroy then self.timer:destroy() end
    end
    self.timer = nil
    for i = #self._rooms, 1, -1 do
        local rs = self._rooms[i]
        if(rs)then rs:destroy() end
        table.remove(self._rooms, i)
    end
    self._rooms = nil
    self.current_room = nil
    -- remate, anula TODO
    for k, _ in pairs(self) do self[k] = nil end
end

-- retorna la siguiente Room, o NIL si "current_room" es la última
function Rooms:nextRoom()
    local result = false
    local next_room = nil
    for _, room in ipairs(self._rooms) do
        if(result)then
            next_room = room
            self.current_room = next_room
            break
        end
        if self.current_room == room then result = true end
    end
    return next_room
end

-- retorna la anterior Room, o NIL si "current_room" es la primera
function Rooms:prevRoom()
    local result = false
    local prev_room = nil
    for i = #self._rooms, 1, -1 do
        local room = self._rooms[i]
        if (result) then
            prev_room = room
            self.current_room = prev_room
            break
        end
        if self.current_room == room then result = true end
    end
    return prev_room
end

--------------
-- actualiza todas sus rooms (y sus áreas) sólo si son 'current'
function Rooms:update(dt)
    --for i, room in ipairs(self._rooms) do
    for i = #self._rooms, 1, -1 do
        local room = self._rooms[i]
        room:update(dt)
        if room.dead then
        -- intenta cambiar de room (siguiente o anterior)
            if(self.current_room == room)then
                self.current_room = self:nextRoom()
                if (not self.current_room) then
                    self.current_room = self:prevRoom()
                end
            end
            table.remove(self._rooms, i)
        end
    end
    if(self.timer)then
        self.timer:update(dt)
    end
    --[[for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then table.remove(self.game_objects, i) end
    end]]
end
-- dibuja todas sus rooms (y sus áreas) sólo si son 'current'
function Rooms:draw()
    for _, room in ipairs(self._rooms) do
        room:draw()
    end
end

function Rooms:textinput(t)
    --print('Rooms.lua', t)
    --[[for _, room in ipairs(self._rooms) do
        if (room.textinput) then room:textinput(t) end
    end]]
    if (self.current_room and self.current_room.textinput) then self.current_room:textinput(t) end
end

return Rooms