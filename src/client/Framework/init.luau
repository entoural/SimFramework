local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Vide = require(Packages.Vide)

local Framework = {}

Framework.Player = Players.LocalPlayer
Framework.Gui = Framework.Player:WaitForChild("PlayerGui")

local function getLength(dictionary: {[any]: any})
    local total = 0
    for _, _ in dictionary do
        total += 1
    end

    return total
end

-- Network
Framework.Remotes = Shared.Remotes

Framework.InitialDataReceived = false
Framework.InitialDataDependencies = {}
Framework.ReadyModules = {}

local InitialDataRequest = require(Shared.Remotes.InitialDataRequest):Client()

function Framework:RegisterInitialDataDependency(name: string)
    assert(not self.InitialDataReceived, `[ENT Framework] Attempted to register {name} as an initial data dependency after initial data was received.`)
    table.insert(self.InitialDataDependencies)
end

function Framework:ModuleReadyForData(name: string)
    assert(table.find(self.InitialDataDependencies, name), `[ENT Framework] Declared {name} as ready to receive intitial data without it being registered as a dependency.`)
    assert(not self.InitialDataReceived, `[ENT Framework] Attempted to register {name} as ready for data after initial data was received.`)
    self.ReadyModules[name] = true

    if getLength(self.ReadyModules) == #self.InitialDataDependencies then
        InitialDataRequest:Fire()
    end
end

-- Replication
Framework.LocalStates = {}
Framework.GlobalStates = {}

local ReplicationUpdate = require(Framework.Remotes.ReplicationUpdate):Client()

ReplicationUpdate:Connect(function(Data: {State: any, Player: Player, Index: string})
    local StateTable

    if Data.Player == Framework.Player then
        StateTable = Framework.LocalStates
    else
        if not Framework.GlobalStates[Data.Player] then
            Framework.GlobalStates[Data.Player] = {}
        end

        StateTable = Framework.GlobalStates[Data.Player]
    end

    if StateTable[Data.Index] then
        StateTable[Data.Index](Data.State)
    else
        StateTable[Data.Index] = Vide.source(Data.State)
    end
end)

function Framework:GetLocalState(Index: string)
    while not self.LocalStates[Index] do
        task.wait()
    end

    return self.LocalStates[Index]
end

return Framework