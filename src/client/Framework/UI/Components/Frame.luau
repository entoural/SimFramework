local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Library = require(ReplicatedStorage:WaitForChild("Shared").Library)
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local Spr = require(Packages.Spr)
local Camera = require(script.Parent.Parent.Parent.Camera)
local Untrack = Vide.untrack

local Effect = Instance.new("ImageLabel")
Effect.Image = "rbxassetid://126920850081338"
Effect.BackgroundTransparency = 1
Effect.ZIndex = -1
Effect.ImageTransparency = 1
Effect.Size = UDim2.fromScale(1, 1)
Effect.Parent = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")

local Blur = Lighting:WaitForChild("Blur")

local NonSimulatenousFrames = {}
local AllFrames = {}

return function(Frame: GuiObject, Simultaneous: boolean?)
    local Source = Vide.source(false)
    local _Janitor = Janitor.new()

    local Attribute = Frame:GetAttribute("ThemeColor")
    local Color = if Attribute then Attribute else Library.GameThemeColor
    local Scale = Frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", Frame)
    local OriginalPosition = Frame.Position
    local ClosedPosition = UDim2.fromScale(OriginalPosition.X.Scale, OriginalPosition.Y.Scale + 0.3)

    if not Simultaneous then
        table.insert(NonSimulatenousFrames, Source)
    end
    table.insert(AllFrames, Source)

    Frame.Visible = false
    Frame.Position = ClosedPosition
    Scale.Scale = 0.8

    local First = true
    Vide.effect(function()
        local Opened = Source()
        _Janitor:Cleanup()

        if First then
            First = false
            return
        end


        local function Animate()
            _Janitor:Add(task.spawn(function()
                if Opened then
                    Frame.Visible = true
                end

                Spr.target(Frame, 0.5, 4, {Position = if Opened then OriginalPosition else ClosedPosition})
                Spr.target(Scale, 0.5, 4, {Scale = if Opened then 1 else 0.8})

                if not Opened then
                    local FoundEnabled = false
                    for _, FrameSource in AllFrames do
                        if Untrack(FrameSource) then
                            FoundEnabled = true
                        end
                    end

                    if not FoundEnabled then
                        Spr.target(Blur, 1, 4, {Size = 1})
                        Spr.target(Effect, 1, 4, {ImageTransparency = 1})
                        Camera.AdjustFOV(70)
                    end
                else
                    Spr.target(Effect, 1, 4, {ImageTransparency = 0, ImageColor3 = Color})
                    Spr.target(Blur, 1, 4, {Size = 3})
                    Camera.AdjustFOV(90)
                end

                task.wait(0.1)

                Frame.Visible = Opened
            end))
        end


        if not Simultaneous and Opened then
            local WasFound = false
            for _, FrameSource in NonSimulatenousFrames do
                if Untrack(FrameSource) and FrameSource ~= Source then
                    WasFound = true
                    FrameSource(false)
                end
            end

            if WasFound then
                _Janitor:Add(task.delay(0.1, Animate))
            else
                Animate()
            end
        else
            Animate()
        end
    end)

    return Source
end