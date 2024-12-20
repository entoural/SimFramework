local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)

return function(Instance: GuiObject): Vide.Source<boolean>
    local Hovered = Vide.source(false)
    Instance.MouseEnter:Connect(function()
        Hovered(true)
    end)
    Instance.MouseLeave:Connect(function()
        Hovered(false)
    end)

    return Hovered
end