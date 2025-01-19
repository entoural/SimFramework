local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Framework = require(script.Parent.Framework)
local UI = Framework.UI
local Clock = require(Shared.Utility).Clock

local Current = 1

local function Next()
    Current = if Current == 6 then 1 else Current + 1

    for _, v in UI.GuiObjects["SideGamepasses"]:GetChildren() do
        if not v:IsA("Frame") then continue end

        if tonumber(v.Name) == Current then
            v.Visible = true
        else
            v.Visible = false
        end
    end
end

return function()
    Clock(30, Next)
end