local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local remotes = RS.Remotes
local trans = remotes.TransitionClient
local storeChar = remotes.StoreSelection
local selection = remotes.CharSelectionClient
local modelName = "Redd"

storeChar.OnServerEvent:Connect(function(plr, name)
	modelName = name
end)

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char) --wrap this in a charAdded event bc of roblox and its dumb new model tech
		local hum = char:WaitForChild("Humanoid")
		
		hum.Died:Connect(function()
			print(plr.Name .. " died!")
			trans:FireClient(plr)
			task.wait(2.25)
			selection:FireClient(plr, modelName)
		end)
	end)
end)