local GM4 = {}

function GM4:Trigger(player: Player)
	print("weapon gm4")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return GM4