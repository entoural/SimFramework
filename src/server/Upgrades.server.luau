local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RocketOrder = require(Shared.RocketOrder)
local Utility = require(Shared.Utility)
local Formulas = require(Shared.Formulas)
local Framework = require(script.Parent.Framework)

Framework.Network.Rebirth.On(function(Player: Player)
    local Object = Framework.PlayerManager:GetPlayer(Player)
    if not Object then return end

    local Record = Object.RecordScore()
    local Rebirths = Object.Rebirths
    local _, _, Minimum = Formulas.GetRebirthModifiers(Rebirths() + 1)

    if Record < Minimum then
        return
    end

    Object:IncrementState("Rebirths", 1)
    Object.Cash(0)
    Object.Floors(1)
    Object.RecordScore(0)
    Object.Rocket(RocketOrder[1])
    Object.RocketLevel(1)
    Object.Building():LoadRocket(RocketOrder[1])
end)