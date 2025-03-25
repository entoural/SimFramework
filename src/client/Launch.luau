local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage:WaitForChild("VFX")
local Flag = ReplicatedStorage:WaitForChild("Flag")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility = require(Shared.Utility)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)
local Vide = require(Packages.Vide)
local Root = Vide.root
local Effect = Vide.effect
local Janitor = require(Packages.Janitor)
local Framework = require(script.Parent.Framework)
local UI = Framework.UI
local Player = Framework.PlayerManager.LocalObject
local CameraShaker = Utility.CameraShaker
local Shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function() end)

type LaunchData = {
    MaxHeightIncrease: number,
    Gravity: number,
    HorizontalSpeed: number,
    SpeedMultiplier: number
}

type ConstantData = {
    StartX: number,
    BaseY: number,
    StartY: number,
    StartZ: number
}

local CurrentData: LaunchData = {
    MaxHeightIncrease = 100,
    Gravity = 196.2,
    HorizontalSpeed = 1,
    SpeedMultiplier = 1
}

local ConstantData: ConstantData?

local MaxHorizontalDistance = 10000
local LoopBackDistance = 10000
local BuildingModel = Player:GetState("BuildingModel")
local LaunchJanitor = Janitor.new()

-- Easing function for realistic motion
local function EaseInOutQuad(t)
	if t < 0.5 then
		return 2 * t * t
	else
		return -1 + (4 - 2 * t) * t
	end
end

-- Bézier curve calculation
local function Bezier(t, p0, p1, p2)
	local u = 1 - t
	local tt = t * t
	local uu = u * u
	return (uu * p0) + (2 * u * t * p1) + (tt * p2)
end

-- Derivative of the Bézier curve (for direction)
local function BezierDerivative(t, p0, p1, p2)
	local u = 1 - t
	return (2 * u * (p1 - p0)) + (2 * t * (p2 - p1))
end

-- Function to calculate trajectory and distance
local function CalculateTrajectory()
	local HorizontalSpeed = CurrentData.HorizontalSpeed -- Negative for direction
	local MaxHeightIncrease = CurrentData.MaxHeightIncrease
	local SpeedMultiplier = CurrentData.SpeedMultiplier
	local StartHeight = ConstantData.StartY
	local Gravity = CurrentData.Gravity

	local MaxHeight = StartHeight + MaxHeightIncrease
	local VerticalVelocity = math.sqrt(2 * Gravity * MaxHeightIncrease)
	local TimeUp = VerticalVelocity / Gravity
	local TimeDown = math.sqrt(2 * MaxHeight / Gravity)
	local TotalTime = TimeUp + TimeDown
	local AdjustedTotalTime = TotalTime / SpeedMultiplier
	local TotalHorizontalDistance = HorizontalSpeed * TotalTime

	local StartPosition = Vector3.new(ConstantData.StartX, StartHeight, ConstantData.StartZ)
	local MaxPoint = Vector3.new(ConstantData.StartX + HorizontalSpeed * TimeUp, MaxHeight, ConstantData.StartZ)
	local EndPoint = Vector3.new(ConstantData.StartX + TotalHorizontalDistance, ConstantData.BaseY, ConstantData.StartZ)

	return AdjustedTotalTime, StartPosition, MaxPoint, EndPoint, TotalHorizontalDistance
end

local function UpdateConstantData()
    local CurrentBuilding = BuildingModel()
    if not CurrentBuilding then
        error(`Unable to retrieve the current building assigned to localplayer`)
    end

    local LaunchCF: CFrame = CurrentBuilding.TopOfBuilding.LaunchPosition.CFrame
    local NewData = {}
    NewData.BaseY = CurrentBuilding.Floors:FindFirstChild("1"):GetPivot().Position.Y + 1
    NewData.StartY = LaunchCF.Position.Y
    NewData.StartX = LaunchCF.Position.X
    NewData.StartZ = LaunchCF.Position.Z
    ConstantData = NewData
end

local function ToggleVFX(Part: BasePart, Enabled: boolean?)
	for _, Descendant in Part:GetDescendants() do
		if Descendant:IsA("ParticleEmitter") then
			Descendant.Enabled = if Enabled ~= nil then Enabled else not Descendant.Enabled
		end
	end
end

local function Transition()
	local TransitionCircle = UI.GuiObjects.TransitionCircle

	TransitionCircle.Size = UDim2.fromScale(0, 0)
	TransitionCircle.Visible = true

	Spr.target(TransitionCircle, 1, 4, {Size = UDim2.fromScale(3, 3)})
	task.wait(0.8)
	Spr.target(TransitionCircle, 1, 4, {Size = UDim2.fromScale(0, 0)})
	task.delay(1, function()
		TransitionCircle.Visible = false
	end)
