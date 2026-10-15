local RNS = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local char = player.Character or player.CharacterAdded:Wait()
local head = char:WaitForChild("Head")
local root = char:WaitForChild("HumanoidRootPart")

local previousOffset = CFrame.identity

RNS:BindToRenderStep("HeadTiltCamera", Enum.RenderPriority.Last.Value, function()
	-- undo exactly what was done last frame, restoring the "clean" camera
	camera.CFrame = camera.CFrame * previousOffset:Inverse()

	local relativeTilt = root.CFrame:ToObjectSpace(head.CFrame) --don't blindly follow the head's cframe; keep it grounded in the root part's cframe

	local look = relativeTilt.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude < 1e-4 then
		flatLook = Vector3.new(0, 0, -1)
	end
	flatLook = flatLook.Unit

	local yawOnly = CFrame.lookAt(Vector3.new(), flatLook)
	local swing = yawOnly:Inverse() * relativeTilt.Rotation

	local tiltStrength = 0.05
	local dampedSwing = CFrame.identity:Lerp(swing, tiltStrength)

	camera.CFrame = camera.CFrame * dampedSwing
	previousOffset = dampedSwing -- remember it so next frame can cleanly undo it
end)