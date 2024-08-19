if (_G["tree"]) then
    return _G["tree"]
end

-- Árbol de nodos de habilidad (SkillTree)
local tree = {
    { -- 1
        name = 'HP',
        type = 'Small',
        shape = "square",
        color = {1, 0.5, 0.5},
        x = 0,
        y = 0,
        stats = {
            -- Primero está la descripción visual de la estadística, 
            -- luego qué variable cambiará en el objeto Jugador y luego la cantidad de ese efecto
            '4% Increased HP', 'hp_multiplier', 0.04,
            '4% Increased Ammo', 'ammo_multiplier', 0.04
        },
        links = { 2 },
        sp = 5 -- costo en skill-points
    },
    { -- 2
        name = 'HP1',
        type = 'Medium',
        shape = "triangle",
        color = { 0.5, 1, 0.5 },
        x = 32,
        y = 0,
        stats = { '6% Increased HP', 'hp_multiplier', 0.02 },
        links = { 1, 3 },
        sp = 7 -- costo en skill-points
    },
    { -- 3
        name = 'Bs1',
        type = 'Medium',
        shape = "square",
        color = { 0.5, 0.5, 1 },
        x = 32,
        y = 32,
        stats = { '6% Increased Boost', 'boost_multiplier', 0.06 },
        links = { 2, 4 },
        sp = 8 -- costo en skill-points
    },
    { -- 4
        name = 'FHp1',
        type = 'Small',
        shape = "circle",
        color = { 0.6, 0.6, 0.8 },
        x = 64,
        y = 32,
        stats = { '6 uds Increased Flat HP', 'flat_hp', 6 },
        links = { 2, 3, 5 },
        sp = 10 -- costo en skill-points
    },
    {           -- 5
        name = 'FA1',
        type = 'Small',
        shape = "circle",
        color = { 0.6, 0.6, 0.8 },
        x = 96,
        y = 32,
        stats = { '6 uds Increased Flat Ammo', 'flat_ammo', 6 },
        links = { 4, 6 },
        sp = 10 -- costo en skill-points
    },
    {           -- 6
        name = 'FB1',
        type = 'Small',
        shape = "circle",
        color = { 0.6, 0.6, 0.8 },
        x = 128,
        y = 32,
        stats = { '6 uds Increased Flat Boost', 'flat_boost', 6 },
        links = { 5, 7 },
        sp = 10 -- costo en skill-points
    },
    {           -- 7
        name = 'AG1',
        type = 'Medium',
        shape = "square",
        color = { 1, 0.5, 1 },
        x = 128,
        y = 64,
        stats = { '8% Increased Ammo-Gain', 'ammo_gain', 0.08 },
        links = { 6, 8 },
        sp = 10 -- costo en skill-points
    },
    {          -- 8
        name = 'AG1',
        type = 'Small',
        shape = "triangle",
        color = { 1, 0.7, 0.7 },
        x = 128,
        y = 96,
        stats = { '6 seconds of invincible', 'invincible_time', 1 },
        links = { 7, 9 },
        sp = 12 -- costo en skill-points
    },
    {           -- 9
        name = 'AG1',
        type = 'Medium',
        shape = "circle",
        color = { 0.7, 0.7, 1 },
        x = 96,
        y = 64,
        stats = { 'x2 shoot-velocity (aspd) multiplier', 'aspd_multiplier', 1 },
        links = { 8, 10 },
        sp = 12 -- costo en skill-points
    },
    {           -- 10
        name = 'AG1',
        type = 'Small',
        shape = "square",
        color = ammo_color,
        x = 64,
        y = 96,
        stats = { '1 adding each sp', 'sp_adding', 1 },
        links = { 9, 11 },
        sp = 16 -- costo en skill-points
    },
    {           -- 11
        name = 'AG1',
        type = 'Medium',
        shape = "circle",
        color = ammo_color,
        x = 0,
        y = 96,
        stats = { 'x2 sp points', 'sp_multiplier', 1 },
        links = { 10, 12 },
        sp = 20 -- costo en skill-points
    },
    {           -- 12
        name = 'AG1',
        type = 'Small',
        shape = "square",
        color = ammo_color,
        x = 0,
        y = 64,
        stats = { '6.5 seconds of invincible', 'invincible_time', 0.5 },
        links = { 11, 13, 14 },
        sp = 25 -- costo en skill-points
    },
    {           -- 13
        name = 'AG1',
        type = 'Medium',
        shape = "triangle",
        color = ammo_color,
        x = -96,
        y = 64,
        stats = { '7 seconds of invincible', 'invincible_time', 0.5 },
        links = { 12, 15 },
        sp = 40 -- costo en skill-points
    },
    {           -- 14
        name = 'AG1',
        type = 'Small',
        shape = "circle",
        color = ammo_color,
        x = -32,
        y = 32,
        stats = { 'x2 points multiplier', 'points_multiplier', 1 },
        links = { 12, 22 },
        sp = 90 -- costo en skill-points
    },
    {           -- 15
        name = 'AG1',
        type = 'Small',
        shape = "circle",
        color = ammo_color,
        x = -96,
        y = 0,
        stats = { '6 sg for 90º proyectile', 'projectile_ninety_degree_time', 1 },
        links = { 13, 16 },
        sp = 22 -- costo en skill-points
    },
    {           -- 16
        name = 'AG1',
        type = 'Small',
        shape = "circle",
        color = ammo_color,
        x = -96,
        y = -32,
        stats = { '6.5 sg for 90º proyectile', 'projectile_ninety_degree_time', 0.5 },
        links = { 15, 17 },
        sp = 26 -- costo en skill-points
    },
    {           -- 17
        name = 'AG1',
        type = 'Medium',
        shape = "square",
        color = ammo_color,
        x = -128,
        y = -64,
        stats = { '1.5 adding each sp', 'sp_adding', 0.5 },
        links = { 16, 18 },
        sp = 32 -- costo en skill-points
    },
    {           -- 18
        name = 'AG1',
        type = 'Small',
        shape = "square",
        color = ammo_color,
        x = -64,
        y = -96,
        stats = { 'x3 sp points', 'sp_multiplier', 1 },
        links = { 17, 19, 24 },
        sp = 46 -- costo en skill-points
    },
    {           -- 19
        name = 'AG1',
        type = 'Small',
        shape = "square",
        color = ammo_color,
        x = -64,
        y = -64,
        stats = { '7 sg for 90º proyectile', 'projectile_ninety_degree_time', 0.5 },
        links = { 18, 20 },
        sp = 50 -- costo en skill-points
    },
    {           -- 20
        name = 'AG1',
        type = 'Medium',
        shape = "circle",
        color = ammo_color,
        x = 0,
        y = -64,
        stats = { '2 adding each sp', 'sp_adding', 0.5 },
        links = { 19, 21, 27 },
        sp = 52 -- costo en skill-points
    },
    {           -- 21
        name = 'AG1',
        type = 'Small',
        shape = "circle",
        color = ammo_color,
        x = 0,
        y = -32,
        stats = { '10% Increased HP', 'hp_multiplier', 0.04 },
        links = { 20, 22 },
        sp = 56 -- costo en skill-points
    },
    {           -- 22
        name = 'AG1',
        type = 'Small',
        shape = "triangle",
        color = ammo_color,
        x = -32,
        y = -32,
        stats = { '20% plus to attacks count', 'attack_count_multiplier', 0.2 },
        links = { 21, 23 },
        sp = 75 -- costo en skill-points
    },
    {           -- 23 [SUB-FINAL 1]
        name = 'AG1',
        type = 'Medium',
        shape = "square",
        color = ammo_color,
        x = -64,
        y = 0,
        stats = { 'x3 points multiplier', 'points_multiplier', 1 },
        links = { 22 },
        sp = 110 -- costo en skill-points
    },
    {           -- 24
        name = 'AG1',
        type = 'Small',
        shape = "square",
        color = ammo_color,
        x = -32,
        y = -96,
        stats = { '10% Increased Boost', 'boost_multiplier', 0.04 },
        links = { 18, 25 },
        sp = 64 -- costo en skill-points
    },
    {           -- 25
        name = 'AG1',
        type = 'Small',
        shape = "circle",
        color = ammo_color,
        x = 64,
        y = -96,
        stats = { '10% Increased Flat HP', 'flat_hp', 0.04 },
        links = { 24, 26, 27 },
        sp = 68 -- costo en skill-points
    },
    {           -- 26
        name = 'AG1',
        type = 'Medium',
        shape = "circle",
        color = ammo_color,
        x = 128,
        y = -64,
        stats = { '12 uds Increased Flat Ammo', 'flat_ammo', 6 },
        links = { 25, 28 },
        sp = 92 -- costo en skill-points
    },
    {           -- 27
        name = 'AG1',
        type = 'Small',
        shape = "triangle",
        color = ammo_color,
        x = 64,
        y = -64,
        stats = { '12 uds Increased Flat Boost', 'flat_boost', 6 },
        links = { 25, 28 },
        sp = 100 -- costo en skill-points
    },
    {           -- 28 [FINAL]
        name = 'AG1',
        type = 'Medium',
        shape = "square",
        color = ammo_color,
        x = 96,
        y = -32,
        stats = { ' ** 1 minute of invincible ** ', 'invincible_time', 53 },
        links = { 26, 27 },
        sp = 200 -- costo en skill-points
    }
}

--[[
function treeToPlayer(_tree, player, bought_node_indexes)
    for _, index in ipairs(bought_node_indexes) do
        local stats = _tree[index].stats
        for i = 1, #stats, 3 do
            local attribute, value = stats[i + 1], stats[i + 2]
            player[attribute] = player[attribute] + value
        end
    end
end
]]

return tree