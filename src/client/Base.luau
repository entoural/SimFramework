local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility = require(Shared.Utility)
local RocketInfo = require(Shared.RocketInfo)
local RocketOrder = require(Shared.RocketOrder)
local Framework = require(script.Parent.Framework)
local Packages  = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local Root = Vide.root
local Effect = Vide.effect

local Player = Framework.PlayerManager.LocalObject
local Building = Player:GetState("BuildingModel")
local Floors = Player:GetState("Floors")
local Cash = Player:GetState("Cash")
local Rocket = Player:GetState("Rocket")
local RocketLevel = Player:GetState("RocketLevel")
local Destructor: () -> ()

local BaseJanitor = Janitor.new()

local function NewBuilding(BuildingModel: Model)
    local GUIs: Folder = BuildingModel.TopOfBuilding.GUIs
    local RocketBuy: BillboardGui = GUIs.RocketBuy
    local BuyLabel: TextLabel = RocketBuy.Frame.Label
    local BuyCost: TextLabel = RocketBuy.Frame.Cost
    local FloorBuy: BillboardGui = GUIs.FloorBuy
    local FloorBuyCost: TextLabel = FloorBuy.Frame.Cost
    local PurchaseZones: Folder = BuildingModel.TopOfBuilding.PurchaseZones

    local RocketDebounce = false
    BaseJanitor:Add(PurchaseZones.CashRocketBuy.Touched:Connect(function(Hit: BasePart)
        if not Player.Character() or Hit.Parent ~= Player.Character() or RocketDebounce then return end

        RocketDebounce = true

        local CurrentRocket = Rocket()
        local CurrentLevel = RocketLevel()
        local CurrentCash = Cash()
        local RocketData = RocketInfo[CurrentRocket]
        local BaseCost = RocketData.BaseCost
        local Next = RocketOrder[table.find(RocketOrder, CurrentRocket) + 1]
        local MaxUpgrade = BaseCost + ((Next and (RocketInfo[Next].BaseCost - BaseCost) or (BaseCost * 3) - BaseCost)) * 0.6

        if CurrentLevel == RocketData.MaxLevel and Next and CurrentCash >= RocketInfo[Next].BaseCost then
            Framework.Network.BuyNextRocket.Fire()
        elseif CurrentLevel < RocketData.MaxLevel and CurrentCash >= BaseCost + (MaxUpgrade - BaseCost) * (CurrentLevel / RocketData.MaxLevel) then
            Framework.Network.UpgradeLevel.Fire()
        end

        task.wait(.75)
        RocketDebounce = false
    end))

    local FloorDebounce = false
    BaseJanitor:Add(PurchaseZones.CashFloorBuy.Touched:Connect(function(Hit: BasePart)
        if not Player.Character() or Hit.Parent ~= Player.Character() or FloorDebounce then return end

        FloorDebounce = true
        Framework.Network.BuyNextFloor.Fire()
        task.wait(.25)
        FloorDebounce = false
    end))

    Root(function(Destroy: () -> ())
        BaseJanitor:Add(Destroy)
        Effect(function()
            local NewFloorCount = Floors()
            local NewRocket = Rocket()
            local NewLevel = RocketLevel()

            FloorBuyCost.Text = `${Utility.Abbreviate(500 * 1.1^(NewFloorCount - 1))}`

            local RocketData = RocketInfo[NewRocket]
            local BaseCost = RocketData.BaseCost
            local Next = RocketOrder[table.find(RocketOrder, NewRocket) + 1]
            local MaxUpgrade = BaseCost + ((Next and (RocketInfo[Next].BaseCost - BaseCost) or (BaseCost + 10000) - BaseCost)) * 0.6
            if NewLevel == RocketData.MaxLevel and Next then
                BuyLabel.Text = "Buy Next"
                BuyLabel.TextColor3 = Color3.fromRGB(11, 137, 255)
                BuyLabel.UIStroke.Color = Color3.fromRGB(17, 81, 76)

                BuyCost.Text = `${Utility.Abbreviate(RocketInfo[Next].BaseCost)}`
            elseif NewLevel < RocketData.MaxLevel then
                BuyLabel.Text = "Upgrade"
                BuyLabel.TextColor3 = Color3.fromRGB(65, 255, 12)
                BuyLabel.UIStroke.Color = Color3.fromRGB(21, 81, 17)

                BuyCost.Text = `${Utility.Abbreviate(BaseCost + (MaxUpgrade - BaseCost) * (NewLevel / RocketData.MaxLevel))}`
            else
                BuyLabel.Text = "Max Rocket"
                BuyLabel.TextColor3 = Color3.fromRGB(145, 145, 145)
                BuyLabel.UIStroke.Color = Color3.fromRGB(0, 0, 0)
            end
        end)
    end)
end

return function()
    Root(function()
        Effect(function()
            if Destructor then
                BaseJanitor:Cleanup()
            end
            NewBuilding(Building())
        end)
    end)
end