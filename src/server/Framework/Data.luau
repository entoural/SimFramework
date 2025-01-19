local ServerStorage = game:GetService("ServerStorage")

local ServerPackages = ServerStorage:WaitForChild("ServerPackages")
local ProfileService = require(ServerPackages.ProfileService)
local Types = require(script.Parent.Types)

export type Data = Types.Data
export type Profile = Types.Profile

local Data: {DefaultProfile: Data} = {}

Data.DefaultProfile = {
    Logins = 0,
    Wins = 0,
    Cash = 0,
    DailyStreak = 1,
    DailyStreakLastAwarded = math.huge,
    OwnedGamepasses = {},
    DevProductPurchaseLogs = {},
    Inventory = {Equipped = "Default", Owned = {Default = true}},
    TutorialCompleted = false
}

Data.ProfileStore = ProfileService.GetProfileStore("DevDataStore1", Data.DefaultProfile)

function Data:RetrieveProfile(Player: Player, ReleaseCallback: () -> nil): (Profile?, RBXScriptConnection?)
    local Id = Player.UserId
    local Profile: Profile = Data.ProfileStore:LoadProfileAsync("EatBlocksDev02_"..Id)

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