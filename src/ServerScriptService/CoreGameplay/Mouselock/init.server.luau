local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local mouselock = script.SLHandler:Clone()
		
		mouselock.Parent = char
		mouselock.Enabled = true
	end)
end)