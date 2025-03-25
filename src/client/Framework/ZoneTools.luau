local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local ZonePlus = require(Packages.ZonePlus)
local Player = Players.LocalPlayer

local module = {}
module.Zones = {}

function module.LinkPartToCallback(Part: BasePart, Callback: () -> ())
    local Zone = module.Zones[Part] or ZonePlus.new(Part)
    module.Zones[Part] = Zone

    Zone.playerEntered:Connect(function(Entered: Player)
        if Entered ~= Player then
            return
        end

        Callback()
    end)

    return Zone
end

function module.LinkPartToFrame(Part: BasePart, Frame: GuiObject, CustomToggledBehavior: ((Toggled: boolean?) -> ())?)
    local Zone = module.Zones[Part] or ZonePlus.new(Part)
    module.Zones[Part] = Zone

    Zone.playerEntered:Connect(function(Entered: Player)
        if Entered == Player then
            Frame.Visible = true
            if CustomToggledBehavior then
                CustomToggledBehavior(true)
            end
        end
    end)

    Zone.playerExited:Connect(function(Entered: Player)
        if Entered == Player then
            if CustomToggledBehavior then
                CustomToggledBehavior(false)
            end
            Frame.Visible = false
        end
    end)

    return Zone
end

return module