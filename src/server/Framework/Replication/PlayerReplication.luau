local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local SharedUtility = require(Shared.Utility)
local PlayerManager = require(script.Parent.Parent.PlayerManager)
local Network = require(script.Parent.Parent.Network)
local RequestReplication = Network.RequestReplication
local ReplicationUpdate = Network.PlayerStateUpdate

local Replication = {}

Replication.ReplicationList = {}
Replication.ReplicatorStates = {}

function Replication:Replicator(Player: Player, State: () -> any, StateName: string, IsGlobal: boolean?)
    SharedUtility.RootedEffect(function()
        local Payload = {Value = {Value = State(), Type = StateName}, Player = Player.Name, Index = StateName}

        if IsGlobal then
            ReplicationUpdate.FireAll(Payload)
        else
            ReplicationUpdate.Fire(Player, Payload)
        end
    end)
end

function Replication:ReplicateState(Index: string, IsGlobal: boolean?)
    table.insert(self.ReplicationList, {Index = Index, Global = IsGlobal})

    for _, Player in PlayerManager.PlayerList do
        if Player[Index] then
            self:Replicator(Player.Player, Player[Index], Index, IsGlobal)

            if IsGlobal then
                table.insert(self.ReplicatorStates, {State = Player[Index], Index = Index, Player = Player.Name})
            end
        end
    end
end

function Replication:ReplicatePlayer(PlayerInstance: Player)
    local Player = PlayerManager:GetPlayer(PlayerInstance)
    if not Player or (Player and Player.Replicating) then
        warn(`[ENT Framework] {if PlayerInstance then PlayerInstance.Name else "Player"} does not exist or is already replicating data`)
        return
    end

    Player.Replicating = true

    for _, State in self.ReplicationList do
        local Index = State.Index
        local Global = State.Global

        if Player[Index] then
            self:Replicator(PlayerInstance, Player[Index], Index, Global)

            if Global then
                table.insert(self.ReplicatorStates, {State = Player[Index], Index = Index, Player = PlayerInstance.Name})
            end
        end
    end

    for _, State in self.ReplicatorStates do
        if State.Player then
            ReplicationUpdate.FireAll({Value = {Value = State.State(), Type = State.Index}, Player = State.Player, Index = State.Index})
        else
            table.remove(self.ReplicatorStates, table.find(self.ReplicatorStates, State))
        end
    end
end

function Replication:Listen()
    RequestReplication.SetCallback(function(Player: Player)
        self:ReplicatePlayer(Player)
    end)
end


return Replication