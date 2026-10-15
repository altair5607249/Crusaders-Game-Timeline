local RM1 = {}

function RM1:Trigger(player: Player)
	print("weapon rm1")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	
end

	return RM1