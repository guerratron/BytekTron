local stages = {
    {
        id = 1,
        img = love.graphics.newImage('promo/img/intro1.png'),
        lines = {
            "----------",
            "Desde que llegaron los invasores ",
            "con su avanzada tecnologia y nos ",
            "dominaron, los 'Bytekis' tenemos ",
            "que refugiarnos en la ",
            "clandestinidad ...",
            "----------"
        },
        music = nil,
        director = true,
        area = true,
        until_time = 30 -- si se especifica nil no se detendrá por tiempo
    },
    {
        id = 2,
        img = love.graphics.newImage('promo/img/intro2.png'),
        lines = {
            "----------",
            "... esto tiene que acabar. ",
            "Necesito formar un reducido ",
            "grupo de valientes pilotos y ",
            "asi planear como apoderarnos ",
            "de sus poderosas naves.",
            "----------"
        },
        music = nil,
        director = true,
        area = true,
        until_time = 30
    },
    {
        id = 3,
        img = love.graphics.newImage('promo/img/intro3.png'),
        lines = {
            "----------",
            "Para eso debemos poco a poco ",
            "ir consiguiendo una rara ",
            "energia llamada 'sp' en forma ",
            "de cuadros amarillentos que la ",
            "adquirimos en luchas por la galaxia ...",
            " ",
            "Ayudanos a conseguir estos ",
            "'Skill-Points' para poder ",
            "hacernos con todas sus naves ..",
            "----------"
        },
        music = nil,
        director = true,
        area = true,
        until_time = 30
    },
    {
        id = 4,
        img = love.graphics.newImage('promo/img/intro4.png'), --nil,
        lines = {
            "----------",
            "En tus manos esta nuestro destino, ",
            "... El destino de los 'Bytekis' ..",
            "----------"
        },
        music = nil,
        director = false,
        area = true,
        until_time = 20
    }
}

return stages