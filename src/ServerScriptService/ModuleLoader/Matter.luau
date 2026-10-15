--my alternative to a character-attributes list, because it is way too insecure

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local CMS = {} --short for Character Management System

local Crusaders = {} --module-level config table for global utility, mostly for untainted player model access

Players.PlayerAdded:Connect(function(player)
	Crusaders[player] = { --table initialization for player
		Core_Initialized = false
	}
end)

Players.PlayerRemoving:Connect(function(player)
	Crusaders[player] = nil --table deletion for player
end)

RS.Remotes.ClientReadiness.OnServerEvent:Connect(function(player, ready: boolean)
	if Crusaders[player].Core_Initialized then return end
	Crusaders[player].Core_Initialized = true
	CMS.Life(player, "Redd") --initial start-up callback; allow default Crusader to be mutable by preference in a future update
end)

function CMS.Life(player: Player, crusader: string)
	if not Crusaders[player] then return end
	
	local template = SS.Characters:FindFirstChild(crusader)
	if template then
		local model = template:Clone()
		model.Name = player.Name
		
		if player.Character then --in the rare case Life is somehow cycled through without Death
			player.Character:Destroy()
		end
		
		player.Character = model
		CMS:SetAttribute(player, "PreviousModel", model)
		player.Character.Parent = workspace
		CMS:SetAttribute(player, "Crusader", crusader)
		
		RS.Remotes.ReturnAttribute:FireClient(player, crusader)
		print("Signal sent")
		
		local hum = player.Character:WaitForChild("Humanoid")
		hum.Died:Connect(function() 
			CMS.Death(player, crusader) 
		end)
	else
		warn("Colored Crusader not found!")
	end
end

function CMS.Death(player: Player, crusader: string) --add more features in the future
	print(player.Name .. " died!")
	RS.Remotes.ReturnAttribute:FireClient(player, nil)
	RS.Remotes.Transition:FireClient(player)
	task.wait(2.25)
	CMS.Life(player, crusader)
end

function CMS:GetAttribute(player: Player, attribute: string)
	if attribute then
		local value = Crusaders[player][attribute]
		--[[if value == nil then 
			warn("Attribute not found")
		end]]
		return value
	end
end

function CMS:GetAttributes(player: Player)
	return Crusaders[player]
end

function CMS:SetAttribute(player: Player, attribute: string, modifier: any)
	Crusaders[player][attribute] = modifier
end

return CMS