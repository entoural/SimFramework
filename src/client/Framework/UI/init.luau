local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Utility = require(Shared.Utility)
local Vide = require(Packages.Vide)
local Components = script.Components
local Network = require(script.Parent.Network)
local PlayerManager = require(script.Parent.PlayerManager)
local Monetization = require(script.Parent.Monetization)
local ButtonInteraction = require(Components.ButtonInteraction)
local HoverIntraction = require(Components.HoverInteraction)
local BasicButton = require(Components.BasicButton)
local Frame = require(Components.Frame)
local HUDButton = require(Components.HUDButton)
local SlidingGradient = require(Components.SlidingGradient)
local Animations = require(script.Animations)
local Color = require(script.Color)
local Combinations = require(script.Combinations)
local RichText = require(script.RichText)
local Modifiers = require(script.Modifiers)

local PlayerObject = PlayerManager.GetPlayer(Player)

local module = {}
module.Animations = Animations
module.Color = Color
module.Combinations = Combinations
module.RichText = RichText
module.Modifiers = Modifiers
module.PlayerGui = PlayerGui
module.GuiObjects = {}
Vide.strict = false

module.Spinning = {}

module.Frames = {}
module.WaitingOnFrame = {}

module.ExistingInteractions = {
    HoverIntractions = {},
    ButtonInteractions = {}
}
module.HasBasicButton = {}
module.ComponentDependencies = {}

local StatEffectImages = {}

module.GeneralComponents = {
    SpecificReference = function(Instance: Instance)
        module.GuiObjects[Instance.Name] = Instance
    end,

    BasicButton = function(Instance: Instance)
        if module.HasBasicButton[Instance] then
            return
        end
        module.HasBasicButton[Instance] = true

        return BasicButton(module.GetEmptyButtonInteraction(Instance))
    end,

    HUDButton = function(Instance: Instance)
        local Toggles = Instance.Name

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
                task.spawn(Callback, {Source = Source})
            end
        end

        return Source
    end,

    StatEffect = function(Instance: GuiObject)
        StatEffectImages[Instance.Parent.Name] = Instance
    end,

    HUDStat = function(Instance: GuiObject)
        local StatName = Instance.Name
        local State = PlayerObject:GetState(StatName, true, true)

        local IsFirst = true
        local LastValue = State()
        local Prefix = Instance:GetAttribute("Prefix") or ""

        Vide.apply(Instance.TextLabel) {
            Text = Vide.derive(function()
                local Value = State()
                return if Value ~= nil then Prefix..Utility.Abbreviate(Value) else Prefix..0
            end)
        }

        Vide.effect(function()
            local Value = State()
            if IsFirst then
                IsFirst = false
                return
            end

            if (Value == nil and LastValue ~= nil) or (Value ~= nil and LastValue ~= nil and Value < LastValue) then
                LastValue = Value
                return
            end

            LastValue = Value
            Animations.GeneralEffects.Burst(Instance.Icon, 1.5, 1)
            Animations.GeneralEffects.Burst(Instance, 1.25, 1)
        end)
    end
}

local InherentBasicButtons = {"Toggles"}

module.SpecificComponents = {
    SlidingGradient = function(Instance: Instance, Input: string)
        SlidingGradient(module.GetHoverInteraction(Instance), Instance, Input)
    end,

    Spin = function(Instance: Instance, Speed: number)
        table.insert(module.Spinning, {Instance = Instance, Speed = Speed})
    end,

    Toggles = function(Instance: Instance, FrameName: string)
        local ExistingFrame = module.Frames[FrameName]
        if ExistingFrame then
            local Interaction = module.GetEmptyButtonInteraction(Instance)
            Interaction.Source = ExistingFrame.Source
            Interaction.Toggle = true
            return ButtonInteraction(ExistingFrame.Source, {Instance = Instance, Toggle = true, HoverInteraction = module.GetHoverInteraction(Instance)})
        else
            module.OnFrameCreated(FrameName, function(Data)
                ButtonInteraction(ExistingFrame.Source, {Instance = Instance, Toggle = true, HoverInteraction = module.GetHoverInteraction(Instance)})
            end)
        end
    end,

    Gamepass = function(Instance: Instance, PassName: string)
        local Interaction = module.GetEmptyButtonInteraction(Instance)
        Interaction.Clicked:Connect(function()
            Monetization.PromptPass(PassName)
        end)
    end,

    Shake = function(Instance: Instance, Input: number)
        Utility.Clock(Input, function()
            Animations.GeneralEffects.Shake(Instance, 3)
            Animations.GeneralEffects.Burst(Instance, 1.2)
        end)
    end
}

