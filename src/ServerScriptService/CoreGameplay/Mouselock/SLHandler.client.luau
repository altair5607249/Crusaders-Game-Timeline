--credit to LightningLion58 for the core logic on scripting the shiftlock itself
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

local player = Players.LocalPlayer
local plrGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local inputAction = RS.AuxInputContexts.MouseStateContext.MouseLock
local inputBinding = inputAction.InputBinding
local active = false
local prevState = false

local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local head = char:WaitForChild("Head")

local expectedAutoRotate = nil --guards against deferred echoes

local function enableShiftLock()
	active = true
	expectedAutoRotate = false
	hum.AutoRotate = false
	hum.CameraOffset = Vector3.new(1.75, 0, 0)
	--camera.CFrame = head.CFrame * CFrame.new(1.75, 0, 0)
	local offset = head.CFrame * CFrame.new(1.75, 5, 10)
	RNS:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, function()
		if char:GetAttribute("Stunned") and not char:HasTag("Dashing") then return end --players should KEEP mouselock state during a dash
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		local _, y = camera.CFrame.Rotation:ToEulerAnglesYXZ()
		root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
		
	end)
end

local function disableShiftLock()
	active = false
	expectedAutoRotate = true
	hum.AutoRotate = true
	hum.CameraOffset = Vector3.new(0, 0, 0)
	RNS:UnbindFromRenderStep("ShiftLock")
	UIS.MouseBehavior = Enum.MouseBehavior.Default
end

local function toggle()
	if not active and hum.AutoRotate == true then
		prevState = true
		enableShiftLock()
	elseif active then
		prevState = false
		disableShiftLock()
	end
end

local keyConn = inputAction.Pressed:Connect(toggle)

hum:GetPropertyChangedSignal("AutoRotate"):Connect(function()
	if hum.AutoRotate == expectedAutoRotate then
		expectedAutoRotate = nil
		return
	end
	if hum.AutoRotate == false and active then --independent of player intent
		disableShiftLock()
	elseif hum.AutoRotate == true and not active and prevState then --dependent on player intent
		enableShiftLock()
	end
end)

--mobile support
local gui: ScreenGui = plrGui:WaitForChild("Gameplay")
local mainframe: Frame = gui:WaitForChild("Moveset")
local button: GuiButton = mainframe:WaitForChild("Extra"):WaitForChild("Mouselock")

button.Interactable = true
button.Selectable = true
inputBinding.UIButton = button

local touchConn = button.Activated:Connect(toggle)

--cleanup
player.CharacterRemoving:Connect(function()
	keyConn:Disconnect()
	touchConn:Disconnect()
	RNS:UnbindFromRenderStep("ShiftLock")
end)