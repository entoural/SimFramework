local Players = game:GetService("Players")
local Framework = require(script.Framework)

local DataStates = {
    {[1] = "Mana", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"},
    {[1] = "Rebirths", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"},
    {[1] = "Aura", [2] = nil, [3] = "IntValue", [4] = true, [5] = false, [6] = "GetData"}
}

Framework.GeneralSetup:LoadDataStates(DataStates)
Framework.PlayerManager:AddState("Training", false)
Framework.Replication.PlayerReplication:ReplicateState("Training", false)

Framework:Start()

task.wait(5)

Framework.PlayerManager.PlayerList[Players.entoural].Mana(100)