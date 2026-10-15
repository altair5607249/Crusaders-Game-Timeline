local BM3 = {}

function BM3:Trigger(player: Player)
	print("weapon bm3")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return BM3