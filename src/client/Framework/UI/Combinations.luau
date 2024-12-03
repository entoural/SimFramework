local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility = require(Shared.Utility)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)
local Janitor = require(Packages.Janitor)

local Color = require(script.Parent.Color)
local Animations = require(script.Parent.Animations)
local Modifiers = require(script.Parent.Modifiers)

local White = Color3.new(1, 1, 1)

local module = {}

function module.ShineGradient(AppliedInstance: Color.GradientAppliable, Delay: number?, CustomColor: Color3?)
    local AppliedColor = CustomColor or AppliedInstance.BackgroundColor3
    local Sequence = Color.ColorToShineSequence(Color.ColorToShineColors(AppliedColor))
    local Gradient = Color.ApplyGradient(AppliedInstance, Sequence, 30)

    return Animations.GradientAnimations.LoopedSpin(Gradient, nil, "X", Delay or 0)
end

function module.ShineImageGradient(AppliedInstance: Color.GradientAppliable, AnimationTime: number?, Delay: number?): RBXScriptConnection
    local _Janitor = Janitor.new()
    AnimationTime = AnimationTime or 3
    local Gray = Color3.new(0.65, 0.65, 0.65)
    local StartOffset = Vector2.new(0, 0)
    local RightOffset = Vector2.new(-0.75, 0)
    local LeftOffset = Vector2.new(0.55, 0)
    local StartGradient = ColorSequence.new(White)

    local KeypointPresets = {
        Start = ColorSequenceKeypoint.new(0, Gray),
        End = ColorSequenceKeypoint.new(1, Gray)
    }

    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = AppliedInstance

    local function Animate()
        _Janitor:Cleanup()

        local StartTime = os.clock()
        local LerpTime = (AnimationTime / 12)

        local StartTI = TweenInfo.new(AnimationTime / 6, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
        local EndTI = TweenInfo.new(AnimationTime / 6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
        local StartTween = TweenService:Create(Gradient, StartTI, {Offset = LeftOffset})
        local EndTween = TweenService:Create(Gradient, EndTI, {Offset = StartOffset})

        _Janitor:Add(RunService.Heartbeat:Connect(function(Delta)
            local Alpha = math.clamp(os.clock() - StartTime, 0, 1) / LerpTime
            local BeginWhite = Alpha * 0.45
            local EndWhite = 1 - BeginWhite

            Gradient.Color = ColorSequence.new({
                KeypointPresets.Start,
                ColorSequenceKeypoint.new(math.clamp(BeginWhite - 0.15, .01, 0.349), Gray),
                ColorSequenceKeypoint.new(math.clamp(BeginWhite, .02, .45), White),
                ColorSequenceKeypoint.new(math.clamp(EndWhite, 0, .99), White),
                ColorSequenceKeypoint.new(math.clamp(EndWhite + 0.15, 0.7, 0.999), Gray),
                KeypointPresets.End
            })

            Gradient.Rotation = Alpha * 35
        end))

        task.wait(LerpTime)
        _Janitor:Cleanup()

        task.wait(AnimationTime / 6)
        StartTween:Play()
        StartTween.Completed:Wait()
        Gradient.Offset = RightOffset
        EndTween:Play()
        EndTween.Completed:Wait()
        task.wait(AnimationTime / 6)

        StartTime = os.clock()
        _Janitor:Add(RunService.Heartbeat:Connect(function(Delta)
            local Alpha = 1 - (math.clamp(os.clock() - StartTime, 0, 1) / LerpTime)
            if Alpha == 1 then
                Gradient.Color = StartGradient
                return
            end

            local BeginWhite = Alpha * 0.45
            local EndWhite = 1 - BeginWhite

            Gradient.Color = ColorSequence.new({
                KeypointPresets.Start,
                ColorSequenceKeypoint.new(math.clamp(BeginWhite - 0.15, 0.001, 0.349), Gray),
                ColorSequenceKeypoint.new(math.clamp(BeginWhite, .02, .45), White),
                ColorSequenceKeypoint.new(math.clamp(EndWhite, 0, .99), White),
                ColorSequenceKeypoint.new(math.clamp(EndWhite + 0.15, 0.7, 0.99), Gray),
                KeypointPresets.End
            })

            Gradient.Rotation = Alpha * 35
        end))

        task.wait(LerpTime)
        _Janitor:Cleanup()

        Gradient.Color = StartGradient
    end

    task.spawn(Animate)
    return Utility.Clock(AnimationTime + (Delay or 2), Animate)
end

function module.ContinuousImageShine(AppliedInstance: Color.GradientAppliable, AnimationTime: number?, Delay: number?)
    AnimationTime = AnimationTime or 2
    local RightOffset = Vector2.new(-.75, 0)
    local LeftOffset = Vector2.new(.8, 0)

    local Gray = Color3.new(0.65, 0.65, 0.65)
    local KeypointPresets = {
        Start = ColorSequenceKeypoint.new(0, Gray),
        End = ColorSequenceKeypoint.new(1, Gray)
    }

    local Sequence = ColorSequence.new({
        KeypointPresets.Start,
        ColorSequenceKeypoint.new(0.3, Gray),
        ColorSequenceKeypoint.new(0.45, White),
        ColorSequenceKeypoint.new(0.55, White),
        ColorSequenceKeypoint.new(0.7, Gray),
        KeypointPresets.End
    })

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = Sequence
    Gradient.Rotation = 35
    Gradient.Offset = RightOffset
    Gradient.Parent = AppliedInstance

    local StartTI = TweenInfo.new(AnimationTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local function Animate()
        TweenService:Create(Gradient, StartTI, {Offset = LeftOffset}):Play()
        task.wait(AnimationTime * 1)
        Gradient.Offset = RightOffset
    end

    task.spawn(Animate)
    return Utility.Clock(AnimationTime + (Delay or .5), Animate)
end


return module