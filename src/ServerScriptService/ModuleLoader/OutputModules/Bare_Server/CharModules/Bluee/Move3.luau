local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local spacing = require(RS.UniversalModules.Space)
local timing = require(RS.UniversalModules.Time)

local damager = require(SSS.ModuleLoader.Managers.DamageManager)

local duration = timing.GetValue("Bluee", "Bare", 3, 3) - timing.GetValue("Bluee", "Bare", 1, 3)

local BM3 = {}

function BM3:Trigger(player: Player)
	print("bm3")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
	local dmg = 2
	
	local attackData = {
		atkdur = duration,
		atkrad = 8,
		atktype = "heavy",
		bdmg = -dmg,
		dmg = dmg,
		ID = 3,
		origin = root,
		DOT = 0.1,
		style = "Bare"
	}

	damager:Damage(player, attackData)
	char:AddTag("Running")
	char:AddTag("Resistance")
	
	local elapsed = 0
	local loop
	loop = RNS.PreSimulation:Connect(function(dt)
		elapsed += dt
		if elapsed >= attackData.atkdur then
			loop:Disconnect()
			char:RemoveTag("Running")
			char:RemoveTag("Resistance")
		end

		local direction = hum.MoveDirection --steering relies on WASD input unfortunately
		if direction.Magnitude < 0.1 then
			direction = root.CFrame.LookVector.Unit --this ABSOLUTELY needs to be normalized
		else
			direction = direction.Unit
		end

		local magnitude = spacing.GetValue("Bluee", 2) * 1.5
		local newPosition = root.Position + (direction * magnitude * dt)
		local target = newPosition + direction

		root.CFrame = CFrame.lookAt(newPosition, target) --gotta use lookAt for the rotation to matter and prevent gliding
	end)
end

return BM3
