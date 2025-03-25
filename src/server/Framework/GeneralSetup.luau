local PlayerManager = require(script.Parent.PlayerManager)
local PlayerReplication = require(script.Parent.Replication).PlayerReplication
local PlayerClass = require(script.Parent.Player)

local module = {}

function module:CreateDataState(Index: string, Convert: (any) -> any, InstanceType: string, IsReplicated: boolean, IsGlobal: boolean, Initial: any)
    if Initial == "GetData" then
        Initial = function(Object: PlayerClass.PlayerObject)
            return Object.Data[Index]
        end
    end

    PlayerManager:AddState(Index, Initial)
    PlayerManager:LinkLeaderstat(Index, Convert, InstanceType)

    if IsReplicated then
        PlayerReplication:ReplicateState(Index, IsGlobal)
    end
end

function module:ReplicateDataState(Index: string, IsGlobal: boolean?)
    local Initial = function(Object: PlayerClass.PlayerObject)
        return Object.Data[Index]
    end

    PlayerManager:AddState(Index, Initial)
    PlayerReplication:ReplicateState(Index, IsGlobal)
end

function module:ReplicateDataStates(DataStates)
    for _, DataState in DataStates do
        self:ReplicateDataState(table.unpack(DataState))
    end
end

function module:ReplicateState(Index: string, Initial: any, IsGlobal: boolean?)
    if Initial == "GetData" then
        Initial = function(Object: PlayerClass.PlayerObject)
            return Object.Data[Index]
        end
    end

    PlayerManager:AddState(Index, Initial)
    PlayerReplication:ReplicateState(Index, IsGlobal)
end

function module:ReplicateStates(DataStates)
    for _, DataState in DataStates do
        self:ReplicateState(table.unpack(DataState))
    end
end

function module:LoadDataStates(DataStates)
    for _, DataState in DataStates do
        self:CreateDataState(table.unpack(DataState))
    end
end

return module