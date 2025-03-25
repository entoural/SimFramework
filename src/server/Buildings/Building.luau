local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Rockets = ServerStorage:WaitForChild("Rockets")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Vide = require(Packages.Vide)
local Source = Vide.source
local Effect = Vide.effect
local Root = Vide.root
local Untrack = Vide.untrack
local Framework = require(script.Parent.Parent.Framework)
local Types = Framework.Types

local FloorTemplate = ReplicatedStorage:WaitForChild("Floor")
local FloorHeight = 25.04

export type Building = {
    Model: Model,
    LoadedRocket: string?,
    AssignedPlayer: Vide.Source<Types.PlayerObject?>,
    Floors: Vide.Source<number>,
    Destructor: () -> (),
    Destroy: () -> (),
    DestroyingConnection: RBXScriptConnection?,
    Assign: (self: Building, Player: Types.PlayerObject) -> nil,
    UpdateFloors: (self: Building, NewAmount: number) -> nil,
    LoadRocket: (self: Building, Rocket: string) -> nil
}

local Building = {}
Building.__index = Building

function Building.new(Model: Model, Destroy: () -> ())
    local self: Building = setmetatable({}, Building)

    self.Model = Model
    self.AssignedPlayer = Source(nil)
    self.Floors = Source(1)
    self.Destroy = Destroy

    self:LoadRocket("Beginner")

    Root(function(Destructor)
        self.Destructor = Destructor
        Effect(function()
            local Player: Types.PlayerObject? = self.AssignedPlayer()
            local PlayerRocket = if Player then Player.Rocket() else nil
            if not Player then
                if self.LoadedRocket ~= "Beginner" then
                    self:LoadRocket("Beginner")
                end
                self.Floors(1)
            else
                if PlayerRocket ~= self.LoadedRocket then
                    self:LoadRocket(PlayerRocket)
                end
                self.Floors(if not Player then 1 else Player.Floors())
            end
        end)
    end)

    Effect(function()
        local Floors = self.Floors()
        self:UpdateFloors(Floors)
    end)

    return self
end

function Building:LoadRocket(Name: string)
    local CurrentRocket = self.Model.TopOfBuilding:FindFirstChild("Rocket")
    if self.DestroyingConnection then
        self.DestroyingConnection:Disconnect()
    end
    if CurrentRocket then
        CurrentRocket:Destroy()
    end

    local NewRocket = Rockets:FindFirstChild(Name):Clone()
    NewRocket.Name = "Rocket"
    NewRocket:PivotTo(self.Model.TopOfBuilding.LaunchPosition.CFrame)
    NewRocket.Parent = self.Model.TopOfBuilding

    self.DestroyingConnection = NewRocket.Destroying:Connect(function()
        self:LoadRocket(Name)
    end)
end

function Building:Assign(Player: Types.PlayerObject)
    self.AssignedPlayer(Player)
    Player.BuildingModel(self.Model)
    Player.Building(self)
    Player.Player.RespawnLocation = self.Model.TopOfBuilding.SpawnLocation

    if self.Destructor then
        self.Destructor()
    end

    Root(function(Destructor)
        self.Destructor = Destructor
        Effect(function()
            self.Floors(Player.Floors())
        end)
    end)

    Player.Player:LoadCharacter()
end

function Building:UpdateFloors(NewAmount: number)
    NewAmount = math.round(NewAmount)
    local Floors = self.Model.Floors
    local ExistingFloors = Floors:GetChildren()
    local Difference = NewAmount - #ExistingFloors
    table.sort(ExistingFloors, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)

    local Total = #ExistingFloors
    if Total < NewAmount then
        local Origin = self.Model:GetPivot()
        local TopCF = Origin + Vector3.new(0, Total * FloorHeight, 0)
        for i = 1, NewAmount - Total do
            local NewCF = TopCF + Vector3.new(0, (i - 1) * FloorHeight + FloorHeight / 2, 0)
            local NewFloor = FloorTemplate:Clone()
            NewFloor:PivotTo(NewCF)
            NewFloor.Name = i
            NewFloor.Parent = Floors
        end
    elseif Total > NewAmount then
        for i = NewAmount + 1, Total, 1 do
            ExistingFloors[i]:Destroy()
        end
    end

    local TopFloor = Floors:FindFirstChild(NewAmount)

    --TODO: Reposition other shit on top of the top floor

    local Player = self.AssignedPlayer()
    local Character = if Player then Player.Character() else nil
    if Player and Character then
        local Pivot = Character:GetPivot()
        Character:PivotTo(Pivot + Vector3.new(0, FloorHeight * Difference, 0))
    end

    local function AdjustChildren(Instance: Instance)
        for _, Child in Instance:GetChildren() do
            if not Child:IsA("Model") and not Child:IsA("BasePart") then
                AdjustChildren(Child)

                continue
            end
            local Pivot = Child:GetPivot()
            Child:PivotTo(Pivot + Vector3.new(0, FloorHeight * Difference, 0))
        end
    end

    AdjustChildren(self.Model.TopOfBuilding)
end

return Building