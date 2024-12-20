local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Library = require(ReplicatedStorage:WaitForChild("Shared").Library)
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local Spr = require(Packages.Spr)
local Camera = require(script.Parent.Parent.Parent.Camera)

local Effect = Instance.new("ImageLabel")
Effect.Image = "rbxassetid://126920850081338"
Effect.BackgroundTransparency = 1
Effect.ZIndex = -1
Effect.ImageTransparency = 1
Effect.Parent = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")

local Blur = Lighting:WaitForChild("Blur")

return function(Instance: GuiObject)
    local Source = Vide.source(false)
    local _Janitor = Janitor.new()

    local Attribute = Instance:GetAttribute("ThemeColor")
    local Color = if Attribute then Attribute else Library.GameThemeColor
    local Scale = Instance:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", Instance)
    local OriginalPosition = Instance.Position
    local ClosedPosition = UDim2.fromScale(OriginalPosition.X.Scale, OriginalPosition.Y.Scale - 0.2)

    Vide.effect(function()
        local Opened = Source()
        _Janitor:Cleanup()

        _Janitor:Add(task.spawn(function()
            Spr.stop(Effect)
            Spr.stop(Blur)

            Spr.target(Instance, 0.7, 4, {Position = if Opened then OriginalPosition else ClosedPosition})
            Spr.target(Scale, 0.7, 4, {Scale = if Opened then 1 else 0.8})
            Spr.target(Effect, 1, 4, {ImageTransparency = if Opened then 0 else 1, ImageColor3 = Color})
            Spr.target(Blur, 1, 4, {Size = 3})
            Camera.AdjustFOV(80)
        end))
    end)

    return Source
end