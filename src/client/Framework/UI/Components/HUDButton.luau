local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility  = require(Shared.Utility)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)
local Types = require(script.Parent.Types)
local Animations = require(script.Parent.Parent.Animations)
local Vide = require(Packages.Vide)
local Signal = require(Packages.Signal)


return function(Button: Types.Button)
    local Icon = Button:FindFirstChild("Icon")

    Utility.RootedEffect(function(Destructor)
        local Hovered = Button.Hovered()

        if Hovered then
            Spr.target(Button.Instance.UIScale, 0.6, 4, {Scale = 1})
        else
            Spr.target(Button.Instance.UIScale, 0.6, 4, {Scale = 1.3})
        end

        Animations.GeneralEffects.Shake(Icon)
    end)
end