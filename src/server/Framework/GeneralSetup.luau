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

function module:LoadDataStates(DataStates)
    for _, DataState in DataStates do
        self:CreateDataState(table.unpack(DataState))
    end
end

return module