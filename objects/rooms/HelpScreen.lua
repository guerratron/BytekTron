if (_G["HelpScreen"]) then
    return _G["HelpScreen"]
end
local Room         = require "objects.rooms.Room"

local HelpScreen = Room:extend()

local Input        = require("_LIBS_.boipushy.Input")
local Timer        = require("_LIBS_.chrono.Timer")
local utils        = require "tools.utils"

local txts         = {
    -- GUIA="que se ocupan de recopilar los valiosos recursos llegados del firmamento"
    --      "sabotaje consiguió sustraerles una *nave básica*, pero perdió muchos de sus"
    {
        title = " · INTRO: ",
        lines = {
            "Todas las pantallas se acceden desde la Consola [ventana de comandos]. ",
            "También el juego en sí a través del comando 'start'. ",
            "",
        }
    },
    {
        title = " · COMANDOS ",
        lines = {
            "Los comandos más relevantes son los siguientes: ",
            "",
            "  - cmd : muestra el command.com de esta consola.",
            "  - ver : versión del command.com",
            "  - vol : el volúmen (ficticio), algo como 'C:>'",
            "  - hello : algunos créditos",
            --"  - ? : sorpresa !",
            "  - pause : pausa la consola hasta pulsar una tecla cualquiera.",
            "  - del : borra los avances logrados. Los puntos gastados se PIERDEN.",
            "  - exit : sale guardando todos los avances.",
            "  - escape : sale SIN guardar.",
            "  - cls : borra la consola.",
            --"  - dir : muestra un listado de archivos de ejemplo.",
            "  - help : muestra esta ayuda.",
            "  - readme : visualiza el archivo Readme.md (MUY INTERESANTE)",
            "  - intro : la ventana de introducción (MUY INTERESANTE)",
            "  - start : INICIA EL JUEGO ",
            "  - skill : muestra el mapa de habilidades para comprar",
            "  - ach : ventana de logros",
            "  - ship : ventana de selección de naves para comprar",
            "  - borders : habilita / deshabilita los bordes en las ventanas.",
            "  - procss : cuenta los procesadores del sistema",
            "  - exec : comando MUY POTENTE. Muestra el 'cmd' del S.O.",
            "  - pwinfo : información de la batería",
            "  - date : fecha del sistema",
            "  - os : sistema operativo [S.O.]",
            "  - clipb : muestra el último texto copiado en el clipboard",
            "  - google : abre el navegador",
            "  - love : abre la página web www.love2d.com",
            "  - res : permite cambiar la resolución de la pantalla del juego."
        }
    },
    {
        title = " · TECLAS ESPECIALES: ",
        lines = {
            "Aparte de los comandos reconocidos (más de 20), existen ciertas teclas ",
            "especiales para la interacción con el usuario. Algunas actúan como ",
            "comandos invisibles, otras como teclas de dirección, ... También el  ",
            "ratón se permite en ciertas pantallas para seleccionar objetos o pulsar ",
            "botones.",
            "Por regla general, las teclas sensibles actúan de la siguiente manera: ",
            "",
            "  - F1 = Captura instantánea de consumo de recursos en depuración",
            "  - F2 = Cierra la Room actual y regresa a la Console (sin guardar ",
            "avances)",
            "  - F3 = En Rooms con players cierra y regresa a la Console (guardando ",
            "avances) [en realidad asesina al player]",
            "  - F4 = ... igual al anterior pero asesina el área del player",
            "  - F5 = Aceptar-Exit, Regresa a Console o si ya está en Console sale ",
            "del juego",
            "  - F8 [~F2] = Finish-Start, Finaliza la Room, regresa a Console (sin ",
            "guardad avances), pero (a diferencia de F2) si ya está en 'Console' ",
            "entonces inicia el juego diréctamente. (dentro de la partida regresa ",
            "a Console GUARDANDO) ",
            "  - escape = Cancelar, Regresa al menú principal Console (botón 'CANCELAR')",
            "si está en Console SALE SIN GUARDAR.",
            "  - backspace = borra caracteres en campos de entrada de texto (En ",
            "Console-InputLineModule)",
            "  - enter [return] = Acepta texto en campos de entrada (En Console-",
            "InputLineModule), en otras pantallas es el botón 'ACEPTAR'",
            "  - [+, -] = Zoom (in-out) en Console, Skill, y otras",
            "  - up-down = Controles del Player (en ciertas pantallas 'desplazador')",
            "  - ... = Otras posibles teclas se transmiten a través de 'love.textinput'"
        }
    },
    {
        title = "",
        lines = {}
    },
    {
        title = "",
        lines = {"* Los avances del juego se guardan en la carpeta de salvado del S.O."}
    },
    {
        title = "",
        lines = {}
    },
    {
        title = "",
        lines = {}
    },
    {
        title = "                   'El Planeta BytekTron'",
        lines = { "", "                 .. by GuerraTron24 <dinertron@gmail.com> .." }
    }
}

