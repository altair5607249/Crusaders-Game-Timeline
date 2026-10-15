local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local hitPart = RS.hitPart

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		local torso = char:WaitForChild("Torso")
		
		if torso then
			print("Hit area being loaded!")
			
			local clone = hitPart:Clone()
			clone.Parent = char
			
			clone.CFrame = torso.CFrame * CFrame.new(Vector3.new(0, 0, -1.15))
			
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = torso
			weld.Part1 = clone
			weld.Parent = clone
		end
	end)
end)