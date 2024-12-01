local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utility = require(Shared.Utility)
local Library = require(Shared.Library)

local Black = Color3.new(0, 0, 0)
local White = Color3.new(1, 1, 1)

local module = {}

function module.ToHex(Color: Color3 | string): string
    local IsString = typeof(Color) == "string"
    if IsString and not Library.ColorPresets[Color] then
        warn(`[ENT Framework] Attempted to get a color preset that does not exist: "{Color}"`)
    end

    return (if IsString then Library.ColorPresets[Color] else Color):ToHex()
end

function module.Color(String: string, Color: Color3?): string
    local Hex = module.ToHex(Color or White)
    return `<font color="#{Hex}">{String}</font>`
end

function module.Stroke(String: string, Color: Color3?, Thickness: number?): string
    local Hex = module.ToHex(Color or Black)
    return `<stroke color="#{Hex}" thickness="{"3"}">{String}</stroke>`
end

return module