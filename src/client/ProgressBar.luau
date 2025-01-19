local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Framework = require(script.Parent.Framework)

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.Spr)

local PlayerObjects = Framework.PlayerManager.Players
local Platform = workspace:WaitForChild("SpawnBase"):WaitForChild("Platform")
local End = workspace:WaitForChild("WinPart")
local MaxZ = Platform.Position.Z + Platform.Size.Z / 2
local MinZ = End.Position.Z - End.Size.Z / 2
local TotalDistance = MaxZ - MinZ
local Bar = Framework.UI.GuiObjects.PlayerProgressBar

local PlayerFrames = {}

local function UpdateFrame(Player: Player, Frame: ImageLabel)
    local Character = Player.Character
    if Character then
        local Z = Character:GetPivot().Position.Z
        local Clamped = math.clamp(Z, MinZ, MaxZ)
        local T = math.clamp(Clamped / MinZ, 0, 1)
        Spr.target(Frame, 1, 1, {Position = UDim2.fromScale(T, 0.5)})
    else
        Frame:Destroy()
        PlayerFrames[Player] = nil
    end
end

return function()
    RunService.Heartbeat:Connect(function()
        for _, Object in PlayerObjects do
            local Player = Object.Player

            if Object:GetStateValue("InRound", true) then
                if PlayerFrames[Player] then
                    UpdateFrame(Player, PlayerFrames[Player])
                else
                    local Frame: ImageLabel = Bar.Template:Clone()
                    Frame.AnchorPoint = Vector2.new(0, 0.5)
                    Frame.Visible = true
                    PlayerFrames[Player] = Frame
                    pcall(function()
                        local Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
                        Frame.Image = Image
                    end)

                    UpdateFrame(Player, Frame)
                    Frame.Parent = Bar
                end
            elseif PlayerFrames[Player] then
                PlayerFrames[Player]:Destroy()
                PlayerFrames[Player] = nil
            end
        end
    end)
end