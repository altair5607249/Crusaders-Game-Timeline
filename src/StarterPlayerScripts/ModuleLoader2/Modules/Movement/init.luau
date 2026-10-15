local debby = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local TS = game:GetService("TweenService")
local currentCam = workspace.CurrentCamera
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local fovUp = TS:Create(currentCam, tweenInfo, {FieldOfView = 80})
local fovDown = TS:Create(currentCam, tweenInfo, {FieldOfView = 70})

local animations = script:WaitForChild("Animations")
local animsTable = animations:GetChildren()
local animDispatch = {}

local char = nil
local root = nil
local baseSpd = nil
local runSpd = nil
local hum = nil
local animator = nil

local function onCharacterAdded()
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	baseSpd = char:GetAttribute("bspd")
	runSpd = char:GetAttribute("sspd")
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")

	for i, anim in pairs(animsTable) do
		local animTrack = animator:LoadAnimation(anim)
		animDispatch[anim] = animTrack
	end
end

onCharacterAdded() --initial call

player:GetPropertyChangedSignal("Character"):Connect(function()
	table.clear(animDispatch)
	onCharacterAdded() --callback in case of respawn and/or character swap
end)

local movement = {}

local dashing = false
local dashCD = 10
local dashDB = false

function movement:Dash(dashDur: number, direction: Vector3, anim: Animation)
	if not dashing then
		dashing = true
		
		animDispatch[anim]:Play()
		
		local x, d = 0, 100 --x should probably start at 0, but modify incase diff starting point desired
		local b = math.sqrt(d)/dashDur
		
		local rootXZ = direction * Vector3.new(1, 0, 1)
		local currentXZ = root.CFrame.LookVector * Vector3.new(1, 0, 1)
			
		local loop = nil
		loop = RNS.RenderStepped:Connect(function(dt)
			if rootXZ == currentXZ and not dashDB then --updates dash direction if forward dash is executed
				dashDB = true
			elseif dashDB then
				direction = root.CFrame.LookVector
			end
			
			local magnitude = -(b*x)^2 + d --so proud of the evolution of this
			root.AssemblyLinearVelocity = direction * magnitude
			
			x += dt
			if x >= dashDur then
				animDispatch[anim]:Stop()
				loop:Disconnect()
			end
		end)
	task.delay(dashCD, function()
		if hum == nil or hum.Health <= 0 then return end
		dashing = false
		dashDB = false
	end)
	end
end

local running = false

function movement:Sprint(bool: boolean)
	if bool then
		fovUp:Play()
		hum.WalkSpeed = runSpd
	else
		hum.WalkSpeed = baseSpd
		fovDown:Play()
	end
end

local IASHandler = require(script.Parent:WaitForChild("IASHandler"))

local movementSpecs = { --it's so peak... so clean..!
	{name = "DashForward", callback = function() movement:Dash(0.75, root.CFrame.LookVector, animations.DashForward) end},
	{name = "DashBackward", callback = function() movement:Dash(0.65, -root.CFrame.LookVector, animations.DashBackward) end},
	{name = "DashRight", callback = function() movement:Dash(0.5, root.CFrame.RightVector, animations.DashRight) end},
	{name = "DashLeft", callback = function() movement:Dash(0.5, -root.CFrame.RightVector, animations.DashLeft) end},
	{name = "Sprint", callback = function(bool: boolean) movement:Sprint(bool) end}
}

function movement.IAS()
	local context = RS:WaitForChild("InputContexts"):WaitForChild("MovementContext")

	IASHandler.ActReg(context, movementSpecs)
end

movement.IAS()

return movement