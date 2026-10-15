local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local remotes = RS.Remotes
local selection = remotes.CharSelectionServer
local humChange = remotes.HumChange

local function morph(player, name)
	print(name)
	local model = SS.Characters:FindFirstChild(name)
	if model then
		local newModel = model:Clone()
		newModel.Name = player.Name
		
		player.Character = newModel
		player.Character.Parent = workspace
		local hum = player.Character.Humanoid
		humChange:FireClient(player, hum)
	else
		warn("Character model not found!")
	end
end

selection.OnServerEvent:Connect(function(plr, charName)
	morph(plr, charName)
end)