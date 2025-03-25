local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Spr = require(Packages.Spr)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility = require(Shared.Utility)
local Formulas = require(Shared.Formulas)

local Framework = require(script.Parent.Framework)
local Player = Framework.Player
local Cash: Vide.source<number> = Player.Cash
local RecordScore: Vide.source<number> = Player.RecordScore
local Rebirths: Vide.source<number> = Player.Rebirths
local UI = Framework.UI
local Frame = UI.GuiObjects.Rebirth
local InsideMain = Frame.Main.Inside.Frame
local CashAmount = InsideMain.CashAmount
local RebirthAmount = InsideMain.RebirthAmount
local ScoreMultiplier = InsideMain.ScoreMultiplier
local SpeedMultiplier = InsideMain.SpeedMultiplier
local Main = InsideMain.Main

return function()
    Vide.effect(function()
        local NewRebirths = Rebirths()
        local NewRecord = RecordScore()

        local SpeedMulti, ScoreMulti = Formulas.GetRebirthModifiers(NewRebirths)
        local NewSpeedMulti, NewScoreMulti, MinimumScore = Formulas.GetRebirthModifiers(NewRebirths + 1)

        SpeedMultiplier.Current.TextLabel.Text = Utility.Percent(SpeedMulti - 1)
        SpeedMultiplier.Next.TextLabel.Text = Utility.Percent(NewSpeedMulti - 1)
        ScoreMultiplier.Current.TextLabel.Text = Utility.Round(ScoreMulti).."x"
        ScoreMultiplier.Next.TextLabel.Text = Utility.Round(NewScoreMulti).."x"
        RebirthAmount.Current.TextLabel.Text = NewRebirths
        RebirthAmount.Next.TextLabel.Text = NewRebirths + 1

        local CanRebirth = NewRecord >= MinimumScore
        Main.Progression.Text.Text = `Max Distance: {Utility.Abbreviate(math.clamp(NewRecord, 0, MinimumScore))}/{Utility.Abbreviate(MinimumScore)}`
        Main.Buttons.RebirthButton.ImageColor3 = if CanRebirth then Color3.fromRGB(84, 255, 11) else Color3.fromRGB(255, 0, 4)

        local Progress = math.clamp(NewRecord / MinimumScore, 0, 1)
        Main.Progression.Bar.Text.Text = Utility.Percent(Progress)
        Spr.target(Main.Progression.Bar.ProgressionBar, 1.2, 3, {Size = UDim2.fromScale(Progress, 1)})
    end)

    Vide.effect(function()
        local NewCash = Cash()

        CashAmount.Current.TextLabel.Text = Utility.Abbreviate(NewCash)
        CashAmount.Next.TextLabel.Text = 0
    end)

    UI.GetEmptyButtonInteraction(Main.Buttons.RebirthButton).Clicked:Connect(function()
        local Minimum = Formulas.GetRebirthModifiers(Rebirths() + 1)
        if RecordScore() < Minimum then return end
        Framework.Network.Rebirth.Fire()
    end)
end