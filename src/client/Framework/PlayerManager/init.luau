local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local LocalPlayer = Players.LocalPlayer
local LocalName = LocalPlayer.Name
local PlayerClass = require(script.Player)
local Network = require(script.Parent.Network)
local StateUpdate = Network.PlayerStateUpdate
local RequestReplication = Network.RequestReplication
local UpdatePasses = Network.UpdatePlayerPasses
local PlayerLeft = Network.PlayerLeft

local Signal = require(Packages.Signal)
local Vide = require(Packages.Vide)
local Source = Vide.source

local module = {}
module.LocalPlayer = LocalPlayer
module.LocalName = LocalName
module.GlobalStates = {}
module.GlobalAdded = Signal.new()
module.DeathSignal = Signal.new()
module.StateAdded = Signal.new()
module.PlayerAdded = Signal.new()
module.Players = {[LocalName] = PlayerClass.new(LocalName, module.DeathSignal)} :: {PlayerClass.Player}

type Method = <T>(self: PlayerClass.Player, ...any) -> T
export type Player = PlayerClass.Player
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

    local PlayerObject = PlayerClass.new(Player, module.DeathSignal)
    for Index, Method in module.Methods do
        PlayerObject[Index] = Method
    end
    module.Players[Name] = PlayerObject

    module.PlayerAdded:Fire(PlayerObject)

    return PlayerObject
end

function module.PlayerExists(Player: string)
    return Players:FindFirstChild(Player)
end

function module.GetPlayer(Player: Instance | string): PlayerClass.Player
    if not Player then
        return
    end

    local IsString = typeof(Player) == "string"
    local PlayerObject = if IsString then module.Players[Player] else module.Players[Player.Name]
    if not PlayerObject and IsString and not module.PlayerExists(Player) then
        error(`[ENT Framework] Could not retrieve Instance for player with name {Player}.`)
    end

    return if not PlayerObject then module.SetupPlayer(Player) else PlayerObject
end

function module.UpdatePasses(Payload: {{Player: string, Data: {Name: string, Owned: boolean, Gifted: boolean, PurchasedAt: DateTime?}}})
    for _, Info in Payload do
        local Player = module.GetPlayer(Info.Player)
        Player:UpdatePass(Info.Data)
    end
end

function module.GetGlobal<T>(Index: string): Source.Source<T>
    local Existing: Source.Source<T>? = module.GlobalStates[Index]
    if Existing then
        return Existing
    else
        local Resolved = false
        module.GlobalAdded:Connect(function(AddedString: string, Value)
            if AddedString == Index then
                Existing = Value
                Resolved = true
            end
        end)

        while not Resolved do
            task.wait()
        end

        return Existing
    end
end

function module:Begin()
    for _, Player in Players:GetPlayers() do
        module.SetupPlayer(Player)
    end

    if not module.Players[LocalPlayer] then
        module.SetupPlayer(LocalPlayer)
    end

    Players.PlayerAdded:Connect(module.SetupPlayer)

    PlayerLeft.On(function(Player: string)
        local PlayerObject = module.Players[Player]
        if not PlayerObject then return end
        PlayerObject:Destroy()
    end)

    StateUpdate.SetCallback(function(Payload)
        if Payload.Player == nil then
            local Existing = module.GlobalStates[Payload.Index]
            if module.GlobalStates[Payload.Index] then
                Existing(Payload.Value.Value)
            else
                Existing = Source(Payload.Value.Value)
                module.GlobalStates[Payload.Index] = Existing

                module.GlobalAdded:Fire(Payload.Index, Existing)
            end

            return
        end

        local Player = module.GetPlayer(Payload.Player)
        if not Player[Payload.Index] then
            local State = Player:UpdateState(Payload.Index, Payload.Value)
            module.StateAdded:Fire(Payload.Index, State, Player)
        else
            Player:UpdateState(Payload.Index, Payload.Value)
        end
    end)

    UpdatePasses.On(module.UpdatePasses)
    RequestReplication.Fire()
end

return module