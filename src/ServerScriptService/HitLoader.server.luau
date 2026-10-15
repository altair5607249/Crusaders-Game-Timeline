local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local hitPart = RS.hitPart

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		local root = char:WaitForChild("HumanoidRootPart")
		
		if hum and root then
			local clone = hitPart:Clone()
			clone.Parent = char
			
			clone.CFrame = root.CFrame * CFrame.new(Vector3.new(0, 0, -2))
			
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = clone
			weld.Parent = clone
		end
	end)
end)