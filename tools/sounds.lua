--[[if (_G["sounds"]) then
    return _G["sounds"]
end]]

local _sounds = {
    static = {
        action1 = -1,
        action2 = -1,
        action3 = -1,
        action4 = -1,
        action5 = -1,
        action6 = -1,
        action7 = -1,
        action8 = -1,
        action9 = -1,
        beep = -1,
        cancel = -1,
        countdown2 = -1,
        explosion = -1,
        impact1 = -1,
        impact2 = -1,
        impact3 = -1,
        impact4 = -1,
        impact5 = -1,
        impact6 = -1,
        impact7 = -1,
        plop = -1,
        power_ups1 = -1,
        power_ups2 = -1,
        power_ups3 = -1,
        room_escape = -1,
        room_init1 = -1,
        ship_select1 = -1,
        ship_select2 = -1,
        ship_select3 = -1,
        ship_shoot = -1,
        ship_shoot2 = -1,
        ship_shoot3 = -1,
        ship_shoot4 = -1,
        ship_shoot5 = -1,
        ship_shoot6 = -1,
        shoot2 = -1,
        shoot3 = -1,
        key_down = -1,
    },
    stream = {
        bk1 = -1,
        bk2 = -1
    }
}
--shoot_sound = love.audio.newSource("assets/ship_shoot.ogg", "static")

local function _load()
    -- Efectos
    for key, _ in pairs(_sounds.static) do
        _sounds.static[key] = love.audio.newSource("assets/" .. key .. ".ogg", "static")
    end
    -- Musica
    for key, _ in pairs(_sounds.stream) do
        --_sounds.stream[key] = love.audio.newSource("assets/" .. key .. ".ogg", "stream")
    end
end
-- libera recursos
local function _unload()
    -- Efectos
    for key, _ in pairs(_sounds.static) do
        _sounds.static[key] = nil
    end
    -- Musica
    for key, _ in pairs(_sounds.stream) do
        _sounds.stream[key] = nil
    end
    _sounds = nil
end

-- para Musica y efectos
local function _play(k)
    local finded = false
    -- Efectos
    for key, _ in pairs(_sounds.static) do
    --for i = 1, #_sounds.static do
            if(_sounds.static[key]:isPlaying())then _sounds.static[key]:stop() end
            if (k == key and _sounds.static[key] ~= -1) then
            _sounds.static[key]:play()
            finded = true
            break
        end
    end
    if(finded)then return end
    -- Musica
    for key, _ in pairs(_sounds.stream) do
        if (k == key and _sounds.stream[key] ~= -1) then
            if (_sounds.stream[key]:isPlaying()) then _sounds.stream[key]:stop() end
            _sounds.stream[key]:play()
            break
        end
    end
end
-- solo para Musica (stream)
local function _stop(k)
    -- Musica
    for key, _ in pairs(_sounds.stream) do
        if (k == key and _sounds.stream[key] ~= -1) then
            if (_sounds.stream[key]:isPlaying()) then _sounds.stream[key]:stop() end
            break
        end
    end
end

-- para Musica y efectos
local function _stopAll()
    local finded = false
    -- Efectos
    for key, _ in pairs(_sounds.static) do
        if (_sounds.static[key] ~= -1) then
            if (_sounds.static[key]:isPlaying()) then _sounds.static[key]:stop() end
        end
    end
    if (finded) then return end
    -- Musica
    for key, _ in pairs(_sounds.stream) do
        if (_sounds.stream[key] ~= -1) then
            if (_sounds.stream[key]:isPlaying()) then _sounds.stream[key]:stop() end
        end
    end
end

-- lo primero que hay que hacer es llamar una vez al método "load", después ya estarán cargados 
-- los sonidos para utilizarse, divididos en dos grupos "static" (stc) y "stream" (str) en función 
-- de que sean sonidos de efectos cortos o fondos musicales largos
return {
    --sounds = _sounds,
    --stc = _sounds.static,
    --str = _sounds.stream,
    load = _load,
    unload = _unload,
    play = _play,
    stop = _stop,
    stopAll = _stopAll
}