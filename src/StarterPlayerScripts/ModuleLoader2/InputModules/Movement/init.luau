local player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")

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

local crusader, char, root: Part?, baseSpd, runSpd, hum: Humanoid?, animator
local techRegistry, frontDash

local sprintConnection: RBXScriptConnection? = nil --moved to module scope so it persists across Sprint() calls
local activeDashLoop: RBXScriptConnection? = nil --prevents overlapping dash loops from fighting over velocity

local movement = {}

local function onCharacterChanged()
	crusader = player:GetAttribute("Crusader")
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	baseSpd = spacing.GetValue(crusader, 1)
	runSpd = spacing.GetValue(crusader, 2)
	hum = char:WaitForChild("Humanoid")
	animator = hum:WaitForChild("Animator")

	techRegistry = {
		FrontDash = 0,
		AuxDash = 0,
		Parry = 0
	}

	frontDash = false

	for i, anim in pairs(animsTable) do
		local animTrack = animator:LoadAnimation(anim)
		animDispatch[anim] = animTrack
	end
end

if player.Character then onCharacterChanged() end --covers the case where Character already exists before this script runs
player.CharacterAdded:Connect(function()
	onCharacterChanged() --callback in case of respawn and/or character swap
end)

local techSpecs = {
	FrontDash = 1,
	AuxDash = 2,
	Parry = 3
}

function movement.Dash(dashDur: number, direction: Vector3)
	local stamina: number = hum:GetAttribute("Stamina")
	if stamina <= 0 then return end --no stamina, no dice
	if char:HasTag("ActiveInput") then return end
	if char:HasTag("TechsDisabled") or char:GetAttribute("Stunned") then return end
	
	local anim: Animation?, name: string?
	
	if direction == root.CFrame.LookVector then --front dash
		if stamina < 5 then return end
		anim = script.Animations.DashForward
		name = "FrontDash"
	else --auxiliary dashes
		if stamina < 2.5 then return end
		name = "AuxDash"
		
		--normalizes the direction for proper application of the dot product in the next few lines
		if direction.Magnitude <= 0.1 then 
			direction = -root.CFrame.LookVector.Unit
		else
			direction = direction.Unit
		end
		
		local frontProduct = direction:Dot(root.CFrame.LookVector)
		local backProduct = direction:Dot(-root.CFrame.LookVector)
		local rightProduct = direction:Dot(root.CFrame.RightVector)
		local leftProduct = direction:Dot(-root.CFrame.RightVector)
		
		anim = script.Animations.DashBackward
		
		local bestProduct = backProduct --starts with the backwards dash by default
		
		if frontProduct > bestProduct then --allows forward dashing with the auxiliary dash for extra distance
			anim = script.Animations.DashForward 
			bestProduct = frontProduct
		end
		
		if rightProduct > bestProduct then 
			anim = script.Animations.DashRight 
			bestProduct = rightProduct
		end
		
		if leftProduct > bestProduct then 
			anim = script.Animations.DashLeft 
			bestProduct = leftProduct
		end
	end
	
	local constraint = timing.GetValue(crusader, "Tech", 2, techSpecs[name])
	if timing.CheckConstraint(techRegistry[name], constraint) then return end
	
	char:AddTag("ActiveInput")

	RS.Remotes.MovementTrigger:FireServer("dashSpecs", name)
	techRegistry[name] = os.clock()

	if direction == root.CFrame.LookVector then frontDash = true end

	animDispatch[anim]:Play()

	local x, d = 0, 95 --x should probably start at 0, but modify incase diff starting point desired
	local b = math.sqrt(d)/dashDur

	if activeDashLoop then activeDashLoop:Disconnect() end --cancel any in-flight dash before starting a new one

	activeDashLoop = RNS.RenderStepped:Connect(function(dt)
		if frontDash == true then direction = root.CFrame.LookVector end

		local magnitude = -(b*x)^2 + d --so proud of this equation's evolution
		root.AssemblyLinearVelocity = direction * magnitude

		x += dt
		if x >= dashDur then
			activeDashLoop:Disconnect()
			activeDashLoop = nil
			if frontDash == true then frontDash = false end
			char:RemoveTag("ActiveInput")
		end
	end)
end

function movement.Sprint(sprinting: boolean)
	if char:HasTag("TechsDisabled") or char:GetAttribute("Stunned") then return end
	
	RS.Remotes.MovementTrigger:FireServer("runSpecs", "Sprint", sprinting)

	if sprinting and hum:GetAttribute("Stamina") > 0 then
		fovUp:Play()
		hum.WalkSpeed = runSpd

		if sprintConnection then sprintConnection:Disconnect() end --clear any stale connection first
		sprintConnection = hum:GetAttributeChangedSignal("Stamina"):Connect(function()
			if hum:GetAttribute("Stamina") <= 0 then movement.Sprint(false) end
		end)
	else
		hum.WalkSpeed = baseSpd
		fovDown:Play()

		if sprintConnection then
			sprintConnection:Disconnect()
			sprintConnection = nil
		end
	end
end

function movement.Parry(anim: Animation) 
	if char:HasTag("ActiveInput") then return end
	if char:HasTag("TechsDisabled") or char:GetAttribute("Stunned") then return end
	
	local name = "Parry"
	local constraint = timing.GetValue(crusader, "Tech", 2, techSpecs[name])
	local stamina: number = hum:GetAttribute("Stamina")

	if timing.CheckConstraint(techRegistry[name], constraint) or char:GetAttribute("Stunned") then return end
	if stamina < 15 then return end
	
	char:AddTag("ActiveInput")
	
	RS.Remotes.MovementTrigger:FireServer("parrySpecs", "Parry")
	techRegistry[name] = os.clock()
	
	animDispatch[anim]:Play()
	
	local duration: number = timing.GetValue(crusader, "Tech", 3, 3)
	
	task.delay(duration, function()
		char:RemoveTag("ActiveInput")
	end)
end

local movementSpecs = { --it's so peak... so clean..!
	{name = "FrontDash", callback = function() movement.Dash(timing.GetValue(crusader, "Tech", 3, 1), root.CFrame.LookVector) end},
	{name = "AuxDash", callback = function() movement.Dash(timing.GetValue(crusader, "Tech", 3, 2), hum.MoveDirection) end},
	{name = "Parry", callback = function() movement.Parry(animations.Parry) end},
	{name = "Sprint", callback = function(sprinting: boolean) movement.Sprint(sprinting) end}
}

function movement.IAS()
	local context = RS.InputContexts.MovementContext

	IAS.ActReg(context, movementSpecs)
end

return movement