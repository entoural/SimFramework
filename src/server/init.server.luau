local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Array = require(Packages.Sift).Array
local Framework = require(script.Framework)

local DataStates = {
    {[1] = "Rebirths", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"},
    {[1] = "Cash", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"},
    {[1] = "Boost", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"},
    {[1] = "Floors", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"},
}

Vide.strict = false

Framework.GeneralSetup:LoadDataStates(DataStates)
Framework.GeneralSetup:ReplicateDataState("Rocket", false)
Framework.GeneralSetup:ReplicateDataState("RocketLevel", false)
Framework.GeneralSetup:ReplicateState("BuildingModel", nil, true)
Framework.GeneralSetup:ReplicateState("InLaunch", false, true)
Framework.GeneralSetup:ReplicateState("RecordScore", "GetData", false)
Framework.PlayerManager:AddState("Building", nil)
Framework:Start()