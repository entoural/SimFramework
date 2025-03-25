local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalName = LocalPlayer.Name
local PlayerLeft = require(script.Parent.Network).PlayerLeft
local PlayerManager = require(script.Parent.PlayerManager)

local Headshots = {}
Headshots.Cached = {}

local function GetHeadshot(Player: Player): string?
    return pcall(function()
        return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
end

local function GetHeadshotMultipleAttempts(Player: Player, Attempts: number?)
    for _ = 1, Attempts or 3 do
        print("Attempt")
        local Success, Result = GetHeadshot(Player)
        print(Result)
        if Success then
            return Result
        else
            warn(`[ENT Framework] Error when retrieving player headshot: {Result}`)
        end
    end
end

function Headshots:GetHeadshot(Player: PlayerManager.Player, DontYield: boolean?, MaxAttempts: number?): string?
    local Name = Player.Player.Name
    if self.Cached[Name] then
        return self.Cached[Name]
    elseif not DontYield then
        return GetHeadshotMultipleAttempts(Player.Player, MaxAttempts or 3)
    end
end

PlayerManager.PlayerAdded:Connect(function(Player: PlayerManager.Player)
    local Headshot = GetHeadshotMultipleAttempts(Player.Player, 3)
    if Headshot then
        Headshots.Cached[Player.Name] = Headshot
    end
end)

PlayerLeft.On(function(Player: string)
    if Headshots.Cached[Player] then
        Headshots.Cached[Player] = nil
    end
end)

print(Headshots.Cached)
if not Headshots.Cached[LocalName] then
    Headshots.Cached[LocalName] = GetHeadshotMultipleAttempts(LocalPlayer, 3)
end

return Headshots