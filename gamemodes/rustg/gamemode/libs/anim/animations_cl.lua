Anim = Anim or {}



local c1 = 1.70158

local c3 = c1 + 1

local c4 = (2 * math.pi) / 3



function Anim.Bounce(x)

    if (x > 0.5) then

        return math.sin(x*math.pi)*0.5

    else

        return math.sin(x*math.pi*-2+-math.pi)

    end

end



function Anim.InOut(x)

    return math.sin(math.rad(x * math.pi))

end



function Anim.EaseInBack(x)

    return c3 * x * x * x - c1 * x * x

end



function Anim.EaseOutBack(x)

    return 1 + c3 * (x - 1)^3 + c1 * (x - 1)^2

end



function Anim.EaseOutElastic(x)

    if (x == 0) then

        return 0

    elseif (x == 1) then

        return 1

    end



    return 2^(-10 * x) * math.sin((x * 10 - 0.75) * c4) + 1

end



function Anim.EaseInElastic(x)

    if (x == 0) then

        return 0

    elseif (x == 1) then

        return 1

    end



    return -(2^(-10 * x)) * math.sin((x * 10 - 0.75) * c4) + 1

end