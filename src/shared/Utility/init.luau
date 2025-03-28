local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Vide = require(Packages.Vide)
local Root = Vide.root
local Effect = Vide.effect

local Utility = {}

Utility.CameraShaker = require(script.CameraShaker)
Utility.Abbreviate = require(script.Abbreviate)
Utility.Clock = require(script.Clock)

function Utility.RootedEffect(Callback: (Destructor: () -> any) -> any)
    Root(function(Destructor)
        Effect(function()
            Callback(Destructor)
        end)
    end)
end

function Utility.Assert(Value: any, Message: string): nil
    if not Value then
        warn(Message)
    end
end

function Utility.Round(Number: number, Decimals: number?)
    local Power = 10 ^ (Decimals or 2)
    return math.floor(Number * Power + 0.5) / Power
end

function Utility.Percent(Number: number, Decimals: number)
    return Utility.Round(Number * 100, Decimals or 0).."%"
end

function Utility.EnsureUIScale(InstanceToCheck: Instance): UIScale
    local Scale = InstanceToCheck:FindFirstChild("UIScale")

    if Scale and Scale.Name ~= "UIScale" then
        Scale.Name = "UIScale"
    elseif not Scale then
        Scale = Instance.new("UIScale")
        Scale.Parent = InstanceToCheck
    end

    return Scale
end

function Utility.AssertDependencies(Instance: Instance, Dependencies: {string})
    for _, Dependency in Dependencies do
        if not Instance:FindFirstChild(Dependency) then
            return false
        end
    end

    return true
end

return Utility