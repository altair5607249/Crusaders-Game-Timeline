local BM2 = {}

function BM2:Trigger(player: Player)
	print("weapon bm2")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return BM2