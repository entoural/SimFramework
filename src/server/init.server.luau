local Players = game:GetService("Players")
local Framework = require(script.Framework)

local DataStates = {
    {[1] = "Cash", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"}
}

Framework.GeneralSetup:LoadDataStates(DataStates)
Framework.PlayerManager:AddState("Deployed", false)
Framework.Replication.PlayerReplication:ReplicateState("Deployed", false)

Framework:Start()

task.wait(5)

Framework.PlayerManager.PlayerList[Players.entoural].Cash(100)