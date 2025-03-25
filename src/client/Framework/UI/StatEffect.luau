local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Gui = Player:WaitForChild("PlayerGui"):WaitForChild("Main")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)
local Vide = require(Packages.Vide)

type Ranges = {XRange: {Min: number, Max: number}, YRange: {Min: number, Max: number}}
local DefaultRanges: Ranges = {XRange = {Min = .2, Max = .8}, YRange = {Min = .5, Max = .85}}

local function QuadraticBezier(t,p0,p1,p2)
	return (1-t)^2*p0+2*(1-t)*t*p1+t^2*p2;
end;


function GetRandomOffsetPoint(OriginOffset, FixedDistance): Vector2
	local Angle = math.rad(math.random(0, 360)) -- Random direction in radians
	local OffsetX = math.cos(Angle) * FixedDistance
	local OffsetY = math.sin(Angle) * FixedDistance
	return OriginOffset + Vector2.new(OffsetX, OffsetY)
end


local function Effect(Icon: string, EndPosition: Vector2, Ranges: Ranges?)
    Ranges = Ranges or DefaultRanges

    local XPos = math.random(Ranges.XRange.Min * 100, Ranges.XRange.Max * 100) / 100
	local YPos = math.random(Ranges.YRange.Min * 100, Ranges.YRange.Max * 100) / 100

    local Image = Vide.create "ImageLabel" {
        Image = Icon,
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundTransparency = 1,
        ZIndex = 10,
        Size = UDim2.fromOffset(Gui.AbsoluteSize.X / 15, Gui.AbsoluteSize.X / 15),
        Position = UDim2.fromScale(XPos, YPos),
        Parent = Gui,
        Visible = false,
        Vide.create "UIScale" {
            Scale = 0,
        },
        Vide.create "UIAspectRatioConstraint" {}
    }

    local OriginalAbs = Image.AbsolutePosition
    local OffsetPoint = GetRandomOffsetPoint(OriginalAbs, math.random(Gui.AbsoluteSize.X / 5, Gui.AbsoluteSize.X / 4))

    do
        local NewAlpha = TweenService:GetValue(0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local X = QuadraticBezier(NewAlpha, OriginalAbs.X, OffsetPoint.X, EndPosition.X)
        local Y = QuadraticBezier(NewAlpha, OriginalAbs.Y, OffsetPoint.Y, EndPosition.Y)
        Image.Position = UDim2.fromOffset(X, Y)
    end

    Image.Visible = true
    Spr.target(Image.UIScale, 0.9, 5, {Scale = 1})
    task.wait(.3)

    TweenService:Create(Image.UIScale, TweenInfo.new(.9, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0}):Play()
    local Connection
    local Start = os.clock()
    Connection = RunService.PreRender:Connect(function()
        local T = math.clamp((os.clock() - Start) / .9, 0, 1)
        local NewAlpha = TweenService:GetValue(T, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local X = QuadraticBezier(NewAlpha, OriginalAbs.X, OffsetPoint.X, EndPosition.X)
        local Y = QuadraticBezier(NewAlpha, OriginalAbs.Y, OffsetPoint.Y, EndPosition.Y)

        Image.Position = UDim2.fromOffset(X, Y)
        if T == 1 then
            Image:Destroy()
            Connection:Disconnect()
        end
    end)
end

local function StatEffect(Icon: string, EndPosition: Vector2, Amount: number?, Ranges: Ranges?)
    Ranges = Ranges or DefaultRanges
    Amount = Amount or math.random(1, 3)

    for _ = 1, Amount do
        print("Spawning")
        task.spawn(Effect, Icon, EndPosition, Ranges)
    end
end

return StatEffect