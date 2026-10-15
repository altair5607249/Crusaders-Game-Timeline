local RS = game:GetService("ReplicatedStorage")
local RNS = game:GetService("RunService")
local Players = game:GetService("Players")

local hitPart = RS.hitPart

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		local root = char:WaitForChild("HumanoidRootPart")
		
		if hum and root then
			local clone = hitPart:Clone()
			clone.Parent = char
			
			local pancake = CFrame.new(root.Position, root.Position + root.CFrame.LookVector * Vector3.new(1, 0, 1))
			clone.CFrame = pancake * CFrame.new(0, 0, -2)
			
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = clone
			weld.Parent = clone
		end
	end)
end)