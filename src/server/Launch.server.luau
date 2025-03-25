local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Formulas = require(Shared.Formulas)
local RocketInfo = require(Shared.RocketInfo)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)
local Framework = require(script.Parent.Framework)

type Data = {
    HorizontalSpeed: number,
    MaxHeightIncrease: number,
    SpeedMultiplier: number,
    StartY: number,
    StartX: number,
    StartZ: number,
    Gravity: number,
}

local BaseY = 1

-- Function to calculate trajectory and distance
local function CalculateTrajectory(Data: {[string]: number})
	local HorizontalSpeed = Data.HorizontalSpeed -- Negative for direction
	local MaxHeightIncrease = Data.MaxHeightIncrease
	local SpeedMultiplier = Data.SpeedMultiplier
	local StartHeight = Data.StartY
	local Gravity = Data.Gravity

	local MaxHeight = StartHeight + MaxHeightIncrease
	local VerticalVelocity = math.sqrt(2 * Gravity * MaxHeightIncrease)
	local TimeUp = VerticalVelocity / Gravity
	local TimeDown = math.sqrt(2 * MaxHeight / Gravity)
	local TotalTime = TimeUp + TimeDown
	local AdjustedTotalTime = TotalTime / SpeedMultiplier
	local TotalHorizontalDistance = HorizontalSpeed * TotalTime

	local StartPosition = Vector3.new(Data.StartX, StartHeight, Data.StartZ)
	local MaxPoint = Vector3.new(Data.StartX + HorizontalSpeed * TimeUp, MaxHeight, Data.StartZ)
	local EndPoint = Vector3.new(Data.StartX + TotalHorizontalDistance, BaseY, Data.StartZ)

	return AdjustedTotalTime, StartPosition, MaxPoint, EndPoint, TotalHorizontalDistance
end


Framework.Network.RequestLaunch.On(function(Player: Player, Accuracy: number)
    local Object = Framework.PlayerManager:GetPlayer(Player, false)
    if not Object or not Object:GetHumanoid() or Object.InLaunch() then
        return
    end

    local SpeedMultiplier, ScoreMultiplier = Formulas.GetRebirthModifiers(Object.Rebirths())

    local Efficiency = 0.3 + math.clamp(Accuracy, 0, 1) * 0.7
    local Rocket = RocketInfo[Object.Rocket()]
    local BuildingModel = Object.BuildingModel()
    local StartPos = BuildingModel.TopOfBuilding.LaunchPosition.Position

    --print(Rocket.HorizontalSpeed * (1 + ((Object.RocketLevel() - 1) / Rocket.MaxLevel * 2)), Rocket.HorizontalSpeed)

    local Data: Data = {
        HorizontalSpeed = Rocket.HorizontalSpeed * (1 + ((Object.RocketLevel() - 1) / Rocket.MaxLevel * 2)),
        MaxHeightIncrease = Rocket.MaxHeightIncrease * Efficiency,
        SpeedMultiplier = 0.6 * SpeedMultiplier,
        Gravity = 196.2,
        StartY = StartPos.Y,
        StartX = StartPos.X,
        StartZ = StartPos.Z
    }

    Object.InLaunch(true)
    local RocketModel: Model = BuildingModel.TopOfBuilding.Rocket
    RocketModel.PrimaryPart.Anchored = false
    RocketModel.PrimaryPart:SetNetworkOwner(Player)

    local TotalTime, _, _, _, TotalDistance = CalculateTrajectory(Data)
    Framework.Network.LaunchPlayer.Fire(Player, {
        LaunchData = {
            MaxHeightIncrease = Data.MaxHeightIncrease,
            Gravity = Data.Gravity,
            HorizontalSpeed = Data.HorizontalSpeed,
            SpeedMultiplier = Data.SpeedMultiplier
        },
        Accuracy = Accuracy
    })

    local LaunchJanitor = Janitor.new()
    LaunchJanitor:Add(task.delay(TotalTime + 3, function()
        LaunchJanitor:Destroy()
    end))

    LaunchJanitor:Add(Object:GetHumanoid().Died:Connect(function()
        LaunchJanitor:Destroy()
    end))

    LaunchJanitor:Add(RocketModel.Destroying:Connect(function()
        LaunchJanitor:Destroy()
    end))

    LaunchJanitor:Add(function()
        Object.InLaunch(false)
        local CashAmount = (if Object.DoubleLaunchReward then TotalDistance * 2 else TotalDistance) * ScoreMultiplier
        Object.DoubleLaunchReward = false
        if TotalDistance > Object.RecordScore() then
            Object.RecordScore(TotalDistance)
        end

        if RocketModel and RocketModel.Parent ~= nil then
            RocketModel.PrimaryPart:SetNetworkOwner(nil)
            RocketModel.PrimaryPart.Anchored = true
            RocketModel:PivotTo(BuildingModel.TopOfBuilding.LaunchPosition.CFrame)
        end

        task.delay(2, function()
            Object:IncrementState("Cash", math.round(CashAmount))
            Framework.Network.StatEffect.Fire(Object.Player, {Stat = "Cash", Amount = 3})
        end)

        if Player and Player.Parent == Players then
            Player:LoadCharacter()
        end
    end)
end)