local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility  = require(Shared.Utility)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)
local Types = require(script.Parent.Types)
local Animations = require(script.Parent.Parent.Animations)
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local Signal = require(Packages.Signal)


return function(Button: Types.Button)
    local Instance = Button.Instance
    local _Janitor = Janitor.new()

    local Scale = Utility.EnsureUIScale(Instance)

    local Hovering = false
    local First = true
    Vide.effect(function()
        Hovering = Button.Hovered()
        if First then
            First = false
            return
        end

        Spr.target(Instance.UIScale, 0.6, 5, {Scale = if Hovering then 1.1 else 1})
    end)

    Button.Clicked:Connect(function()
        _Janitor:Add(task.spawn(function()
            Spr.target(Scale, 0.4, 5, {Scale = 0.85})
            task.wait(0.15)
            Spr.target(Scale, 0.4, 5, {Scale = if Hovering then 1.1 else 1})
        end), true, "Click")
    end)
end