local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local DataModule = require(script.Parent.Data)
local Leaderstats = require(script.Leaderstats)

local Root = Vide.root
local Create = Vide.create

export type PlayerObject = {
    Player: Player,
    Name: string,
    Replicating: boolean,
    Id: number,
    _Janitor: Janitor.Janitor,
    Profile: DataModule.Profile,
    Data: DataModule.Data,
    Leaderstats: Folder,
    DeathSignal: {Fire: ({}, {}) -> any},
    Character: (Model?) -> Model?,
    GetHumanoid: (self: PlayerObject) -> Humanoid?,
    AddState: <T>(self: PlayerObject, Name: string, DefaultValue: T) -> ((value: T?) -> T?),
    LinkLeaderstat: <T>(self: PlayerObject, StateName: string, Convert: (T) -> any, InstanceType: string) -> nil
}

local PlayerClass = {}
PlayerClass.__index = PlayerClass

function PlayerClass.new(Player: Player, DefaultStates: {[string]: any}, LeaderstatLinks: Leaderstats.LeaderstatLinks, DeathSignal: {Fire: ({}, {}) -> any}, ReleaseCallback: () -> nil): PlayerObject
    local self = setmetatable({}, PlayerClass)
    self._Janitor = Janitor.new()

    self.Player = Player
    self.Name = Player.Name
    self.Id = Player.UserId
    self.Replicating = false
    self.DeathSignal = DeathSignal

    local Profile, Listener = DataModule:RetrieveProfile(Player, ReleaseCallback)
    assert(Profile, `[ENT Framework] Failed to retrieve data for player {Player.Name}.`)

    self.Profile = Profile
    self.Data = self.Profile.Data
    self.ReleaseListener = self._Janitor:Add(Listener, "Disconnect", "Release")

    self.Character = Vide.source(Player.Character)
    self.CharacterJanitor = Janitor.new()

    for Name, DefaultValue in DefaultStates do
        self:AddState(Name, DefaultValue)
    end

    self.Leaderstats = Leaderstats(LeaderstatLinks, self)
    self.Leaderstats.Parent = Player

    self._Janitor:Add(Player.CharacterAdded:Connect(function(Character)
        self.Character(Character)
        self.CharacterJanitor:Cleanup()

        if self._Janitor:Get("Died") then
            self._Janitor:Remove("Died")
        end

        local Humanoid = self:GetHumanoid()
        if self:GetHumanoid() then
            self._Janitor:Add(Humanoid.Died:Connect(function()
                self.CharacterJanitor:Cleanup()
                DeathSignal:Fire()
            end), "Disconnect", "Died")
        else
            assert(Profile, `[ENT Framework] Character for {self.Name} was not loaded with a Humanoid.`)
        end
    end), "Disconnect", "CharacterAdded")

    return self
end

function PlayerClass:AddState<T>(Name: string, DefaultValue: T)
    if typeof(DefaultValue) == "function" then
        DefaultValue = DefaultValue(self)
    end

    local State = Vide.source(DefaultValue)
    self[Name] = State

    if self.Data[Name] then
        Vide.effect(function()
            self.Data[Name] = State()
        end)
    end

    return State
end

function PlayerClass:LinkLeaderstat(StateName: string, Convert: (any) -> any, InstanceType: string)
    if not self[StateName] or self.Leaderstats:FindFirstChild(StateName) then
        return
    end

    local State = self[StateName]

    Root(function()
        Create(InstanceType) {
            Name = StateName,
            Parent = self.Leaderstats,
            Value = function()
                if Convert then
                    return Convert(State())
                else
                    return State()
                end
            end
        }
    end)
end

function PlayerClass:GetHumanoid(): Humanoid?
    local Character: Model? = self.Character()
    local Humanoid

    if Character and Character:IsA("Model") then
        Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    end

    return Humanoid
end

function PlayerClass:Destroy()
    self.Profile:Release()
end

return PlayerClass