--basis provided by 70rnk

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:FindFirstChild("Humanoid")
local PS = player:WaitForChild("PlayerScripts")
local PM = require(PS:WaitForChild("PlayerModule"))
local controls = PM:GetControls()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local RS = game:GetService("ReplicatedStorage")
local remotes = RS:WaitForChild("Remotes")
local trans = remotes:WaitForChild("TransitionServer")
local load = remotes:WaitForChild("LoadingClient")
local controller = remotes:WaitForChild("ControlsServer")
local humChange = remotes:WaitForChild("HumChange")

local CamPart = RS:FindFirstChild("camPart"):Clone()

task.wait(3)

CamPart.Parent = workspace
CamPart.Position = workspace:FindFirstChild("introPart").Position
Camera.CameraSubject = CamPart
Camera.CameraType = Enum.CameraType.Scriptable

local moveFactor = 0.0005
local previousMouseX, previousMouseY = nil, nil
local MAX_POSITION = 0.5
local originalPosition = CamPart.Position
local UI = RS:FindFirstChild("MenuUI"):Clone()
UI.Parent = workspace

local targetPosition = originalPosition
local moving = false

--button scripts
local PlayButton = UI:FindFirstChild("PlayPart").SurfaceGui.TextButton
local CreditsButton = UI:FindFirstChild("CreditsPart").SurfaceGui.TextButton
local db = true
local db2 = true

load.OnClientEvent:Connect(function()
	db = false
	db2 = false
end)

--start/play
PlayButton.Activated:Connect(function()
	if not db then
		db = true
		db2 = true
		trans:FireServer()
		task.wait(2.25)
		controller:FireServer(true)
		humChange.OnClientEvent:Connect(function(humanoid)
			hum = humanoid
		end)
		task.wait()
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = hum
		UI:Destroy()
		script:Destroy()
	end
end)

--character selection
local PG = player:WaitForChild("PlayerGui")
local gui = PG:WaitForChild("Credits")

CreditsButton.Activated:Connect(function()
	if not db2 then
		db = true
		db2 = true
		trans:FireServer()
		task.wait(2.25)
		gui.Enabled = true
		db = false
		db2 = false
	end
end)

--main menu
RunService.RenderStepped:Connect(function()
	local mouse = player:GetMouse()
	
	local screenX = Camera.ViewportSize.X
	local screenY = Camera.ViewportSize.Y
	
	local leftoverScreenX = screenX - mouse.X
	local leftoverScreenY = screenY - mouse.Y
	
	local DistanceFromOriginX = (screenX/2) - leftoverScreenX
	local DistanceFromOriginY = leftoverScreenY - (screenY/2)
	
	local clampedX = math.clamp(DistanceFromOriginX * moveFactor, -MAX_POSITION, MAX_POSITION)
	local clampedY = math.clamp(DistanceFromOriginY * moveFactor, -MAX_POSITION, MAX_POSITION)
	
	if previousMouseX and previousMouseY then
		local mouseMoved = (DistanceFromOriginX ~= previousMouseX) or (DistanceFromOriginY ~= previousMouseY)
		if mouseMoved then
			moving = true
			targetPosition = originalPosition + Vector3.new(clampedX, clampedY, 0)
		else
			moving = false
		end
	end

	if moving then
		CamPart.CFrame = CamPart.CFrame:Lerp(CFrame.new(targetPosition), .1)
	else
		CamPart.CFrame = CamPart.CFrame:Lerp(CFrame.new(targetPosition), .2)
	end
	
	local offsetUIX = (screenX/4) * 0.009
	local offsetUIY = (screenY/5) * 0.009
	
	Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(CamPart.Position), .2)
	local finalTargetPosition = CamPart.Position + Vector3.new(-offsetUIX, -offsetUIY, -10)
	if UI.PrimaryPart then
		UI:SetAttribute("CFrame", UI.PrimaryPart.CFrame:Lerp(CFrame.new(finalTargetPosition) * CFrame.Angles(0, math.rad(23), 0), .1))
	end
	
	previousMouseX = DistanceFromOriginX
	previousMouseY = DistanceFromOriginY
end)