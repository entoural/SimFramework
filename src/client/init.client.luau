--[[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Color = require(script.Framework.UI.Color)
local Modifiers = require(script.Framework.UI.Modifiers)
local Combinations = require(script.Framework.UI.Combinations)
local Animations = require(script.Framework.UI.Animations)
local sg = require(script.Framework.UI.Components.SlidingGradient)
local hi = require(script.Framework.UI.Components.HoverInteraction)
local RichText = require(script.Framework.UI.RichText)
local plr = Players.LocalPlayer
local gui = plr:WaitForChild("PlayerGui")
local Framework = require(script.Framework)

Vide.strict = false

Vide.root(function()
    require(script.Framework.UI).BeginSetup()
    Framework.PlayerManager:Begin()
end)

local InRound = Framework.Player:GetState("InRound")
local RoundSystem = require(script.RoundSystem)

local RoundState
Vide.root(function(destroy)
    RoundState = RoundSystem(InRound)
end)
require(script.GamepassSwap)()
require(script.ProgressBar)()

Framework.ZoneTools.LinkPartToCallback(workspace:WaitForChild("JoinPart"), function()
    local Current = RoundState()
    if Current.State == "RoundEnded" or Current.State == "NewRound" then
        return
    end

    if not Framework.Player:GetStateValue("PlayedRound", true) then
        Framework.Network.RejoinRound.Fire()
    else
        Framework.Monetization.PromptProduct("Revive")
    end
end)]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Vide = require(ReplicatedStorage.Packages.Vide)
Vide.strict = false

local Framework = require(script.Framework)
Vide.root(function()
    require(script.Framework.UI).BeginSetup()
    Framework.PlayerManager:Begin()
end)

require(script.Launch)
require(script.Demo)
require(script.LaunchZone)()
require(script.Base)()
Vide.root(require(script.Rebirths))