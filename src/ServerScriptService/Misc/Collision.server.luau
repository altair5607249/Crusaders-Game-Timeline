local Players = game:GetService("Players")

local function setCollision(character: Model)
	for i, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CollisionGroup = "Player"
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		setCollision(char)
	end)
end)