local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Signal = require(Packages.Signal)
local HoverInteraction = require(script.Parent.HoverInteraction)

type Props = {Instance: GuiButton, Toggle: boolean?, ClickValue: boolean?, HoverInteraction: Vide.Source<boolean>}

return function(Source: Vide.Source<boolean>, Props: Props)
    local Button = {
        Clicked = Signal.new(),
        Hovered = Props.HoverInteraction or HoverInteraction(Props.Instance),
        Locked = false,
        Source = Source,
        Props = Props,
        Instance = Props.Instance
    }

    Button.Instance.MouseButton1Click:Connect(function()
        Button.Clicked:Fire()
        if Props.Toggle and not Button.Locked then
            Source(not Source())
        else
            Source(Props.ClickValue)
        end
    end)

    return Button
end