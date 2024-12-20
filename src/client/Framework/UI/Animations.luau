local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
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

function module.GeneralEffects.Shake(Instance: GuiObject)
    if ShakeTasks[Instance] then
        task.cancel(ShakeTasks[Instance])
    end

    ShakeTasks[Instance] = task.spawn(function()
        Spr.target(Instance, 0, 4, {Rotation = 15})
        task.wait(0.15)
        Spr.target(Instance, 0, 4, {Rotation = 0})
        task.wait(0.4)
        Spr.target(Instance, 0.5, 3, {Rotation = 0})

        ShakeTasks[Instance] = nil
    end)
end

return module