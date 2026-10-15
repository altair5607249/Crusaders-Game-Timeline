local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

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
	
	local dmg = 10
	local duration = timing.GetValue("Gleen", "Bare", 3, 2) - timing.GetValue("Gleen", "Bare", 1, 2)
	
	local maxHealth = hum.MaxHealth
	local currentHealth = hum.Health
	local health = maxHealth - currentHealth
	
	local attackData = {
		atkdur = duration/2,
		atkrad = 30,
		atktype = "light",
		bdmg = 0,
		dmg = 0,
		getTargets = true,
		ID = 2,
		style = "Bare"
	}
	
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
	
	if not targetRoots[1] then return end
	
	attackData = {
		atkdur = duration/2,
		atkrad = 10,
		atktype = "heavy",
		bdmg = dmg,
		dmg = healthCurve(health, maxHealth, dmg),
		DOT = 0.5,
		ID = 2
	}
	
	damager:Damage(player, attackData)
	char:AddTag("Running")
	char:AddTag("Resistance")
	
	local elapsed = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		elapsed += dt
		if elapsed >= attackData.atkdur or not targetRoots then
			loop:Disconnect()
			char:RemoveTag("Running")
			char:RemoveTag("Resistance")
		end
		
		local direction = -(root.Position - targetRoots[1].Position).Unit
		
		local magnitude = spacing.GetValue("Gleen", 2) * 1.5
		local newPosition = root.Position + (direction * magnitude * dt)
		local target = newPosition + direction
		
		root.CFrame = CFrame.lookAt(newPosition, target) --gotta use lookAt for the rotation to matter and prevent gliding
	end)
end

return GM2