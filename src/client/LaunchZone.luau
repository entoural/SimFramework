local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util = require(ReplicatedStorage:WaitForChild("Shared").Utility)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local Root = Vide.root
local Effect = Vide.effect

local Framework = require(script.Parent.Framework)
local Player = Framework.PlayerManager.LocalObject

local LaunchInputs = {
    Enum.UserInputType.MouseButton1,
    Enum.UserInputType.Touch
}

return function()
    local BuildingModel = Player:GetState("BuildingModel")
    local Frame = Framework.UI.GuiObjects.LaunchBar
    local Marker = Frame.Marker
    local LaunchJanitor = Janitor.new()
    local Zone

    local UpTI = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local DownTI = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local UpTween = TweenService:Create(Marker, UpTI, {Position = UDim2.fromScale(.868, 0)})
    local DownTween = TweenService:Create(Marker, DownTI, {Position = UDim2.fromScale(.868, 1)})

    Util.RootedEffect(function()
        local Building = BuildingModel()

        if Zone then
            Zone:Destroy()
        end

        Zone = Framework.ZoneTools.LinkPartToFrame(Building.TopOfBuilding.LaunchZone, Frame, function(Toggled: boolean)
            LaunchJanitor:Cleanup()
            if not Toggled then
                return
            end

            LaunchJanitor:Add(function()
                UpTween:Cancel()
                DownTween:Cancel()
                --Marker.Position = UDim2.fromScale(1, 0.5)
            end)

            LaunchJanitor:Add(task.spawn(function()
                while true do
                    UpTween:Play()
                    UpTween.Completed:Wait()
                    DownTween:Play()
                    DownTween.Completed:Wait()
                end
            end))

            LaunchJanitor:Add(UserInputService.InputEnded:Connect(function(Input, GPE)
                if GPE or not table.find(LaunchInputs, Input.UserInputType) then
                    return
                end

                Framework.Network.RequestLaunch.Fire(1 - Marker.Position.Y.Scale)
                --Frame.Visible = false
                LaunchJanitor:Cleanup()
            end))
        end)
    end)
end