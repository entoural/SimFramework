local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Janitor = require(Packages.Janitor)

export type Data = {
    Rebirths: number,
    Cash: number,
    Boost: number,
    Rocket: string,
    RocketLevel: number,
    Logins: number,
    Floors: number,
    DailyStreak: number,
    DailyStreakLastAwarded: number,
    OwnedGamepasses: {[string]: {Owned: boolean, Gifted: boolean, PurchasedAt: DateTime?}},
    DevProductPurchaseLogs: {},
    TutorialCompleted: boolean
}

export type Profile = {
    Data: Data,
    AddUserId: (self: Profile, number) -> nil,
    ListenToRelease: (self: Profile, () -> nil) -> RBXScriptConnection,
    Reconcile: () -> nil,
    ListenToHopReady: (self: Profile, () -> nil) -> RBXScriptConnection
}

export type PlayerObject = {
    Player: Player,
    Name: string,
    Destructor: () -> (),
    DoubleLaunchReward: boolean?,
    InLaunch: Vide.Source<boolean>,
    Played: Vide.Source<boolean>,
    Rebirths: Vide.Source<number>,
    BuildingModel: Vide.Source<Model?>,
    Building: Vide.Source<Building>,
    Rocket: Vide.Source<string?>,
    RocketLevel: Vide.Source<number>,
    RecordScore: Vide.Source<number>,
    Floors: Vide.Source<number>,
    Cash: Vide.Source<number>,
    Boost: Vide.Source<number>,
    Replicating: boolean,
    Id: number,
    _Janitor: Janitor.Janitor,
    Profile: Profile,
    Data: Data,
    Leaderstats: Folder,
    DeathSignal: {Fire: ({}, {}) -> any},
    Character: Vide.source<Model>,
    CharacterJanitor: Janitor.Janitor,
    GetHumanoid: (self: PlayerObject) -> Humanoid?,
    HasPass: (self: PlayerObject, PassName: string) -> boolean?,
    AddState: <T>(self: PlayerObject, Name: string, DefaultValue: T) -> ((value: T?) -> T?),
    IncrementState: (self: PlayerObject, StateBane: string, Amount: number) -> nil,
    LinkLeaderstat: <T>(self: PlayerObject, StateName: string, Convert: (T) -> any, InstanceType: string) -> nil
}

export type Building = {
    Model: Model,
    LoadedRocket: string?,
    AssignedPlayer: Vide.Source<PlayerObject?>,
    Floors: Vide.Source<number>,
    Destructor: () -> (),
    Destroy: () -> (),
    DestroyingConnection: RBXScriptConnection?,
    Assign: (self: Building, Player: PlayerObject) -> nil,
    UpdateFloors: (self: Building, NewAmount: number) -> nil,
    LoadRocket: (self: Building, Rocket: string) -> nil
}

return {}