local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Source = Vide.source
local Effect = Vide.effect
local Root = Vide.root
local Untrack = Vide.untrack
local Framework = require(script.Parent.Framework)
local Types = Framework.Types

local FloorTemplate = ReplicatedStorage:WaitForChild("Floor")
local FloorHeight = 25.04

local Building = require(script.Building)

local Buildings: {
    Objects: {Building.Building}
} = {}
Buildings.Objects = {}

function Buildings.AssignPlayerBuilding(Player: Types.PlayerObject)
    local Found = false
    for _, Object: Building.Building in Buildings.Objects do
        if not Object.AssignedPlayer() then
            Object:Assign(Player)

            Found = true
            break
        end
    end

    if not Found then
        error(`Unable to assign a building for player {Player.Name}`)
    end

    return true
end

for _, Model: Model in workspace:WaitForChild("BuildingModels"):GetChildren() do
    Root(function(Destroy: () -> ())
        Buildings.Objects[Model] = Building.new(Model, Destroy)
    end)
end

Framework.PlayerManager.PlayerAdded:Connect(Buildings.AssignPlayerBuilding)
Framework.PlayerManager.PlayerLeft:Connect(function(Player: Types.PlayerObject)
    local PlayerBuilding: Building.Building? = Player.Building()
    if PlayerBuilding and PlayerBuilding.Destructor then
        PlayerBuilding.Destructor()
        PlayerBuilding.AssignedPlayer(nil)
        PlayerBuilding.Floors(1)
    end
end)
Framework.Network.ChangeFloors.On(function(Player, NewFloors)
    Framework.PlayerManager:GetPlayer(Player).Floors(NewFloors)
end)