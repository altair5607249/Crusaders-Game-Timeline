local BM1 = {}

function BM1:Trigger(player: Player)
	print("weapon bm1")

	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

end

return BM1