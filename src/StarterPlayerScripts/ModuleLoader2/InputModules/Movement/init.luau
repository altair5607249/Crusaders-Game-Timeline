local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

local stunHandler = require(player.PlayerScripts.ModuleLoader2.Handlers.StunHandler)

local IAS = require(player.PlayerScripts.Energy)
local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local TS = game:GetService("TweenService")
local currentCam = workspace.CurrentCamera
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local fovUp = TS:Create(currentCam, tweenInfo, {FieldOfView = 80})
local fovDown = TS:Create(currentCam, tweenInfo, {FieldOfView = 70})

local animations = script:WaitForChild("Animations")
local animsTable = animations:GetChildren()
local animDispatch = {}

local crusader, char, root, baseSpd, runSpd, hum, animator = nil, nil, nil, nil, nil, nil
local dashing, frontDash, dashCD = nil, nil, nil

local function onCharacterChanged()
	crusader = player:GetAttribute("Crusader")
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	baseSpd = spacing.GetValue(crusader, 1)
	runSpd = spacing.GetValue(crusader, 2)
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")
	
	dashing, frontDash, dashCD = false, false, 8

	for i, anim in pairs(animsTable) do
		local animTrack = animator:LoadAnimation(anim)
		animDispatch[anim] = animTrack
	end
end

player.CharacterAdded:Connect(function()
	onCharacterChanged() --callback in case of respawn and/or character swap
end)

local movement = {}

local dashRegistry = {0, 0}

local dashSpecs = {
	DashForward = 1,
	DashBackward = 2,
	DashRight = 2,
	DashLeft = 2
}

function movement.Dash(dashDur: number, direction: Vector3, anim: Animation)
	local constraint = timing.GetValue(crusader, "Tech", 2, dashSpecs[anim.Name])
	if timing.CheckConstraint(dashRegistry[dashSpecs[anim.Name]], constraint) or stunHandler:GetStunState() then return end
		
	RS.Remotes.MovementTrigger:FireServer("dashSpecs", anim.Name)
	dashRegistry[dashSpecs[anim.Name]] = os.clock()
		
	if direction == root.CFrame.LookVector then frontDash = true end
		
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
			if frontDash == true then frontDash = false end
		end
	end)
end

function movement.Sprint(sprinting: boolean)
	RS.Remotes.MovementTrigger:FireServer("runSpecs", "Sprint", sprinting)
	if sprinting then
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
	{name = "DashForward", callback = function() movement.Dash(timing.GetValue(crusader, "Tech", 3, 1), root.CFrame.LookVector, animations.DashForward) end},
	{name = "DashBackward", callback = function() movement.Dash(timing.GetValue(crusader, "Tech", 3, 2), -root.CFrame.LookVector, animations.DashBackward) end},
	{name = "DashRight", callback = function() movement.Dash(timing.GetValue(crusader, "Tech", 3, 2), root.CFrame.RightVector, animations.DashRight) end},
	{name = "DashLeft", callback = function() movement.Dash(timing.GetValue(crusader, "Tech", 3, 2), -root.CFrame.RightVector, animations.DashLeft) end},
	{name = "Parry", callback = function() movement.Parry() end},
	{name = "Sprint", callback = function(sprinting: boolean) movement.Sprint(sprinting) end}
}

function movement.IAS()
	local context = RS.InputContexts.MovementContext

	IAS.ActReg(context, movementSpecs)
end

return movement