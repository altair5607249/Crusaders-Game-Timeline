--camera manipulation math provided by 70rnk
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PG = player:WaitForChild("PlayerGui")
local loadingManager = require(PG:WaitForChild("LoadingScreen").ModuleLoader3.Manager)

local hum = nil
local function onCharacterAdded(char: Model)
	hum = char:WaitForChild("Humanoid")
end

if player.Character then --in case the character model already exists (race condition for initial player entry)
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(function(char) --in case the character model doesn't already exist
	onCharacterAdded(char)
end)

local Camera = workspace.CurrentCamera
local CamPart = RS:FindFirstChild("camPart"):Clone()

CamPart.Parent = workspace
CamPart.Position = workspace:WaitForChild("introPart").Position
Camera.CameraSubject = CamPart
Camera.CameraType = Enum.CameraType.Scriptable

repeat task.wait() until hum ~= nil

loadingManager.StartScreen() 

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
local db, db2 = false, false

--start/play
PlayButton.Activated:Connect(function()
	if not db then
		db = true
		db2 = true
		loadingManager.Transition()
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = hum
		UI:Destroy()
		script:Destroy()
	end
end)

--credits
local credits = PG:WaitForChild("Credits")

CreditsButton.Activated:Connect(function()
	if not db2 then
		db = true
		db2 = true
		loadingManager.Transition()
		credits.Enabled = true
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