local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = require(script.Parent.Framework)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Launch = require(script.Parent.Launch)
local Iris = require(Packages.Iris).Init()

Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorLight)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)


Iris:Connect(function()
    Iris.Window({"Panel"})
        local FloorInput = Iris.InputNum({"Change Floor Count", 1, 1, 200})

        if FloorInput.numberChanged() then
            Framework.Network.ChangeFloors.Fire(FloorInput.state.number.value)
        end

        Iris.Tree({"Rocket Launch"})
            local MaxHeightIncrease = Iris.SliderNum({"Max Height Increase", 1, 100, 1000})
            local Gravity = Iris.SliderNum({"Gravity", 0.1, 196.2 / 4, 196.2})
            local HorizontalSpeed = Iris.SliderNum({"Horizontal Speed", 1, 100, 1000})
            local SpeedMultiplier = Iris.SliderNum({"Speed Multiplier", 0.1, 1, 10})
            local Accuracy = Iris.SliderNum({"Accuracy", 0.01, 0, 1})
            if Iris.Button({"Launch Rocket"}).clicked() then
                local Data = {
                    MaxHeightIncrease = MaxHeightIncrease.state.number.value,
                    Gravity = Gravity.state.number.value,
                    HorizontalSpeed = HorizontalSpeed.state.number.value,
                    SpeedMultiplier = SpeedMultiplier.state.number.value
                }
                Framework.Network.RequestLaunch.Fire({Accuracy = Accuracy.state.number.value, Data = Data})
            end
        Iris.End()

    Iris.End()
end)


return {}