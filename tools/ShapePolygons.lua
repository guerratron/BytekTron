if (_G["ShapePolygons"]) then
    return _G["ShapePolygons"]
end

local Mos             = require("_LIBS_.Moses.moses_min")
local utils           = require "tools.utils"

-- ancho/alto base
local _w = 20

local _ships = nil

-- vuelve a calcular las coordenadas en función del ancho de la nave
local function _makeShips(w)
    w = w or _w
    _ships = {
        Fighter = {
            {
                w, 0,       -- 1
                w / 2, -w / 2, -- 2
                -w / 2, -w / 2, -- 3
                -w, 0,      -- 4
                -w / 2, w / 2, -- 5
                w / 2, w / 2, -- 6
            },
            {
                w / 2, -w / 2,  -- 7
                0, -w,          -- 8
                -w - w / 2, -w, -- 9
                -3 * w / 4, -w / 4, -- 10
                -w / 2, -w / 2, -- 11
            },
            {
                w / 2, w / 2,  -- 12
                -w / 2, w / 2, -- 13
                -3 * w / 4, w / 4, -- 14
                -w - w / 2, w, -- 15
                0, w,          -- 16
            }
        },
        Master = {
            {
                w, 0,       -- 1
                0, -w / 4,  -- 2
                -w / 4, -3 * w / 4, -- 3
                -w / 2, 0,  -- 4
                -w / 4, 3 * w / 4, -- 5
                0, w / 4,   -- 6
            },
            {
                3 * w / 4, 3 * w / 8, -- 7
                w / 2, 3 * w / 4, -- 8
                0, 3 * w / 8, -- 9
            },
            {
                3 * w / 4, -3 * w / 8, -- 10
                w / 2, -3 * w / 4, -- 11
                0, -3 * w / 8,     -- 12
            }
        },
        -- 1 (w/4), 2 (w/2), 3 (3 * w/4), 4 (w)
        Medium = {
            {
                w, 0,       -- 1
                w / 4, -3 * w / 4, -- 2
                -3 * w / 4, -w / 2, -- 3
                w / 4, 0,   -- 4
                -3 * w / 4, w / 2, -- 5
                w / 4, 3 * w / 4, -- 6
            }
        },
        Tulip = {
            {
                -w / 2, 0,  -- 1
                0, -w,      -- 2
                -3 * w / 4, -w / 2, -- 3
                -w, 0,      -- 4
                -3 * w / 4, w / 2, -- 5
                0, w,       -- 6
            },
            {
                w, 0,      -- 7
                0, -w / 2, -- 8
                -3 * w / 4, 0, -- 9
                0, w / 2,  -- 10
            }
        },
        Crusader = {
            {
                -w / 4, 0,      -- 1
                w / 4, -3 * w / 4, -- 2
                -3 * w / 4, -3 * w / 4, -- 3
                -w, 0,          -- 4
                -3 * w / 4, 3 * w / 4, -- 5
                w/4, 3 * w / 4,   -- 6
            },
            {
                w, 0,    -- 7
                w / 4, -w / 2, -- 8
                -3 * w / 4, 0, -- 9
                w / 4, w / 2, -- 10
            }
        }
    }
    return _ships
end

_ships = _makeShips()

local function _getPoints(polygon, x, y)
    return Mos.map(polygon, function(v, k)
        if k % 2 == 1 then
            return x + v + utils.random(-1, 1)
        else
            return y + v + utils.random(-1, 1)
        end
    end)
end

-- shipName = "Fighter, Master, Medium, Tulip, Crusader"
local function _drawPolygons(shipName, x, y, w)
    _makeShips(w)
    for _, polygon in ipairs(_ships[shipName]) do
        -- draw each polygon here
        local points = _getPoints(polygon, x, y)
        love.graphics.polygon('line', points)
    end
end

return {
    ships = _ships,
    makeShips = _makeShips,
    getPoints = _getPoints,
    drawPolygons = _drawPolygons
}