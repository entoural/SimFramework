--[[Services]]--
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

--[[Variables]]--
local LoadingScreen = script:WaitForChild("LoadingScreen"):Clone()
local Background = LoadingScreen.Background
local Loading = Background.Loading
local AssetsLabel = Background.Assets
local Bar = Background.BarHolder.Bar

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
LoadingScreen.Parent = PlayerGui

local Assets = game:GetDescendants()
local TotalAssets = #Assets

--[[Loading]]--
Loading.Text = "Loading..."
ReplicatedFirst:RemoveDefaultLoadingScreen()
while not game:IsLoaded() do
    task.wait()
end

AssetsLabel.Text = `1/{TotalAssets}`
task.wait()

for i, AssetsNeeded in Assets do
    ContentProvider:PreloadAsync({AssetsNeeded})
    AssetsLabel.Text = `{i}/{TotalAssets}`
    Bar.Size = UDim2.fromScale(i/TotalAssets, 1)
end

task.wait()
Loading.Text = "Loading Completed!"
task.wait(0.5)
LoadingScreen:Destroy()