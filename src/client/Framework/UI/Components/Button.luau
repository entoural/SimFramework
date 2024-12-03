local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Signal = require(Packages.Signal)

type Props = {Instance: GuiButton, Toggle: boolean?, ClickValue: boolean?}

return function(Source: Vide.source<boolean>, Props: Props)
    local Button = {
        Clicked = Signal.new(),
        Hovered = Vide.source(),
        Locked = false,
        Source = Source,
        Props = Props,
        Instance = Props.Instance
    }

    if Props.Toggle then
        Button.Toggled = Source
    end

    Button.Instance.MouseButton1Click:Connect(function()
        Button.Clicked:Fire()
        if Props.Toggle and not Button.Locked then
            Source(not Source())
        else
            Source(Props.ClickValue)
        end
    end)

    Button.Instance.MouseEnter:Connect(function(x, y)
        Button.Hovered(true)
    end)
    Button.Instance.MouseLeave:Connect(function(x, y)
        Button.Hovered(false)
    end)

    return Button
end