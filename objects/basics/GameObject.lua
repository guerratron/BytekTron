if (_G["GameObject"]) then
    return _G["GameObject"]
end

-- Cualquier objeto actualizable del juego. El área se encargará de actualizarlos y dibujarlos, 
-- también de eliminarlos llamando a su método ".kill()".  
-- Muchos de ellos necesitarán otros parámetros que se le pasarán en ".opts", sobre todo un 
-- parámetro ".parent" y las coordenadas ".x, .y".  
-- Otros parámetros pueden ser: 
--[[
    ```lua
    {
        parent = self,  -- el objeto padre, algunas veces necesario para obtener propiedades o métodos suyos.
        x = self.x,     -- coordenadas
        y = self.y,     -- coordenadas
        depth = 75,     -- para el orden de dibujado, capas, solapado, .. (por defecto = 50)
        timer = Timer() -- cada gameobject debe tener su propio temporizador o compartirlo ??
        live = 0.12,    -- Si es mayor de "0" se cuentan esas centésimas de cuadro antes de "autodestruirse"
        ... pueden existir otros en función del tipo de gameobject: color, numEff, d, r, ...
    }
    ```
]]
-- Necesita Timer y UUID
local GameObject = Object:extend()

local Timer = require("_LIBS_.chrono.Timer")
--local Timer = require("_LIBS_.hump.timer")
local Utils = require("tools.utils")

function GameObject:new(area, x, y, opts)
    self.type = "GameObject"
    opts = opts or {}
    if opts then for k, v in pairs(opts) do self[k] = v end end

    --self.parent = area -- en las opciones
    self.area = area -- referencia al área madre
    self.parent = opts.parent
    self.x, self.y = x, y
    self.id = opts.id or Utils.UUID()
    --Necesita que se le pase un índice a través de las opciones [self.index]
    self.dead = false -- al pasarlo a "true", debe encargarse el ".area" de eliminarlos llamando al método ".kill()"
    self.depth = opts.depth or 50 -- para el orden de dibujado (capas, unos encima de otros, las más altas por encima)
    self.visible = true
    self.hit_flash = false
    --self.type = opts.type or "Neutral"

    --self.creation_time = opts.creation_time or os.time() -- en caso de igualdad de profundidades (.depth) para el orden de dibujado, y destrucción.
    -- los gameobjects deben tener su propio temporizador
    --self.timer = opts.timer or (self.parent and self.parent.timer) or (self.area and self.area.timer) or Timer()
    self.innerTimer = false
    self.timer = opts.timer or (self.parent and self.parent.timer) or (self.area and self.area.timer)
    if (not self.timer) then
        self.timer = Timer()
        self.innerTimer = true
    end
    self.cont = 0 -- inicio del contador (incrementos de 0.01). Se utiliza conjuntamente con ".live" para controlar la "autodestrucción".
    -- Si se desea destruir por tiempo se debe pasar opts.live en miliseg. (> 0)
end

function GameObject:kill()
    self.dead = true
    self.visible = false
    self:destroy()
end
function GameObject:destroy()
    --if self.timer and self.timer.destroy then self.timer:destroy() end
    -- solo destruye el timer si lo ha creado él
    if (self.innerTimer and self.timer) then
        if self.timer.destroy then self.timer:destroy() end
    end
    self.timer = nil
    if self.collider and self.collider.destroy then self.collider:destroy() end
    self.collider = nil
    --self:notify("destroy")
    --[[if(self.area and self.index)then
        self.area:remove(self.index)
    end]]
    self.parent = nil
    self.area = nil
    -- remate, anula TODO
    -- for k, _ in pairs(self) do self[k] = nil end
end

--[[function GameObject:receive(what)

end
function GameObject:notify(what)
    self.parent:receive({
        who = self,
        type = self._type,
        what = what
    })
end]]

function GameObject:update(dt)
    if(self.live and (self.live > 0))then
        if(self.cont >= self.live)then
            self:kill()
        end
        self.cont = self.cont + 0.01
    end
    --if self.dead or not self.visible then return end
    if self.dead then return end
    --if ((self.timer) and (not self.dead)) then self.timer:update(dt) end
    --if self.timer then self.timer:update(dt) end
    if(self.parent)then
        self.x, self.y = self.parent.x, self.parent.y
    else
        if self.collider then self.x, self.y = self.collider:getPosition() end
    end
end

function GameObject:draw()
    local result = true
    if self.dead or not self.visible then result = false end
    return result
end

return GameObject