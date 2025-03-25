local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)

local ModelTools = {}

function ModelTools.SpringModelScale(Model: Model, GoalSize: number, Period: number?, DampingRatio: number?)
    local SizeTarget = Vide.source(Model:GetScale())
    Vide.root(function(Destroy: () -> ())
        local SizeSpring = Vide.spring(SizeTarget, Period or 0.3, DampingRatio or 0.7)
        local LastCheck = false
        Vide.effect(function()
            Model:ScaleTo(SizeSpring())
            if SizeSpring() == GoalSize then
                if LastCheck then
                    Destroy()
                else
                    LastCheck = true
                end
            end
        end)
    end)
end

return ModelTools