local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local LocalPlayer = Players.LocalPlayer
local LocalName = LocalPlayer.Name
local PlayerClass = require(script.Player)
local Network = require(script.Parent.Network)
local StateUpdate = Network.PlayerStateUpdate
local RequestReplication = Network.RequestReplication
local PlayerLeft = Network.PlayerLeft

local Vide = require(Packages.Vide)
local Source = Vide.source

local module = {}
module.Players = {[LocalName] = PlayerClass.new(LocalName)} :: {PlayerClass.Player}

type Method = <T>(self: PlayerClass.Player, ...any) -> T
module.Methods = {} :: {[string]: Method}

function module.AddMethod(Index: string, Method: Method)
    module.Methods[Index] = Method

    for _, PlayerObject in module.Players do
        PlayerObject[Index] = Method
    end
end

function module.SetupPlayer(Player: Player | string): PlayerClass.Player
    local Name = if typeof(Player) == "string" then Player else Player.Name
    if module.Players[Name] then return end

    local PlayerObject = PlayerClass.new(Player)
    for Index, Method in module.Methods do
        PlayerObject[Index] = Method
    end
    module.Players[Name] = PlayerObject

    return module.Players[Name]
end

function module.PlayerExists(Player: string)
    return Players:FindFirstChild(Player)
end

function module.GetPlayer(Player: Instance | string): PlayerClass.Player
    local IsString = typeof(Player) == "string"
    local PlayerObject = if IsString then module.Players[Player] else module.Players[Player.Name]
    if not PlayerObject and IsString and not module.PlayerExists(Player) then
        error(`[ENT Framework] Could not retrieve Instance for player with name {Player}.`)
    end

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

    StateUpdate.SetCallback(function(Payload)
        module.GetPlayer(Payload.Player):UpdateState(Payload.Index, Payload.Value)
    end)

    RequestReplication.Fire()
end

return module