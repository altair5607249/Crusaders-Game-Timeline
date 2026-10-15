--for the wife
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	if player.UserId == 1686067617 then
		player.CharacterAdded:Connect(function()
			--fill with something epic when thought of
		end)
	end
end)