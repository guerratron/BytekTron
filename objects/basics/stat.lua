if (_G["Stat"]) then
    return _G["Stat"]
end

-- Objeto para incrementar/decrementar variables multiplicadoras como "aspd_multiplier".  
-- USO:  
--[[
    ```lua
    function Player:new(...)
        ...
        
        self.aspd_multiplier = Stat(1)
    end

    function Player:update(dt)
        ...
    
        if self.inside_haste_area then self.aspd_multiplier:decrease(100) end
        if self.aspd_boosting then self.aspd_multiplier:decrease(100) end
        self.aspd_multiplier:update(dt)
    
        ...
    end
    ```
]]
Stat = Object:extend()

function Stat:new(base)
    self.base = base

    self.additive = 0
    self.additives = {}
    self.value = self.base * (1 + self.additive)
end

function Stat:update(dt)
    for _, additive in ipairs(self.additives) do self.additive = self.additive + additive end

    if self.additive >= 0 then
        self.value = self.base * (1 + self.additive)
    else
        self.value = self.base / (1 - self.additive)
    end

    self.additive = 0
    self.additives = {}
end

function Stat:increase(percentage)
    table.insert(self.additives, percentage * 0.01)
end

function Stat:decrease(percentage)
    table.insert(self.additives, -percentage * 0.01)
end

return Stat