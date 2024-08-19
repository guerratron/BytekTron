local bitser = require '_LIBS_.bitser.bitser'

--local utils = require "tools.utils"
local ShapePolygons = require "tools.ShapePolygons"

gw = 480    -- ancho original windows
gh = 270    -- alto original windows
sx = 1      -- escala del ancho (a utilizar en el dibujado de algunas pantallas, gameobjects, ..)
sy = 1      -- escala del alto (a utilizar en el dibujado de algunas pantallas, gameobjects, ..)
minZoom, maxZoom = 1, 4

default_color = { 0.9, 0.9, 0.9, 1 }
background_color = { 0.1, 0.1, 0.1, 1 }
impact_color = { 1, 1, 1, 1 }
ammo_color = { 0.5, 0.8, 0.7, 1 }
boost_color = { 0.3, 0.8, 0.9, 1 }
boost_up_color = { 0.3, 0.8, 0.9, 1 }
boost_down_color = { 0.8, 0.3, 0.3, 1 }
hp_color = { 1, 0.4, 0.2, 1 }
sp_color = { 1, 1, 0.2, 1 }
skill_point_color = { 1, 0.8, 0.4, 1 }
invincible_color = { 0.6, 0.6, 0, 1 }
title_color = boost_color
resalt_color = hp_color

bullet_color = { 1, 0.3, 0.3, 1 }
shooter_color = { 0.8, 0.2, 0.2, 1 }
seeker_color = { 0.7, 0.3, 0.3, 1 }

rapid_color = { 0.9, 0.9, 0.1, 1 }
double_color = { 0.1, 0.1, 0.5, 1 }
double_back_color = { 0.1, 0.1, 0.9, 1 }
triple_color = { 0.1, 0.5, 0.1, 1 }
triple_back_color = { 0.1, 0.9, 0.1, 1 }
side_color = { 0.5, 1, 1, 1 }
spread_color = { 0.6, 0, 0.6, 1 }
homing_color = { 0.9, 0.2, 0.9, 1 }
blast_color = { 0.6, 0.6, 0.9, 1 }
spin_color = { 0.9, 0.6, 0.6, 1 }
bounce_color = { 0.6, 0.9, 0.6, 1 }
ray_color = { 1, 0.6, 0.2, 1 }

default_colors = { default_color, hp_color, ammo_color, boost_color, skill_point_color }
negative_colors = {
    { 1 - default_color[1],     1 - default_color[2],     1 - default_color[3] },
    { 1 - hp_color[1],          1 - hp_color[2],          1 - hp_color[3] },
    { 1 - ammo_color[1],        1 - ammo_color[2],        1 - ammo_color[3] },
    { 1 - boost_color[1],       1 - boost_color[2],       1 - boost_color[3] },
    { 1 - skill_point_color[1], 1 - skill_point_color[2], 1 - skill_point_color[3] }
}
--[[negative_colors = {
    { 255 - default_color[1],     255 - default_color[2],     255 - default_color[3] },
    { 255 - hp_color[1],          255 - hp_color[2],          255 - hp_color[3] },
    { 255 - ammo_color[1],        255 - ammo_color[2],        255 - ammo_color[3] },
    { 255 - boost_color[1],       255 - boost_color[2],       255 - boost_color[3] },
    { 255 - skill_point_color[1], 255 - skill_point_color[2], 255 - skill_point_color[3] }
}]]

