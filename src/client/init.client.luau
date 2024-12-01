local Players = game:GetService("Players")
local Color = require(script.Framework.UI.Color)
local Modifiers = require(script.Framework.UI.Modifiers)
local Combinations = require(script.Framework.UI.Combinations)
local Animations = require(script.Framework.UI.Animations)
local RichText = require(script.Framework.UI.RichText)
local plr = Players.LocalPlayer
local gui = plr:WaitForChild("PlayerGui")

local frame = gui:WaitForChild("Main").Frame

--local Gradient = Color.ApplyGradient(gui:WaitForChild("Main").Frame, Color.ColorToShineColors(Color3.new(0.819607, 0.839215, 0.827450)))
Modifiers.ApplyCorner(frame)
Modifiers.ApplyStroke(frame)
--Animations.GradientAnimations.LoopedSpin(Gradient, nil, "X", 0)
Combinations.ShineGradient(frame, 0, Color3.new(0, 0.8, 0.2))
Combinations.ShineImageGradient(frame.ImageLabel2, 2, 0)
Combinations.ContinuousImageShine(frame.ImageLabel)
frame.TextLabel.Text = RichText.Stroke(RichText.Color("this is some text"))