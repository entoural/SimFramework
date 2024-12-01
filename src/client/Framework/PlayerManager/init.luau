local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local LocalPlayer = Players.LocalPlayer
local LocalName = LocalPlayer.Name
local PlayerClass = require(script.Player)
local Network = require(script.Parent.Network)
local StateUpdate = Network.PlayerStateUpdate
local PlayerLeft = Network.PlayerLeft

local Vide = require(Packages.Vide)
local Source = Vide.source

local module = {}
module.Players = {[LocalName] = {}} :: {PlayerClass.Player}

function module.SetupPlayer(Player: Player | string)
    local Name = if typeof(Player) == "string" then Player else Player.Name
    if module.Players[Name] then return end

    module.Players[Name] = PlayerClass.new(Player)
    return module.Players[Name]
end

function module.GetPlayer(Player: Instance | string)
    local PlayerObject = if typeof(Player) == "string" then module.Players[Player] else module.Players[Player.Name]
    return if not PlayerObject then module:SetupPlayer(Player) else PlayerObject
end

function module.UpdatePasses(Payload: {{Player: string, Data: {Name: string, Owned: boolean, Gifted: boolean}}})
    for _, Info in Payload do
        local Player = module:GetPlayer(Info.Player)
        Player:UpdatePass(Info.Data)
    end
end

function module:Begin()
    for _, Player in Players:GetPlayers() do
        module.SetupPlayer(Player)
    end
    Players.PlayerAdded:Connect(module.SetupPlayer)

    PlayerLeft.On(function(Player: string)
        local PlayerObject = module.Players[Player]
        if not PlayerObject then return end

        PlayerObject:Destroy()
    end)
end

return module