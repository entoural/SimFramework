local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RocketInfo = require(Shared.RocketInfo)
local RocketOrder = require(Shared.RocketOrder)
local Framework = require(script.Parent.Framework)

Framework.Network.UpgradeLevel.On(function(Player: Player)
    local Object = Framework.PlayerManager:GetPlayer(Player)
    if not Object then return end

    --[[
    local CurrentRocket = Rocket()
        local CurrentLevel = RocketLevel()
        local CurrentCash = Cash()
        local RocketData = RocketInfo[CurrentRocket]
        local BaseCost = RocketData.BaseCost
        local Next = RocketOrder[table.find(RocketOrder, CurrentRocket) + 1]
        local MaxUpgrade = BaseCost + ((Next and (RocketInfo[Next].BaseCost - BaseCost) or (BaseCost + 10000) - BaseCost)) * 0.6

        if CurrentLevel == RocketData.MaxLevel and Next and CurrentCash >= RocketInfo[Next].BaseCost then
            Framework.Network.BuyNextRocket.Fire()
        elseif CurrentLevel < RocketData.MaxLevel and CurrentCash >= BaseCost + (MaxUpgrade - BaseCost) * (CurrentLevel / RocketData.MaxLevel) then
            Framework.Network.UpgradeLevel.Fire()
        end
    ]]

    local Rocket = Object.Rocket()
    local Cash = Object.Cash()
    local Level = Object.RocketLevel()
    local RocketData = RocketInfo[Rocket]

    if Level >= RocketData.MaxLevel then
        return
    end

    local BaseCost = RocketData.BaseCost
    local Next = RocketOrder[table.find(RocketOrder, Rocket) + 1]
    local MaxUpgrade = BaseCost + ((Next and (RocketInfo[Next].BaseCost - BaseCost) or (BaseCost * 3) - BaseCost)) * 0.6
    local UpgradeCost = BaseCost + (MaxUpgrade - BaseCost) * (Level / RocketData.MaxLevel)

    if Cash >= UpgradeCost then
        Object:IncrementState("Cash", -UpgradeCost)
        Object:IncrementState("RocketLevel", 1)
    end
end)

Framework.Network.BuyNextRocket.On(function(Player: Player)
    local Object = Framework.PlayerManager:GetPlayer(Player)
    if not Object then return end

    local Rocket = Object.Rocket()
    local Next = RocketOrder[table.find(RocketOrder, Rocket) + 1]
    if not Next then return end
    if Object.Cash() >= RocketInfo[Next].BaseCost then
        Object:IncrementState("Cash", -RocketInfo[Next].BaseCost)
        Object.Rocket(Next)
        Object.RocketLevel(1)
        Object.Building():LoadRocket(Next)
    end
end)

Framework.Network.BuyNextFloor.On(function(Player: Player)
    local Object = Framework.PlayerManager:GetPlayer(Player)
    if not Object then return end

    local Floors = Object.Floors()
    local NextFloorCost = 500 * 1.1^(Floors - 1)
    if Object.Cash() >= NextFloorCost then
        Object:IncrementState("Cash", -NextFloorCost)
        Object:IncrementState("Floors", 1)
        Framework.Network.StatEffect.Fire(Player, {Stat = "Floors", Amount = 1})
    end
end)