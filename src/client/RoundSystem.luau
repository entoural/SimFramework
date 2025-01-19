local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local Framework = require(script.Parent.Framework)

local LiveTiles = workspace.LiveTiles
local Burst = Framework.UI.Animations.GeneralEffects.Burst
local RoundInfo = Framework.UI.GuiObjects.RoundInfo
local Info = RoundInfo.Info
local ColorInfo = RoundInfo.ColorInfo
local Scale = ColorInfo.UIScale
local RoundState = Framework.PlayerManager.GetGlobal("RoundState")
local ShowingTiles = Framework.PlayerManager.GetGlobal("ShowingTiles")

local IsInRound

local Colors: {[string]: BrickColor} = {
	Blue = BrickColor.Blue(),
	White = BrickColor.White(),
	Cyan = BrickColor.new("Toothpaste"),
	Pink = BrickColor.new("Pink"),
	Orange = BrickColor.new("Neon orange"),
	Brown = BrickColor.new("Brown"),
	Green = BrickColor.Green(),
	Purple = BrickColor.new("Royal purple"),
	Black = BrickColor.Black(),
	Red = BrickColor.Red(),
	Yellow = BrickColor.Yellow()
}

local CurrentTask: thread?
local function DisplayText(Text: string, Position: UDim2?, TextColor: Color3?, HideIn: number?)
    if CurrentTask then
        task.cancel(CurrentTask)
    end
    CurrentTask = nil

    Info.Position = Position or UDim2.fromScale(.5, .2)
    Info.TextColor3 = TextColor or Color3.new(1, 1, 1)
    Info.Text = Text
    ColorInfo.Visible = false
    Info.Visible = true
    Burst(Info, 2.5, 2)

    if HideIn then
        CurrentTask = task.spawn(function()
            task.wait(HideIn)
            Info.Visible = false
        end)
    end
end

local function HideText()
    if CurrentTask then
        task.cancel(CurrentTask)
    end

    Spr.target(Scale, 1, 4, {Scale = 0})
    Info.Visible = false
end

local StateEvents = {
    NewRound = function(StartsIn: number)
        DisplayText(`Game starting! ({StartsIn})!`)
    end,

    RoundEnded = function(NextIn: number)
        DisplayText(`Game ended! ({NextIn})!`)
    end,

    StartedRound = function(StartsIn: number)
        DisplayText(StartsIn, UDim2.fromScale(.5, .5), Color3.new(0, 1, 0))
    end,

    BlankIntermission = function()
        HideText()
    end,

    Color = function(Color: string, TimeLeft: number)
        if not IsInRound then
            return
        end

        Info.Visible = false
        Spr.target(Scale, 0.5, 5, {Scale = 1})
        Spr.target(ColorInfo.Progress, 1, 0.5, {Size = UDim2.fromScale((TimeLeft) / 4, 0.15)})
        ColorInfo.TextLabel.Text = TimeLeft + 1
        ColorInfo.TextLabel.TextColor3 = Colors[Color].Color
        ColorInfo.Visible = true
    end
}

local function ToggleTile(Tile: BasePart, Enabled: number?)
    Spr.target(Tile, 1, 2, {Transparency = if Enabled then 0 else 1})

    local Collision = Tile:FindFirstChild("Collision")
    if Collision then
        Collision.CanCollide = if Enabled then true else false
    end
end

return function(InRound: Vide.Source<boolean>)
    Vide.effect(function()
        local State = RoundState()

        if StateEvents[State.State] then
            task.spawn(StateEvents[State.State], State.Num1, State.Num2)
        else
            task.spawn(StateEvents.Color, State.State, State.Num1)
        end
    end)
    Vide.effect(function()
        local State = ShowingTiles()

        for _, Tile in LiveTiles:GetChildren() do
            ToggleTile(Tile, table.find(State, Tile))
        end
    end)

    Vide.effect(function()
        print("Updating")
        IsInRound = InRound()
        print(IsInRound)
        Info.Visible = IsInRound
        ColorInfo.Visible = IsInRound
    end)
end