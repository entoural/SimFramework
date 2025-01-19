local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages.Signal)
local Janitor = require(Packages.Janitor)
local Vide = require(Packages.Vide)
local Source = Vide.source

local PlayerClass = {}
PlayerClass.__index = PlayerClass

export type Player = {
    Player: Player?,
    Name: string?,
    CharacterJanitor: Janitor.Janitor,
    CharacterAdded: RBXScriptSignal,
    Character: Vide.source<Model>,
    Passes: {string: {Owned: boolean, Gifted: boolean}},
    HasPass: (self: Player, PassName: string) -> boolean,
    UpdatePass: (self: Player, Data: {Name: string, Owned: boolean, Gifted: boolean}) -> (),
    UpdateState: (self: Player, Index: string, Value: any) -> (),
    GetState: <T>(self: Player, Index: string, DontYield: boolean?) -> Source.Source<T>,
    GetStateValue: <T>(self: Player, Index: string, DontYield: boolean?) -> T,
    Destroy: (self: Player) -> ()
}

function PlayerClass.new(Player: string, DeathSignal: {Fire: ({}, {}) -> any}): Player
    local self = setmetatable({}, PlayerClass)

    local PlayerInstance = if typeof(Player) == "string" then Players:FindFirstChild(Player) else Player

    if PlayerInstance then
        self.Player = PlayerInstance
        self.Name = PlayerInstance.Name
    end
    self.Passes = {}
    self._Janitor = Janitor.new()
    self.CharacterJanitor = Janitor.new()

    if PlayerInstance then
        self.Character = Source(PlayerInstance.Character)

        self._Janitor:Add(PlayerInstance.CharacterAdded:Connect(function(Character)
            self.Character(Character)
            self.CharacterJanitor:Cleanup()

            if self._Janitor:Get("Died") then
                self._Janitor:Remove("Died")
            end

            local Humanoid = Character:WaitForChild("Humanoid", 20)
            if Humanoid then
                self._Janitor:Add(Humanoid.Died:Connect(function()
                    self.CharacterJanitor:Cleanup()
                    DeathSignal:Fire()
                end), "Disconnect", "Died")
            else
                assert(Humanoid, `[ENT Framework Client] Character for {self.Name} was not loaded with a Humanoid.`)
            end
        end), "Disconnect", "CharacterAdded")
    else
        self.Character = Source(nil)
        Vide.effect(function()
            local Character = self.Character()
            self.CharacterJanitor:Cleanup()

            if self._Janitor:Get("Died") then
                self._Janitor:Remove("Died")
            end

            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid then
                self._Janitor:Add(Humanoid.Died:Connect(function()
                    self.CharacterJanitor:Cleanup()
                    DeathSignal:Fire()
                end), "Disconnect", "Died")
            else
                assert(Humanoid, `[ENT Framework Client] Character for {self.Name} was not loaded with a Humanoid.`)
            end
        end)
    end

    return self
end

function PlayerClass:GetHumanoid(): Humanoid?
    local Character: Model? = self.Character()
    local Humanoid

    if Character and Character:IsA("Model") then
        Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    end

    return Humanoid
end

function PlayerClass:UpdatePass(Data: {Name: string, Owned: boolean, Gifted: boolean, PurchasedAt: DateTime?})
    local CurrentData = self.Passes[Data.Name]
    if not CurrentData then
        self.Passes[Data.Name] = {Owned = Data.Owned, Gifted = Data.Gifted, PurchasedAt = DateTime}
    else
        CurrentData.Owned = Data.Owned
        CurrentData.Gifted = Data.Gifted
    end
end

function PlayerClass:HasPass(PassName: string)
    return if not self.Passes[PassName] then false else self.Passes[PassName].Owned
end

function PlayerClass:UpdateState(Index: string, Value: any)
    local State = self[Index]
    if State then
        State(Value.Value)
        return State
    else
        local NewState = Source(Value.Value)
        self[Index] = NewState

        return NewState
    end
end


function PlayerClass:GetState(Index: string, DontYield: boolean, CreateIfNotExists: boolean?)
    if self[Index] then
        return self[Index]
    elseif not DontYield then
        while not self[Index] do
            task.wait()
        end

        return self[Index]
    elseif CreateIfNotExists then
        local State = Source(nil)
        self[Index] = State

        return State
    end
end

function PlayerClass:GetStateValue(...): any
    local State = self:GetState(...)
    return if State then State() else nil
end

return PlayerClass