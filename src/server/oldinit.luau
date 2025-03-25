local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Array = require(Packages.Sift).Array
local Framework = require(script.Parent.Framework)

local RoundSystem = require(script.Parent.RoundSystem)
local BasicUtil = require(script.Parent.BasicUtil)

local DataStates = {
    {[1] = "Wins", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"},
    {[1] = "Cash", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"}
}

local ReplicatedDataStates = {
    {[1] = "Inventory", [2] = false},
    {[1] = "Level", [2] = true},
    {[1] = "DailyStreak", [2] = false}
}

local ReplicatedStates = {
    {[1] = "InRound", [2] = false, [3] = true},
    {[1] = "PlayedRound", [2] = false, [3] = true}
}
-- Name, Initial, Global

Vide.strict = false

BasicUtil.KillPart(workspace:WaitForChild("KillPart"))

local Winners = Vide.source({})
Framework.Replication.PlayerReplication:ReplicateGlobalState("Winners", RoundSystem.CurrentState)

local CashPlacementRewards = {100, 50, 25}
local function PlayerWon(Player: Player, Placement: number)
	local Object = Framework.PlayerManager:GetPlayer(Player, true)
    if not Object then return end

    if CashPlacementRewards[Placement] then
        Object.Cash(Object.Cash() + CashPlacementRewards[Placement])
    end

    if Placement <= 3 then
        Winners(Array.set(Winners(), Placement, Player.UserId))
    end
end

Framework.GeneralSetup:LoadDataStates(DataStates)
Framework.GeneralSetup:ReplicateStates(ReplicatedStates)
Framework:Start()


local ActiveRound = false

task.spawn(function()
    local FirstPassed = false
    while true do
        if FirstPassed then
            for i = 5, 1, -1 do
                RoundSystem.CurrentState({State = "RoundEnded", Num1 = i})
                task.wait(1)
            end
        else
            FirstPassed = true
        end

        Winners({})

        RoundSystem.CurrentState({State = "BlankIntermission"})
        task.wait(2)

        for i = 5, 1, -1 do
            RoundSystem.CurrentState({State = "NewRound", Num1 = i})
            task.wait(1)
        end

        for _, Object in Framework.PlayerManager.PlayerList do
            Object.PlayedRound(true)
        end

        ActiveRound = true
        RoundSystem:BeginRound(PlayerWon)
        ActiveRound = false

        for _, Object in Framework.PlayerManager.PlayerList do
            Object.PlayedRound(false)
        end
    end
end)

local function BringIntoGame(Player: Framework.PlayerObject)
    local Character = Player.Character()
    if not Player.Character() or not ActiveRound then
        return
    end

    Player.Played(true)
    Player.InRound(true)
    table.insert(RoundSystem.RemainingPlayers, Player)
    Character.PrimaryPart.Position = RoundSystem.GetRandomSpawnPosition(Player.Player)
end

Framework.Network.RejoinRound.SetCallback(function(Player: Player)
    local Object = Framework.PlayerManager:GetPlayer(Player, true)
    if not Object or Object.Played() then
        return
    end

    
end)

--Framework.PlayerManager.PlayerList[Players.entoural].Cash(100)

return 3