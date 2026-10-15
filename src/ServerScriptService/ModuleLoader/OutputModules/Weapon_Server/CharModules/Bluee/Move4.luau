local BM4 = {}

function BM4:Trigger(player: Player)
	print("weapon bm4")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return BM4