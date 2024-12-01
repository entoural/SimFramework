local module = {}

function module.ApplyCorner(AppliedInstance: Instance, Size: UDim?): UICorner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Size or UDim.new(0.2, 0)
    Corner.Parent = AppliedInstance

    return Corner
end

function module.ApplyStroke(AppliedInstance: Instance, Thickness: number?, Color: Color3?, StrokeMode: Enum.ApplyStrokeMode?): UIStroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Color3.new(0, 0, 0)
    Stroke.Thickness = Thickness or 2
    Stroke.ApplyStrokeMode = StrokeMode or Enum.ApplyStrokeMode.Contextual
    Stroke.Parent = AppliedInstance
end

return module