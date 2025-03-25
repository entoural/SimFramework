local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Source = Vide.source
local Janitor = require(Packages.Janitor)
local Framework = require(script.Parent.Framework)
local PlayerManager = Framework.PlayerManager

local WinPart: BasePart = workspace.WinPart
local Barrier: BasePart = workspace.Barrier
local TilePositions = workspace.TilePositions
local LiveTiles = workspace.LiveTiles
local SpawnPlatform: BasePart = workspace.SpawnBase.Platform
local SpawnPosition = SpawnPlatform.Position
local SpawnSize = SpawnPlatform.Size
local SpawnY = SpawnPosition.Y + SpawnPlatform.Size.Y / 2
local MinSpawnX, MaxSpawnX = SpawnPosition.X - SpawnSize.X * 0.75 / 2, SpawnPosition.X + SpawnSize.X * 0.75 / 2
local MinSpawnZ, MaxSpawnZ = SpawnPosition.Z - SpawnSize.Z * 0.75 / 2, SpawnPosition.Z + SpawnSize.Z * 0.75 / 2
local ReferenceTiles: {BasePart} = workspace.ReferenceTiles:GetChildren()

local TileSize = 10
local Colors = {
	Blue = BrickColor.Blue(),
	White = BrickColor.White(),
	Cyan = BrickColor.new("Cyan"),
	Pink = BrickColor.new("Pink"),
	Orange = BrickColor.new("Neon orange"),
	Brown = BrickColor.new("Brown"),
	Green = BrickColor.Green(),
	Purple = BrickColor.new("Royal purple"),
	Black = BrickColor.Black(),
	Red = BrickColor.Red(),
	Yellow = BrickColor.Yellow()
} :: {[string]: BrickColor}

local ColorsList = {
	"Blue", "White", "Cyan", "Pink", "Orange", "Brown", "Green", "Purple", "Black", "Red", "Yellow"
}

local RoundSystem = {}
RoundSystem.CurrentState = Source({State = "NewRound", Num1 = 10})
RoundSystem.ShowingTiles = Source({})
RoundSystem.Winners = Source({})
RoundSystem.Janitor = Janitor.new()

Framework.Replication.PlayerReplication:ReplicateGlobalState("RoundState", RoundSystem.CurrentState)
Framework.Replication.PlayerReplication:ReplicateGlobalState("ShowingTiles", RoundSystem.ShowingTiles)

local ColorsLength = #ColorsList

local function GetRandomColor(): BrickColor
	return Colors[ColorsList[math.random(1, ColorsLength)]]
end

