local YM3 = {}

function YM3:Trigger(player: Player)
	print("weapon ym3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return YM3