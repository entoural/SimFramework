local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Source = Vide.source

local PlayerClass = {}
PlayerClass.__index = PlayerClass

export type Player = {
    Passes: {string: {Owned: boolean, Gifted: boolean}},
    HasPass: (self: Player, PassName: string) -> boolean,
    UpdatePass: (self: Player, Data: {Name: string, Owned: boolean, Gifted: boolean}) -> (),
    UpdateState: (self: Player, Index: string, Value: any) -> (),
    GetState: <T>(self: Player, Index: string, DontYield: boolean?) -> Source.Source<T>,
    GetStateValue: <T>(self: Player, Index: string, DontYield: boolean?) -> T,
    Destroy: (self: Player) -> ()
}

function PlayerClass.new(Player: Player): Player
    local self = setmetatable({}, PlayerClass)

    self.Player = Player
    self.Name = Player.Name
    self.Passes = {}

    return self
end

function PlayerClass:UpdatePass(Data: {Name: string, Owned: boolean, Gifted: boolean})
    local CurrentData = self.Passes[Data.Name]
    if not CurrentData then
        self.Passes[Data.Name] = {Owned = Data.Owned, Gifted = Data.Gifted}
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
        State(Value)
    else
        self[Index] = Source(Value)
    end
end

function PlayerClass:GetStateValue(...): any
    return self:GetState(...)()
end

function PlayerClass:GetState(Index: string, DontYield: boolean)
    if self[Index] then
        return self[Index]
    elseif not DontYield then
        while not self[Index] do
            task.wait()
        end

        return self[Index]
    end
end

return PlayerClass