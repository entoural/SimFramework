local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility = require(Shared.Utility)
local Spr = require(Packages.Spr)

local Offsets = {BackX = Vector2.new(-1, 0), FrontX = Vector2.new(1, 0)}
local TweenInfos = {
    SlowLinear = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
    ExponentialOnce = TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
}

local module = {}
module.GradientAnimations = {}

type Axis = "X" | "Y"

function module.GradientAnimations.HoverStay(Gradient: UIGradient, TweenInfo: TweenInfo): Tween
    Gradient.Offset = Offsets.BackX

    local Goal = {Offset = Offsets.FrontX}
    local Tween = TweenService:Create(Gradient, TweenInfo or TweenInfos.SlowLinear, Goal)
    Tween:Play()

    return Tween
end

function module.GradientAnimations.LoopedSpin(Gradient: UIGradient, TweenInfo: TweenInfo?, Axis: Axis?, WaitBetween: number?): Tween
    local StartOffset = Offsets["Back".."X" or Axis]
    local EndOffset = Offsets["Front".."X" or Axis]

    Gradient.Offset = StartOffset
    local Goal = {Offset = EndOffset}
    local Tween = TweenService:Create(Gradient, TweenInfo or TweenInfos.ExponentialOnce, Goal)

    Tween.Completed:Connect(function(playbackState)
        Gradient.Offset = StartOffset
        task.wait(WaitBetween or 2.5)
        Tween:Play()
    end)
    Tween:Play()

    return Tween
end

module.GeneralEffects = {}

local ShakeTasks = {}

function module.GeneralEffects.Shake(Instance: GuiObject, Speed: number)
    Speed = Speed or 1

    if ShakeTasks[Instance] then
        task.cancel(ShakeTasks[Instance])
    end

    ShakeTasks[Instance] = task.spawn(function()
        Spr.target(Instance, .3, 3 * Speed, {Rotation = -20})
        task.wait(.2 / Speed)
        Spr.target(Instance, .1, 2 * Speed, {Rotation = 0})
        task.wait(3 / Speed)
        Spr.target(Instance, 1.2, 4 * Speed, {Rotation = 0})

        ShakeTasks[Instance] = nil
    end)
end

function module.GeneralEffects.SwayLoop(Instance: GuiObject, Speed: number, RotationRange: number)
    Speed = Speed or 1
    Instance.Rotation = -(RotationRange or 15)
    local Goal = {Rotation = RotationRange or 15}
    local Tween = TweenService:Create(Instance, TweenInfo.new(2 / Speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), Goal)

    Tween:Play()

    return Tween
end

local BurstTasks = {}

function module.GeneralEffects.Burst(Instance: GuiObject, Multi: number?, BackTo: number?)
    local Scale = Utility.EnsureUIScale(Instance)
    local OriginalScale = Scale.Scale

    if BurstTasks[Instance] then
        task.cancel(BurstTasks[Instance])
    end

    BurstTasks[Instance] = task.spawn(function()
        Spr.target(Scale, .5, 5, {Scale = Multi or 1.15})
        task.wait(.1)
        Spr.target(Scale, .5, 5, {Scale = BackTo or 1})
        task.wait(.2)

        BurstTasks[Instance] = nil
    end)
end

return module