local Players = game:GetService("Players")
local Util = {}

function Util.KillPart(Part: BasePart)
    local Debounces = {}
    Part.Touched:Connect(function(Hit)
        if not Hit.Parent then
            return
        end

        if not Hit.Parent:FindFirstChildOfClass("Humanoid") then
            return
        end

        local Player = Players:GetPlayerFromCharacter(Hit.Parent)
        if Player and not Debounces[Player] then
            Debounces[Player] = true
            Player:LoadCharacter()
            task.wait(1)
            Debounces[Player] = nil
        end
    end)
end


return Util