attacks = {
    ['Neutral'] = { cooldown = 0.54, ammos = 0, abbr = 'N', color = default_color },
    ['Rapid'] = {cooldown = 0.24, ammos = 1, abbr = 'R', color = rapid_color},
    ['Projectile'] = { cooldown = 0.34, ammos = 1, abbr = 'P', color = bullet_color },
    ['Double'] = { cooldown = 0.38, ammos = 2, abbr = '2', color = double_color },
    ['DoubleBack'] = { cooldown = 0.38, ammos = 2, abbr = '2B', color = double_back_color }, -- 2B, Ba
    ['Triple'] = { cooldown = 0.42, ammos = 3, abbr = '3', color = triple_color },
    ['TripleBack'] = { cooldown = 0.42, ammos = 3, abbr = '3B', color = triple_back_color },
    ['Side'] = { cooldown = 0.32, ammos = 2, abbr = 'Si', color = side_color },
    ['Spread'] = { cooldown = 0.36, ammos = 1, abbr = 'SR', color = spread_color }, -- RS, SR
    ['Homing'] = { cooldown = 1.26, ammos = 4, abbr = 'H', color = skill_point_color },
    ['Blast'] = { cooldown = 0.64, ammos = 0.5, abbr = 'W', color = blast_color },
    ['Flame'] = { cooldown = 0.28, ammos = 0.4, abbr = 'F', color = skill_point_color },
    ['Spin'] = { cooldown = 0.84, ammos = 2, abbr = 'Sp', color = spin_color },
    ['Bounce'] = { cooldown = 0.54, ammos = 2, abbr = 'Bn', color = bounce_color },
    ['2Split'] = { cooldown = 0.62, ammos = 1, abbr = '2S', color = ammo_color },
    ['LightningRay'] = { cooldown = 0.72, ammos = 1, abbr = 'LR', color = ray_color },
    ['LaserRay'] = { cooldown = 0.82, ammos = 1, abbr = 'Ls', color = ray_color }
}
enemies = {
    ['Rock'] = { hp = 50, abbr = 'N', color = bullet_color },
    ['BigRock'] = { hp = 150, abbr = 'B', color = bullet_color },
    ['Shooter'] = { hp = 100, abbr = 'R', color = shooter_color },
    ['Seeker'] = { hp = 200, abbr = 'S', color = seeker_color },
}
enemyAttacks = {
    ['Neutral'] = { cooldown = 0.54, ammos = 0, abbr = 'N', color = default_color },
    ['Rapid'] = { cooldown = 0.24, ammos = 1, abbr = 'R', color = rapid_color },
    ['Projectile'] = { cooldown = 0.34, ammos = 1, abbr = 'P', color = bullet_color },
    ['Double'] = { cooldown = 0.38, ammos = 2, abbr = '2', color = double_color },
    ['DoubleBack'] = { cooldown = 0.38, ammos = 2, abbr = 'Ba', color = double_back_color }, -- 2B
    ['Triple'] = { cooldown = 0.42, ammos = 3, abbr = '3', color = triple_color },
    ['TripleBack'] = { cooldown = 0.42, ammos = 3, abbr = '3B', color = triple_back_color },
    ['Side'] = { cooldown = 0.32, ammos = 2, abbr = 'Si', color = side_color },
    ['Spread'] = { cooldown = 0.36, ammos = 1, abbr = 'RS', color = spread_color }
}

function love.conf(t)
    --t.identity = nil                    -- The name of the save directory (string)
    --t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.version = "11.4"                    -- The LÖVE version this game was made for (string)
    --t.console = false                   -- Attach a console (boolean, Windows only)
    --t.accelerometerjoystick = true      -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    --t.externalstorage = false           -- True to save files (and read from the save directory) in external storage on Android (boolean)
    --t.gammacorrect = false              -- Enable gamma-correct rendering, when supported by the system (boolean)

    --t.audio.mic = false                 -- Request and use microphone capabilities in Android (boolean)
    --t.audio.mixwithsystem = true        -- Keep background music playing when opening LOVE (boolean, iOS and Android only)

    t.window.title = "BytekTron - v1.0"  -- The window title (string)
    t.window.icon = "logo.png"            -- Filepath to an image to use as the window's icon (string)
    t.window.width = gw                   -- The window width (number)
    t.window.height = gh                  -- The window height (number)
    --t.window.borderless = false         -- Remove all border visuals from the window (boolean)
    t.window.resizable = true             -- Let the window be user-resizable (boolean)
    --t.window.minwidth = 1               -- Minimum window width if the window is resizable (number)
    --t.window.minheight = 1              -- Minimum window height if the window is resizable (number)
    --t.window.fullscreen = false         -- Enable fullscreen (boolean)
    --t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.vsync = true                 -- Vertical sync mode (number)
    t.window.fsaa = 0                     -- The number of samples to use with multi-sampled antialiasing (number)
    --t.window.msaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)
    --t.window.depth = nil                -- The number of bits per sample in the depth buffer
    --t.window.stencil = nil              -- The number of bits per sample in the stencil buffer
    --t.window.display = 1                -- Index of the monitor to show the window in (number)
    --t.window.highdpi = false            -- Enable high-dpi mode for the window on a Retina display (boolean)
    --t.window.usedpiscale = true         -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
    t.window.srgb = false                 -- Enable sRGB gamma correction when drawing to the screen (boolean)
    --t.window.x = nil                    -- The x-coordinate of the window's position in the specified display (number)
    --t.window.y = nil                    -- The y-coordinate of the window's position in the specified display (number)

    t.modules.audio = true    -- Enable the audio module (boolean)
    t.modules.data = true     -- Enable the data module (boolean)
    t.modules.event = true    -- Enable the event module (boolean)
    t.modules.font = true     -- Enable the font module (boolean)
    t.modules.graphics = true -- Enable the graphics module (boolean)
    t.modules.image = true    -- Enable the image module (boolean)
    t.modules.joystick = true -- Enable the joystick module (boolean)
    t.modules.keyboard = true -- Enable the keyboard module (boolean)
    t.modules.math = true     -- Enable the math module (boolean)
    t.modules.mouse = true    -- Enable the mouse module (boolean)
    t.modules.physics = true  -- Enable the physics module (boolean)
    t.modules.sound = true    -- Enable the sound module (boolean)
    t.modules.system = true   -- Enable the system module (boolean)
    t.modules.thread = true   -- Enable the thread module (boolean)
    t.modules.timer = true    -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = true    -- Enable the touch module (boolean)
    t.modules.video = false    -- Enable the video module (boolean)
    t.modules.window = true   -- Enable the window module (boolean)