function HelpScreen:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index = 1,
        _id = utils.UUID(),
        _type = "HelpScreen",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        --input = Input()
    }
    HelpScreen.super.new(self, true, pars)

    self._type = "HelpScreen"
    self.type = "HelpScreen"
    self.font = fonts.m5x7_16
    self.fontTitle = love.graphics.newFont(16)
    self.fontLines = love.graphics.newFont(12)
    self.input = self.input or opts.input or Input()

    self.logo = love.graphics.newImage('assets/bytektron_logo_micro.png')

    -- arrastrar la cámara
    self.input:bind('mouse1', 'left_click')
    self.camera:setBounds(-gw / 2, -gh / 2, gw / 2, gh / 2)
    self.lastX, self.lastY = 0, 0
    self.relX, self.relY = 0, 0
    self.min_cam_x, self.min_cam_y = -gw / 2, -gh / 2
    self.max_cam_x, self.max_cam_y = gw / 2, gh / 2
    -- cámara zoom
    self.incr = 0.2
    self.input:bind('+', 'zoom_in')
    self.input:bind('-', 'zoom_out')
end

function HelpScreen:destroy()
    if (self.camera) then
        --self.camera.detach()
        self.camera = nil
    end
    if (self.main_canvas) then
        love.graphics.setCanvas() -- por si acaso, regresa al canvas principal
        self.main_canvas = nil
    end
    if (self.font) then
        self.font = nil
    end
    HelpScreen.super.destroy(self)
end

function HelpScreen:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    --NO SE ACTUALIZA LA ROOM PADRE PORQUE NO TIENE ÁREAS QUE ACTUALIZAR
    -- Arrastrar la cámara
    if self.input:pressed('left_click') then
        self.lastX, self.lastY = utils.getMouseXY(self.camera)
    end
    if self.input:released('left_click') then
        --[[local condX1 = self.camera.x > self.min_cam_x
        local condX2 = self.camera.x < self.max_cam_x
        local condY1 = self.camera.y > self.min_cam_y
        local condY2 = self.camera.y < self.max_cam_y
        if(condX1 and condX2 and condY1 and condY2)then]]
        local lim = false
        if (self.camera.x < self.min_cam_x) then
            self.camera.x = self.min_cam_x; lim = true
        end
        if (self.camera.y < self.min_cam_y) then
            self.camera.y = self.min_cam_y; lim = true
        end
        if (self.camera.x > self.max_cam_x) then
            self.camera.x = self.max_cam_x; lim = true
        end
        if (self.camera.y > self.max_cam_y) then
            self.camera.y = self.max_cam_y; lim = true
        end
        if (not lim) then
            local lX, lY = self.lastX, self.lastY --self.camera.x, self.camera.y
            self.lastX, self.lastY = utils.getMouseXY(self.camera)
            self.relX = self.camera.x + (self.lastX - lX) / self.camera.scale
            self.relY = self.camera.y + (self.lastY - lY) / self.camera.scale
            --print(lX, lY, self.lastX, self.lastY)
            --self.camera:move((self.lastX - lX) / self.camera.scale, (self.lastY - lY) / self.camera.scale)
            self.timer:tween(0.2, self.camera,
                {
                    x = self.relX,
                    y = self.relY
                },
                'in-out-cubic', 'move'
            )
        end
    end
    -- zoom de la cámara
    if self.input:pressed('zoom_in') then
        self.timer:tween(0.2, self.camera, { scale = self.camera.scale + self.incr }, 'in-out-cubic', 'zoom')
    end
    if self.input:pressed('zoom_out') then
        self.timer:tween(0.2, self.camera, { scale = self.camera.scale - self.incr }, 'in-out-cubic', 'zoom')
    end

    -- CRONÓMETRO MORTAL
    if (self.max_time) then
        if (self.max_time) then
            self.total_time = self.total_time + dt
        end
        if (self.total_time > self.max_time) then
            --self.timer:after(1.5, function()
            --"IntroScreen [1] Complete"
            --if (not achievements["IntroScreen [4] Complete"]) then
            --    if (not self.rooms) then return false end
            --    self.rooms:toNewRoom("Splash:Intro", self.camera, { rooms = self.rooms, timer = self.timer })
            --else
            self:finish()
            --end
            --end)
            self.total_time = 0
            return false
        end
    end

    return true
