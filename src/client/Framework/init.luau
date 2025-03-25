local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local Framework = {}
Framework.Network = require(script.Network)
Framework.ZoneTools = require(script.ZoneTools)
Framework.Monetization = require(script.Monetization)
Framework.Camera = require(script.Camera)
Framework.ModelTools = require(script.ModelTools)
Framework.Headshots = require(script.Headshots)
Framework.PlayerManager = require(script.PlayerManager)
Framework.UI = require(script.UI)

Framework.Player = Framework.PlayerManager.GetPlayer(Players.LocalPlayer.Name)
Framework.Gui = Framework.Player.Player:WaitForChild("PlayerGui")

return Framework