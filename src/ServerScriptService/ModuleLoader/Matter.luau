--my alternative to a character-attributes list, because it is way too insecure

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local CMS = {} --short for Character Management System

RS.Remotes.ClientReadiness.OnServerEvent:Connect(function(player, ready: boolean)
	CMS.Life(player, "Redd") --initial start-up callback; allow default Crusader to be mutable by preference in a future update
end)

function CMS.Life(player: Player, crusader: string)
	if player.Parent ~= Players then return end
	
	local template = SS.Characters:FindFirstChild(crusader)
	if template then
		local model = template:Clone()
		model.Name = player.Name
		
		if player.Character then --in the rare case Life is somehow cycled through without Death
			player.Character:Destroy()
		end
		
		player:SetAttribute("Crusader", crusader)
		player.Character = model
		player.Character.Parent = workspace
		
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
	RS.Remotes.Transition:FireClient(player)
	task.wait(2.25)
	CMS.Life(player, crusader)
end

return CMS