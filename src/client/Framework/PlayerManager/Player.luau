local PlayerClass = {}
PlayerClass.__index = PlayerClass

export type Player = {
    Passes: {string: {Owned: boolean, Gifted: boolean}},
    HasPass: (self: Player, PassName: string) -> boolean,
    UpdatePass: (self: Player, Data: {Name: string, Owned: boolean, Gifted: boolean}) -> (),
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

return PlayerClass