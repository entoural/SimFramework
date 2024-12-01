local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Vide = require(Packages.Vide)
local Root = Vide.root
local Effect = Vide.effect

local Utility = {}

function Utility.RootedEffect(Callback: (Destructor: () -> any) -> any)
    Root(function(Destructor)
        Effect(function()
            Callback(Destructor)
        end)
    end)
end

return Utility