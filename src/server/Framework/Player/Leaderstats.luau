local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Create = Vide.create

export type LeaderstatLinks = {{StateName: string,  Convert: (any) -> any, InstanceType: string}}

return function (LeaderstatLinks: LeaderstatLinks, PlayerObject)
    local DataObjects = {}

    for _, Link in LeaderstatLinks do
        if not PlayerObject[Link.StateName] then
            continue
        end

        local State = PlayerObject[Link.StateName]
        table.insert(DataObjects, Create(Link.InstanceType) {
            Name = Link.StateName,
            Value = function()
                if Link.Convert then
                    return Link.Convert(State())
                else
                    return State()
                end
            end
        })
    end

    return Create "Folder" {
        Name = "leaderstats",
        table.unpack(DataObjects)
    }
end