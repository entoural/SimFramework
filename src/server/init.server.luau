local Framework = require(script.Framework)

local DataStates = {
    {[1] = "Cash", [2] = nil, [3] = "IntValue", [4] = true, [5] = true, [6] = "GetData"}
}

Framework.GeneralSetup:LoadDataStates(DataStates)

Framework:Start()