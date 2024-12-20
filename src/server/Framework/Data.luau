local ServerStorage = game:GetService("ServerStorage")

local ServerPackages = ServerStorage:WaitForChild("ServerPackages")
local ProfileService = require(ServerPackages.ProfileService)

export type Data = {
    Mana: number,
    Rebirths: number,
    Aura: number,
    Logins: number,
    DailyStreak: number,
    DailyStreakLastAwarded: number,
    OwnedGamepasses: {},
    DevProductPurchaseLogs: {}
}

export type Profile = {
    Data: Data,
    AddUserId: (self: Profile, number) -> nil,
    ListenToRelease: (self: Profile, () -> nil) -> RBXScriptConnection,
    Reconcile: () -> nil,
    ListenToHopReady: (self: Profile, () -> nil) -> RBXScriptConnection
}

local Data: {DefaultProfile: Data} = {}

Data.DefaultProfile = {
    Logins = 0,
    Mana = 0,
    Aura = 0,
    Rebirths = 0,
    DailyStreak = 1,
    DailyStreakLastAwarded = math.huge,
    OwnedGamepasses = {},
    DevProductPurchaseLogs = {}
}

Data.ProfileStore = ProfileService.GetProfileStore("DevDataStore1", Data.DefaultProfile)

function Data:RetrieveProfile(Player: Player, ReleaseCallback: () -> nil): (Profile?, RBXScriptConnection?)
    local Id = Player.UserId
    local Profile: Profile = Data.ProfileStore:LoadProfileAsync("SimFrameworkDev01_"..Id)

    if Profile then
        Profile:AddUserId(Id)
        Profile:Reconcile()
        local Listener = Profile:ListenToRelease(function()
            if ReleaseCallback then
                ReleaseCallback()
            end

            Player:Kick()
        end)

        return Profile, Listener
    else
        Player:Kick(`Failed to load your data! Try again later`)
        return nil
    end
end

return Data