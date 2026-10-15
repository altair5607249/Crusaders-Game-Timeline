local YM1 = {}

function YM1:Trigger(player: Player)
	print("weapon ym1")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return YM1