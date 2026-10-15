local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local focus = script.CameraHandler:Clone()
		
		focus.Parent = char
		focus.Enabled = true
	end)
end)