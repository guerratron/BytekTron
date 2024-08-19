if (_G["utils"]) then
    return _G["utils"]
end
-- from: https://stackoverflow.com/questions/1426954/split-string-in-lua
local function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end
-- mejorada (solo un carácter separador)
local function _split(inputstr, sep)
    sep = sep or '%s'
    local t = {}
    for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
        table.insert(t, field)
        if s == "" then return t end
    end
    --[[
    local i = 1
    if (text) then
        for c in text:gmatch('.') do
            self.str[i] = c
            i = i + 1
        end
    end
    ]]
end

-- From: https://github.com/a327ex/blog/issues/16

-- Construye un listado de archivos dentro de una carpeta 
-- y los almacena en un objeto tabla "file_list".  
-- Util para cargar archivos assets (image, sound, ..).  
-- Permite especificar el tipo de archivo a indizar.
local function _recursiveEnumerate(folder, file_list, type)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local ext = item:sub(-4):lower()
        if ((item ~= ".") and (item ~= "..")) then
            local file = folder .. '/' .. item
            local infoTable = {}
            local infoFile = love.filesystem.getInfo(file, nil, infoTable)
            --if love.filesystem.isFile(file) then
            if ((infoFile.type == "file") or (infoTable.type == "file")) then
                if ((not type) or (ext == type:lower())) then
                    table.insert(file_list, file)
                end
            --elseif love.filesystem.isDirectory(file) then
            elseif ((infoFile.type == "directory") or (infoTable.type == "directory")) then
                _recursiveEnumerate(file, file_list, type)
            end
        end
    end
end

-- Incluye ("require") todos los archivos (".lua") de una carpeta.  
-- Utiliza internamente "_recursiveEnumerate(..)".
local function _requireLuaFolder(folder)
    local file_list = {}
    _recursiveEnumerate(folder, file_list, ".lua")
    for _, item in ipairs(file_list) do
        local name = item:sub(1, -5) -- elimina ".lua"
        require(name)
    end