end

local function SwitchBar(Bar, IsLaunchMeter: boolean)
	if IsLaunchMeter then
		Bar.Instruction.Visible = true
		Bar.TopLabel.Text = "Max"
		Bar.BottomLabel.Text = "Min"
		Bar.Marker.Position = UDim2.fromScale(.868, 1)
	else
		Bar.Instruction.Visible = false
		Bar.TopLabel.Text = "Full"
		Bar.BottomLabel.Text = "Empty"

		local LastPosition = Bar.Marker.Position.Y.Scale
		Bar.Marker.Position = UDim2.fromScale(.868, .7 * LastPosition)
		return LastPosition
	end
end

local function TransitionLaunchState(InLaunch: boolean)
	if InLaunch then
		local Bar = UI.GuiObjects.LaunchBar
		local Bottom = UI.GuiObjects.Bottom
		Bar.Position = UDim2.fromScale(1.5, .5)
		local LastPosition = SwitchBar(Bar, false)
		Transition()
		task.wait(0.4)
		Spr.target(Bar, 1.2, 4, {Position = UDim2.fromScale(.96, .5)})
		Bar.Visible = true
		Spr.target(Bottom, 1.2, 4, {Position = UDim2.fromScale(.5, .875)})
		task.wait(.7)

		return LastPosition
	else
		local Bottom = UI.GuiObjects.Bottom
		Spr.target(Bottom, 1.2, 4, {Position = UDim2.fromScale(.5, 1.3)})
		Transition()
		
	end
end

local function GetMilestone(Index)
    if Index < 1 then
        return nil -- Invalid index
    end
    local Base = 10
    local Power = math.floor((Index - 1) / 2)

    if Index % 2 == 1 then
        return 5 * (Base ^ Power) -- 500, 5000, 500000, etc.
    else
        return Base ^ (Power + 1) -- 1000, 10000, 1000000, etc.
    end
end


local VFXNames = {"Thrust", "ReentryPlasma", "Exhaust"}
local function GetVFX(Rocket: Model)
	local Parts = {}
	for _, Name in VFXNames do
		local Clone = VFX:FindFirstChild(Name):Clone()
		ToggleVFX(Clone)

		Clone.Parent = Rocket
		Clone.CFrame = Rocket.PrimaryPart:FindFirstChild(Name).WorldCFrame
		Clone.Anchored = false

		local Constraint = Instance.new("WeldConstraint")
		Constraint.Part0 = Clone
		Constraint.Part1 = Rocket.PrimaryPart
		Constraint.Parent = Clone

		Parts[Name] = Clone
	end

	return Parts
end

local function RecordMarker(Distance: number)
	local Adjusted = Distance % 10000
	local FlagModel = Flag:Clone()
	FlagModel:PivotTo(CFrame.new(ConstantData.StartX + Adjusted, 1, ConstantData.StartZ))
	FlagModel.BillboardGui.Main.Score.Text = Utility.Abbreviate(Distance, 2)
	Framework.UI.Animations.GeneralEffects.SwayLoop(FlagModel.BillboardGui.Main)
	FlagModel.Parent = workspace

	--[[Framework.ModelTools.SpringModelScale(FlagModel, 2)
	task.delay(3, Framework.ModelTools.SpringModelScale, FlagModel, 1)]]

	return FlagModel
end

