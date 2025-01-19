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
    local Instance = Button.Instance
    local Icon = Instance:FindFirstChild("Icon")

    local Scale = Utility.EnsureUIScale(Instance.Icon)

    local Hovered = false
    local Clicking = false
    local First = true
    Vide.effect(function()
        Hovered = Button.Hovered()

        if First then
            First = false
            return
        end

        if Clicking then
            return
        end

        if Hovered then
            Spr.target(Scale, 0.6, 4, {Scale = 1.2})
            Animations.GeneralEffects.Shake(Icon, 4)
        else
            Spr.target(Scale, 0.6, 4, {Scale = 1})
        end
    end)

    local Debounce = false
    Button.Clicked:Connect(function()
        if Debounce then
            return
        end

        Clicking = true
        Spr.target(Scale, 0.6, 4, {Scale = 0.9})
        task.wait(0.1)
        Spr.target(Scale, 0.6, 4, {Scale = if Hovered then 1.2 else 1})
        Clicking = false
    end)
end