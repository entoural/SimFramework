local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local SharedUtility = require(Shared.Utility)
local Signal = require(Packages.Signal)
local Vide = require(Packages.Vide)
local Janitor = require(Packages.Janitor)
local PlayerClass = require(script.Parent.Player)
local Root = Vide.root

local Manager = {}
Manager.DefaultStates = {}
Manager.LeaderstatLinks = {}
Manager.PlayerList = {} :: {[Player]: PlayerClass.PlayerObject}

Manager.Death = Signal.new()
Manager.CharacterAdded = Signal.new()
Manager.PlayerAdded = Signal.new()
Manager.PlayerLeft = Signal.new()

function Manager:AddState(Name: string, DefaultState: any)
    self.DefaultStates[Name] = DefaultState

    for _, Player in self.PlayerList do
        Player:AddState(Name, DefaultState)
    end
end

function Manager:LinkLeaderstat(StateName: string, Convert: ((any) -> any)?, InstanceType: string)
    table.insert(self.LeaderstatLinks, {StateName = StateName, Convert = Convert, InstanceType = InstanceType})

    for _, Player in self.PlayerList do
        Player:LinkLeaderstat(StateName, Convert, InstanceType)
    end
end

function Manager:AddMethod(Name: string, Method: (Player: PlayerClass.PlayerObject, ...any) -> ...any)
    PlayerClass[Name] = Method
end

function Manager:AddPlayer(Player: Player)
    local NewPlayer = PlayerClass.new(Player, self.DefaultStates, self.LeaderstatLinks, self.Death)
    self.PlayerList[Player] = NewPlayer

    SharedUtility.RootedEffect(function()
        self.CharacterAdded:Fire(NewPlayer, NewPlayer.Character())
    end)

    self.PlayerAdded:Fire(NewPlayer)
end

function Manager:GetPlayer(Player: Player): PlayerClass.PlayerObject
    if not Player or not Player:IsA("Player") or Player.Parent ~= Players then
        return
    end

    local Resolved = false
    local PlayerObject = self.PlayerList[Player]

    if PlayerObject then
        return PlayerObject
    end

    local TempJanitor = Janitor.new()
    TempJanitor:Add(self.PlayerAdded:Connect(function(Object: PlayerClass.PlayerObject)
        if Object.Player == Player then
            PlayerObject = Object
            Resolved = true
        end
    end), "Disconnect")
    TempJanitor:Add(task.spawn(function()
        task.wait(5)
        if not Resolved then
            Resolved = true
        end
    end))

    while not Resolved do
        task.wait()
    end

    TempJanitor:Destroy()
    if not PlayerObject then
        error(`[ENT Framework] Could not retrieve Object for player {Player.Name} within 5 seconds.`)
    end
    return PlayerObject
end

function Manager:Begin()
    Players.PlayerAdded:Connect(function(Player)
        Root(function()
            self:AddPlayer(Player)
        end)
    end)
    for _, Player in Players:GetPlayers() do
        Root(function()
            self:AddPlayer(Player)
        end)
    end

    Players.PlayerRemoving:Connect(function(Player)
        local Object = self.PlayerList[Player]
        assert(Object)

        self.PlayerLeft:Fire()
        Object:Destroy()
        self.PlayerList[Player] = nil
    end)
end

return Manager