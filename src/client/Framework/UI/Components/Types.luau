local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Signal = require(Packages.Signal)

export type Props = {Instance: GuiButton, Toggle: boolean?, ClickValue: boolean?}

export type HoverInteraction = Vide.Source<boolean>

export type Button = {
    Clicked: RBXScriptSignal,
    Hovered: HoverInteraction,
    Locked: boolean,
    Source: Vide.source<boolean>,
    Props: Props,
    Instance: GuiButton
}


local Types = {}


return Types