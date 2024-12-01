--\\ Private
local BLOCK = { 0, 1, 2, 3, 4, 5, 6, 7 }
local WEDGE = { 0, 1, 3, 4, 5, 7 }
local CORNER_WEDGE = { 0, 1, 4, 5, 6 }

local function getIndices(part)
    if part:IsA("WedgePart") then
        return WEDGE
    elseif part:IsA("CornerWedgePart") then
        return CORNER_WEDGE
    end
    return BLOCK
end

local function getCorners(cf, size2, indices)
    local corners = {}
    for j, i in pairs(indices) do
        corners[j] = cf
            * (size2 * Vector3.new(2 * (math.floor(i / 4) % 2) - 1, 2 * (math.floor(i / 2) % 2) - 1, 2 * (i % 2) - 1))
    end
    return corners
end

local function getModelPointCloud(model)
    local points = {}
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local indices = getIndices(part)
            local corners = getCorners(part.CFrame, part.Size / 2, indices)
            for _, wp in pairs(corners) do
                table.insert(points, wp)
            end
        end
    end
    return points
end

local function viewProjectionEdgeHits(cloud, axis, depth, tanFov2)
    local max, min = -math.huge, math.huge

    for _, lp in pairs(cloud) do
        local distance = depth - lp.Z
        local halfSpan = tanFov2 * distance

        local a = lp[axis] + halfSpan
        local b = lp[axis] - halfSpan

        max = math.max(max, a, b)
        min = math.min(min, a, b)
    end

    return max, min
end

--\\ Public
local ViewportFitter = {}

--[==[
    Returns a fixed distance that is guaranteed to encapsulate the full model
    this is useful for when you want to rotate freely around an object without expensive calculations.

    `focusPosition` can be used to set the origin of where the camera's looking
    otherwise the model's bounding box center is assumed.
]==]
function ViewportFitter.GetFitDistance(viewport: ViewportFrame, model: Model, camera: Camera, focusPosition: Vector3?)
    local cf, modelSize = model:GetBoundingBox()
    local displacement = focusPosition and (focusPosition - cf.Position).Magnitude or 0
    local radius = (modelSize.Magnitude / 2) + displacement
    local vpSize = viewport.AbsoluteSize
    return radius / (math.sin(math.atan(math.tan(math.rad(camera.FieldOfView / 2)) * math.min(1, vpSize.X / vpSize.Y))))
end

--[==[
    Convenience function that sets the given camera's CFrame to the given orientation and
    pushes it backwards by a distance that's guaranteed to encapsulate the full model.

    `focusPosition` can be used to set the origin of where the camera's looking
    otherwise the model's bounding box center is assumed.

    ```lua
    local ViewportFitter = require(path/to/ViewportFitter)
    local viewport: ViewportFrame = ...
    local model: Model = ...
    local camera = Instance.new("Camera")

    viewport.CurrentCamera = camera
    model.Parent = viewport
    camera.FieldOfView = 35

    local orientation = CFrame.fromOrientation(0, -math.pi, 0)
    camera.CFrame = ViewportFitter.GetFitCFrame(viewport, model, camera, orientation)
    ```
--]==]
function ViewportFitter.GetFitCFrame(
    viewport: ViewportFrame,
    model: Model,
    camera: Camera,
    orientation: CFrame,
    focusPosition: Vector3?
)
    focusPosition = focusPosition or model:GetBoundingBox().Position
    return CFrame.new(
        focusPosition - orientation.LookVector * ViewportFitter.GetFitDistance(viewport, model, camera, focusPosition)
    ) * orientation
end

--[==[
    Returns the optimal camera CFrame that would be needed to best fit
    the model in the viewport frame at the given orientation.
    Keep in mind this functions best when the model's point-cloud is correct
    as such models that rely heavily on meshesh, csg, etc will only return an accurate
    result as their point cloud

    ```lua
    local ViewportFitter = require(path/to/ViewportFitter)
    local viewport: ViewportFrame = ...
    local model: Model = ...
    local camera = Instance.new("Camera")

    viewport.CurrentCamera = camera
    model.Parent = viewport
    camera.FieldOfView = 35

    local orientation = CFrame.fromOrientation(0, -math.pi, 0)
    camera.CFrame = ViewportFitter.GetMinimumFitCFrame(viewport, model, camera, orientation)
    ```
--]==]
function ViewportFitter.GetMinimumFitCFrame(
    viewport: ViewportFrame,
    model: Model,
    camera: Camera,
    orientation: CFrame
): CFrame
    local rInverse = orientation.Rotation:Inverse()

    local wcloud = getModelPointCloud(model)
    local cloud = { rInverse * wcloud[1] }
    local furthest = cloud[1].Z

    for i = 2, #wcloud do
        local lp = rInverse * wcloud[i]
        furthest = math.min(furthest, lp.Z)
        cloud[i] = lp
    end

    local size = viewport.AbsoluteSize
    local aspect = size.X / size.Y

    local tanyFov2 = math.tan(math.rad(camera.FieldOfView / 2))
    local tanxFov2 = math.tan(math.atan(tanyFov2 * aspect))

    local hMax, hMin = viewProjectionEdgeHits(cloud, "X", furthest, tanxFov2)
    local vMax, vMin = viewProjectionEdgeHits(cloud, "Y", furthest, tanyFov2)

    return orientation
        * CFrame.new(
            (hMax + hMin) / 2,
            (vMax + vMin) / 2,
            furthest + math.max(((hMax - hMin) / 2) / tanxFov2, ((vMax - vMin) / 2) / tanyFov2)
        )
end

--\\ Class

return ViewportFitter