end
-- mejorada la _requireLuaFolder(..) para uso GLOBAL
-- realiza "require" sobre todos los archivos ".lua" existentes en un directorio 
-- (y todos sus subdirectorios) importándolos con su nombre de archivo.
-- Por ejemplo, para un archivo "Circle.lua" en el interior de una carpeta "shapes":  
-- ```lua
--    requireFiles("shapes")  
--    local circle = Circle(10, 10, 10)
-- ```  
-- IMPORTANTE: Sólo funcionará si el nombre del archivo es igual al nombre de clase deseada !
-- Y solo cargará los que no sobreescriban una Global, osea los que no hayan sido cargados ya.
local function _requireLuaFolder2(folder)
    local file_list = {}
    _recursiveEnumerate(folder, file_list, ".lua")
    for _, filepath in ipairs(file_list) do
        local fp = filepath:sub(1, -5) --sin ext (elimina ".lua")
        local parts = _split(fp, "/") -- ó "." ??
        local class = parts[#parts]
        --print(filepath, fp, class)
        if(not _G[class])then
            _G[class] = require(fp)
        end
    end
end

-- from: https://github.com/a327ex/blog/issues/48
local function _probandoTimers()
    --SIMPLE TIMER
    local timer_current = 0
    local timer_delay = 5
    function update(dt)
        timer_current = timer_current + dt
        if timer_current > timer_delay then
            -- do the thing
        end
    end

    --AFTER (+TAG +REPETEABLE +FINISH + LOOP)
    local timers = { tag = { current_time = 0, delay = 5, action = function() end, repeatable = 0, finish = function() end}}
    --[[
        Temporizador "AFTER" que ejecuta una acción tras una espera especificada. (Utiliza una tabla "timers" global)  
        Otros parámetros serán cuantas veces se repite, una acción de finalización y una etiqueta.  
        ```
        local a = after(0.04, function() print("after") end, 25, function() print("after-end") end, 'just_hit')
        for _, timer in ipairs(timers) do  
            -- update after timer  
            update_after_timers(dt)
        end  
        ```
        La función en sí sólo almacena las propiedades y métodos, será en la actualización (update) cuando se lleve 
        a cabo el trabajo duro.
    ]]
    function after(delay, action, repeatable, finish, tag)
        timers[tag] = {current_time = 0, delay = delay, action = action, repeatable = repeatable, finish = finish}
    end
    function update_after_timers(dt)
        for tag, timer in pairs(timers) do
            timer.current_time = timer.current_time + dt
            if timer.current_time > timer.delay then
                if timer.action then timer.action() end
                if timer.repeatable then
                    if type(timer.repeatable) == 'number' then
                        timer.repeatable = timer.repeatable - 1
                        if timer.repeatable >= 0 then
                            timer.current_time = 0
                        else
                            timers[tag] = nil
                        end                    -- this timer is done, destroy it
                    else
                        timer.current_time = 0
                    end
                else
                    if(timer.finish)then timer.finish() end
                end
            end
        end
    end

    --
end

--local random = math.random
--[[local function _UUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end]]

-- alguna cadena única como esta: '123e4567-e89b-12d3-a456-426655440000'
local function _UUID()
    --math.randomseed(os.time())
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

-- Obtiene un número aleatorio entre dos números cualesquiera
local function _random(min, max)
    local mn, mx = min or 0, max or 1
    return (mn > mx and (love.math.random() * (mn - mx) + mx)) or (love.math.random() * (mx - mn) + mn)
end

-- elimina el/los item/items de un array que cumplan una condición dada como una función.  
-- A esta función se le entregarán dos parámetros (index, item) y se llamará en cada elemento y si retorna "true" se eliminará.  
-- por ejemplo: function (index, item) return (index >2) end
local function _itemDelete(arr, condition)
    for i = #arr, 1, -1 do
        if(condition(i, arr[i]))then
            table.remove(arr, i)
        end
    end
end

-- FROM: https://github.com/a327ex/blog/issues/19  
-- Retorna fugas de memoria. Utilizar con:  
--[[
    ```lua
    input:bind('f1', function()
        print("Before collection: " .. collectgarbage("count") / 1024) -- Mbt
        collectgarbage()
        print("After collection: " .. collectgarbage("count") / 1024) -- Mbt
        print("Object count: ")
        local counts = checkMEM()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end)
    ```
]]
local function _checkMEM()
    local global_type_table = nil
    local function type_name(o)
        if global_type_table == nil then
            global_type_table = {}
            for k, v in pairs(_G) do
                global_type_table[v] = k
            end
            global_type_table[0] = "table"
        end
        return global_type_table[getmetatable(o) or 0] or "Unknown"
    end

    local function count_all(f)
        local seen = {}
        local count_table
        count_table = function(t)
            if seen[t] then return end
            f(t)
            seen[t] = true
            for k, v in pairs(t) do
                if type(v) == "table" then
                    count_table(v)
                elseif type(v) == "userdata" then
                    f(v)
                end
            end
        end
        count_table(_G)
    end

    local function type_count()
        local counts = {}
        local enumerate = function(o)
            local t = type_name(o)
            counts[t] = (counts[t] or 0) + 1
        end
        count_all(enumerate)
        return counts
    end

    return type_count()
end

local function _showMEM()
    local before = collectgarbage("count") / 1024
    print("- Before collection (Mb): " .. before)     -- Mbt
    collectgarbage()
    local after = collectgarbage("count") / 1024
    print("- After collection (Mb): " .. after)
    print("- Diff (Mb): " .. before - after)
    before, after = nil, nil
    print("- Object count: ")
    local counts = _checkMEM()
    for k, v in pairs(counts) do print("- ", k, v) end
    print("-------------------------------------")
end

-- retorna aleatoriamente un elemento cualquiera de la tabla
local function _tableRandom(t)
    return t[love.math.random(1, #t)]
end
-- Retorna una nueva tabla con la mezcla de las dos pasadas.  
-- Si se entrega "deep = true" se tratarán los valores internos 
-- como posibles tablas de forma RECURSIVA. Esto sirve para que la 
-- tabla entregada no tenga referencias de la original.
local function _tableMerge(t1, t2, deep)
    local new_table = {}
    if(deep)then
        for k, _ in pairs(t1) do
            local val = t1[k]
            if(type(t1[k]) == "table")then
                val = _tableMerge(val, {})
            end
            new_table[k] = val
        end
        for k, _ in pairs(t2) do
            local val = t2[k]
            if (type(t2[k]) == "table") then
                val = _tableMerge(val, {})
            end
            new_table[k] = val
        end
    else
        for k, v in pairs(t1) do new_table[k] = t1[k] end
        for k, v in pairs(t2) do new_table[k] = t2[k] end
    end
    --for k, v in pairs(t1) do new_table[k] = v end
    return new_table
end
-- Añade/modifica las claves/valores de la tabla 2 a la 1.  
-- también retorna la tabla 1
local function _tableAddTable(t1, t2)
    for k, v in pairs(t2) do t1[k] = v end
    return t1
end
-- comprueba si existe un valor (sencillo) en una tabla
local function _tableExists(t, val)
    local result = false
    for k, v in pairs(t) do
        if(v == val or t[k] == val)then result = true end
    end
    return result
end
-- cuenta las claves en una tabla asociativa (con "pairs")
local function _tablePairsCount(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    --print(#t, count)
    return count
end
-- repite un texto x veces  
-- Para no pasarnos en el BUCLE, se ha limitado a un máximo de 1000 multiplicaciones.
local function _repeat(text, num)
    if (num > 1000) then return text .. " ... " end
    local txt = text
    for i=1, num do
        txt = txt .. txt
    end
    return txt
end

-- Necesita un temporizador como: [hump.timer](http://hump.readthedocs.io/en/latest/timer.html)
local function _typewrite(text, delay, timer)
    
end

-- Dumpea una variable para visualizar HUMANAMENTE sus resultados (al estilo de PHP.dump(txt)), 
-- mostrando su valor y tipo.  
-- En caso de tablas mostrando además su clave-índice y número de elmentos (AL FINAL), todo ello de 
-- forma tabulada.    
-- Posiblemente se salte valores NIL, o se comporte de manera extraña.  
-- NO tiene porqué mostrar todos los valores en el mismo orden que estén en la tabla original.  
-- Al ser una función RECURSIVA, se ha limitado a un máximo de 100 registros.  
-- DE TODAS FORMAS CUIDADO AL PASAR OBJETOS CON REFERENCIAS CRUZADAS...  
-- PUEDE PROVOCAR "FREEZER" del S.O.  
-- SÓLO SIRVE PARA OBJETOS PEQUEÑOS.  
-- ejemplo: 
--[[
    ```lua
    print(utils.dump({ bool = true, "hola", 23, nil, nulo=nil, boost_color, math }))
    ```
]]
local function _dump(t, txt, level)
    local cont = 0
    txt = txt or ""
    if(t == nil)then return txt .. " {NIL} " end
    level = level or 0
    if(level > 100)then return txt .. " ... " end
    local tab = _repeat("\t", level)
    if type(t) == "string" then
        txt = txt .. "{STRING}"
        txt = txt .. "\t'" .. t .. "'"
    elseif type(t) == "number" then
        txt = txt .. "{NUMBER}"
        txt = txt .. "\t" .. t
    elseif type(t) == "boolean" then
        local txtV = "false"
        if(t)then txtV = "true" end
        txt = txt .. "{BOOLEAN}"
        txt = txt .. "\t" .. txtV
    elseif type(t) == "function" then
        txt = txt .. "{FUNCTION}"
        txt = txt .. "\t [f(..)]"
    elseif type(t) == "userdata" then
        txt = txt .. "{USERDATA}"
        --f(v)
        txt = txt .. "\t [userdata]"
    --elseif type(t) == "nil" then
    elseif not t then
        txt = txt .. "{NIL}"
        txt = txt .. "\t "
    elseif type(t) == "table" then
        --print("{TABLE}", t[1], t[2], 2)
        --txt = txt .. "{BEGIN:TABLE}\n"
        --txt = txt .. tab .. "{TABLE}\n"
        --txt = txt .. "(#" .. #t .. ")"
        --if(#t == 0)then txt = txt .. tab .. "(#" .. #t .. ")" end
        for k, v in pairs(t) do
            cont = cont + 1
            if k == nil then k = " " end
            txt = txt .. tab .. "[" .. k .. "] = "
            if (type(v) == "table") then
                txt = txt .. "{TABLE}"-- (#" .. #v .. ")"
                level = level + 1
                --if(level > 1)then tab = "\t" end
                txt = _dump(v, txt .. "\n", level)
                level = level - 1
                tab = _repeat("\t", level)
            elseif type(v) == "string" then
                txt = txt .. "{STRING}"
                txt = txt .. "\t'" .. v .. "'"
            elseif type(v) == "number" then
                txt = txt .. "{NUMBER}"
                txt = txt .. "\t" .. v
            elseif type(v) == "boolean" then
                local txtV = "false"
                if(v)then txtV = "true" end
                txt = txt .. "{BOOLEAN}"
                txt = txt .. "\t" .. txtV
            elseif type(v) == "function" then
                txt = txt .. "{FUNCTION}"
                txt = txt .. "\t [f(..)]"
            elseif type(v) == "userdata" then
                txt = txt .. "{USERDATA}"
                --f(v)
                txt = txt .. "\t [userdata]"
            --elseif type(v) == "nil" then
            elseif not t then
                txt = txt .. "{NIL}"
                txt = txt .. "\t "
            else
                txt = txt .. "{VALUE}"
                txt = txt .. "\t" .. v
            end
            txt = txt .. "\n"
        end
        --txt = txt .. "{END:TABLE}\n"
        txt = txt .. tab .. "((#" .. cont .. "))"
    else
        txt = txt .. "?"
    end
    return txt
end

-- genera y retorna posibilidades aleatoriamente pero proporcionadas desde una tabla
--[[
    --PROBAR CON: 
    events = Utils.chanceList({ 'X', 5 }, { 'Y', 5 }, { 'Z', 10 })
    for i = 1, 40 do
        print(events:next()) --> will print X 10 times, Y 10 times and Z 20 times
    end
    --DEBERÍA SALIR: X=10, Y=10, Z=20 VECES DE FORMA ALEATORIA
]]
local function _chanceList(...)
    return {
        chance_list = {},
        chance_definitions = { ... },
        next = function(self)
            if #self.chance_list == 0 then
                for _, chance_definition in ipairs(self.chance_definitions) do
                    for i = 1, chance_definition[2] do
                        table.insert(self.chance_list, chance_definition[1])
                    end
                end
            end
            return table.remove(self.chance_list, love.math.random(1, #self.chance_list))
        end
    }
end

-- crea una barra proporcional con dos textos, uno superior con el título y otro inferior con las cantidades
-- necesita la fuente a utilizar, el texto (título), su posición (x, y), un número o cantidad inicial variable,
-- otro número que represente el total, el color de la barra + textos  y por último la posibilidad de invertir la 
-- posición del título con las cantidades.
-- Por ejemplo, para representar la HP de un gameobject:
-- ```lua
-- _textBar(self.font, "HP", gw / 2 - 52, gh - 16, self.player.hp, self.player.max_hp, hp_color)
-- ```
local function _textBar(font, text, x, y, num, total, color, invert)
    -- bar
    local r, g, b = unpack(color)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle('fill', x, y, 48 * (num / total), 4)
    --love.graphics.setColor(r - 32, g - 32, b - 32)
    love.graphics.setColor(r - 0.1, g - 0.1, b - 0.1)
    love.graphics.rectangle('line', x, y, 48, 4)
    -- texts
    local function _txt(txt, _x, _y)
        love.graphics.print(txt,
            _x, _y,
            0, 1, 1,
            math.floor(font:getWidth(txt) / 2),
            math.floor(font:getHeight() / 2)
        )
    end
    local posY1 = y - 6
    local posY2 = y + 8
    if(invert)then
        posY1 = y + 8
        posY2 = y - 6
    end
    -- text Sup.
    _txt(text, x + 24, posY1)
    -- text Inf.
    _txt(num .. " / " .. total, x + 24, posY2)
end

local function _distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

-- comprueba si un objeto se cruza o está contenido en la perimetral de un cuadrado  
-- el objeto debe tener accesible su posición (x, y) y tamaño (w, h) y el cuadrado sus 
-- vértices opuestos (x1, y1, x2, y2)
--[[```lua
local function _inSquare1(obj, square)
    local result = false
    local wO, hO = obj.w, obj.h
    if(((obj.x + wO) > square.x1) and (obj.x < square.x2))then
        if (((obj.y + hO) > square.y1) and (obj.y < square.y2)) then
            result = true
        end
    end
    return result
end
```]]
local function _inSquare(obj, square)
    local result = true
    -- Rectángulo 1 con esquina superior izquierda en (x1,y1) ancho w1 y alto h1
    -- Rectángulo 2 con esquina superior izquierda en (x2,y2) ancho w2 y alto h2
    -- primero ordenamos
    local x1, x2 = math.min(square.x1, square.x2), math.max(square.x1, square.x2)
    local y1, y2 = math.min(square.y1, square.y2), math.max(square.y1, square.y2)
    local wR, hR = x2 - x1, y2 - y1
    if ( obj.x > x1 + wR ) then result = false end
    if ( obj.x + obj.w < x1 ) then result = false end
    if ( obj.y > y1 + hR ) then result = false end
    if (obj.y + obj.h < y1) then result = false end
    return result
end
-- comprueba la intersección entre dos círculos: x, y, r
local function _inCircle(cir1, cir2)
    local result = false
    -- círculo 1 con centro en (cx1,cy1) y radio r1
    -- círculo 2 con centro en (cx2,cy2) y radio r2
    if (_distance(cir1.x, cir1.y, cir2.x, cir2.y) < cir1.r + cir2.r ) then
        result = true
    end
end
-- grados a radianes
local function _toRad(grad) return grad * math.pi / 180 end
-- radianes a grados
local function _toGrad(rad) return rad * 180 / math.pi end
-- radianes a grados normalizados (de 0 a 360 sin signo)
local function _toGradNormalized(rad) return (math.abs(_toGrad(rad)) % 360) end

-- crea un polígono irregular
local function _createIrregularPolygon(size, point_amount)
    local points = {}
    point_amount = point_amount or 8
    for i = 1, point_amount do
        local angle_interval = 2 * math.pi / point_amount
        local distance = size + _random(-size / 4, size / 4)
        local angle = (i - 1) * angle_interval + _random(-angle_interval / 4, angle_interval / 4)
        table.insert(points, distance * math.cos(angle))
        table.insert(points, distance * math.sin(angle))
    end
    return points
end

-- obtiene las coordenadas de la posición del ratón en función de la cámara activa
-- necesitamos las globales "gw, gh, sx y sy" además de la cámara
local function _getMouseXY(camera)
    local dx, dy = camera:toCameraCoords(camera:getMousePosition(sx, sy, 0, 0, sx * gw, sy * gh))
    return gw / 2 - dx / sx, gh / 2 - dy / sy
end

---

local function _toParticles(imgName, x, y, speed)
    local logo = love.graphics.newImage(imgName)
    local _ps = love.graphics.newParticleSystem(logo)
    _ps:setEmissionRate(5)
    _ps:setParticleLifetime(2)
    _ps:setSpeed(speed)
    _ps:setColors({ 1, 1, 1, 1 }, { 1, 1, 1, 0 })
    _ps:setPosition(x, y)
    --ps:emit(20)
    _ps:start()
    return {
        ps = _ps,
        draw = function(self) love.graphics.draw(self.ps) end,
        update = function(self, dt)
            --[[if not love.mouse.getRelativeMode() and love.mouse.isDown(1) then
                --love.mouse.setCursor()
                self.ps:moveTo(love.mouse.getPosition())
            end]]
            self.ps:update(dt)
        end
    }
end

local function _toFramesSequences(_FS) -- FramesSequences
    _FS = _FS or function() return {draw = function () end, update = function () end} end
    return {
            FS = _FS({
            ui = {
                x = 10,
                y = 10,
                over = true
            },
            keyEvents = {
                record = "r",
                pause = "p",
                stop = "s",
                save = "g",
                test = "t",
            },
            -- fileType = "png",         -- para las imágenes
            -- fps = 60,                 -- útil para el guardado del video [default=60]
            -- video = true,             -- booleano para guardar vídeo en formato "mp4" u "ogg" [por defecto true en mp4]
            -- imgRemove = true,         -- si es "true" borrará las imágenes después de crear el vídeo [default=true]
            -- audioVideoRemove = true, -- Indica si borrar los archivos preliminares de audio y video generados antes de mezclar
            videoName = "out",
            -- videoFormat = "ogg",      -- mp4, ogg [ACORDE CON SU CODEC, default=mp4]
            -- videoCodec = "libtheora", -- mp4 = [libx264 | libx265], ogg = libtheora [default=libx264]
            audioName = "out",
            -- audioFormat = "wav",      -- wav decidido de forma temporal internamente [NO VA A JUEGO CON EL CODEC]
            audioCodec = "ac3",     -- ac3, flac, opus, mjpeg, wavpack, mp3, m4a [CODEC DEL AUDIO DENTRO DEL VÍDEO]
            samplerate = 16000,
            samplecount = 600000,
            bitdepth = 8,
            channels = 1,
        }),
        draw = function (self) self.FS:draw() end,
        update = function (self, dt) self.FS:update(dt) end
    }
end

-- retorna el array de líneas de puntos que dibujarán el marco o borde del rectángulo pasado
-- por ejemplo:
-- 
--[[
    ```lua
    -- {{5, 10, 25, 10}, {30, 20, 30, 40}, ...}
    local x, y, width, height = 0, 0, gw, gh
    local opts = {
        maxLinesX = 4,
        maxLinesY = 4,
        line_width = width * 0.05,
        line_height = height * 0.05,
        paddX = width * 0.05,
        paddY = height * 0.05,
        scaleX = sx,
        scaleY = sy,
        color = ammo_color
    }
    for _, line in ipairs(utils.borderLinesRect(3, 4, hp_color)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
    ```
]]
function _borderLinesRect(_x, _y, width, height, opts)
    opts = opts or {
        maxLinesX = 4,
        maxLinesY = 3,
        line_width = width * 0.05,
        line_height = height * 0.05,
        paddX = width * 0.05,
        paddY = height * 0.05,
        scaleX = sx,
        scaleY = sy,
        color = background_color
    }
    local lines = {}
    love.graphics.setColor(opts.color)
    --local line_width, line_height = gw * 0.05, gw * 0.05 -- 10% del ancho/alto total
    --local paddX, paddY = gw * 0.05, gh * 0.05
    local x, y = _x + opts.paddX/4, _y + opts.paddY/4 -- _x + opts.paddX, _y + opts.paddY
    local lineX, lineXor = x, x
    local lineY, lineYor = y, y
    --local numLinesX = math.floor(width / opts.line_width) / opts.scaleX * 2  -- elimina las que se salen de la pantalla
    --local numLinesY = math.floor(height / opts.line_height) / opts.scaleY * 2 -- elimina las que se salen de la pantalla
    local numLinesX = math.floor(width / opts.line_width) / 1 * 2   -- elimina las que se salen de la pantalla
    local numLinesY = math.floor(height / opts.line_height) / 1 * 2 -- elimina las que se salen de la pantalla
    opts.maxLinesX = opts.maxLinesX or numLinesX
    opts.maxLinesY = opts.maxLinesY or numLinesY
    if (numLinesX > opts.maxLinesX) then numLinesX = opts.maxLinesX end
    if (numLinesY > opts.maxLinesY) then numLinesY = opts.maxLinesY end
    --print(line_width, line_height, paddX, paddY, partsX, partsY) -- 48	48	24	13.5    10	5
    function _toBorder(_x, _y, lw, lh, pX, pY)
        lineX = _x
        lineY = _y
        for i = 1, numLinesX do
            table.insert(lines, { lineX, _y, lineX + lw, _y })
            lineX = lineX + lw + pX
        end
        for i = 1, numLinesY do
            table.insert(lines, { _x, lineY, _x, lineY + lh })
            lineY = lineY + lh + pY
        end
        lineX = lineXor
        lineY = lineYor
    end

    --_toBorder(lineX + width * 0.01, lineY + height * 0.01, opts.line_width, opts.line_height, opts.paddX, opts.paddY)
    --_toBorder(lineX + width * 0.99, lineY + height * 0.99, -opts.line_width, -opts.line_height, -opts.paddX, -opts.paddY)
    _toBorder(lineX, lineY, opts.line_width, opts.line_height, opts.paddX, opts.paddY)
    _toBorder(lineX + width * 0.98, lineY + height * 0.98, -opts.line_width, -opts.line_height, -opts.paddX, -opts.paddY)
    --print(utils.dump(lines))
    return lines
end

-- retorna el array de líneas de puntos que dibujarán el marco o borde de la pantalla
-- por ejemplo:
--
--[[
    ```lua
    -- {{5, 10, 25, 10}, {30, 20, 30, 40}, ...}
    for _, line in ipairs(utils.borderLinesScreen(3, 4, hp_color)) do
        love.graphics.line(line[1], line[2], line[3], line[4])
    end
    ```
]]
function _borderLinesScreen(maxLinesX, maxLinesY, color)
    local x, y, width, height = 0, 0, gw, gh
    local opts = {
        maxLinesX = maxLinesX,
        maxLinesY = maxLinesY,
        line_width = width * 0.05,
        line_height = height * 0.05,
        paddX = width * 0.05,
        paddY = height * 0.05,
        scaleX = sx,
        scaleY = sy,
        color = color or ammo_color
    }
    --print(utils.dump(lines))
    return _borderLinesRect(x, y, width, height, opts)
end

return {
    split = _split,
    recursiveEnumerate = _recursiveEnumerate,
    --requireLuaFolder = _requireLuaFolder,
    requireLuaFolder = _requireLuaFolder2,
    random = _random,
    UUID = _UUID,
    itemDelete = _itemDelete,
    checkMEM = _checkMEM,
    showMEM = _showMEM,
    tableRandom = _tableRandom,
    tableMerge = _tableMerge,
    tableAddTable = _tableAddTable,
    tableExists = _tableExists,
    tablePairsCount = _tablePairsCount,
    rep = _repeat,
    dump = _dump,
    chanceList = _chanceList,
    textBar = _textBar,
    distance = _distance,
    inSquare = _inSquare,
    inCircle = _inCircle,
    toRad = _toRad,
    toGrad = _toGrad,
    toGradNormalized = _toGradNormalized,
    createIrregularPolygon = _createIrregularPolygon,
    getMouseXY = _getMouseXY,
    toParticles = _toParticles,
    toFramesSequences = _toFramesSequences,
    borderLinesRect = _borderLinesRect,
    borderLinesScreen = _borderLinesScreen
}

-- obtener el ángulo desde fuente a objetivo:
-- angle = math.atan2(target.y - source.y, target.x - source.x)