end

tree = require "objects.basics.Tree"

function treeToPlayer(_tree, player, bought_node_indexes)
    for _, index in ipairs(bought_node_indexes) do
        local stats = _tree[index].stats
        for i = 1, #stats, 3 do
            local attribute, value = stats[i + 1], stats[i + 2]
            player[attribute] = player[attribute] + value
        end
    end
end

function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s -- en conf.lua
end

input = nil
rooms = nil
camera = nil
fonts = {}
slow_amount = 1    -- ralentización del tiempo de update
flash_frames = nil -- relampaguear la pantalla n segundos
first_run_ever = false
with_borders = false

-- ralentiza el tiempo, para efectos llamados de forma global desde gameobjects
function slow(timer, amount, duration)
    slow_amount = amount
    -- Timer:tween(delay, subject, target, method, after, tag, ...)
    -- timer:tween('slow', duration, _G, { slow_amount = 1 }, 'in-out-cubic')
    timer:tween(duration, _G, { slow_amount = 1 }, 'in-out-cubic', nil, 'slow')
end

-- la pantalla relampaguea durante n segundos
function flash(frames)
    flash_frames = frames
end

Sounds = nil

achievements = {
    ["IntroScreen [1] Complete"] = false,
    ["IntroScreen [2] Complete"] = false,
    ["IntroScreen [3] Complete"] = false,
    ["IntroScreen [4] Complete"] = false,
    ['10K Fighter'] = false,      -- 10k puntos en Player.points cuando Player.ship.type = "Fighter"
    ['2 Cycles Fighter'] = false, -- 2 ciclos en Player.cycles cuando Player.ship.type = "Fighter"
    _10k = false,                 -- 50k score en Room
    _20k = false,                 -- 50k score en Room
    _30k = false,                 -- 50k score en Room
    _50k = false,                -- 50k score en Room
    _60k = false,                -- 50k score en Room
    _70k = false,                -- 50k score en Room
    _80k = false,                -- 50k score en Room
    _90k = false,                -- 50k score en Room
    ["10 Attacks"] = false,
    ["1 Stage Complete"] = false
}
achievements_description = {
    ['10K Fighter'] = "10k puntos en Player.points cuando Player.ship.type = 'Fighter'",
    ['2 Cycles Fighter'] = "2 ciclos en Player.cycles cuando Player.ship.type = 'Fighter'",
    _10k = "10k score en Room",
    _20k = "20k score en Room",
    _30k = "30k score en Room",
    _50k = "50k score en Room",
    _60k = "60k score en Room",
    _70k = "70k score en Room",
    _80k = "80k score en Room",
    _90k = "90k score en Room",
    ["10 Attacks"] = "primeros 10 Attacques conseguidos en la misma pantalla",
    ["1 Stage Complete"] = "Completar la primera Pantalla al 100%"
}

-- Establece la clave de "achievements" como lograda, siempre y cuando se cumpla la condición pasada
function achs(key, cond)
    if not achievements[key] and cond then
        print("-ACHIEVEMENTS: '" .. key .. "'", cond)
        achievements[key] = true
        -- Do whatever else that should be done when an achievement is unlocked
        Sounds.play("action3")
    end
end

Shapes = ShapePolygons

-- shipName = "Fighter, Master, Medium, Tulip, Crusader"
ships = {
    Fighter = true,
    Master = false,
    Medium = false,
    Tulip = false,
    Crusader = false
}
ship_selected = "Fighter"
ship_cost = 50 -- 50 sp

loadedData = {}

