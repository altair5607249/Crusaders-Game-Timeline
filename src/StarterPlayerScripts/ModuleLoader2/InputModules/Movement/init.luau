local player = game:GetService("Players").LocalPlayer

local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

local IAS = require(RS.UniversalModules.Energy)

local TS = game:GetService("TweenService")
local currentCam = workspace.CurrentCamera
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local fovUp = TS:Create(currentCam, tweenInfo, {FieldOfView = 80})
local fovDown = TS:Create(currentCam, tweenInfo, {FieldOfView = 70})

local animations = script:WaitForChild("Animations")
local animsTable = animations:GetChildren()
local animDispatch = {}

local char, root, baseSpd, runSpd, hum, animator = nil, nil, nil, nil, nil, nil
local dashing, frontDash, dashCD = nil, nil, nil

local function onCharacterChanged()
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	baseSpd = char:GetAttribute("bspd")
	runSpd = char:GetAttribute("sspd")
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")
	
	dashing, frontDash, dashCD = false, false, 8

	for i, anim in pairs(animsTable) do
		local animTrack = animator:LoadAnimation(anim)
		animDispatch[anim] = animTrack
	end
end

onCharacterChanged() --initial call

player:GetPropertyChangedSignal("Character"):Connect(function()
	table.clear(animDispatch)
	onCharacterChanged() --callback in case of respawn and/or character swap
end)

local movement = {}

function movement.Dash(dashDur: number, direction: Vector3, anim: Animation, specialCase: boolean)
	if not dashing or specialCase then
		if not dashing then dashing = true end
		
		if direction == root.CFrame.LookVector then frontDash = true
		else char:SetAttribute("Immortal", true) end --iframes granted to back and side dashes
		
		animDispatch[anim]:Play()
		
		local x, d = 0, 95 --x should probably start at 0, but modify incase diff starting point desired
		local b = math.sqrt(d)/dashDur
			
		local loop = nil
		loop = RNS.RenderStepped:Connect(function(dt)
			if frontDash == true then direction = root.CFrame.LookVector end
			
			local magnitude = -(b*x)^2 + d --so proud of this equation's evolution
			root.AssemblyLinearVelocity = direction * magnitude
			
			x += dt
			if x >= dashDur then
				loop:Disconnect()
				if frontDash == true then frontDash = false
				else char:SetAttribute("Immortal", false) end
			end
		end)
	task.delay(dashCD, function()
		if hum == nil or hum.Health <= 0 then return end
		dashing = false
	end)
	end
end

function movement.Sprint(bool: boolean)
	if bool then
		fovUp:Play()
		hum.WalkSpeed = runSpd
	else
		hum.WalkSpeed = baseSpd
		fovDown:Play()
	end
end

function movement.Parry() --this is gonna be fun to program!
	print("Parry") --remember that this should reduce player's cooldowns and stun the other player if landed!
end

local movementSpecs = { --it's so peak... so clean..!
	{name = "DashForward", callback = function() movement.Dash(0.7, root.CFrame.LookVector, animations.DashForward, false) end},
	{name = "DashBackward", callback = function() movement.Dash(0.3, -root.CFrame.LookVector, animations.DashBackward, false) end},
	{name = "DashRight", callback = function() movement.Dash(0.3, root.CFrame.RightVector, animations.DashRight, false) end},
	{name = "DashLeft", callback = function() movement.Dash(0.3, -root.CFrame.RightVector, animations.DashLeft, false) end},
	{name = "Parry", callback = function() movement.Parry() end},
	{name = "Sprint", callback = function(bool: boolean) movement.Sprint(bool) end}
}

function movement.IAS()
	local context = RS.InputContexts.MovementContext

	IAS.ActReg(context, movementSpecs)
end

return movement