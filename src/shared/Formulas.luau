local Formulas = {}

function Formulas.GetRebirthModifiers(Rebirth: number): (number, number, number)
    local SpeedMultiplier = math.clamp(Rebirth * .2, 0, 1) + 1
    local ScoreMultiplier = (Rebirth / 10 + 1) ^ 1.2
    local MinimumScore = 100000 * Rebirth ^ 1.5

    return SpeedMultiplier, ScoreMultiplier, MinimumScore
end

return Formulas