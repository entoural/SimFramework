local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vide = require(ReplicatedStorage.Packages.Vide)
local Color = require(script.Framework.UI.Color)
local Modifiers = require(script.Framework.UI.Modifiers)
local Combinations = require(script.Framework.UI.Combinations)
local Animations = require(script.Framework.UI.Animations)
local sg = require(script.Framework.UI.Components.SlidingGradient)
local hi = require(script.Framework.UI.Components.HoverInteraction)
local RichText = require(script.Framework.UI.RichText)
local plr = Players.LocalPlayer
local gui = plr:WaitForChild("PlayerGui")

vide.root(function(destroy)
    local inst = gui:WaitForChild("ScreenGui").Canva.Shop.MainFrame.ScrollingFrame.LargeFrame
    sg(hi(inst), inst, inst:GetAttribute("SlidingGradient"))
end)


--[[local frame = gui:WaitForChild("Main").Frame

--local Gradient = Color.ApplyGradient(gui:WaitForChild("Main").Frame, Color.ColorToShineColors(Color3.new(0.819607, 0.839215, 0.827450)))
Modifiers.ApplyCorner(frame)
Modifiers.ApplyStroke(frame)
--Animations.GradientAnimations.LoopedSpin(Gradient, nil, "X", 0)
Combinations.ShineGradient(frame, 0, Color3.new(0, 0.8, 0.2))
Combinations.ShineImageGradient(frame.ImageLabel2, 1, 0)
Combinations.ContinuousImageShine(frame.ImageLabel)
frame.TextLabel.Text = RichText.Stroke(RichText.Color("this is some text"))

require(ReplicatedStorage.Shared.Utility).Clock(5, function()
    Animations.GeneralEffects.Shake(frame.TextLabel)
end)

require(script.Framework.PlayerManager):Begin()
local state = require(script.Framework.PlayerManager).GetPlayer(Players.LocalPlayer):GetState("Mana")
print(state())

require(ReplicatedStorage.Packages.Vide).root(function()
    require(ReplicatedStorage.Packages.Vide).effect(function()
        print(state())
    end)
end)]]