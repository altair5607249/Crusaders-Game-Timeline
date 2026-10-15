local GM3 = {}

function GM3:Trigger(player: Player)
	print("weapon gm3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return GM3