-- borra todos los logros (achievements, skills, ships, ..)
-- CUIDADO ! También se pierden todos los puntos gastados.
function _delData()
    print("deleting data ..")
    local globalsData = { "slow_amount", "gw", "gh", "sx", "sy", "minZoom", "maxZoom", "ship_selected", "ship_cost",
        "with_borders" }
    local save_data = {}
    -- resetea y guarda achievements
    for key, _ in pairs(achievements) do
        --print("SAVE-ACHIEVEMENTS", key, achievements[key])
        achievements[key] = false
        save_data[key] = achievements[key] --value
    end
    -- resetea algunas globales y las guarda
    ships = {
        Fighter = true,
        Master = false,
        Medium = false,
        Tulip = false,
        Crusader = false
    }
    ship_selected = "Fighter"
    bought_node_indexes = {1}
    save_data["bought_node_indexes"] = bought_node_indexes
    for i = 1, #globalsData do
        local key = globalsData[i]
        save_data[key] = _G[key]
        --print("SAVE3: ", key, save_data[key])
    end
    loadedData = save_data
    bitser.dumpLoveFile('save', save_data)
end

-- guardar datos en la global "loadedData"
function saveData(data)
    if (data) then
        --[[print(#data)
        for i = 1, #data do
            print(data[i])
        end]]
        for key, value in pairs(data) do
            --print(key, value)
            loadedData[key] = data[key] --value
        end
    end
end
-- guardar datos en C:\Users\user\AppData\Roaming\[GAME_NAME]  
-- al mismo tiempo guarda variables globales, o todas (nil), o las indicadas
function save(data, globalsData)
    print("saving data ..")
    if(globalsData == nil)then
        globalsData = { "slow_amount", "gw", "gh", "sx", "sy", "minZoom", "maxZoom", "ship_selected", "ship_cost",
            "with_borders" }
    end
    local save_data = {}
    -- Set all save data here: 
    if (data == nil) then
        data = loadedData
    end
    -- guarda el resto de variables pasadas (de forma estructurada por claves y valores)
    --[[print(#data)
    for i = 1, #data do
        print(data[i])
    end]]
    -- además guarda las pasadas por parámetro (puede sobreescibir "achievements")
    for key, _ in pairs(data) do
        --print(key, value)
        save_data[key] = data[key] --value
        --print("SAVE2: ", key, save_data[key])
    end
    -- guarda achievements
    for key, _ in pairs(achievements) do
        --print("SAVE-ACHIEVEMENTS", key, achievements[key])
        save_data[key] = achievements[key] --value
    end
    -- guarda las globales (puede sobreescibir algunas como "ship_selected")
    for i = 1, #globalsData do
        local key = globalsData[i]
        save_data[key] = _G[key]
        --print("SAVE3: ", key, save_data[key])
    end
    --print("SAVE: ship_selected", save_data.ship_selected, data.ship_selected, ship_selected)
    --print("SAVE:achievements[_10k]", achievements["_10k"])
    --print("SAVE:save_data[_10k]", save_data["_10k"])
    --print(utils.dump(save_data))
    bitser.dumpLoveFile('save', save_data)
end
-- cargar datos de C:\Users\user\AppData\Roaming\[GAME_NAME]\save  
-- al mismo tiempo puede actualizar variables globales con los valores guardados.
function load(globalsData)
    print("loading data ..")
    local info = love.filesystem.getInfo("save", "file")
    local loaded_data = nil
    --if love.filesystem.exists('save') then
    if info.size > 0 then
        loaded_data = bitser.loadLoveFile('save')
        if(loaded_data)then
            -- Load all saved data here
            -- skill_points = save_data.skill_points
            --slow_amount = loaded_data.slow_amount
            -- da valor a las globales
            if(globalsData)then
                for i = 1, #globalsData do
                    local key = globalsData[i]
                    -- si existe en las globales y en las guardadas
                    if ((_G[key] or (_G[key] == false)) and (loaded_data[key] or (loaded_data[key] == false))) then
                        _G[key] = loaded_data[key]
                    end
                end
            end
            -- También actualiza la global "achievements"
            for key, _ in pairs(achievements) do
                --print("LOAD-ACHIEVEMENTS-1", key, value)
                -- si existe la clave en "loadedData" la copia a "achievements"
                if (loaded_data[key] or (loaded_data[key] == false)) then
                    --print("LOAD-ACHIEVEMENTS-2", key, loaded_data[key])
                    achievements[key] = loaded_data[key] --value
                end
            end

            if(loaded_data["ships"])then
                ships = loaded_data["ships"]
            end
            --print("LOAD:achievements[_10k]", achievements["_10k"])
        end
    else
        first_run_ever = true
    end
    --print("LOAD: ship_selected", loaded_data.ship_selected)
    return loaded_data
end

-- lee las variables almacenadas y actualiza las globales guardadas (también "achievements")
loadedData = load({ "slow_amount", "gw", "gh", "sx", "sy", "minZoom", "maxZoom", "ship_selected", "ship_cost",
    "with_borders" })

--print(utils.dump(loadedData))

--shoot_sound = nil
--sounds = nil