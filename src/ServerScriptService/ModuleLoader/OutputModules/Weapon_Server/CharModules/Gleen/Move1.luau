local GM1 = {}

function GM1:Trigger(player: Player)
	print("weapon gm1")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return GM1