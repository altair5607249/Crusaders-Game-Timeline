--my alternative to a character-attributes list, because it is way too insecure
local CP = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")

local function preloadMapAssets(mapModel: Model)
	local assetsToLoad = {}
	for _, descendant in ipairs(mapModel:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("ParticleEmitter") or descendant:IsA("Sound") or descendant:IsA("Texture") then
			table.insert(assetsToLoad, descendant)
		end
	end
	CP:PreloadAsync(assetsToLoad)
end

local activeSpawns = {}

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
		player.Character:MoveTo(activeSpawns[math.random(1, #activeSpawns)].Position)
		
		local hum = player.Character:WaitForChild("Humanoid")
		hum.Died:Connect(function() 
			CMS.Death(player, crusader) 
		end)
	else
		warn("Colored Crusader not found!")
	end
end

function CMS.Death(player: Player, crusader: string) --add more features in the future
	RS.Remotes.Transition:FireClient(player)
	task.wait(2.25)
	CMS.Life(player, crusader)
end

function CMS.ManageSpawns(spawns: Folder, enabled: boolean)
	if enabled then
		for i, location: SpawnLocation in ipairs(spawns:GetChildren()) do
			table.insert(activeSpawns, location)
		end
	else
		for i, location: SpawnLocation in ipairs(spawns:GetChildren()) do
			local index = table.find(activeSpawns, location)
			if index then table.remove(activeSpawns, index) end
		end
	end
end

return CMS