local YM4 = {}

function YM4:Trigger(player: Player)
	print("weapon ym4")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return YM4