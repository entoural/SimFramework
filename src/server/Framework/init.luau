local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Vide = require(Packages.Vide)

local Network = require(script.Network)
local Data = require(script.Data)
local Replication = require(script.Replication)
local PlayerClass = require(script.Player)
local Types = require(script.Types)
local Utility = require(script.Utility)
local OctreeManager = require(script.OctreeManager)
local PlayerManager = require(script.PlayerManager)
local GeneralSetup = require(script.GeneralSetup)

local Framework = {}
Framework.Player = PlayerClass
Framework.PlayerManager = PlayerManager
Framework.OctreeManager = OctreeManager
Framework.Replication = Replication
Framework.Network = Network
Framework.Types = Types
Framework.GeneralSetup = GeneralSetup

export type PlayerObject = PlayerClass.PlayerObject

-- Player Management

Framework.Players = {}
function Framework:GetPlayerObject(Player: Player, Callback: (Player: PlayerObject) -> any): PlayerObject
    Utility.Assert(self.Players[Player], `[ENT Framework] Attempted to get player object for a player with no player object, {Player}.`)

    if Callback then
        Callback(self.Players[Player])
    end

    return self.Players[Player]
end

-- Network

--[[Framework.Remotes = Shared.Remotes
Framework.InitialDataCallbacks = {}

local dataRequest = require(Framework.Remotes.InitialDataRequest):Server()
dataRequest:On(function(player: Player)
    local Player = Framework:GetPlayerObject(player)
    local DataPayload = {}

    for i, callback in Framework.InitialDataCallbacks do
        DataPayload[i] = callback(Player)
    end

    dataRequest:Fire(player, DataPayload)
end)[[]]

function Framework:Start()
    PlayerManager:Begin()
    Replication.PlayerReplication:Listen()
end

return Framework