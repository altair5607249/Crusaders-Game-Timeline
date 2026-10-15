--credit to LightningLion58's forum post regarding this!

local UIS = game:GetService("UserInputService")
local RNS = game:GetService("RunService")

local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

function shiftLock(active)
	if active then
		hum.CameraOffset = Vector3.new(1.75, 0, 0)
		hum.AutoRotate = false
		
		RNS:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, function()
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			
			local _, y = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ()
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
		end)
	else
		hum.CameraOffset = Vector3.new(0, 0, 0)
		RNS:UnbindFromRenderStep("ShiftLock")
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		hum.AutoRotate = true
	end
end

shiftLock(true)