end

-- dibuja el título de la pantalla
function HelpScreen:drawTitle(txt, x, y)
    -- FONDO
    love.graphics.setColor({ 0.2, 0.2, 0.2, 0.7 })
    love.graphics.rectangle("fill", x - 75, y - self.font:getHeight(), 150, self.font:getHeight() * 2)
    local font = love.graphics.newFont(24) --self.font
    love.graphics.setFont(font)
    love.graphics.setColor(title_color)
    txt = txt or self.type
    -- TITLE
    local w, h = font:getWidth(txt), font:getHeight()
    love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
end

function HelpScreen:drawLogo(x, y)
    love.graphics.draw(self.logo, x, y, 0)--, sx / 16, sy / 16)
end

function HelpScreen:drawTxts()
    local x, y = 10, 10
    local w, h = 50, self.font:getHeight()
    local sepH, sepV = 1, 1
    --print(self.type, "Achievements->dump(achievements)")
    --print(utils.dump(achievements))
    for _, txt in ipairs(txts) do
        w = math.floor(self.font:getWidth(txt.title)) * 2
        y = y + h + sepV
        love.graphics.setColor(hp_color)
        love.graphics.setFont(self.fontTitle)
        love.graphics.print(txt.title, x, y, 0, 1, 1)
        y = y + h * 2 + sepV
        for _, line in ipairs(txt.lines) do
            w = math.floor(self.font:getWidth(line)) * 2
            love.graphics.setColor(default_color)
            love.graphics.setFont(self.fontLines)
            love.graphics.print(line, x, y, 0, 1, 1)
            y = y + h + sepV
            --local w, h = font:getWidth(txt), font:getHeight()
            --love.graphics.print(txt, x, y, 0, 1, 1, math.floor(w / 2), math.floor(h / 2))
        end
    end
    --[[if (self.complete_the_readme) then
        love.graphics.setColor(hp_color)
        love.graphics.setFont(self.fontTitle)
        love.graphics.print("README END", gw/2, self.max_slideY + 100, 0, 1, 1)
    end]]
end

function HelpScreen:draw()
    if (not self.camera) then return false end
    --NO SE DIBUJA LA ROOM PADRE PORQUE NO TIENE ÁREAS QUE ACTUALIZAR
    -- inner-canvas
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    self.camera:attach(0, 0, gw, gh)
    self:drawTxts()
    self.camera:detach()
    love.graphics.setFont(self.font)
    self:drawLogo(gw * 0.75, 0)
    self:drawTitle(self.type, gw / 2, 10)
    love.graphics.setCanvas()

    -- outer-canvas
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    return true
end

function HelpScreen:textinput(t)
    -- SALTAR LA SPLASH
    if (t == "f5" or t == "return" or t == "escape" or t == "scape" or t == "space" or t == " ") then
        self:finish()
        self:destroy()
    elseif (t == "down") then
        self.relY = self.camera.y + self.font:getHeight() / self.camera.scale
        --print(lX, lY, self.lastX, self.lastY)
        --self.camera:move((self.lastX - lX) / self.camera.scale, (self.lastY - lY) / self.camera.scale)
        self.timer:tween(0.2, self.camera, { y = self.relY }, 'in-out-cubic', 'move')
    elseif (t == "up") then
        self.relY = self.camera.y - self.font:getHeight() / self.camera.scale
        --print(lX, lY, self.lastX, self.lastY)
        --self.camera:move((self.lastX - lX) / self.camera.scale, (self.lastY - lY) / self.camera.scale)
        self.timer:tween(0.2, self.camera, { y = self.relY }, 'in-out-cubic', 'move')
    end
end

return HelpScreen