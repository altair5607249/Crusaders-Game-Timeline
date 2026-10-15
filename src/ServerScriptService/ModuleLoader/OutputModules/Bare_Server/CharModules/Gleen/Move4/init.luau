local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)
local movement = require(SSS.ModuleLoader.Managers.MovementManager)

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return -(b*(health-maxHealth))^3 + stat
end

local GM4 = {}

function GM4:Trigger(player: Player)
	print("gm4")

	if player:HasTag("HitFinished") then player:RemoveTag("HitFinished") end

	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local dmg = 20
	local duration = timing.GetValue("Gleen", "Bare", 3, 4) - timing.GetValue("Gleen", "Bare", 1, 4)
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration,
		atkrad = 8,
		atktype = "heavy",
		bdmg = dmg,
		dmg = healthCurve(health, maxHealth, dmg),
		ID = 4,
		oneHit = true,
		style = "Bare"
	}

	damager:Damage(player, attackData)

	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)

	local att0 = Instance.new("Attachment")
	local att1 = Instance.new("Attachment")
	att0.Parent = root
	att1.Parent = root
	att1.Position = Vector3.new(0, 0, 2.5)

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Texture = "rbxassetid://5699911427"

	--customizations
	trail.Brightness = 1
	trail.Color = ColorSequence.new(Color3.new(0, 1, 0))
	trail.FaceCamera = true
	trail.Lifetime = duration
	trail.LightInfluence = 0
	trail.LightEmission = 0.5
	trail.Transparency = NumberSequence.new(0.4)

	trail.Parent = workspace

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {char}
	
	char:AddTag("Running") --sets up adding tolerance
	char:AddTag("Resistance")

	local elapsed = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		elapsed += dt

		if elapsed >= attackData.atkdur or char:HasTag("HitFinished") or char:HasTag("Parried") then
			loop:Disconnect()
			
			char:RemoveTag("Running")
			char:RemoveTag("Resistance")
			
			trail:Destroy()
			att0:Destroy()
			att1:Destroy()
			
			local runSpeed = spacing.GetValue("Gleen", 2)
			movement.ChangeTolerance(player, runSpeed) --sets it back to normal (forgetting to do this will permanently increase tolerance)
		end
		
		local direction = hum.MoveDirection --steering relies on WASD input unfortunately
		
		if direction.Magnitude < 0.1 then
			direction = root.CFrame.LookVector.Unit --normalizes the vector
		else
			direction = direction.Unit
		end
		
		local magnitude: number = spacing.GetValue("Gleen", 2) * 2 --speed of the ram
		local step = direction * magnitude * dt
		
		movement.ChangeTolerance(player, magnitude) --stops player from clashing with anticheat

		--checks the path before committing to it with raycasting, instead of phasing/teleporting
		local result = workspace:Raycast(root.Position, step, raycastParams)
		local newPosition: Vector3?
		
		if result then
			newPosition = result.Position - (direction * 0.1) --stop a little bit in front of the detected wall
		else
			newPosition = root.Position + step
		end
		
		local target = newPosition + direction

		root.CFrame = CFrame.lookAt(newPosition, target) --gotta use lookAt for the rotation to matter and prevent gliding
	end)
end
return GM4