module.InstanceCallbacks = {

}

function module.OnFrameCreated(FrameName: string, Callback: (Info: {Source: Vide.Source<boolean>}) -> ())
    if not module.WaitingOnFrame[FrameName] then
        module.WaitingOnFrame[FrameName] = {}
    end

    table.insert(module.WaitingOnFrame[FrameName], Callback)
end

function module.GetHoverInteraction(Instance: Instance)
    local Existing = module.ExistingInteractions.HoverIntractions[Instance]
    return if Existing then Existing else HoverIntraction(Instance)
end

function module.GetButtonInteraction(Instance: Instance, Source: Vide.Source<boolean>, Props)
    local Existing = module.ExistingInteractions.ButtonInteractions[Instance]
    return if Existing then Existing else ButtonInteraction(Source, Props)
end

function module.GetEmptyButtonInteraction(Instance: Instance)
    local Existing = module.ExistingInteractions.ButtonInteractions[Instance]
    return if Existing then Existing else ButtonInteraction(nil, {HoverInteraction = module.GetHoverInteraction(Instance), Instance = Instance})
end

function module.GetFrameSource(Name: string)
    if not module.Frames[Name] then
        warn(`[ENT Framework Client] Couldn't find Frame "{Name}"`)
    end

    return module.Frames[Name].Source
end

function module.WithFrame(Name: string, Callback: (Info: {Source: Vide.Source<boolean>}) -> ())
    if module.Frames[Name] then
        task.spawn(Callback, {Source = module.Frames[Name].Source})
    else
        module.OnFrameCreated(Name, Callback)
    end
end

function module.ExtractComponents(Instance: Instance)
    local GeneralComponents = Instance:GetAttribute("Components")
    if GeneralComponents == nil then
        return {}
    end

    local FoundComponents = {}
    for Component in string.gmatch(GeneralComponents, "[^,]+") do
        if not module.GeneralComponents[Component] then
            continue
        end
        table.insert(FoundComponents, Component)
    end

    return FoundComponents
end

function module.SetupInstance(Instance: Instance)
    local GeneralComponents = module.ExtractComponents(Instance)
    for _, Component in GeneralComponents do
        module.GeneralComponents[Component](Instance)
    end

    for Name, Value in Instance:GetAttributes() do
        if module.SpecificComponents[Name] then
            if table.find(InherentBasicButtons, Name) then
                module.GeneralComponents.BasicButton(Instance)
            end
            module.SpecificComponents[Name](Instance, Value)
        end
    end

    if module.InstanceCallbacks[Instance.ClassName] then
        module.InstanceCallbacks[Instance.ClassName]()
    end
end

function module.BeginSetup()
    PlayerGui.DescendantAdded:Connect(function(Descendant)
        Vide.root(function()
            module.SetupInstance(Descendant)
        end)
    end)

    for _, Instance in PlayerGui:GetDescendants() do
        Vide.root(function()
            module.SetupInstance(Instance)
        end)
    end

    game.DescendantRemoving:Connect(function(Descendant)
        for _, Interactions in module.ExistingInteractions do
            if Interactions[Descendant] then
                Interactions[Descendant] = nil
            end
        end

        if module.HasBasicButton[Descendant] then
            module.HasBasicButton[Descendant] = nil
        end
    end)

    RunService.Heartbeat:Connect(function(DeltaTime)
        for _, Info in module.Spinning do
            Info.Instance.Rotation += DeltaTime * Info.Speed * 90
        end
    end)

    local StatEffect = require(script.StatEffect)

    Network.StatEffect.On(function(Data: {Stat: string, Amount: number})
        local Image = StatEffectImages[Data.Stat]
        if not Image then
            error(`[ENT Framework Client] Couldn't find stat "{Data.Stat}"`)
        end

        StatEffect(Image.Image, Image.AbsolutePosition + (Image.AbsoluteSize / 2), Data.Amount)
    end)
end

return module