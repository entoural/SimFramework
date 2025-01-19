local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
PlayerGui:WaitForChild("ScreenGui").Enabled = false
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local goalSize = UDim2.fromOffset(0, 0)

UserInputService.InputBegan:Connect(function(input, gpe)
	--if gpe then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	local startPosition = UserInputService:GetMouseLocation()
	local startX = startPosition.X
	local startY = startPosition.Y

	local frames = {}

	for i = 1, math.random(3, 5) do
		local Frame = Instance.new("Frame")
		Frame.Size = UDim2.fromOffset(25, 25)
		Frame.Position = UDim2.fromOffset(0, 0)
		Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		Frame.ZIndex = 10
		Frame.BackgroundColor3 = Color3.new(1, 1, 1)
		Frame.BorderSizePixel = 0
		Frame.Visible = false
		
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.75
		stroke.Color = Color3.new(0.2, 0.2, 0.2)
		stroke.Parent = Frame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = Frame

		local constraint = Instance.new("UIAspectRatioConstraint")
		constraint.AspectRatio = 1
		constraint.Parent = Frame

		Frame.Parent = gui


		table.insert(frames, Frame)
	end

	for _, frame in frames do
		frame.Position = UDim2.fromOffset(startX, startY)
		frame.Visible = true
		
		local distance = math.random(30, 50)

		local ranAngle = math.random(1, 360)
		local xOffset = math.sin(math.rad(ranAngle)) * distance
		local yOffset = math.cos(math.rad(ranAngle)) * distance

		local goalPosition = UDim2.fromOffset(startX + xOffset, startY + yOffset)
		local Tween = TweenService:Create(frame, ti, {Position = goalPosition, Size = goalSize})
		Tween.Completed:Once(function()
			frame.Visible = false
			Tween:Destroy()
		end)
		Tween:Play()
		
		task.wait()
	end
end)