local function GetRandomColorExcluding(Excluded: string?): string
	local NewList: {string} = {}

	for _, Color: string in ColorsList do
		if Color ~= Excluded then
			table.insert(NewList, Color)
		end
	end

	return NewList[math.random(1, #NewList)]
end

function RoundSystem.RandomizeTiles()
	for _, Part: BasePart in LiveTiles:GetChildren() do
		Part.BrickColor = GetRandomColor()
	end
end

function RoundSystem.RandomTileSet()
	local Reference = ReferenceTiles[math.random(1, #ReferenceTiles)]
	LiveTiles:ClearAllChildren()

	for _, TilePart: Part in TilePositions:GetChildren() do
		local NewTile = Reference:Clone()
		NewTile.Position = TilePart.Position
		NewTile.BrickColor = GetRandomColor()
		NewTile.CanCollide = false
		NewTile.Parent = LiveTiles

		local Collision = TilePart:Clone()
		Collision.Name = "Collision"
		Collision.CanCollide = true
		Collision.Transparency = 1
		Collision.Parent = NewTile
	end
end

function RoundSystem.GetRandomSpawnPosition(Player: Player)
	local YSize = Player.Character:GetExtentsSize().Y / 2
	local RanX, RanZ = math.random(MinSpawnX, MaxSpawnX), math.random(MinSpawnZ, MaxSpawnZ)
	return Vector3.new(RanX, SpawnY + YSize, RanZ)
end

function RoundSystem:BeginRound(PlayerWon: (Player, Placement: number) -> ())
    local Completed = false

    local RoundJanitor = self.Janitor
    local CurrentState = RoundSystem.CurrentState
    RoundSystem.RemainingPlayers = {} :: {Framework.PlayerObject}
	local RemainingPlayers = RoundSystem.RemainingPlayers
    local Won = 0

    self.Winners({})

    -- Checks if no players remain
	local function CheckForReset()
		if #RemainingPlayers == 0 then
			RoundJanitor:Cleanup()
		end
	end

    -- Sets player position
	for _, Player in Players:GetPlayers() do
		if Player.Character then
            local Object = PlayerManager:GetPlayer(Player, true)
            if not Object then continue end
			table.insert(RemainingPlayers, Object)
            Object.InRound(true)

			Player.Character.PrimaryPart.Position = RoundSystem.GetRandomSpawnPosition(Player)
		end
	end

    -- Respawns players when round ends
	RoundJanitor:Add(function()
		for _, Player in RemainingPlayers do
			Player.Player:LoadCharacter()
            Player.InRound(false)
		end

		table.clear(RemainingPlayers)
		LiveTiles:ClearAllChildren()
		RoundSystem.ShowingTiles({})
		Barrier.CanCollide = true

		Completed = true
	end)

    -- Player win
    RoundJanitor:Add(WinPart.Touched:Connect(function(Hit: BasePart)
        if not Hit.Parent then
			return
		end

		if not Hit.Parent:FindFirstChildOfClass("Humanoid") then
			return
		end

        local Player = Players:GetPlayerFromCharacter(Hit.Parent)
        local Object = PlayerManager:GetPlayer(Player, true)
        if not Object then return end

        local RemainingPlayersIndex = table.find(RemainingPlayers, Object)
        if RemainingPlayersIndex then
            table.remove(RemainingPlayers, RemainingPlayersIndex)
            Object.InRound(false)
            CheckForReset()

            local DeathJanitor = RoundJanitor:Get(Player.Name.."DeathJanitor")

			if DeathJanitor then
				RoundJanitor:Remove(Player.Name.."DeathJanitor")
			end

			Player:LoadCharacter()
			task.spawn(PlayerWon, Player, Won + 1)
			Won += 1
        end
    end))

    -- Actual round
    RoundJanitor:Add(task.spawn(function()
        RoundSystem.RandomTileSet()
		CurrentState({State = "BlankIntermission"})
		task.wait(1)
		RoundSystem.ShowingTiles(LiveTiles:GetChildren())

        for i = 5, 1, -1 do
            CurrentState({State = "StartedRound", Num1 = i})
            task.wait(1)
        end

        local LastColor: string? = nil
        Barrier.CanCollide = false
        for i = 1, 15 do
            local NotExcluded = GetRandomColorExcluding(LastColor)
			LastColor = NotExcluded
			local Color = Colors[NotExcluded]

            for k = 4, 0, -1 do
				CurrentState({State = LastColor, Num1 = k, Num2 = i})
				task.wait(1)
			end

            CurrentState({State = "BlankIntermission"})

			local ShowingTiles = {}
            for _, Tile in LiveTiles:GetChildren() do

				if Tile.BrickColor == Color then
					table.insert(ShowingTiles, Tile)
				end
            end
			RoundSystem.ShowingTiles(ShowingTiles)

            task.wait(3)

			RoundSystem.ShowingTiles(LiveTiles:GetChildren() or {})

			RoundSystem.RandomizeTiles()
        end

        task.spawn(function()
			RoundJanitor:Cleanup()
		end)
    end))

    -- Disqualifies players if they die
    for _, Object in RemainingPlayers do
        local Humanoid = Object:GetHumanoid()
        local Player = Object.Player

        local function RemovePlayer()
			table.remove(RemainingPlayers, table.find(RemainingPlayers, Object))
            Object.InRound(false)
			CheckForReset()

			local DeathJanitor = RoundJanitor:Get(Player.Name.."DeathJanitor")

			if DeathJanitor then
				RoundJanitor:Remove(Player.Name.."DeathJanitor")
			end
		end

		local DeathJanitor = Janitor.new()
		RoundJanitor:Add(DeathJanitor, "Destroy", Player.Name.."DeathJanitor")

        DeathJanitor:Add(Player.CharacterRemoving:Connect(RemovePlayer))
		RoundJanitor:Add(Player.Character.Destroying:Connect(RemovePlayer))

        if not Humanoid then continue end
        DeathJanitor:Add(Humanoid.Died:Connect(RemovePlayer))
    end

    RoundJanitor:Add(Players.PlayerRemoving:Connect(function(Player: Player)
        local Object = PlayerManager:GetPlayer(Player, true)
        if not Object then return end
        local Found = table.find(RemainingPlayers, Object)

        if Found then
            Object.InRound(false)
            table.remove(RemainingPlayers, Found)
            CheckForReset()
        end
    end))

    while not Completed do
        task.wait()
    end
end

return RoundSystem