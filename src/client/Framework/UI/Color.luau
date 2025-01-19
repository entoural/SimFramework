local module = {}

export type GradientAppliable = Frame | TextLabel | TextButton | ImageLabel | ImageButton | ViewportFrame

function module.DarkenColor(Input: Color3 | {Color3}, ...: Color3?): Color3...
    local Colors = if typeof(Input) == "Color3" then {Input, ...} else Input
    local Darkened = {}

    for i, Color in Colors do
        local H, S, V = Color:ToHSV()
        Darkened[i] = Color3.fromHSV(H, S, V * 0.9)
    end

    return table.unpack(Darkened)
end

function module.RotationToOffset(Rotation: number, Offset: Vector2): Vector2
    local Radians = math.rad(Rotation)

    local RotatedX = Offset.X * math.cos(Radians) - Offset.Y * math.sin(Radians)
    local RotatedY = Offset.X * math.sin(Radians) + Offset.Y * math.cos(Radians)

    return Vector2.new(RotatedX, RotatedY)

end

function module.ColorsToGradient(...: Color3): ColorSequence
    local Colors: {Color3} = {...}
    if #Colors == 1 then
        local H, S, V = Colors[1]:ToHSV()
        table.insert(Colors, Color3.fromHSV(H, S, V * 0.7))
    end

    local Total = #Colors
    local Keypoints = {}
    for i, Color in Colors do
        print((i - 1) / (Total - 1))
        table.insert(Keypoints, ColorSequenceKeypoint.new((i - 1) / (Total - 1), Color))
    end

    return ColorSequence.new(Keypoints)
end

function module.ColorToShineColors(Color: Color3): {Color3}
    local H, S, V = Color:ToHSV()
    S = math.clamp(S * 0.75, 0, 1)
    V = math.clamp(S * 1.2, 0, 1)

    local ShineColor = Color3.fromHSV(H, S, V)
    return {Color, ShineColor, Color}
end

function module.ColorToShineSequence(Colors: {Color3}): ColorSequence
    local Keypoints = {
        ColorSequenceKeypoint.new(0, Colors[1]),
        ColorSequenceKeypoint.new(0.2, Colors[1]),
        ColorSequenceKeypoint.new(0.4, Colors[2]),
        ColorSequenceKeypoint.new(0.6, Colors[2]),
        ColorSequenceKeypoint.new(0.8, Colors[3]),
        ColorSequenceKeypoint.new(1, Colors[3])
    }

    return ColorSequence.new(Keypoints)
end

function module.ApplyGradient(AppliedInstance: GradientAppliable, Colors: {Color3} | ColorSequence, Rotation: number?, IsEnabled: boolean?): UIGradient
    local Gradient = Instance.new("UIGradient")
    local Sequence = if typeof(Colors) == "ColorSequence" then Colors else module.ColorsToGradient(table.unpack(Colors))

    Gradient.Color = Sequence
    Gradient.Rotation = Rotation or 0
    Gradient.Enabled = IsEnabled or true
    Gradient.Parent = AppliedInstance

    return Gradient
end

return module