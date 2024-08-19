if (_G["SplashScreen"]) then
    return _G["SplashScreen"]
end

local Room = require "objects.rooms.Room"

local SplashScreen = Room:extend()

local Timer       = require("_LIBS_.chrono.Timer")
local utils       = require "tools.utils"

function SplashScreen:new(_camera, opts)
    opts = opts or {}
    local pars = {
        _index =  1,
        _id = utils.UUID(),
        _type = "SplashScreen",
        timer = opts.timer,
        rooms = opts.rooms,
        camera = _camera,
        imgFondoPath = opts.imgFondoPath
    }
    SplashScreen.super.new(self, true, pars)
    self._type = "SplashScreen"
    self.type = "SplashScreen"
    self.camera = _camera
    self.camera.x = gw / 2
    self.camera.y = gh / 2
    self.imgFondoPath = opts.imgFondoPath or "promo/img/bytektron_splash.png"
    self.imgFondo = love.graphics.newImage(self.imgFondoPath)
    
    -- se reutiliza pars para el siguiente elemento
    pars._id = utils.UUID()
    pars._type = "Area"
    pars.timer = self.timer          --nil --Timer()-- su propio timer ??
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.font = fonts.m5x7_16

    -- control a través de tiempo.
    -- Si se especifica "max_time" se pasa a limitar la partida a un máximo de tiempo
    self.max_time = 3
    self.total_time = 0

    self.paused = false
    self.visible = true

    --self.scale = 1
    --love.graphics.scale(0.2)
    self.camera.scale = 0.2
    self.handler1 = self.timer:tween(2, self.camera, { scale = 1 }, 'in-out-back', 'auto-scale')
    --[[self.timer:after(2, function()
        if (self.dead) then return end
        self.handler1 = self.timer:tween(2, self.camera, { scale = 1 }, 'in-out-back', 'auto-scale')
    end)]]
end

function SplashScreen:destroy()
    if(self.handler1)then
        self.timer:cancel(self.handler1)
    end
    if (self.camera) then
        --self.camera.detach()
        self.camera = nil
    end
    if(self.main_canvas)then
        love.graphics.setCanvas() -- por si acaso, regresa al canvas principal
        self.main_canvas = nil
    end
    if (self.font) then
        self.font = nil
    end
    SplashScreen.super.destroy(self)
end

function SplashScreen:drawFondoImg()
    love.graphics.draw(self.imgFondo, 0, 0, 0, 1, 1)
    --love.graphics.draw(self.imgFondo, 0, 0, 0, self.scale, self.scale)
end

function SplashScreen:update(dt)
    if (self.paused or self.dead) then return false end
    if (not self.current) then return false end
    --NO SE ACTUALIZA LA ROOM PADRE PORQUE NO TIENE ÁREAS QUE ACTUALIZAR

    -- CRONÓMETRO MORTAL
    if(self.max_time)then
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

function SplashScreen:draw()
    if (not self.camera) then return false end
    --NO SE DIBUJA LA ROOM PADRE PORQUE NO TIENE ÁREAS QUE ACTUALIZAR
    -- inner-canvas
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        self.camera:attach(0, 0, gw, gh)
            self:drawFondoImg()
        self.camera:detach()
        love.graphics.setFont(self.font)
    love.graphics.setCanvas()

    -- outer-canvas
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
    return true
end

function SplashScreen:textinput(t)
    -- SALTAR LA SPLASH
    if (t == "f5" or t == "return" or t == "escape" or t == "scape" or t == "space" or t == " ") then
        self:finish()
    end
end

return SplashScreen