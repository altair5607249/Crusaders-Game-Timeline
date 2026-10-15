local RM3 = {}

function RM3:Trigger(player: Player)
	print("weapon rm3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return RM3