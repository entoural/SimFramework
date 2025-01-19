local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Janitor = require(Packages.Janitor)

export type Data = {
    Wins: number,
    Cash: number,
    Logins: number,
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
    InRound: Vide.Source<boolean>,
    Played: Vide.Source<boolean>,
    Wins: Vide.Source<number>,
    Cash: Vide.Source<number>,
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
    LinkLeaderstat: <T>(self: PlayerObject, StateName: string, Convert: (T) -> any, InstanceType: string) -> nil
}


return {}