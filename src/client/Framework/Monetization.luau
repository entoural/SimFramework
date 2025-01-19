local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Library = require(Shared.Library)
local PlayerManager = require(script.Parent.PlayerManager)
local Player = PlayerManager.GetPlayer(PlayerManager.LocalPlayer)

local module = {}

function module.GetId(ProductName: string)
    local Id = Library.Gamepasses[ProductName] or Library.Products[ProductName]
    if not Id then
        warn(`[ENT Framework] Could not retrieve id for gamepass / dev product "{ProductName}"`)
    end

    return Id
end

function module.PromptPass(PassName: string)
    local Id = module.GetId(PassName)
    if Player:HasPass(PassName) or not Id then
        return
    end

    MarketplaceService:PromptGamePassPurchase(Player.Player, Id)
end

function module.PromptProduct(ProductName: string)
    local Id = module.GetId(ProductName)
    MarketplaceService:PromptProductPurchase(Player.Player, Id)
end

return module