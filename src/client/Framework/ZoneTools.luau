local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local ZonePlus = require(Packages.ZonePlus)
local Player = Players.LocalPlayer

local module = {}
module.Zones = {}

function module.LinkPartToCallback(Part: BasePart, Callback: () -> ())
    local Zone = ZonePlus.new(Part)
    module.Zones[Part] = Zone

    Zone.playerEntered:Connect(function(Entered: Player)
        if Entered ~= Player then
            return
        end

        Callback()
    end)
end

return module