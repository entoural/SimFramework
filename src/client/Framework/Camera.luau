local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)
local CC = workspace.CurrentCamera

local module = {}

function module.AdjustFOV(NewFOV: number, Frequency: number?)
    Spr.target(CC, 1, Frequency or 3, {FieldOfView = NewFOV})
end

return module