local function Launch(Data: LaunchData)
	LaunchJanitor:Cleanup()
    UpdateConstantData()
	task.spawn(TransitionLaunchState, true)
    CurrentData = Data.LaunchData
	print(Data.Accuracy)
	local StartFuel = (1 - Data.Accuracy) * .7
	local CurrentBuilding = BuildingModel()

    if not Player.Character() then
        error(`Cannot launch without a character`)
    end

	local DistanceBar = UI.GuiObjects.DistanceBar
	local DistanceCount = UI.GuiObjects.DistanceCount
	local DistanceLabel = DistanceCount.Main.TextLabel
	local Frame = UI.GuiObjects.LaunchBar
    local Marker = Frame.Marker

	local PlayerMarker = DistanceBar.Player
	PlayerMarker.Vector.Visible = false
	PlayerMarker.TextLabel.Visible = false
	PlayerMarker.PlayerImage.Image = Framework.Headshots:GetHeadshot(Player, true)

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	local Rocket: Model = CurrentBuilding.TopOfBuilding.Rocket
	local Ground = CurrentBuilding.Ground
	local RocketRoot = Rocket.PrimaryPart
	local Character = Player.Character()
	local InLaunch = Player.InLaunch
	local RecordModel
	local RecordScore = Player.RecordScore()
	local RecordLoop = math.floor(RecordScore / 10000)
    local RootPart = Character.HumanoidRootPart
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	local VFXParts = GetVFX(Rocket)
	local LastMilestone = 0

	Shaker._callback = function(ShakeCF)
		local RocketPosition = Rocket:GetPivot().Position
		local Position = RocketPosition + Vector3.new(0, 0, 35)
		workspace.CurrentCamera.CFrame = CFrame.lookAt(Position, RocketPosition) * ShakeCF
	end
	Shaker:Start()
	Shaker:ShakeSustain(CameraShaker.Presets.Earthquake)


    local AdjustedTotalTime, StartPosition, MaxPoint, EndPoint, TotalDistance = CalculateTrajectory()
	local Duration = AdjustedTotalTime
	local StartTime = os.clock()

	local OriginalTransparencies: {[BasePart]: number} = {}
	for _, Part in Rocket:GetDescendants() do
		if Part:IsA("BasePart") then
			OriginalTransparencies[Part] = Part.Transparency
		end
	end

	local Loops = 0
	for _, Part in Ground:GetChildren() do
		Part.SurfaceGui.TextLabel.Text = Utility.Abbreviate(tonumber(Part.Name) * 100)
	end

	ToggleVFX(VFXParts.Thrust, true)

	local OriginalThrustRates: {[ParticleEmitter]: number} = {}
	for _, Descendant in VFXParts.Thrust:GetDescendants() do
		if Descendant:IsA("ParticleEmitter") then
			OriginalThrustRates[Descendant] = Descendant.Rate
		end
	end

	if RecordLoop == 0 and RecordScore ~= 0 then
		RecordModel = RecordMarker(RecordScore)
	end

	RootPart.CanCollide = false

	local EnabledPlasma = false
	local DisabledThrust = false
	local UnoffsetStart = StartPosition
	local LastPosition = Rocket:GetPivot().Position
	LaunchJanitor:Add(RunService.Heartbeat:Connect(function(Delta)
		local ElapsedTime = os.clock() - StartTime
		local T = math.clamp(ElapsedTime / Duration, 0, 1)

		-- Apply easing for realistic motion
		local EasedT = EaseInOutQuad(T)

		local DistanceCovered = EasedT * TotalDistance
		local NewPosition = Bezier(EasedT, StartPosition, MaxPoint, EndPoint)
		local Unoffset = Bezier(EasedT, UnoffsetStart, MaxPoint, EndPoint)
		local DistanceChange = (NewPosition - LastPosition).Magnitude / Delta
		LastPosition = NewPosition
		local UnoffsetDirection = BezierDerivative(EasedT, UnoffsetStart, MaxPoint, EndPoint)
		local LookAt = NewPosition + UnoffsetDirection

		-- Milestones
		DistanceLabel.Text = Utility.Abbreviate(math.floor(DistanceCovered), 2)
		if DistanceCovered >= GetMilestone(LastMilestone + 1) then
			LastMilestone += 1
			UI.Animations.GeneralEffects.Burst(DistanceCount, 1.3)
			UI.Animations.GeneralEffects.Burst(DistanceCount.Vector, 1.2)
			UI.Animations.GeneralEffects.Shake(DistanceCount.Vector, 2)
		end

		-- Thrust particle strength and fuel
		if Unoffset.X < MaxPoint.X then
			local Ratio = Unoffset.X / MaxPoint.X
			for Emitter, OriginalRate in OriginalThrustRates do
				Emitter.Rate = (1 - Ratio) * OriginalRate
			end

			Marker.Position = UDim2.fromScale(.868, StartFuel + (1 - StartFuel) * Ratio)
		elseif NewPosition.X >= MaxPoint.X and not DisabledThrust then
			DisabledThrust = true
			ToggleVFX(VFXParts.Thrust, false)
			if Marker.Position.Y.Scale ~= 1 then
				Marker.Position = UDim2.fromScale(.868, 1)
			end
		end

		-- Reentry plasma color changing
		if DistanceChange > 300 and DistanceChange < 50000 then
			if not EnabledPlasma then
				EnabledPlasma = true
				ToggleVFX(VFXParts.ReentryPlasma, true)
			end

			local Alpha = TweenService:GetValue(DistanceChange / 3000, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			VFXParts.ReentryPlasma.Main.MainColor.Color = ColorSequence.new(Color3.fromHSV(43 / 359 + (Alpha * 240) / 359, 1, 1))
			local Rate = math.clamp(DistanceChange / 3000, 0, 1)
			VFXParts.ReentryPlasma.Main.MainColor.Rate = Rate * 200
			VFXParts.ReentryPlasma.Main.ParticleEmitter.Rate = Rate * 100
		end


		-- Loop logic
		if NewPosition.X > ConstantData.StartX + MaxHorizontalDistance then
			Loops += 1
			PlayerMarker.TextLabel.Text = `{Loops} Laps`
			PlayerMarker.TextLabel.Visible = true
			PlayerMarker.Vector.Visible = true

            local Offset = LoopBackDistance
            NewPosition = Vector3.new(NewPosition.X - Offset, NewPosition.Y, NewPosition.Z)
            StartPosition = Vector3.new(StartPosition.X - Offset, StartPosition.Y, StartPosition.Z)
            MaxPoint = Vector3.new(MaxPoint.X - Offset, MaxPoint.Y, MaxPoint.Z)
            EndPoint = Vector3.new(EndPoint.X - Offset, EndPoint.Y, EndPoint.Z)

			for _, Part in Ground:GetChildren() do
				Part.SurfaceGui.TextLabel.Text = Utility.Abbreviate(tonumber(Part.Name) * 100 + Loops * LoopBackDistance)
			end

			if Loops == RecordLoop and RecordScore ~= 0 then
				RecordModel = RecordMarker(RecordScore)
			end
        end

		-- Player distance meter
		PlayerMarker.Position = UDim2.fromScale((NewPosition.X - UnoffsetStart.X - if Loops > 0 then 0 else 0) / 10000, -.978)

		-- Update character position and orientation
		local CF = CFrame.new(NewPosition, LookAt) * CFrame.Angles(math.rad(-90), 0, 0)
		Rocket:PivotTo(CF)
		RootPart.CFrame = CF * CFrame.new(0, 0, 5) * CFrame.Angles(math.rad(90), 0, 0)

		if T >= 1 then
			RootPart.CanCollide = true
			Shaker:Stop()
			LaunchJanitor:Remove("Motion")
			LaunchJanitor:Remove("Camera")
			ToggleVFX(VFXParts.Thrust, false)
			ToggleVFX(VFXParts.ReentryPlasma, false)
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			Character.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
			Character.PrimaryPart.AssemblyAngularVelocity = Vector3.zero

			if TotalDistance > RecordScore then
				if RecordModel then
					RecordModel:Destroy()
				end

				RecordModel = RecordMarker(TotalDistance)
			end

			for Part, _ in OriginalTransparencies do
				Part.Transparency = 1
			end

			local NewCF = CF - Vector3.new(0, 20, 0)
			LaunchJanitor:Add(RunService.Heartbeat:Connect(function()
				Rocket:PivotTo(NewCF)
			end), "Disconnect", "HoldPosition")
		end
	end), "Disconnect", "Motion")

	--[[LaunchJanitor:Add(RunService.RenderStepped:Connect(function()
		RocketPosition = Rocket:GetPivot().Position
		Position = RocketPosition + Vector3.new(0, 0, 35)
		workspace.CurrentCamera.CFrame.Position = Position
	end), "Disconnect", "Camera")]]

	LaunchJanitor:Add(Humanoid.Died:Connect(function()
		LaunchJanitor:Cleanup()
	end))

	LaunchJanitor:Add(Rocket.Destroying:Connect(function()
		LaunchJanitor:Cleanup()
	end))

	LaunchJanitor:Add(function()
		Frame.Visible = false
		SwitchBar(Frame, true)
		TransitionLaunchState(false)
		RootPart.CanCollide = true
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		Shaker:Stop()

		for _, Part in Ground:GetChildren() do
			Part.SurfaceGui.TextLabel.Text = Utility.Abbreviate(tonumber(Part.Name) * 100)
		end

		for _, Part in VFXParts do
			Part:Destroy()
		end

		if RecordModel then
			RecordModel:Destroy()
		end
	end)

	LaunchJanitor:Add(task.delay(AdjustedTotalTime, function()

	end))

	local Destructor: () -> ()
	Root(function(Destroy)
		Destructor = Destroy
		Effect(function()
			local IsInLaunch = InLaunch()
			if not IsInLaunch then
				LaunchJanitor:Cleanup()
				for Part, Transparency in OriginalTransparencies do
					Part.Transparency = Transparency
				end

				Rocket:PivotTo(CurrentBuilding.TopOfBuilding.LaunchPosition.CFrame)
			end
		end)
	end)

	LaunchJanitor:Add(Destructor)
end

Framework.Network.LaunchPlayer.On(function(Data: LaunchData)
    Launch(Data)
end)

return Launch