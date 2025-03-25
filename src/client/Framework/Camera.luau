local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local CameraShaker = require(Shared.Utility).CameraShaker
local Spr = require(Packages.Spr)
local CC = workspace.CurrentCamera

local module = {}

local function ShakeCamera(ShakeCf)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * ShakeCf
end
module.Shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, ShakeCamera)

function module.AdjustFOV(NewFOV: number, Frequency: number?)
    Spr.target(CC, 1, Frequency or 3, {FieldOfView = NewFOV})
end

function module.BasicShakeSustain()
    print("Saking")
    module.Shaker:ShakeSustain(CameraShaker.Presets.Earthquake)
end

function module.EndSustain()
    print("End :(")
    module.Shaker:StopSustained(1.25)
end

return module