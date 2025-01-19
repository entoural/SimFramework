local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Utility = require(ReplicatedStorage:WaitForChild("Shared").Utility)
local Vide = require(Packages.Vide)
local Spr = require(Packages.Spr)
local ColorUtility = require(script.Parent.Parent.Color)
local Types = require(script.Parent.Types)

return function(Source: Types.HoverInteraction, Instance: GuiObject, Input: string)
    assert(Utility.AssertDependencies(Instance, {"UIGradient"}), `[ENT Framework Client] Couldn't find UIGradient inside {Instance.Name}`)

    local Color1 = Color3.fromHex(string.match(Input, 'Color1="(%x%x%x%x%x%x)"'))
    local Color2 = Color3.fromHex(string.match(Input, 'Color2="(%x%x%x%x%x%x)"'))

    local Darkened1, Darkened2 = ColorUtility.DarkenColor(Color1, Color2)
    local White = Color3.new(1, 1, 1)
    local WhiteRange = Instance.AbsoluteSize.Y / Instance.AbsoluteSize.X * 0.06
    --local WhiteRange = 10 / Instance.AbsoluteSize.Y * (Instance.AbsoluteSize.Y / Instance.AbsoluteSize.X)

    local Sequence = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Darkened1),
        ColorSequenceKeypoint.new(.5 - WhiteRange * 1.1, Color1),
        ColorSequenceKeypoint.new(.5 - WhiteRange, White),
        ColorSequenceKeypoint.new(.5 + WhiteRange, White),
        ColorSequenceKeypoint.new(.5 + WhiteRange * 1.1, Color2),
        ColorSequenceKeypoint.new(1, Darkened2),
    })

    local Gradient = Instance.UIGradient
    Gradient.Color = Sequence
    Gradient.Rotation -= 2
    Gradient.Enabled = true

    local Rotation = Gradient.Rotation
    local StartOffset = ColorUtility.RotationToOffset(Rotation, Vector2.new(0.25, 0))
    local EndOffset = ColorUtility.RotationToOffset(Rotation, Vector2.new(-0.2, 0))
    Gradient.Offset = StartOffset

    Vide.effect(function()
        local Hovered = Source()
        Spr.target(Gradient, 0.5, 3, {Offset = if Hovered then EndOffset else StartOffset})
    end)
end