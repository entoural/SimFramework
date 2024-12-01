local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Octree = require(Shared.Octree)

local module = {}

module.new = Octree.new


return module