local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local slashes = RS.AttackVFX.Slashes

local function healthCurve(health: number, maxHealth: number, stat: number) --cubic curve
	local b = (stat^(1/3))/maxHealth
	return -(b*(health-maxHealth))^3 + stat
end

local GM2 = {}

function GM2:Trigger(player: Player)
	print("gm2")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")
	
	local dmg = 8
	local duration = 2*(timing.GetValue("Gleen", "Bare", 3, 2) - timing.GetValue("Gleen", "Bare", 1, 2))
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration*0.5,
		atkrad = 30,
		atktype = "light",
		bypassParry = true,
		dmg = 0,
		getTargets = true,
		ID = 2,
		precedent = true,
		style = "Bare"
	}
	
	--copy and pastable move sfx code
	local sfx = script.AuxSound:Clone()
	sfx.Parent = root
	sfx:Play()
	sfx.Ended:Connect(function()
		sfx:Destroy()
	end)
	
	local targets: {Instance} = damager:Damage(player, attackData)
	local targetRoots = {}
	
	for i, targetHum in ipairs(targets) do
		local targetRoot: Part = targetHum.Parent:WaitForChild("HumanoidRootPart")
		table.insert(targetRoots, targetRoot)
	end
	
	table.sort(targetRoots, function(a, b)
		local directionA = (root.Position - a.Position).Magnitude
		local directionB = (root.Position - b.Position).Magnitude
		return directionA < directionB
	end)
	
	if not targetRoots[1] then --necessary tagging for continuation-based moves
		print("Discontinue")
		char:AddTag("Discontinue") 
		task.delay(0.1, function()
			char:RemoveTag("Discontinue")
		end)
		return 
	else
		print("Continue")
		char:AddTag("Continue")
		task.delay(0.1, function()
			char:RemoveTag("Continue")
		end) 
	end
	
	attackData = {
		atkdur = duration*0.5,
		atkrad = 10,
		atktype = "heavy",
		bdmg = dmg,
		bypassParry = true,
		dmg = healthCurve(health, maxHealth, dmg),
		DOT = 0.3,
		ID = 2,
		style = "Bare"
	}
	
	damager:Damage(player, attackData)
	char:AddTag("Running")
	char:AddTag("Resistance")
	
	local clone = slashes:Clone()
	clone.Position = root.Position
	clone.Parent = workspace
	
	--copy and pastable move sfx code
	local sfx = script.Sound:Clone()
	sfx.Parent = root
	sfx:Play()
	task.delay(attackData.atkdur, function()
		sfx:Destroy()
	end)
	
	local elapsed = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		elapsed += dt
		if elapsed >= attackData.atkdur or not targetRoots then
			loop:Disconnect()
			char:RemoveTag("Running")
			char:RemoveTag("Resistance")
			clone:Destroy()
		end
		
		local direction = -(root.Position - targetRoots[1].Position).Unit
		
		local magnitude = spacing.GetValue("Gleen", 2) * 2
		local newPosition = root.Position + (direction * magnitude * dt)
		local target = newPosition + direction
		
		root.CFrame = CFrame.lookAt(newPosition, target) --gotta use lookAt for the rotation to matter and prevent gliding
		clone.Position = newPosition
	end)
end

return GM2