local Players = game:GetService("Players")
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

local GM4 = {}

function GM4:Trigger(player: Player)
	print("gm4")
	
	if player:HasTag("HitFinished") then player:RemoveTag("HitFinished") end
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum: Humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")

	local dmg = 20
	local duration = timing.GetValue("Gleen", "Bare", 3, 2) - timing.GetValue("Gleen", "Bare", 1, 2)

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
	char:AddTag("Running")
	char:AddTag("Resistance")

	local elapsed = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		elapsed += dt
		if elapsed >= attackData.atkdur or char:HasTag("HitFinished") then
			loop:Disconnect()
			char:RemoveTag("Running")
			char:RemoveTag("Resistance")
			if char:HasTag("HitFinished") then char:RemoveTag("HitFinished") end
		end

		local direction = hum.MoveDirection --steering relies on WASD input unfortunately
		if direction.Magnitude < 0.1 then
			direction = root.CFrame.LookVector.Unit --this ABSOLUTELY needs to be normalized
		else
			direction = direction.Unit
		end

		local magnitude = spacing.GetValue("Gleen", 2) * 1.5
		local newPosition = root.Position + (direction * magnitude * dt)
		local target = newPosition + direction
		
		root.CFrame = CFrame.lookAt(newPosition, target) --gotta use lookAt for the rotation to matter and prevent gliding
	end)
end

return GM4