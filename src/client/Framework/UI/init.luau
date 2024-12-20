local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Components = script.Components
local ButtonInteraction = require(Components.ButtonInteraction)
local HoverIntraction = require(Components.HoverInteraction)
local Frame = require(Components.Frame)
local HUDButton = require(Components.HUDButton)

local module = {}
module.PlayerGui = PlayerGui
module.GuiObjects = {}

module.Frames = {}
module.WaitingOnFrame = {}

module.ExistingInteractions = {
    HoverIntractions = {},
    ButtonInteractions = {}
}

module.ComponentDependencies = {}

module.GeneralComponents = {
    SpecificReference = function(Instance: Instance)
        module.GuiObjects[Instance.Name] = Instance
    end,

    HUDButton = function(Instance: Instance)
        local Toggles = Instance:GetAttribute("Toggles")
        if not Toggles then
            warn(`[ENT Framework Client] Couldn't find "Toggles" attribute inside {Instance.Name}`)
            return
        end

        local ExistingFrame = module.Frames[Toggles]
        if ExistingFrame then
            return HUDButton(ButtonInteraction(ExistingFrame.Source, {Instance = Instance, Toggle = true, HoverInteraction = module.GetHoverInteraction(Instance)}))
        else
            module.OnFrameCreated(Toggles, function(Data)
                HUDButton(ButtonInteraction(Data.Source, {Instance = Instance, Toggle = true, HoverInteraction = module.GetHoverInteraction(Instance)}))
            end)
        end
    end,

    Frames = function(Instance: GuiObject)
        local Name = Instance.Name
        if module.Frames[Name] then
            warn(`[ENT Framework Client] Frame object already exists for {Name}`)
            return
        end

        local Source = Frame(Instance)
        module.Frames[Name] = {Source = Source, Instance = Instance}

        if module.WaitingOnFrame[Name] then
            for _, Callback in module.WaitingOnFrame[Name] do
                task.spawn(Callback)
            end
        end

        return Source
    end
}

module.SpecificComponents = {}

function module.OnFrameCreated(FrameName: string, Callback: () -> ())
    if not module.WaitingOnFrame[FrameName] then
        module.WaitingOnFrame[FrameName] = {}
    end

    table.insert(module.WaitingOnFrame[FrameName], Callback)
end

function module.GetHoverInteraction(Instance: Instance)
    local Existing = module.ExistingInteractions.HoverIntractions[Instance]
    return if Existing then Existing else HoverIntraction(Instance)
end

function module.GetFrameSource(Name: string)
    if not module.Frames[Name] then
        warn(`[ENT Framework Client] Couldn't find Frame "{Name}"`)
    end

    return module.Frames[Name].Source
end

function module.ExtractComponents(Instance: Instance)
    local GeneralComponents = Instance:GetAttribute("Components")
    if not GeneralComponents then
        return {}
    end

    local FoundComponents = {}
    for Component in string.gmatch(GeneralComponents, "[^,]+") do
        table.insert(Components, Component)
    end

    return Components
end

function module.SetupInstance(Instance)
    local GeneralComponents = module.ExtractComponents(Instance)
    for _, Component in GeneralComponents do
        module.GeneralComponents[Component](Instance)
    end
end

function module.BeginSetup()
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Parent = Lighting

    game.DescendantRemoving:Connect(function(Descendant)
        for _, Interactions in module.ExistingInteractions do
            if Interactions[Descendant] then
                Interactions[Descendant] = nil
            end
        end
    end)
end

return module