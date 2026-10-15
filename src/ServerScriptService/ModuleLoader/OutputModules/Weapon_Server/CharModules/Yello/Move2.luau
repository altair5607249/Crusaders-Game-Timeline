local YM2 = {}

function YM2:Trigger(player: Player)
	print("weapon ym2")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return YM2