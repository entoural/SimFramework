local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Library = require(Shared.Library)
local Types = require(script.Parent.Types)

local module = {}

module.GamepassCallbacks = {} :: {[string]: (Player: Types.PlayerObject) -> ()}

function module.CheckPasses(Player: Types.PlayerObject)
    for Name, Id in Library.Gamepasses do
        local Gamepass = Player.Data.OwnedGamepasses[Name]
        if not Gamepass then
            Gamepass = {Owned = false, Gifted = false}
            Player.Data.OwnedGamepasses[Name] = Gamepass
        end
        local Owned = Gamepass and Gamepass.Owned

        local Callback = module.GamepassCallbacks[Name]
        if Owned and Callback then
            Callback(Player)
        elseif Owned then
            continue
        end

        pcall(function()
            if MarketplaceService:UserOwnsGamePassAsync(Player.Id, Id) then
                Gamepass.Owned = true
                Gamepass.Gifted = false

                if Callback then
                    Callback(Player)
                end

                Gamepass.PurchasedAt = DateTime.now()
            end
        end)
    end
end

return module