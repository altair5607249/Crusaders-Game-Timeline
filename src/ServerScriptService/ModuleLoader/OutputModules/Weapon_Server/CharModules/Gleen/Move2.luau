local GM2 = {}

function GM2:Trigger(player: Player)
	print("weapon gm2")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return GM2